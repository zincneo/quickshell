import QtQuick
import QtQuick.Layouts
import ".." as C
import "../../services" as Svc
import "../../themes" as Themes

Item {
    id: root
    required property var palette
    readonly property string font: "Rubik"

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            // Click switches the shared colour theme.
            C.AvatarLogo {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 56
                Layout.preferredHeight: 56
                Layout.maximumWidth: 56
                Layout.maximumHeight: 56
                logoIndex: Themes.ThemeManager.logoIndex
                onClicked: Themes.ThemeManager.toggle()
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Themes.ThemeManager.light ? "Light" : "Dark"
                color: root.palette.lavender
                font.family: root.font
                font.pixelSize: 12
                font.weight: Font.Bold
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            spacing: 4

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
            size: 18
            color: parent.palette.mauve
        }
        Text {
            text: ":"
            color: parent.palette.subtext0
            font.family: root.font
            font.pixelSize: 14
        }
        Text {
            Layout.fillWidth: true
            text: parent.value
            color: parent.palette.text
            font.family: root.font
            font.pixelSize: 14
            elide: Text.ElideRight
        }
    }
}
