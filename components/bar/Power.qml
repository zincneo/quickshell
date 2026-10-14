import QtQuick
import ".." as C

Rectangle {
    id: root
    required property var palette
    property bool expanded: false
    readonly property bool hovered: mouse.containsMouse

    implicitWidth: 32
    implicitHeight: 32
    radius: 11
    color: !expanded && mouse.containsMouse ? palette.surface1 : "transparent"

    C.MaterialIcon {
        anchors.centerIn: parent
        visible: !root.expanded
        text: "power_settings_new"
        size: 20
        weight: 700
        color: root.palette.red
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
}
