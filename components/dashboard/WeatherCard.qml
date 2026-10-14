import QtQuick
import QtQuick.Layouts
import ".." as C
import "../../services" as Svc

Item {
    id: root
    required property var palette
    readonly property string font: "Rubik"

    RowLayout {
        anchors.centerIn: parent
        spacing: 14

        C.MaterialIcon {
            text: Svc.Weather.icon
            size: 50
            color: root.palette.peach
            filled: true
        }

        ColumnLayout {
            spacing: 0

            Text {
                text: Svc.Weather.temp
                color: root.palette.mauve
                font.family: root.font
                font.pixelSize: 28
                font.weight: Font.DemiBold
            }
            Text {
                text: Svc.Weather.description
                color: root.palette.subtext0
                font.family: root.font
                font.pixelSize: 13
            }
            Text {
                text: Svc.Weather.location
                color: root.palette.subtext1
                font.family: root.font
                font.pixelSize: 11
                visible: text.length > 0
                elide: Text.ElideRight
                Layout.maximumWidth: 150
            }
        }
    }
}
