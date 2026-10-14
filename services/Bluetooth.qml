pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Bluetooth status via bluetoothctl (needs bluez).
Singleton {
    id: root

    property bool powered: false
    property int connectedCount: 0

    readonly property string icon: !powered ? "bluetooth_disabled" : (connectedCount > 0 ? "bluetooth_connected" : "bluetooth")

    Process {
        id: proc
        running: true
        command: ["sh", "-c", "bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo on || echo off; bluetoothctl devices Connected 2>/dev/null | grep -c Device"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                root.powered = lines[0] === "on";
                root.connectedCount = parseInt(lines[1]) || 0;
            }
        }
    }

    Timer {
        interval: 6000
        running: true
        repeat: true
        onTriggered: proc.running = true
    }
}
