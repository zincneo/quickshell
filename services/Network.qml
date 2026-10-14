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

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: proc.running = true
    }
}
