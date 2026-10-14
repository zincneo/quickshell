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
    property bool expanded: false
    property int hoveredTab: 0
    readonly property bool hovered: hoverArea.containsMouse

    implicitWidth: 32
    implicitHeight: col.implicitHeight + 16
    radius: 16
    color: palette.surface0
    opacity: expanded ? 0 : 1
    Behavior on opacity {
        NumberAnimation { duration: 400; easing.type: Easing.InOutCubic }
    }

    readonly property string audioIcon: {
        if (Svc.Audio.muted || Svc.Audio.volume <= 0)
            return "volume_off";
        return "speaker";
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
        enabled: !root.expanded
        spacing: 10

        C.MaterialIcon {
            id: audioGlyph
            Layout.alignment: Qt.AlignHCenter
            text: root.audioIcon
            size: 20
            weight: 600
            color: Svc.Audio.muted ? root.palette.overlay0 : root.palette.text

        }

        C.MaterialIcon {
            id: networkGlyph
            Layout.alignment: Qt.AlignHCenter
            text: Svc.Network.icon
            size: 20
            color: Svc.Network.type === "disconnected" ? root.palette.overlay0 : root.palette.text
        }

        C.MaterialIcon {
            id: bluetoothGlyph
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

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.PointingHandCursor

        function updateTab(): void {
            const icons = [audioGlyph, networkGlyph, bluetoothGlyph];
            for (let i = 0; i < icons.length; ++i) {
                const point = icons[i].mapFromItem(root, mouseX, mouseY);
                if (point.y >= -5 && point.y < icons[i].height + 5) {
                    root.hoveredTab = i;
                    return;
                }
            }
        }

        onEntered: updateTab()
        onPositionChanged: updateTab()
    }
}
