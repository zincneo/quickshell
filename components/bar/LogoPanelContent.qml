pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ".." as C
import "../dashboard" as D
import "../../services" as Svc

// Contents of the bottom-logo panel, stacked top to bottom.
ColumnLayout {
    id: root

    required property var palette
    required property real leftThickness

    readonly property real edgeGap: 20
    readonly property real verticalGap: 8
    signal actionRequested(string selectedAction)

    readonly property var quickActions: [
        { icon: "tune", color: root.palette.mauve },
        { icon: "wifi", color: root.palette.blue },
        { icon: "bluetooth", color: root.palette.sapphire },
        { icon: "speed", color: root.palette.green },
        { icon: "restart_alt", color: root.palette.peach }
    ]
    property int currentQuick: 0
    readonly property real calendarRowHeight: 144
    readonly property bool pickerOpen: audio.selectedPicker >= 0
    readonly property bool listExpanded: (currentQuick === 1 && Svc.Network.wifiEnabled) || (currentQuick === 2 && Svc.Bluetooth.powered)
    property real calendarHeight: pickerOpen || listExpanded ? 0 : calendarRowHeight
    Behavior on calendarHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    function resetWorkspaceHover(): void {
        workspaceTile.resetToFocused();
        currentQuick = 0;
    }

    x: edgeGap - leftThickness
    y: verticalGap
    width: parent.width + leftThickness - edgeGap * 2
    height: parent.height - verticalGap * 2
    spacing: 6

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: workspaceTile.implicitHeight + 22
        radius: 20
        color: root.palette.surface0

        WorkspaceManager {
            id: workspaceTile
            anchors.fill: parent
            anchors.margins: 16
            anchors.bottomMargin: 6
            palette: root.palette
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 120
        Layout.minimumHeight: 120
        Layout.maximumHeight: 120
        spacing: 6

        Rectangle {
            Layout.preferredWidth: 88
            Layout.fillHeight: true
            radius: 20
            color: root.palette.surface0

            D.DateTimeCard {
                anchors.fill: parent
                palette: root.palette
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 20
            color: root.palette.surface0

            D.UserCard {
                anchors.fill: parent
                palette: root.palette
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: root.calendarHeight
        Layout.minimumHeight: 0
        Layout.maximumHeight: root.calendarHeight
        visible: root.calendarHeight > 0.5
        clip: true
        spacing: 6

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 20
            color: root.palette.surface0

            D.CalendarView {
                id: calendar
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 12
                palette: root.palette
            }
        }

        Rectangle {
            Layout.preferredWidth: root.calendarRowHeight
            Layout.fillHeight: true
            radius: 20
            color: root.palette.surface0

            D.WeatherCard {
                anchors.fill: parent
                palette: root.palette
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 20
        color: root.palette.surface0

        Item {
            id: quickContent
            clip: true
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: quickBar.top
            anchors.margins: 10

            Item {
                id: pickerArea
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: audio.pickerOpen ? Math.max(0, parent.height - audio.controlsTop - 4) : 0
                clip: true
            }

            AudioControls {
                id: audio
                anchors.fill: parent
                palette: root.palette
                pickerLayer: pickerArea
                inline: true
                rowSpacing: 13
                active: root.currentQuick === 0
                visible: root.currentQuick === 0
            }

            NetworkControls {
                anchors.fill: parent
                palette: root.palette
                active: root.currentQuick === 1
                visible: root.currentQuick === 1
            }

            BluetoothControls {
                anchors.fill: parent
                palette: root.palette
                active: root.currentQuick === 2
                visible: root.currentQuick === 2
            }

            D.PerformanceTab {
                anchors.fill: parent
                palette: root.palette
                visible: root.currentQuick === 3
                ringSize: 84
                ringValueSize: 18
                centerSize: 124
                centerValueSize: 30
                ringSpacing: 8
            }

            Column {
                anchors.centerIn: parent
                width: parent.width
                spacing: 8
                visible: root.currentQuick === 4

                C.MaterialIcon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "restart_alt"
                    size: 28
                    weight: 700
                    color: root.palette.peach
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Restart system?"
                    font.family: "Rubik"
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    color: root.palette.text
                }

                Text {
                    width: parent.width
                    text: "Are you sure you want to restart?"
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    font.family: "Rubik"
                    font.pixelSize: 12
                    color: root.palette.subtext0
                }

                Item {
                    width: parent.width
                    height: 34

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.round(parent.width * 0.6)
                    height: parent.height
                    radius: 12
                    color: confirmMouse.containsMouse ? Qt.lighter(root.palette.peach, 1.1) : root.palette.peach

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        C.MaterialIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "restart_alt"
                            size: 16
                            weight: 700
                            color: root.palette.base
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Confirm"
                            font.family: "Rubik"
                            font.pixelSize: 12
                            color: root.palette.base
                        }
                    }

                    MouseArea {
                        id: confirmMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.actionRequested("restart")
                    }
                }
                }
            }
        }

        Rectangle {
            id: quickBar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 44
            color: root.palette.mantle
            bottomLeftRadius: 20
            bottomRightRadius: 20

            Row {
                anchors.fill: parent

                Repeater {
                    model: root.quickActions

                    delegate: Rectangle {
                        id: quick
                        required property var modelData
                        required property int index

                        width: quickBar.width / root.quickActions.length
                        height: quickBar.height
                        color: root.currentQuick === index ? root.palette.surface1 : quickMouse.containsMouse ? root.palette.surface0 : "transparent"
                        bottomLeftRadius: index === 0 ? 20 : 0
                        bottomRightRadius: index === root.quickActions.length - 1 ? 20 : 0

                        C.MaterialIcon {
                            anchors.centerIn: parent
                            text: quick.modelData.icon
                            size: 20
                            weight: 700
                            color: quick.modelData.color
                        }

                        MouseArea {
                            id: quickMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.currentQuick = quick.index
                        }
                    }
                }
            }
        }
    }
}
