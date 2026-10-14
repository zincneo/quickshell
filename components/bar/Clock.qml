import QtQuick
import QtQuick.Layouts
import "../../services" as Svc
import ".." as C

ColumnLayout {
    id: root
    required property var palette
    readonly property string font: "Rubik"
    spacing: 2

    C.MaterialIcon {
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: 4
        text: "calendar_month"
        size: 18
        color: root.palette.yellow
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: Svc.Time.fmt("hh")
        color: root.palette.yellow
        font.family: root.font
        font.pixelSize: 20
        font.weight: Font.Normal
    }
    Text {
        Layout.alignment: Qt.AlignHCenter
        text: Svc.Time.fmt("mm")
        color: root.palette.yellow
        font.family: root.font
        font.pixelSize: 20
        font.weight: Font.Normal
    }
}
