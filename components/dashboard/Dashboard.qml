pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ".." as C
import "." as D

// Top-center dropdown dashboard matching the reference layout:
//   Row 1: [Weather] [User]            [Media (tall, spans both rows)]
//   Row 2: [DateTime | Calendar] [Res]
C.Popout {
    id: root

    required property real screenWidth
    required property real screenHeight
    required property real leftThickness
    required property real rightThickness
    required property real verticalThickness
    required property var palette

    readonly property string font: "Rubik"
    property int currentTab: 0
    readonly property var tabs: [
        { icon: "dashboard", label: "Dashboard" },
        { icon: "queue_music", label: "Media" },
        { icon: "speed", label: "Performance" }
    ]

    edge: "top"
    cornerRadius: 26
    expandedWidth: 880
    expandedHeight: currentTab === 2 ? 300 : 450
    openDuration: 320

    expandedX: leftThickness + (screenWidth - leftThickness - rightThickness - expandedWidth) / 2
    expandedY: verticalThickness
    triggerZone: Qt.rect(expandedX, 0, expandedWidth, verticalThickness)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // Tab bar.
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: root.tabs

                delegate: Item {
                    id: tab
                    required property int index
                    required property var modelData
                    readonly property bool current: root.currentTab === index

                    Layout.fillWidth: true
                    implicitHeight: 48

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        C.MaterialIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: tab.modelData.icon
                            size: 20
                            filled: tab.current
                            color: tab.current ? root.palette.mauve : root.palette.subtext0
                        }
                        Text {
                            id: tabLabel
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: tab.modelData.label
                            color: tab.current ? root.palette.mauve : root.palette.subtext0
                            font.family: root.font
                            font.pixelSize: 12
                            font.weight: tab.current ? Font.Medium : Font.Normal
                        }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: tab.current ? Math.max(42, tabLabel.implicitWidth + 8) : 0
                        height: 3
                        radius: 2
                        color: root.palette.mauve

                        Behavior on width {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.currentTab = tab.index
                        onClicked: root.currentTab = tab.index
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: root.palette.surface1
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.currentTab

            // --- Dashboard tab.
            RowLayout {
                spacing: 10

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10

                    // Row 1: weather + user.
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        Layout.minimumHeight: 100
                        Layout.maximumHeight: 100
                        spacing: 10

                        Cell {
                            Layout.preferredWidth: 236
                            Layout.fillHeight: true
                            D.WeatherCard {
                                anchors.fill: parent
                                palette: root.palette
                            }
                        }
                        Cell {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            D.UserCard {
                                anchors.fill: parent
                                palette: root.palette
                            }
                        }
                    }

                    // Row 2: separate datetime, calendar and resources cards.
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 10

                        Cell {
                            Layout.preferredWidth: 112
                            Layout.fillHeight: true
                            D.DateTimeCard {
                                anchors.fill: parent
                                palette: root.palette
                            }
                        }
                        Cell {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            D.CalendarView {
                                anchors.fill: parent
                                anchors.margins: 14
                                palette: root.palette
                            }
                        }
                        Cell {
                            Layout.preferredWidth: 78
                            Layout.fillHeight: true
                            D.ResourcesCard {
                                anchors.fill: parent
                                palette: root.palette
                            }
                        }
                    }
                }

                // Media, spanning both rows.
                Cell {
                    Layout.preferredWidth: 206
                    Layout.fillHeight: true
                    D.MediaCard {
                        anchors.fill: parent
                        palette: root.palette
                    }
                }
            }

            Placeholder {
                palette: root.palette
                text: "Media"
            }
            D.PerformanceTab {
                palette: root.palette
            }
        }
    }

    component Cell: Rectangle {
        default property alias content: holder.data
        radius: 20
        color: root.palette.surface0
        Item {
            id: holder
            anchors.fill: parent
        }
    }

    component Placeholder: Item {
        property var palette
        property alias text: ph.text
        Text {
            id: ph
            anchors.centerIn: parent
            color: parent.palette.subtext0
            font.family: root.font
            font.pixelSize: 14
        }
    }
}
