import QtQuick
import Quickshell
import ".." as C
import "../../services" as Svc

// Focused window: app icon + vertical app name. Shows "Desktop" when no window.
Item {
    id: root
    required property var palette
    readonly property var win: Svc.Niri.focusedWindow
    readonly property var desktopEntry: win?.appId ? DesktopEntries.heuristicLookup(win.appId) : null
    readonly property string label: win ? (desktopEntry?.name || win.appId || "Application") : "Desktop"
    readonly property string font: "Rubik"

    implicitWidth: Math.max(32, nameBox.width)
    implicitHeight: icon.height + 8 + nameBox.height

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8

        Item {
            id: icon
            anchors.horizontalCenter: parent.horizontalCenter
            width: 32
            height: 32

            Image {
                id: appIcon
                anchors.fill: parent
                source: root.win ? Quickshell.iconPath(root.desktopEntry?.icon || root.win.appId, "application-x-executable") : ""
                sourceSize.width: 64
                sourceSize.height: 64
                fillMode: Image.PreserveAspectFit
                visible: root.win && status === Image.Ready
            }
            C.MaterialIcon {
                anchors.centerIn: parent
                visible: !appIcon.visible
                text: "desktop_windows"
                size: 32
                color: root.palette.mauve
            }
        }

        // Vertical (rotated) app name.
        Item {
            id: nameBox
            anchors.horizontalCenter: parent.horizontalCenter
            width: nameText.implicitHeight
            height: Math.min(nameText.implicitWidth, 150)
            clip: true

            Text {
                id: nameText
                anchors.centerIn: parent
                rotation: 90
                width: Math.min(implicitWidth, 150)
                elide: Text.ElideRight
                text: root.label
                color: root.palette.mauve
                font.family: root.font
                font.pixelSize: 16
                font.letterSpacing: 1.2
                font.weight: Font.Normal
            }
        }
    }
}
