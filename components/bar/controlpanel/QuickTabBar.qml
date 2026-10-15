pragma ComponentBehavior: Bound

import QtQuick
import "../.." as C

// Icon strip that selects one of the quick panel tabs.
Rectangle {
    id: root

    required property var palette
    required property var tabs
    required property int currentIndex
    signal selected(int index)

    height: 44
    color: palette.mantle
    bottomLeftRadius: 20
    bottomRightRadius: 20

    Row {
        anchors.fill: parent

        Repeater {
            model: root.tabs

            delegate: Rectangle {
                id: tab

                required property var modelData
                required property int index

                width: root.width / root.tabs.length
                height: root.height
                color: root.currentIndex === index ? root.palette.surface1 : tabMouse.containsMouse ? root.palette.surface0 : "transparent"
                bottomLeftRadius: index === 0 ? 20 : 0
                bottomRightRadius: index === root.tabs.length - 1 ? 20 : 0

                C.MaterialIcon {
                    anchors.centerIn: parent
                    text: tab.modelData.icon
                    size: 20
                    weight: 700
                    color: tab.modelData.color
                }

                MouseArea {
                    id: tabMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.selected(tab.index)
                }
            }
        }
    }
}
