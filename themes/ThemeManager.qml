pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Shared theme state; every window and component reads `current`.
QtObject {
    id: root

    property bool light: false
    readonly property var current: light ? Light : Dark
    // Avatar image variant: catppuccin0 for light, catppuccin1 for dark.
    readonly property int logoIndex: light ? 0 : 1

    function toggle(): void {
        light = !light;
    }

    // Applies the kitty theme matching the current mode on startup and on every switch.
    function applyKittyTheme(): void {
        Quickshell.execDetached([Quickshell.shellDir + "/scripts/kitty-theme.sh", root.light ? "light" : "dark"]);
    }

    onLightChanged: applyKittyTheme()
    Component.onCompleted: applyKittyTheme()
}
