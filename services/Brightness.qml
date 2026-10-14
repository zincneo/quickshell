pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property real brightness: 0
    property bool available: false
    property string error: ""
    property int pendingPercent: -1

    function setBrightness(value: real): void {
        brightness = Math.max(0.01, Math.min(1, value));
        pendingPercent = Math.round(brightness * 100);
        applyTimer.restart();
    }

    Timer {
        id: applyTimer
        interval: 70
        onTriggered: {
            if (writeProc.running || root.pendingPercent < 0)
                return;
            writeProc.command = ["brightnessctl", "--class=backlight", "set", root.pendingPercent + "%"];
            root.pendingPercent = -1;
            writeProc.running = true;
        }
    }

    Process {
        id: writeProc
        stderr: StdioCollector {}
        onExited: (exitCode, exitStatus) => {
            root.error = exitCode === 0 ? "" : "Could not change brightness";
            if (root.pendingPercent >= 0)
                applyTimer.restart();
            else
                readProc.running = true;
        }
    }

    Process {
        id: readProc
        command: ["brightnessctl", "--class=backlight", "--machine-readable"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("\n")[0].split(",");
                const current = Number(fields[2]);
                const maximum = Number(fields[4]);
                root.available = fields.length >= 5 && maximum > 0;
                if (root.available && !writeProc.running && root.pendingPercent < 0)
                    root.brightness = Math.max(0, Math.min(1, current / maximum));
            }
        }
        stderr: StdioCollector {}
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!writeProc.running && root.pendingPercent < 0)
                readProc.running = true;
        }
    }
}
