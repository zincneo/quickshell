pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// System usage, polled from /proc, /sys and df.
Singleton {
    id: root

    // Fractions 0..1.
    property real cpu: 0
    property real memory: 0
    property real storage: 0
    property real gpu: NaN
    property real gpuTemp: NaN

    // Details.
    property string cpuName: ""
    property real cpuTemp: 0          // deg C
    property real memUsedGb: 0
    property real memTotalGb: 0
    property real storageUsedGb: 0
    property real storageTotalGb: 0
    property real netDown: 0          // bytes/s
    property real netUp: 0            // bytes/s
    property real netPeak: 1024       // rolling peak for the network bar

    property int _prevIdle: 0
    property int _prevTotal: 0
    property real _prevRx: 0
    property real _prevTx: 0
    property real _prevT: 0

    function fmtRate(bps: real): string {
        if (bps >= 1048576)
            return (bps / 1048576).toFixed(1) + " MB/s";
        if (bps >= 1024)
            return (bps / 1024).toFixed(0) + " KB/s";
        return Math.max(0, bps).toFixed(0) + " B/s";
    }

    FileView { id: statFile; path: "/proc/stat" }
    FileView { id: memFile; path: "/proc/meminfo" }
    FileView { id: netFile; path: "/proc/net/dev" }
    FileView {
        path: "/proc/cpuinfo"
        onLoaded: {
            const m = text().match(/model name\s*:\s*(.+)/);
            if (m)
                root.cpuName = m[1].trim();
        }
    }

    function _poll(): void {
        statFile.reload();
        memFile.reload();
        netFile.reload();

        // CPU.
        const p = statFile.text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
        if (p.length >= 4) {
            const idle = p[3] + (p[4] || 0);
            const total = p.reduce((a, b) => a + b, 0);
            const dIdle = idle - root._prevIdle;
            const dTotal = total - root._prevTotal;
            if (dTotal > 0 && root._prevTotal > 0)
                root.cpu = Math.max(0, Math.min(1, 1 - dIdle / dTotal));
            root._prevIdle = idle;
            root._prevTotal = total;
        }

        // Memory.
        const mem = memFile.text();
        const totKb = parseInt((mem.match(/MemTotal:\s+(\d+)/) || [])[1] || "0");
        const availKb = parseInt((mem.match(/MemAvailable:\s+(\d+)/) || [])[1] || "0");
        if (totKb > 0) {
            root.memTotalGb = totKb / 1048576;
            root.memUsedGb = (totKb - availKb) / 1048576;
            root.memory = Math.max(0, Math.min(1, 1 - availKb / totKb));
        }

        // Network (sum of non-loopback interfaces).
        let rx = 0, tx = 0;
        for (const line of netFile.text().split("\n")) {
            const m = line.match(/^\s*([^:]+):\s*(\d+)(?:\s+\d+){7}\s+(\d+)/);
            if (m && m[1].trim() !== "lo") {
                rx += Number(m[2]);
                tx += Number(m[3]);
            }
        }
        const now = Date.now() / 1000;
        if (root._prevT > 0) {
            const dt = now - root._prevT;
            if (dt > 0) {
                root.netDown = Math.max(0, (rx - root._prevRx) / dt);
                root.netUp = Math.max(0, (tx - root._prevTx) / dt);
            }
        }
        root._prevRx = rx;
        root._prevTx = tx;
        root._prevT = now;

        // Decaying rolling peak so the network bar stays meaningful.
        root.netPeak = Math.max(root.netPeak * 0.8, root.netDown, root.netUp, 1024);
    }

    // Read labelled CPU sensors rather than thermal_zone0, which can be an
    // unrelated ACPI sensor. Missing GPU counters remain unavailable.
    Process {
        id: sensorProc
        command: ["sh", "-c", `
            cpu=NaN
            for hw in /sys/class/hwmon/hwmon*; do
                read -r name < "$hw/name" 2>/dev/null || continue
                case "$name" in
                    coretemp|k10temp|zenpower)
                        if [ -r "$hw/temp1_input" ]; then
                            read -r cpu < "$hw/temp1_input"
                            break
                        fi ;;
                esac
            done
            if [ "$cpu" = NaN ]; then
                for zone in /sys/class/thermal/thermal_zone*; do
                    read -r type < "$zone/type" 2>/dev/null || continue
                    case "$type" in
                        x86_pkg_temp|cpu-thermal)
                            read -r cpu < "$zone/temp"
                            break ;;
                    esac
                done
            fi
            printf 'cpu %s\\n' "$cpu"
            if command -v nvidia-smi >/dev/null 2>&1; then
                nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null |
                    awk -F ', *' 'NR==1 {print "gpu", $1, $2}'
            else
                for card in /sys/class/drm/card[0-9]*; do
                    [ -d "$card/device" ] || continue
                    busy=NaN
                    temp=NaN
                    if [ -r "$card/device/gpu_busy_percent" ]; then
                        read -r busy < "$card/device/gpu_busy_percent"
                    fi
                    for hw in "$card"/device/hwmon/hwmon*; do
                        if [ -r "$hw/temp1_input" ]; then
                            read -r temp < "$hw/temp1_input"
                            break
                        fi
                    done
                    if [ "$busy" != NaN ] || [ "$temp" != NaN ]; then
                        awk -v busy="$busy" -v temp="$temp" 'BEGIN {print "gpu", busy, temp == "NaN" ? "NaN" : temp / 1000}'
                        break
                    fi
                done
            fi
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                root.gpu = NaN;
                root.gpuTemp = NaN;
                for (const line of text.trim().split("\n")) {
                    const fields = line.trim().split(/\s+/);
                    if (fields[0] === "cpu")
                        root.cpuTemp = Number(fields[1]) / 1000;
                    else if (fields[0] === "gpu") {
                        const usage = Number(fields[1]);
                        root.gpu = isNaN(usage) ? NaN : Math.max(0, Math.min(1, usage / 100));
                        root.gpuTemp = Number(fields[2]);
                    }
                }
            }
        }
    }

    Process {
        id: dfProc
        running: true
        command: ["sh", "-c", "df -PB1 / | awk 'NR==2{print $2, $3}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/).map(Number);
                if (parts.length >= 2 && parts[0] > 0) {
                    root.storageTotalGb = parts[0] / 1073741824;
                    root.storageUsedGb = parts[1] / 1073741824;
                    root.storage = Math.max(0, Math.min(1, parts[1] / parts[0]));
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root._poll();
            dfProc.running = true;
            sensorProc.running = true;
        }
    }
}
