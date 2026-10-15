import QtQuick
import ".." as C
import "../../services" as Svc

Item {
    id: root
    required property var palette
    readonly property string font: "Rubik"

    Item {
        anchors.centerIn: parent
        width: 76
        height: 76

        C.MaterialIcon {
            anchors.centerIn: parent
            text: Svc.Weather.icon
            size: 72
            color: root.palette.peach
            filled: true
        }

        Text {
            z: 1
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -12
            anchors.rightMargin: -4
            text: Svc.Weather.temp
            color: root.palette.mauve
            font.family: root.font
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }
    }
}
