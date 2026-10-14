pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Primary network connection via nmcli (needs networkmanager).
Singleton {
    id: root

    property string type: "disconnected"   // wifi | ethernet | disconnected
    property string name: ""
    property int strength: 0                // 0..100 (wifi)

    property bool wifiEnabled: true
    property bool wifiAvailable: false
    property bool ethernetAvailable: false
    property string ethernetState: "unavailable"   // connected | disconnected | unavailable...
    readonly property bool ethernetConnected: ethernetState === "connected"
    property var networks: []                       // {ssid, signal, secure, active, saved}
    property var savedSsids: []
    property bool scanning: false
    property bool connecting: false
    property string connectingSsid: ""
    property string error: ""
    property string passwordRequiredSsid: ""
    property bool usedPassword: false

    function refresh() {
        proc.running = true;
        statusProc.running = true;
    }

    function scan() {
        if (!wifiEnabled || scanProc.running)
            return;
        scanning = true;
        scanProc.rescan = true;
        scanProc.running = true;
    }

    function setWifiEnabled(on: bool) {
        error = "";
        wifiEnabled = on;
        radioProc.command = ["nmcli", "radio", "wifi", on ? "on" : "off"];
        radioProc.running = true;
    }

    function connectTo(ssid: string, password: string) {
        if (connecting)
            return;
        error = "";
        connecting = true;
        connectingSsid = ssid;
        usedPassword = password !== "";
        passwordRequiredSsid = "";
        const cmd = ["nmcli", "--wait", "30", "device", "wifi", "connect", ssid];
        if (password !== "")
            cmd.push("password", password);
        connectProc.command = cmd;
        connectProc.running = true;
    }

    function forget(ssid: string) {
        error = "";
        cleanupProc.command = ["nmcli", "connection", "delete", "id", ssid];
        cleanupProc.running = true;
    }

    function disconnectWifi() {
        error = "";
        disconnectProc.running = true;
    }

    function splitTerse(line: string): var {
        const out = [];
        let cur = "";
        for (let i = 0; i < line.length; i++) {
            const c = line[i];
            if (c === "\\" && i + 1 < line.length) {
                cur += line[++i];
            } else if (c === ":") {
                out.push(cur);
                cur = "";
            } else {
                cur += c;
            }
        }
        out.push(cur);
        return out;
    }

    readonly property string icon: {
        if (type === "ethernet")
            return "lan";
        if (type === "wifi") {
            if (strength >= 75)
                return "signal_wifi_4_bar";
            if (strength >= 50)
                return "network_wifi_3_bar";
            if (strength >= 25)
                return "network_wifi_2_bar";
            if (strength > 0)
                return "network_wifi_1_bar";
            return "signal_wifi_0_bar";
        }
        return "signal_wifi_off";
    }

    Process {
        id: proc
        running: true
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION device 2>/dev/null; echo '---'; nmcli -t -f ACTIVE,SIGNAL device wifi 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                const sections = text.split("---");
                const devs = (sections[0] || "").trim().split("\n");
                let found = false;
                for (const line of devs) {
                    const p = line.split(":");
                    if (p[1] === "connected" && (p[0] === "wifi" || p[0] === "ethernet")) {
                        root.type = p[0];
                        root.name = p.slice(2).join(":");
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    root.type = "disconnected";
                    root.name = "";
                    root.strength = 0;
                }
                if (root.type === "wifi") {
                    for (const line of (sections[1] || "").trim().split("\n")) {
                        const p = line.split(":");
                        if (p[0] === "yes") {
                            root.strength = parseInt(p[1]) || 0;
                            break;
                        }
                    }
                }
            }
        }
    }

    Process {
        id: statusProc
        running: true
        command: ["sh", "-c", "nmcli radio wifi; echo '---'; nmcli -t -f TYPE,STATE device; echo '---'; nmcli -t -f NAME,TYPE connection show"]
        stdout: StdioCollector {
            onStreamFinished: {
                const sec = text.split("---");
                root.wifiEnabled = (sec[0] || "").trim() === "enabled";
                let wifi = false, eth = false, ethState = "unavailable";
                for (const line of (sec[1] || "").trim().split("\n")) {
                    const p = line.split(":");
                    if (p[0] === "wifi")
                        wifi = true;
                    if (p[0] === "ethernet") {
                        eth = true;
                        if (p[1] === "connected" || ethState !== "connected")
                            ethState = p[1];
                    }
                }
                root.wifiAvailable = wifi;
                root.ethernetAvailable = eth;
                root.ethernetState = ethState;
                const saved = [];
                for (const line of (sec[2] || "").trim().split("\n")) {
                    const p = root.splitTerse(line);
                    if (p[1] === "802-11-wireless")
                        saved.push(p[0]);
                }
                root.savedSsids = saved;
            }
        }
    }

    Process {
        id: scanProc
        property bool rescan: false
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list", "--rescan", rescan ? "yes" : "no"]
        stdout: StdioCollector {
            onStreamFinished: {
                const best = {};
                for (const line of text.trim().split("\n")) {
                    if (!line)
                        continue;
                    const p = root.splitTerse(line);
                    const ssid = p[1];
                    if (!ssid)
                        continue;
                    const n = {
                        ssid: ssid,
                        signal: parseInt(p[2]) || 0,
                        secure: (p[3] || "") !== "",
                        active: p[0] === "*",
                        saved: root.savedSsids.indexOf(ssid) >= 0
                    };
                    const old = best[ssid];
                    if (!old || n.active || (!old.active && n.signal > old.signal))
                        best[ssid] = n;
                }
                const list = Object.values(best);
                list.sort((a, b) => (b.active - a.active) || (b.signal - a.signal));
                root.networks = list;
            }
        }
        onExited: {
            root.scanning = false;
            rescan = false;
        }
    }

    Process {
        id: radioProc
        onExited: {
            root.refresh();
            if (root.wifiEnabled)
                scanDelay.restart();
        }
    }

    Timer {
        id: scanDelay
        interval: 1500
        onTriggered: root.scan()
    }

    Process {
        id: connectProc
        stderr: StdioCollector {
            id: connectErr
        }
        onExited: code => {
            root.connecting = false;
            if (code !== 0) {
                const m = connectErr.text.trim();
                const needsPw = /Secrets were required|No secrets|802-11-wireless-security/.test(m);
                if (root.usedPassword || needsPw) {
                    // drop the profile NetworkManager created with a bad/missing password
                    cleanupProc.command = ["nmcli", "connection", "delete", "id", root.connectingSsid];
                    cleanupProc.running = true;
                }
                if (needsPw && !root.usedPassword)
                    root.passwordRequiredSsid = root.connectingSsid;
                else
                    root.error = root.usedPassword ? "Connection failed — check the password" : (m !== "" ? m.replace(/^Error: /, "") : "Failed to connect to " + root.connectingSsid);
            }
            root.refresh();
            root.scanning = false;
            scanProc.running = true;
        }
    }

    Process {
        id: cleanupProc
        onExited: {
            root.refresh();
            root.scanning = false;
            scanProc.running = true;
        }
    }

    Process {
        id: disconnectProc
        command: ["sh", "-c", "dev=$(nmcli -t -f DEVICE,TYPE device | awk -F: '$2==\"wifi\"{print $1; exit}'); [ -n \"$dev\" ] && nmcli device disconnect \"$dev\""]
        onExited: {
            root.refresh();
            scanProc.running = true;
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
