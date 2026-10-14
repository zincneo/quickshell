pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".." as C
import "../../services" as Svc

Item {
    id: root
    required property var palette
    property bool active: false
    property string promptSsid: ""
    property string forgetSsid: ""
    readonly property real preferredPanelHeight: Svc.Network.wifiEnabled ? 540 : 260

    onActiveChanged: {
        if (active) {
            Svc.Network.refresh();
            Svc.Network.scan();
        } else {
            promptSsid = "";
            forgetSsid = "";
            passwordField.text = "";
        }
    }

    Connections {
        target: Svc.Network
        function onPasswordRequiredSsidChanged() {
            if (Svc.Network.passwordRequiredSsid !== "")
                root.promptSsid = Svc.Network.passwordRequiredSsid;
        }
    }

    function submit() {
        if (root.promptSsid === "")
            return;
        Svc.Network.connectTo(root.promptSsid, passwordField.text);
        root.promptSsid = "";
        passwordField.text = "";
    }

    function wifiIcon(s: int): string {
        return s >= 75 ? "signal_wifi_4_bar" : s >= 50 ? "network_wifi_3_bar" : s >= 25 ? "network_wifi_2_bar" : "network_wifi_1_bar";
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // Ethernet
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 52
            radius: 14
            color: Svc.Network.ethernetConnected ? Qt.alpha(root.palette.mauve, 0.12) : root.palette.surface0
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                Item { Layout.fillWidth: true }
                C.MaterialIcon {
                    text: "lan"
                    size: 24
                    color: Svc.Network.ethernetConnected ? root.palette.mauve : root.palette.subtext0
                }
                ColumnLayout {
                    spacing: 2
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Ethernet"
                        font.family: "Rubik"
                        font.pixelSize: 14
                        color: root.palette.text
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: !Svc.Network.ethernetAvailable ? "No adapter" : Svc.Network.ethernetConnected ? "Connected" : Svc.Network.ethernetState === "unavailable" ? "Cable unplugged" : "Disconnected"
                        font.family: "Rubik"
                        font.pixelSize: 12
                        color: root.palette.subtext0
                    }
                }
                Item { Layout.fillWidth: true }
            }
        }

        // Wi-Fi header
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            C.MaterialIcon {
                text: Svc.Network.wifiEnabled ? "wifi" : "wifi_off"
                size: 26
                weight: 600
                color: Svc.Network.wifiEnabled ? root.palette.mauve : root.palette.subtext0
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: "Wi-Fi"
                    font.family: "Rubik"
                    font.pixelSize: 18
                    font.weight: Font.Medium
                    color: root.palette.text
                }
                Text {
                    text: !Svc.Network.wifiAvailable ? "No Wi-Fi adapter" : !Svc.Network.wifiEnabled ? "Disabled" : Svc.Network.type === "wifi" ? "Connected to " + Svc.Network.name : "Not connected"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    font.family: "Rubik"
                    font.pixelSize: 12
                    color: root.palette.subtext0
                }
            }
            Switch {
                id: wifiSwitch
                checked: Svc.Network.wifiEnabled
                enabled: Svc.Network.wifiAvailable
                onToggled: Svc.Network.setWifiEnabled(checked)
                Accessible.name: "Enable Wi-Fi"
                implicitWidth: 52
                implicitHeight: 32
                padding: 0
                indicator: Rectangle {
                    anchors.centerIn: parent
                    width: 48
                    height: 28
                    radius: 14
                    color: wifiSwitch.checked ? root.palette.mauve : root.palette.surface1
                    opacity: wifiSwitch.enabled ? 1 : 0.5
                    Rectangle {
                        x: wifiSwitch.checked ? 23 : 3
                        y: 3
                        width: 22
                        height: 22
                        radius: 11
                        color: wifiSwitch.checked ? root.palette.base : root.palette.subtext0
                        Behavior on x { NumberAnimation { duration: 150 } }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: Svc.Network.wifiEnabled
            Text {
                Layout.fillWidth: true
                text: Svc.Network.networks.length + " networks"
                font.family: "Rubik"
                font.pixelSize: 12
                color: root.palette.subtext0
            }
            Rectangle {
                implicitWidth: scanContent.implicitWidth + 20
                implicitHeight: 32
                radius: 10
                color: Svc.Network.scanning ? Qt.alpha(root.palette.mauve, 0.18) : (scanMouse.containsMouse ? root.palette.surface1 : root.palette.surface0)
                Row {
                    id: scanContent
                    anchors.centerIn: parent
                    spacing: 6
                    C.MaterialIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "wifi_find"
                        size: 20
                        color: root.palette.mauve
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Svc.Network.scanning ? "Scanning…" : "Scan"
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
                    onClicked: Svc.Network.scan()
                }
            }
        }

        Text {
            Layout.fillWidth: true
            visible: Svc.Network.error !== ""
            text: Svc.Network.error
            wrapMode: Text.WordWrap
            font.family: "Rubik"
            font.pixelSize: 12
            color: root.palette.red
        }

        // Password prompt
        Rectangle {
            Layout.fillWidth: true
            visible: root.promptSsid !== ""
            implicitHeight: promptCol.implicitHeight + 20
            radius: 14
            color: root.palette.surface0
            border.color: root.palette.mauve
            border.width: 1
            ColumnLayout {
                id: promptCol
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8
                Text {
                    Layout.fillWidth: true
                    text: "Password for " + root.promptSsid
                    elide: Text.ElideRight
                    font.family: "Rubik"
                    font.pixelSize: 13
                    color: root.palette.text
                }
                TextField {
                    id: passwordField
                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                    placeholderText: "Enter password"
                    font.family: "Rubik"
                    font.pixelSize: 13
                    color: root.palette.text
                    placeholderTextColor: root.palette.overlay0
                    onAccepted: root.submit()
                    background: Rectangle {
                        radius: 8
                        color: root.palette.surface1
                    }
                    onVisibleChanged: if (visible) forceActiveFocus()
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        implicitWidth: 72
                        implicitHeight: 30
                        radius: 10
                        color: root.palette.surface1
                        Text {
                            anchors.centerIn: parent
                            text: "Cancel"
                            font.family: "Rubik"
                            font.pixelSize: 12
                            color: root.palette.text
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.promptSsid = "";
                                passwordField.text = "";
                            }
                        }
                    }
                    Rectangle {
                        implicitWidth: 72
                        implicitHeight: 30
                        radius: 10
                        color: root.palette.mauve
                        opacity: passwordField.text.length >= 8 ? 1 : 0.5
                        Text {
                            anchors.centerIn: parent
                            text: "Connect"
                            font.family: "Rubik"
                            font.pixelSize: 12
                            color: root.palette.base
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: passwordField.text.length >= 8
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.submit()
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.promptSsid === ""

            Text {
                anchors.centerIn: parent
                width: parent.width - 16
                visible: !Svc.Network.wifiEnabled || Svc.Network.networks.length === 0
                text: !Svc.Network.wifiEnabled ? "Turn on Wi-Fi to see networks" : Svc.Network.scanning ? "Searching for networks…" : "No networks found. Click Scan."
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.family: "Rubik"
                font.pixelSize: 14
                color: root.palette.subtext0
            }

            ListView {
                anchors.fill: parent
                visible: Svc.Network.wifiEnabled
                model: Svc.Network.networks
                spacing: 6
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                delegate: Rectangle {
                    id: net
                    required property var modelData
                    readonly property bool busy: Svc.Network.connecting && Svc.Network.connectingSsid === modelData.ssid
                    readonly property bool forgetting: root.forgetSsid === modelData.ssid
                    width: ListView.view.width
                    height: 52
                    radius: 14
                    color: modelData.active ? Qt.alpha(root.palette.mauve, 0.12) : (rowMouse.containsMouse ? root.palette.surface1 : root.palette.surface0)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        C.MaterialIcon {
                            text: root.wifiIcon(net.modelData.signal)
                            size: 24
                            color: net.modelData.active ? root.palette.mauve : root.palette.subtext0
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                Layout.fillWidth: true
                                text: net.modelData.ssid
                                elide: Text.ElideRight
                                font.family: "Rubik"
                                font.pixelSize: 14
                                color: root.palette.text
                            }
                            Text {
                                Layout.fillWidth: true
                                text: net.busy ? "Connecting…" : net.modelData.active ? "Connected" : net.modelData.saved ? "Saved" : net.modelData.secure ? "Secured" : "Open"
                                font.family: "Rubik"
                                font.pixelSize: 12
                                color: root.palette.subtext0
                            }
                        }
                        Rectangle {
                            visible: net.forgetting
                            implicitWidth: 34
                            implicitHeight: 30
                            radius: 10
                            color: forgetMouse.containsMouse ? Qt.alpha(root.palette.red, 0.3) : Qt.alpha(root.palette.red, 0.18)
                            C.MaterialIcon {
                                anchors.centerIn: parent
                                text: "delete"
                                size: 20
                                color: root.palette.red
                            }
                            MouseArea {
                                id: forgetMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    Svc.Network.forget(net.modelData.ssid);
                                    root.forgetSsid = "";
                                }
                            }
                        }
                        C.MaterialIcon {
                            visible: net.modelData.secure && !net.modelData.active && !net.busy && !net.forgetting
                            text: "lock"
                            size: 18
                            color: root.palette.subtext0
                        }
                        C.MaterialIcon {
                            visible: net.modelData.active && !net.forgetting
                            text: "link_off"
                            size: 22
                            color: root.palette.mauve
                        }
                        C.MaterialIcon {
                            visible: net.busy
                            text: "sync"
                            size: 22
                            color: root.palette.mauve
                            RotationAnimator on rotation {
                                from: 0
                                to: 360
                                duration: 1000
                                loops: Animation.Infinite
                                running: net.busy
                            }
                        }
                    }
                    MouseArea {
                        id: rowMouse
                        anchors.fill: parent
                        enabled: !net.busy && !Svc.Network.connecting
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                if (net.modelData.saved || net.modelData.active) {
                                    root.forgetSsid = root.forgetSsid === net.modelData.ssid ? "" : net.modelData.ssid;
                                }
                                return;
                            }
                            if (net.forgetting) {
                                root.forgetSsid = "";
                                return;
                            }
                            root.forgetSsid = "";
                            if (net.modelData.active)
                                Svc.Network.disconnectWifi();
                            else if (net.modelData.secure && !net.modelData.saved)
                                root.promptSsid = net.modelData.ssid;
                            else
                                Svc.Network.connectTo(net.modelData.ssid, "");
                        }
                    }
                }
            }
        }
    }
}
