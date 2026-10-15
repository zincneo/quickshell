import QtQuick
import QtQuick.Layouts
import "." as D
import "../../services" as Svc

Item {
    id: root
    required property var palette
    property real ringSize: 0
    property real ringValueSize: 0
    property real centerSize: 0
    property real centerValueSize: 0
    property real ringSpacing: 24

    RowLayout {
        anchors.centerIn: parent
        width: parent.width - 28
        spacing: root.ringSpacing

        D.RingCard {
            Layout.fillWidth: true
            sizeOverride: root.ringSize
            valueFontSize: root.ringValueSize
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
            sizeOverride: root.centerSize
            valueFontSize: root.centerValueSize
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
            sizeOverride: root.ringSize
            valueFontSize: root.ringValueSize
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
