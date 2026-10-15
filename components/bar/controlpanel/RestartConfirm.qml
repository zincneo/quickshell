pragma ComponentBehavior: Bound

import QtQuick
import "../.." as C

// Restart tab: asks once more and emits confirmed() when the button is pressed.
Column {
    id: root

    required property var palette
    signal confirmed()

    spacing: 8

    C.MaterialIcon {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "restart_alt"
        size: 28
        weight: 700
        color: root.palette.peach
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Restart system?"
        font.family: "Rubik"
        font.pixelSize: 16
        font.weight: Font.Medium
        color: root.palette.text
    }

    Text {
        width: parent.width
        text: "Are you sure you want to restart?"
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.family: "Rubik"
        font.pixelSize: 12
        color: root.palette.subtext0
    }

    Item {
        width: parent.width
        height: 34

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.round(parent.width * 0.6)
            height: parent.height
            radius: 12
            color: confirmMouse.containsMouse ? Qt.lighter(root.palette.peach, 1.1) : root.palette.peach

            Row {
                anchors.centerIn: parent
                spacing: 6

                C.MaterialIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "restart_alt"
                    size: 16
                    weight: 700
                    color: root.palette.base
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Confirm"
                    font.family: "Rubik"
                    font.pixelSize: 12
                    color: root.palette.base
                }
            }

            MouseArea {
                id: confirmMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.confirmed()
            }
        }
    }
}
