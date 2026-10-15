pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Month calendar matching the reference: English, Monday-first, no month/year
// title, today in a filled circle. Fills the width it is given.
ColumnLayout {
    id: root

    required property var palette
    readonly property string font: "Rubik"
    readonly property var loc: Qt.locale("en_GB")

    spacing: 4

    DayOfWeekRow {
        Layout.fillWidth: true
        locale: root.loc

        delegate: Text {
            required property var model
            horizontalAlignment: Text.AlignHCenter
            text: model.shortName
            font.family: root.font
            font.pixelSize: 10
            font.weight: Font.Medium
            color: root.palette.subtext0
        }
    }

    MonthGrid {
        id: grid
        Layout.fillWidth: true
        month: new Date().getMonth()
        year: new Date().getFullYear()
        locale: root.loc
        spacing: 0

        delegate: Item {
            id: dayItem
            required property var model
            implicitWidth: 30
            implicitHeight: 18

            Rectangle {
                anchors.centerIn: parent
                width: 18
                height: 18
                radius: width / 2
                visible: dayItem.model.today
                color: root.palette.mauve
            }

            Text {
                anchors.centerIn: parent
                text: dayItem.model.day
                font.family: root.font
                font.pixelSize: 11
                font.weight: dayItem.model.today ? Font.Medium : Font.Normal
                opacity: dayItem.model.month === grid.month ? 1 : 0.35
                color: dayItem.model.today ? root.palette.base : root.palette.subtext1
            }
        }
    }
}
