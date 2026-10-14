import QtQuick
import QtQuick.Layouts
import ".." as C
import "../../services" as Svc

Item {
    id: root
    required property var palette
    readonly property string font: "Rubik"

    // Avatar logo; click toggles between catppuccin0 and catppuccin1.
    property alias logoIndex: avatar.logoIndex

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 16

        C.AvatarLogo {
            id: avatar
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 76
            Layout.preferredHeight: 76
            Layout.maximumWidth: 76
            Layout.maximumHeight: 76
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
