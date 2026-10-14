import QtQuick
import "../themes" as Themes

Item {
    id: timeDisplay

    property var palette: Themes.Macchiato
    property date currentTime: new Date()

    function twoDigits(value) {
        return String(value).padStart(2, "0")
    }

    Timer {
        interval: 10000
        repeat: true
        running: true
        onTriggered: timeDisplay.currentTime = new Date()
    }

    Column {
        anchors.centerIn: parent
        width: parent.width
        spacing: 0

        Text {
            width: parent.width
            height: 28
            text: timeDisplay.twoDigits(timeDisplay.currentTime.getHours())
            color: timeDisplay.palette.lavender
            font.family: "Iosevka Nerd Font Mono"
            font.pixelSize: 22
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            width: parent.width
            height: 28
            text: timeDisplay.twoDigits(timeDisplay.currentTime.getMinutes())
            color: timeDisplay.palette.lavender
            font.family: "Iosevka Nerd Font Mono"
            font.pixelSize: 22
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
