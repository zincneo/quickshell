import QtQuick
import QtQuick.Layouts
import "../../services" as Svc

Item {
    id: root
    required property var palette
    readonly property string font: "CaskaydiaCove Nerd Font Mono"

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 0

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Svc.Time.fmt("hh")
            color: root.palette.lavender
            font.family: root.font
            font.pixelSize: 18
            font.weight: Font.Bold
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: -2
            Layout.bottomMargin: -2
            text: "\u2022\u2022\u2022"
            color: root.palette.mauve
            font.family: root.font
            font.pixelSize: 12
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Svc.Time.fmt("mm")
            color: root.palette.lavender
            font.family: root.font
            font.pixelSize: 18
            font.weight: Font.Bold
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 4
            text: Qt.locale("en_GB").toString(Svc.Time.now, "ddd, d")
            color: root.palette.peach
            font.family: root.font
            font.pixelSize: 10
            font.weight: Font.Bold
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.locale("en_GB").toString(Svc.Time.now, "MMM, yyyy")
            color: root.palette.peach
            font.family: root.font
            font.pixelSize: 10
            font.weight: Font.Bold
        }
    }
}
