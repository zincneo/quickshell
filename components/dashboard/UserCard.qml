import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import ".." as C
import "../../services" as Svc

Item {
    id: root
    required property var palette
    readonly property string font: "Rubik"

    // Avatar logo; click toggles between catppuccin0 and catppuccin1.
    property int logoIndex: 0

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 16

        // Circular avatar.
        Item {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillHeight: true
            Layout.preferredWidth: height

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: root.palette.surface1
            }

            Image {
                id: logoImg
                anchors.fill: parent
                source: "../../assets/logo/catppuccin" + root.logoIndex + ".png"
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: false
            }
            Rectangle {
                id: circleMask
                anchors.fill: parent
                radius: width / 2
                visible: false
                layer.enabled: true
            }
            MultiEffect {
                anchors.fill: parent
                source: logoImg
                maskEnabled: true
                maskSource: circleMask
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.logoIndex = 1 - root.logoIndex
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            spacing: 7

            InfoRow {
                palette: root.palette
                icon: "computer"
                value: Svc.SysInfo.distro
            }
            InfoRow {
                palette: root.palette
                icon: "web_asset"
                value: Svc.SysInfo.wm
            }
            InfoRow {
                palette: root.palette
                icon: "timer"
                value: Svc.SysInfo.uptimeStr
            }
        }
    }

    component InfoRow: RowLayout {
        required property var palette
        required property string icon
        required property string value
        spacing: 8

        C.MaterialIcon {
            text: parent.icon
            size: 19
            color: parent.palette.mauve
        }
        Text {
            text: ":"
            color: parent.palette.subtext0
            font.family: root.font
            font.pixelSize: 15
        }
        Text {
            Layout.fillWidth: true
            text: parent.value
            color: parent.palette.text
            font.family: root.font
            font.pixelSize: 15
            elide: Text.ElideRight
        }
    }
}
