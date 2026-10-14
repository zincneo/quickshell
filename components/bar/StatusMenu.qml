pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ".." as C

C.Popout {
    id: root
    required property var palette
    required property real screenWidth
    required property real screenHeight
    required property real leftThickness
    required property real rightThickness
    required property real verticalThickness
    property rect statusZone: Qt.rect(0, 0, 0, 0)
    property bool buttonHovered: false
    property bool blocked: false
    property int requestedTab: 0
    property int currentTab: 0
    readonly property rect devicePickerRect: audioControls.pickerRect
    readonly property bool pointerInside: buttonHovered || hovered || audioControls.pickerHovered
    readonly property var tabs: [
        { icon: "tune", label: "Controls" },
        { icon: "wifi", label: "Network" },
        { icon: "bluetooth", label: "Bluetooth" }
    ]

    edge: "left"
    expandedWidth: Math.min(400, screenWidth - leftThickness - rightThickness)
    expandedHeight: Math.min(currentTab === 0 ? 340 : currentTab === 2 ? bluetoothControls.preferredPanelHeight : 200, screenHeight - verticalThickness * 2)
    expandedX: leftThickness
    expandedY: screenHeight - verticalThickness - expandedHeight
    cornerRadius: 24
    triggerZone: statusZone
    triggerActive: buttonHovered || audioControls.pickerHovered || hoverGrace.running
    hoverEnabled: !blocked
    onPointerInsideChanged: {
        if (pointerInside)
            hoverGrace.stop();
        else
            hoverGrace.restart();
    }

    Timer {
        id: hoverGrace
        interval: 150
    }
    onOpenChanged: {
        if (open)
            currentTab = requestedTab;
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.currentTab
            AudioControls {
                id: audioControls
                palette: root.palette
                active: root.open && root.currentTab === 0
                pickerLayer: root.overlayLayer
                windowX: root.expandedX + 16
                windowY: root.expandedY + 16
            }
            Item {}
            BluetoothControls {
                id: bluetoothControls
                palette: root.palette
                active: root.open && root.currentTab === 2
            }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: root.palette.surface1 }

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: root.tabs
                delegate: Item {
                    id: tab
                    required property int index
                    required property var modelData
                    readonly property bool current: index === root.currentTab
                    Layout.fillWidth: true
                    implicitHeight: 54

                    Column {
                        anchors.centerIn: parent
                        spacing: 4
                        C.MaterialIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: tab.modelData.icon
                            size: 24
                            weight: 600
                            color: tab.current ? root.palette.mauve : root.palette.subtext0
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: tab.modelData.label
                            font.family: "Rubik"
                            font.pixelSize: 12
                            color: tab.current ? root.palette.mauve : root.palette.subtext0
                        }
                    }
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        width: 48
                        height: 3
                        radius: 2
                        visible: tab.current
                        color: root.palette.mauve
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.currentTab = tab.index
                    }
                }
            }
        }

    }
}
