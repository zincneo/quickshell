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
    property real sizeOverride: 0
    property real valueFontSize: 0
    readonly property real diameter: sizeOverride > 0 ? sizeOverride : (prominent ? 196 : 164)
    readonly property real valuePixelSize: valueFontSize > 0 ? valueFontSize : (prominent ? 36 : 30)
    readonly property real labelPixelSize: sizeOverride > 0 ? (prominent ? 12 : 10) : (prominent ? 14 : 12)
    readonly property real subPixelSize: sizeOverride > 0 ? (prominent ? 11 : 9) : (prominent ? 14 : 12)
    readonly property string font: "Rubik"

    implicitWidth: diameter + 20
    implicitHeight: diameter

    Item {
        id: ring
        x: (parent.width - width - 20) / 2
        y: (parent.height - height) / 2
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
                font.pixelSize: root.valuePixelSize
                font.weight: Font.Normal
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.mainLabel
                color: root.palette.subtext0
                font.family: root.font
                font.pixelSize: root.labelPixelSize
            }
        }

        Column {
            x: sizeOverride > 0 ? parent.width - 8 : parent.width - width / 2 - 4
            y: parent.height / 2 + 10
            spacing: 3

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.subValue
                color: root.palette.subtext1
                font.family: root.font
                font.pixelSize: root.subPixelSize
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.subLabel
                color: root.palette.subtext0
                font.family: root.font
                font.pixelSize: root.subPixelSize
            }
        }
    }
}
