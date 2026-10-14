pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ".." as C

Item {
    id: root

    required property var palette
    property string action: ""
    readonly property bool restarting: action === "restart"
    readonly property string actionIcon: restarting ? "restart_alt" : "power_settings_new"
    readonly property color accent: restarting ? palette.peach : palette.red
    signal confirmed(string selectedAction)

    function cancel(): void {
        action = "";
    }

    function confirm(): void {
        const selected = action;
        action = "";
        if (selected === "restart" || selected === "shutdown")
            confirmed(selected);
    }

    anchors.fill: parent
    z: 1000
    visible: action !== ""
    onVisibleChanged: {
        if (visible)
            forceActiveFocus();
    }
    Keys.onEscapePressed: event => {
        cancel();
        event.accepted = true;
    }

    Rectangle {
        anchors.fill: parent
        color: "#99000000"
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onClicked: root.cancel()
            onWheel: wheel => wheel.accepted = true
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(380, parent.width - 48)
        height: content.implicitHeight + 48
        radius: 24
        color: root.palette.base
        border.width: 3
        border.color: root.palette.lavender

        // Consume clicks on the dialog surface without dismissing it.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
        }

        ColumnLayout {
            id: content
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 24
            spacing: 16

            C.MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: root.actionIcon
                size: 40
                weight: 700
                color: root.accent
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: root.restarting ? "Restart system?" : "Shut down system?"
                font.family: "Rubik"
                font.pixelSize: 22
                font.weight: Font.Medium
                color: root.palette.text
            }

            Text {
                Layout.fillWidth: true
                text: root.restarting ? "Are you sure you want to restart?" : "Are you sure you want to shut down?"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.family: "Rubik"
                font.pixelSize: 14
                color: root.palette.subtext0
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 12

                layoutDirection: Qt.LeftToRight

                ConfirmationButton {
                    confirmButton: true
                }

                ConfirmationButton {
                    confirmButton: false
                }
            }
        }
    }

    component ConfirmationButton: Rectangle {
        id: button
        required property bool confirmButton

        function activate(): void {
            if (confirmButton)
                root.confirm();
            else
                root.cancel();
        }

        Layout.fillWidth: true
        implicitHeight: 46
        radius: 14
        color: confirmButton ? root.accent : (mouse.containsMouse ? root.palette.surface1 : root.palette.surface0)
        border.width: activeFocus ? 2 : 0
        border.color: root.palette.text
        activeFocusOnTab: true
        Keys.onReturnPressed: activate()
        Keys.onEnterPressed: activate()
        Keys.onSpacePressed: activate()

        Row {
            anchors.centerIn: parent
            spacing: 8
            C.MaterialIcon {
                anchors.verticalCenter: parent.verticalCenter
                text: button.confirmButton ? root.actionIcon : "close"
                size: 20
                weight: 700
                color: button.confirmButton ? root.palette.base : root.palette.text
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: button.confirmButton ? "Confirm" : "Cancel"
                font.family: "Rubik"
                font.pixelSize: 14
                color: button.confirmButton ? root.palette.base : root.palette.text
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.activate()
        }
    }
}
