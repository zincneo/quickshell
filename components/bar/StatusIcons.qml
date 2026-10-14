pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import ".." as C
import "../../services" as Svc

// Bottom status cluster (audio / network / bluetooth / battery) on a rounded
// background, like the reference.
Rectangle {
    id: root
    required property var palette

    implicitWidth: 32
    implicitHeight: col.implicitHeight + 16
    radius: 16
    color: palette.surface0

    readonly property string audioIcon: {
        if (Svc.Audio.muted || Svc.Audio.volume <= 0)
            return "volume_off";
        if (Svc.Audio.volume < 0.5)
            return "volume_down";
        return "volume_up";
    }

    readonly property var battery: UPower.displayDevice
    readonly property string batteryIcon: {
        const b = root.battery;
        if (!b)
            return "battery_unknown";
        if (b.state === UPowerDeviceState.Charging || b.state === UPowerDeviceState.FullyCharged)
            return "battery_charging_full";
        const p = b.percentage;
        if (p >= 0.9)
            return "battery_full";
        if (p >= 0.6)
            return "battery_5_bar";
        if (p >= 0.4)
            return "battery_3_bar";
        if (p >= 0.15)
            return "battery_2_bar";
        return "battery_alert";
    }

    ColumnLayout {
        id: col
        anchors.centerIn: parent
        spacing: 10

        C.MaterialIcon {
            Layout.alignment: Qt.AlignHCenter
            text: root.audioIcon
            size: 20
            color: Svc.Audio.muted ? root.palette.overlay0 : root.palette.text

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Svc.Audio.toggleMute()
                onWheel: wheel => Svc.Audio.changeVolume(wheel.angleDelta.y > 0 ? 0.05 : -0.05)
            }
        }

        C.MaterialIcon {
            Layout.alignment: Qt.AlignHCenter
            text: Svc.Network.icon
            size: 20
            color: Svc.Network.type === "disconnected" ? root.palette.overlay0 : root.palette.text
        }

        C.MaterialIcon {
            Layout.alignment: Qt.AlignHCenter
            text: Svc.Bluetooth.icon
            size: 20
            color: Svc.Bluetooth.powered ? root.palette.text : root.palette.overlay0
        }

        C.MaterialIcon {
            Layout.alignment: Qt.AlignHCenter
            visible: root.battery && root.battery.isLaptopBattery
            text: root.batteryIcon
            size: 20
            filled: true
            color: {
                const b = root.battery;
                if (b && b.state !== UPowerDeviceState.Charging && b.percentage < 0.15)
                    return root.palette.red;
                return root.palette.text;
            }
        }
    }
}
