import QtQuick
import QtQuick.Layouts
import M3Shapes
import ".." as C

Rectangle {
    id: root

    required property var palette
    required property string icon
    required property string label
    required property string subLabel
    required property color accent
    required property real usage        // 0..1
    required property real temperature  // deg C
    readonly property string font: "Rubik"

    radius: 24
    color: palette.surface0

    C.CircularProgress {
        id: prog
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 18
        width: 56
        height: 56
        strokeWidth: 5
        value: root.usage
        fgColour: root.accent
        bgColour: root.palette.surface2

        C.MaterialIcon {
            anchors.centerIn: parent
            text: root.icon
            size: 24
            color: root.accent
        }
    }

    ColumnLayout {
        anchors.left: prog.right
        anchors.right: usageShape.left
        anchors.verticalCenter: prog.verticalCenter
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 2

        Text {
            text: root.label
            color: root.accent
            font.family: root.font
            font.pixelSize: 18
            font.weight: Font.DemiBold
        }
        Text {
            Layout.fillWidth: true
            text: root.subLabel
            color: root.palette.subtext0
            font.family: root.font
            font.pixelSize: 13
            elide: Text.ElideRight
        }
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 18
        spacing: 5
        width: parent.width * 0.5

        RowLayout {
            spacing: 5
            C.MaterialIcon {
                text: root.temperature > 90 ? "thermometer_alert" : "thermometer"
                size: 19
                filled: true
                color: root.temperature > 90 ? root.palette.red : root.accent
            }
            Text {
                text: root.temperature > 0 ? root.temperature.toFixed(0) + "\u00b0C" : "--"
                color: root.palette.text
                font.family: root.font
                font.pixelSize: 15
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 6
            radius: 3
            color: root.palette.surface2
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * Math.max(0, Math.min(1, root.temperature / 100))
                radius: 3
                color: root.accent
            }
        }
    }

    MaterialShape {
        id: usageShape
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 18
        implicitSize: 74
        color: root.palette.surface2
        shape: root.usage >= 0.8 ? MaterialShape.SoftBurst : (root.usage >= 0.4 ? MaterialShape.Sunny : MaterialShape.Cookie4Sided)

        Text {
            anchors.centerIn: parent
            text: (root.usage * 100).toFixed(0) + "%"
            color: root.accent
            font.family: root.font
            font.pixelSize: 20
            font.weight: Font.DemiBold
        }
    }
}
