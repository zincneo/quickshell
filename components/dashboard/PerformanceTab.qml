import QtQuick
import QtQuick.Layouts
import "." as D
import "../../services" as Svc

// Performance tab: CPU hero card + memory / storage / network stat cards.
Item {
    id: root
    required property var palette

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        D.HeroCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 128
            palette: root.palette
            icon: "memory"
            label: "CPU"
            subLabel: Svc.SysUsage.cpuName || "Processor"
            accent: root.palette.mauve
            usage: Svc.SysUsage.cpu
            temperature: Svc.SysUsage.cpuTemp
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            D.StatCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                palette: root.palette
                icon: "memory_alt"
                label: "Memory"
                accent: root.palette.teal
                fraction: Svc.SysUsage.memory
                value1: Svc.SysUsage.memUsedGb.toFixed(1)
                value2: Svc.SysUsage.memTotalGb.toFixed(1) + " GB"
            }
            D.StatCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                palette: root.palette
                icon: "hard_drive"
                label: "Storage"
                accent: root.palette.peach
                fraction: Svc.SysUsage.storage
                value1: Svc.SysUsage.storageUsedGb.toFixed(0)
                value2: Svc.SysUsage.storageTotalGb.toFixed(0) + " GB"
            }
            D.StatCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                palette: root.palette
                icon: "lan"
                label: "Network"
                accent: root.palette.blue
                fraction: Svc.SysUsage.netPeak > 0 ? Svc.SysUsage.netDown / Svc.SysUsage.netPeak : 0
                value1: "\u2193 " + Svc.SysUsage.fmtRate(Svc.SysUsage.netDown)
                value2: "\u2191 " + Svc.SysUsage.fmtRate(Svc.SysUsage.netUp)
            }
        }
    }
}
