pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Bluetooth as Bluez
import ".." as C
import "../../services" as Svc

Item {
    id: root
    required property var palette
    property bool active: false
    readonly property real preferredPanelHeight: Svc.Bluetooth.powered ? Math.min(480, 240 + Math.min(4, Svc.Bluetooth.devices.length) * 66) : 260

    onActiveChanged: {
        if (!active)
            Svc.Bluetooth.stopDiscovery();
    }
    Component.onDestruction: Svc.Bluetooth.stopDiscovery()

    function deviceIcon(icon: string): string {
        const icons = {
            "audio-headset": "headset",
            "audio-headphones": "headphones",
            "audio-card": "speaker",
            "audio-speakers": "speaker",
            "input-keyboard": "keyboard",
            "input-mouse": "mouse",
            "input-gaming": "sports_esports",
            "phone": "smartphone",
            "computer": "computer"
        };
        return icons[icon] || "bluetooth";
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            C.MaterialIcon {
                text: Svc.Bluetooth.icon
                size: 26
                weight: 600
                color: Svc.Bluetooth.powered ? root.palette.mauve : root.palette.subtext0
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: "Bluetooth"
                    font.family: "Rubik"
                    font.pixelSize: 18
                    font.weight: Font.Medium
                    color: root.palette.text
                }
                Text {
                    text: !Svc.Bluetooth.available ? "No Bluetooth adapter" : Svc.Bluetooth.blocked ? "Blocked by hardware" : Svc.Bluetooth.changingPower ? "Updating…" : Svc.Bluetooth.powered ? "Enabled" : "Disabled"
                    font.family: "Rubik"
                    font.pixelSize: 12
                    color: root.palette.subtext0
                }
            }

            Switch {
                id: powerSwitch
                checked: Svc.Bluetooth.powered
                enabled: Svc.Bluetooth.available && !Svc.Bluetooth.blocked && !Svc.Bluetooth.changingPower
                onToggled: Svc.Bluetooth.setPowered(checked)
                Accessible.name: "Enable Bluetooth"
                implicitWidth: 52
                implicitHeight: 32
                padding: 0

                indicator: Rectangle {
                    anchors.centerIn: parent
                    width: 48
                    height: 28
                    radius: 14
                    color: powerSwitch.checked ? root.palette.mauve : root.palette.surface1
                    opacity: powerSwitch.enabled ? 1 : 0.5
                    Rectangle {
                        x: powerSwitch.checked ? 23 : 3
                        y: 3
                        width: 22
                        height: 22
                        radius: 11
                        color: powerSwitch.checked ? root.palette.base : root.palette.subtext0
                        Behavior on x { NumberAnimation { duration: 150 } }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: Svc.Bluetooth.powered
            Text {
                Layout.fillWidth: true
                text: Svc.Bluetooth.connectedCount + (Svc.Bluetooth.connectedCount === 1 ? " device connected" : " devices connected")
                font.family: "Rubik"
                font.pixelSize: 12
                color: root.palette.subtext0
            }

            Rectangle {
                implicitWidth: scanContent.implicitWidth + 20
                implicitHeight: 32
                radius: 10
                color: Svc.Bluetooth.discovering ? Qt.alpha(root.palette.mauve, 0.18) : (scanMouse.containsMouse ? root.palette.surface1 : root.palette.surface0)

                Row {
                    id: scanContent
                    anchors.centerIn: parent
                    spacing: 6
                    C.MaterialIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Svc.Bluetooth.discovering ? "stop" : "bluetooth_searching"
                        size: 20
                        color: root.palette.mauve
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Svc.Bluetooth.discovering ? "Stop scan" : "Scan"
                        font.family: "Rubik"
                        font.pixelSize: 12
                        color: root.palette.mauve
                    }
                }
                MouseArea {
                    id: scanMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Svc.Bluetooth.setDiscovering(!Svc.Bluetooth.discovering)
                }
            }
        }

        Text {
            Layout.fillWidth: true
            visible: Svc.Bluetooth.error !== ""
            text: Svc.Bluetooth.error
            wrapMode: Text.WordWrap
            font.family: "Rubik"
            font.pixelSize: 12
            color: root.palette.red
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Text {
                anchors.centerIn: parent
                width: parent.width - 16
                visible: !Svc.Bluetooth.powered || Svc.Bluetooth.devices.length === 0
                text: !Svc.Bluetooth.available ? "No Bluetooth adapter found" : Svc.Bluetooth.blocked ? "Bluetooth is blocked by hardware" : !Svc.Bluetooth.powered ? "Turn on Bluetooth to connect devices" : Svc.Bluetooth.discovering ? "Searching for devices…" : "No devices found. Click Scan to search."
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.family: "Rubik"
                font.pixelSize: 14
                color: root.palette.subtext0
            }

            ListView {
                id: deviceList
                anchors.fill: parent
                visible: Svc.Bluetooth.powered
                model: Svc.Bluetooth.devices
                spacing: 6
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                delegate: Rectangle {
                    id: device
                    required property Bluez.BluetoothDevice modelData
                    readonly property bool busy: modelData.pairing || modelData.state === Bluez.BluetoothDeviceState.Connecting || modelData.state === Bluez.BluetoothDeviceState.Disconnecting
                    width: ListView.view.width
                    height: 60
                    radius: 14
                    color: modelData.connected ? Qt.alpha(root.palette.mauve, 0.12) : root.palette.surface0

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        C.MaterialIcon {
                            text: root.deviceIcon(device.modelData.icon)
                            size: 26
                            color: device.modelData.connected ? root.palette.mauve : root.palette.subtext0
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3
                            Text {
                                Layout.fillWidth: true
                                text: device.modelData.name || device.modelData.address
                                elide: Text.ElideRight
                                font.family: "Rubik"
                                font.pixelSize: 14
                                color: root.palette.text
                            }
                            Text {
                                Layout.fillWidth: true
                                text: device.modelData.pairing ? "Pairing…" : device.modelData.state === Bluez.BluetoothDeviceState.Connecting ? "Connecting…" : device.modelData.state === Bluez.BluetoothDeviceState.Disconnecting ? "Disconnecting…" : device.modelData.connected ? "Connected" + (device.modelData.batteryAvailable ? " · " + Math.round(device.modelData.battery * 100) + "%" : "") : device.modelData.paired || device.modelData.bonded ? "Saved" : "Not paired"
                                elide: Text.ElideRight
                                font.family: "Rubik"
                                font.pixelSize: 12
                                color: root.palette.subtext0
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            radius: 12
                            color: device.modelData.connected ? root.palette.mauve : (connectMouse.containsMouse ? root.palette.surface2 : root.palette.surface1)

                            C.MaterialIcon {
                                anchors.centerIn: parent
                                visible: !device.busy
                                text: device.modelData.connected ? "link_off" : device.modelData.paired || device.modelData.bonded ? "link" : "add_link"
                                size: 22
                                weight: 600
                                color: device.modelData.connected ? root.palette.base : root.palette.text
                            }
                            C.MaterialIcon {
                                anchors.centerIn: parent
                                visible: device.busy
                                text: "sync"
                                size: 22
                                color: root.palette.mauve
                                RotationAnimator on rotation {
                                    from: 0
                                    to: 360
                                    duration: 1000
                                    loops: Animation.Infinite
                                    running: device.busy
                                }
                            }
                            MouseArea {
                                id: connectMouse
                                anchors.fill: parent
                                enabled: !device.busy && (!Svc.Bluetooth.pendingPair || device.modelData.paired || device.modelData.connected)
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Svc.Bluetooth.toggleConnection(device.modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
