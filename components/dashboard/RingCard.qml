import QtQuick
import ".." as C

// Independent lower sensor and upper usage arcs, matching the reference capture.
Item {
    id: root

    required property var palette
    required property color accent
    required property real mainProgress
    required property real usageProgress
    required property string mainValue
    required property string mainLabel
    required property string subValue
    required property string subLabel
    property bool prominent: false
    readonly property real diameter: prominent ? 196 : 164
    readonly property string font: "Rubik"

    implicitWidth: diameter + 20
    implicitHeight: diameter

    Item {
        id: ring
        x: (parent.width - width - 20) / 2
        anchors.verticalCenter: parent.verticalCenter
        width: root.diameter
        height: width

        C.CircularProgress {
            anchors.fill: parent
            startAngle: 45
            sweepAngle: 180
            strokeWidth: 8
            spacing: 4
            value: isNaN(root.mainProgress) ? 0 : root.mainProgress
            fgColour: root.accent
            bgColour: root.palette.surface1
        }

        C.CircularProgress {
            anchors.fill: parent
            startAngle: 235
            sweepAngle: 125
            strokeWidth: 8
            spacing: 4
            value: isNaN(root.usageProgress) ? 0 : root.usageProgress
            fgColour: root.accent
            bgColour: root.palette.surface1
        }

        Column {
            anchors.centerIn: parent
            spacing: 5

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.mainValue
                color: root.palette.text
                font.family: root.font
                font.pixelSize: root.prominent ? 36 : 30
                font.weight: Font.Normal
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.mainLabel
                color: root.palette.subtext0
                font.family: root.font
                font.pixelSize: root.prominent ? 14 : 12
            }
        }

        Column {
            x: parent.width - width / 2 - 4
            y: parent.height / 2 + 10
            spacing: 3

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.subValue
                color: root.palette.subtext1
                font.family: root.font
                font.pixelSize: root.prominent ? 14 : 12
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.subLabel
                color: root.palette.subtext0
                font.family: root.font
                font.pixelSize: root.prominent ? 14 : 12
            }
        }
    }
}
