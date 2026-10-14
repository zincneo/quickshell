import QtQuick
import QtQuick.Layouts
import ".." as C

Rectangle {
    id: root

    required property var palette
    required property string icon
    required property string label
    required property string value1   // green (used / download)
    required property string value2   // blue  (total / upload)
    property real fraction: -1        // <0 hides the bar
    required property color accent
    readonly property string font: "Rubik"

    radius: 24
    color: palette.surface0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 8

        RowLayout {
            spacing: 9
            C.MaterialIcon {
                text: root.icon
                size: 28
                color: root.accent
            }
            Text {
                text: root.label
                color: root.accent
                font.family: root.font
                font.pixelSize: 19
                font.weight: Font.DemiBold
            }
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true
            spacing: 5
            Text {
                text: root.value1
                color: root.palette.green
                font.family: root.font
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }
            Text {
                text: "/"
                color: root.palette.subtext0
                font.family: root.font
                font.pixelSize: 14
            }
            Text {
                Layout.fillWidth: true
                text: root.value2
                color: root.palette.blue
                font.family: root.font
                font.pixelSize: 14
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 6
            radius: 3
            color: root.palette.surface2
            visible: root.fraction >= 0
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * Math.max(0, Math.min(1, root.fraction))
                radius: 3
                color: root.accent

                Behavior on width {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
