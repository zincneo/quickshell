import QtQuick
import QtQuick.Layouts
import ".." as C
import "../../services" as Svc

Item {
    id: root
    required property var palette

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        Bar {
            palette: root.palette
            icon: "memory"
            value: Svc.SysUsage.cpu
            fill: root.palette.mauve
        }
        Bar {
            palette: root.palette
            icon: "memory_alt"
            value: Svc.SysUsage.memory
            fill: root.palette.teal
        }
        Bar {
            palette: root.palette
            icon: "hard_drive"
            value: Svc.SysUsage.storage
            fill: root.palette.peach
        }
    }

    component Bar: ColumnLayout {
        required property var palette
        required property string icon
        required property real value
        required property color fill
        spacing: 8

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            implicitWidth: 8
            radius: 4
            color: parent.palette.surface1

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.height * Math.max(0.03, Math.min(1, parent.parent.value))
                radius: 4
                color: parent.parent.fill

                Behavior on height {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        C.MaterialIcon {
            Layout.alignment: Qt.AlignHCenter
            text: parent.icon
            size: 15
            color: parent.fill
        }
    }
}
