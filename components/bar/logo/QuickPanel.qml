pragma ComponentBehavior: Bound

import QtQuick
import ".." as Bar
import "../../dashboard" as D
import "../../../services" as Svc

// Tabbed card at the bottom of the logo panel: one content page per tab,
// switched with the tab bar.
PanelCard {
    id: root

    readonly property int audioTab: 0
    readonly property int networkTab: 1
    readonly property int bluetoothTab: 2
    readonly property int performanceTab: 3
    readonly property int restartTab: 4

    readonly property var tabs: [
        { icon: "tune", color: root.palette.mauve },
        { icon: "wifi", color: root.palette.blue },
        { icon: "bluetooth", color: root.palette.sapphire },
        { icon: "speed", color: root.palette.green },
        { icon: "restart_alt", color: root.palette.peach }
    ]

    property int currentIndex: audioTab
    readonly property bool pickerOpen: audio.pickerOpen
    // Network/Bluetooth lists take the space of the calendar while enabled.
    readonly property bool listExpanded: (currentIndex === networkTab && Svc.Network.wifiEnabled) || (currentIndex === bluetoothTab && Svc.Bluetooth.powered)

    signal restartConfirmed()

    Item {
        id: content

        clip: true
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: tabBar.top
        anchors.margins: 10

        Item {
            id: pickerArea

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: audio.pickerOpen ? Math.max(0, parent.height - audio.controlsTop - 4) : 0
            clip: true
        }

        Bar.AudioControls {
            id: audio

            anchors.fill: parent
            palette: root.palette
            pickerLayer: pickerArea
            inline: true
            rowSpacing: 13
            active: root.currentIndex === root.audioTab
            visible: root.currentIndex === root.audioTab
        }

        Bar.NetworkControls {
            anchors.fill: parent
            palette: root.palette
            active: root.currentIndex === root.networkTab
            visible: root.currentIndex === root.networkTab
        }

        Bar.BluetoothControls {
            anchors.fill: parent
            palette: root.palette
            active: root.currentIndex === root.bluetoothTab
            visible: root.currentIndex === root.bluetoothTab
        }

        D.PerformanceTab {
            anchors.fill: parent
            palette: root.palette
            visible: root.currentIndex === root.performanceTab
            ringSize: 84
            ringValueSize: 18
            centerSize: 124
            centerValueSize: 30
            ringSpacing: 8
        }

        RestartConfirm {
            anchors.centerIn: parent
            width: parent.width
            palette: root.palette
            visible: root.currentIndex === root.restartTab
            onConfirmed: root.restartConfirmed()
        }
    }

    QuickTabBar {
        id: tabBar

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        palette: root.palette
        tabs: root.tabs
        currentIndex: root.currentIndex
        onSelected: index => root.currentIndex = index
    }
}
