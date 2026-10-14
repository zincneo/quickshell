pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Distro / window manager / uptime info.
Singleton {
    id: root

    property string distro: "Linux"
    property string wm: {
        const d = Quickshell.env("XDG_CURRENT_DESKTOP") || Quickshell.env("XDG_SESSION_DESKTOP") || "";
        return d ? d.split(":")[0] : "Wayland";
    }
    property int uptimeSeconds: 0

    readonly property string uptimeStr: {
        const s = uptimeSeconds;
        const d = Math.floor(s / 86400);
        const h = Math.floor((s % 86400) / 3600);
        const m = Math.floor((s % 3600) / 60);
        const parts = [];
        if (d > 0)
            parts.push(d + (d === 1 ? " day" : " days"));
        if (h > 0)
            parts.push(h + (h === 1 ? " hour" : " hours"));
        if (d === 0)
            parts.push(m + (m === 1 ? " minute" : " minutes"));
        return "up " + parts.join(", ");
    }

    FileView {
        path: "/etc/os-release"
        onLoaded: {
            const m = text().match(/^PRETTY_NAME="?([^"\n]+)"?/m);
            if (m)
                root.distro = m[1];
        }
    }

    Process {
        id: uptimeProc
        running: true
        command: ["cat", "/proc/uptime"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = parseFloat(text.trim().split(" ")[0]);
                if (!isNaN(v))
                    root.uptimeSeconds = Math.floor(v);
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: uptimeProc.running = true
    }
}
