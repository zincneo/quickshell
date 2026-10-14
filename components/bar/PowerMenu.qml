pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ".." as C

C.Popout {
    id: root

    required property var palette
    required property real screenHeight
    required property real leftThickness
    required property real verticalThickness
    required property rect buttonZone
    property bool confirmationOpen: false
    property bool buttonHovered: false
    signal actionRequested(string selectedAction)

    edge: "left"
    expandedWidth: 152
    expandedHeight: 84
    expandedX: leftThickness
    expandedY: screenHeight - verticalThickness - expandedHeight
    cornerRadius: 24
    hoverEnabled: !confirmationOpen
    triggerActive: buttonHovered
    triggerZone: buttonZone

    readonly property var actions: [
        { icon: "restart_alt", action: "restart", color: root.palette.peach },
        { icon: "power_settings_new", action: "shutdown", color: root.palette.red }
    ]

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        Repeater {
            model: root.actions

            delegate: Rectangle {
                id: action
                required property var modelData

                Layout.preferredWidth: 60
                Layout.preferredHeight: 60
                radius: 16
                color: mouse.containsMouse ? root.palette.surface1 : root.palette.surface0

                C.MaterialIcon {
                    anchors.centerIn: parent
                    text: action.modelData.icon
                    size: 28
                    weight: 700
                    color: action.modelData.color
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.actionRequested(action.modelData.action)
                }
            }
        }
    }
}
