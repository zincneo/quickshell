import QtQuick
import QtQuick.Layouts
import "../../services" as Svc

Item {
    id: root
    required property var palette
    readonly property string font: "Rubik"

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 0

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Svc.Time.fmt("hh")
            color: root.palette.lavender
            font.family: root.font
            font.pixelSize: 38
            font.weight: Font.DemiBold
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: -4
            Layout.bottomMargin: -4
            text: "\u2022\u2022\u2022"
            color: root.palette.mauve
            font.family: root.font
            font.pixelSize: 20
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Svc.Time.fmt("mm")
            color: root.palette.lavender
            font.family: root.font
            font.pixelSize: 38
            font.weight: Font.DemiBold
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            text: Qt.locale("en_GB").toString(Svc.Time.now, "ddd, d")
            color: root.palette.peach
            font.family: root.font
            font.pixelSize: 13
            font.weight: Font.Medium
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.locale("en_GB").toString(Svc.Time.now, "MMM, yyyy")
            color: root.palette.peach
            font.family: root.font
            font.pixelSize: 13
            font.weight: Font.Medium
        }
    }
}
