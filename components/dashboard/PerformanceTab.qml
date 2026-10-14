import QtQuick
import QtQuick.Layouts
import "." as D
import "../../services" as Svc

Item {
    id: root
    required property var palette

    RowLayout {
        anchors.centerIn: parent
        width: parent.width - 28
        spacing: 24

        D.RingCard {
            Layout.fillWidth: true
            palette: root.palette
            accent: root.palette.mauve
            mainProgress: Svc.SysUsage.gpuTemp / 100
            usageProgress: Svc.SysUsage.gpu
            mainValue: Svc.SysUsage.gpuTemp > 0 ? Svc.SysUsage.gpuTemp.toFixed(0) + "\u00b0C" : "--"
            mainLabel: "GPU temp"
            subValue: isNaN(Svc.SysUsage.gpu) ? "--" : (Svc.SysUsage.gpu * 100).toFixed(0) + "%"
            subLabel: "Usage"
        }

        D.RingCard {
            Layout.fillWidth: true
            prominent: true
            palette: root.palette
            accent: root.palette.mauve
            mainProgress: Svc.SysUsage.cpuTemp / 100
            usageProgress: Svc.SysUsage.cpu
            mainValue: Svc.SysUsage.cpuTemp > 0 ? Svc.SysUsage.cpuTemp.toFixed(0) + "\u00b0C" : "--"
            mainLabel: "CPU temp"
            subValue: (Svc.SysUsage.cpu * 100).toFixed(0) + "%"
            subLabel: "Usage"
        }

        D.RingCard {
            Layout.fillWidth: true
            palette: root.palette
            accent: root.palette.mauve
            mainProgress: Svc.SysUsage.storage
            usageProgress: Svc.SysUsage.memory
            mainValue: Svc.SysUsage.memUsedGb.toFixed(1) + "GiB"
            mainLabel: "Memory"
            subValue: Svc.SysUsage.storageUsedGb.toFixed(0) + "GiB"
            subLabel: "Storage"
        }
    }
}
