import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import "../themes" as Themes

PanelWindow {
    id: wallpaperWindow

    readonly property real frameLeftInset: 48
    readonly property real frameRightInset: 12
    readonly property real frameVerticalInset: 12
    readonly property real wallpaperGap: 24
    readonly property var palette: Themes.ThemeManager.current

    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    implicitWidth: screen.width
    implicitHeight: screen.height

    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    color: "transparent"
    focusable: false
    mask: Region {}

    Rectangle {
        anchors.fill: parent
        color: wallpaperWindow.palette.base
    }

    Rectangle {
        id: shadowSurface
        x: wallpaperWindow.frameLeftInset + wallpaperWindow.wallpaperGap
        y: wallpaperWindow.frameVerticalInset + wallpaperWindow.wallpaperGap
        width: wallpaperWindow.width - wallpaperWindow.frameLeftInset
            - wallpaperWindow.frameRightInset - wallpaperWindow.wallpaperGap * 2
        height: wallpaperWindow.height - wallpaperWindow.frameVerticalInset * 2
            - wallpaperWindow.wallpaperGap * 2
        radius: 12
        color: wallpaperWindow.palette.base
        layer.enabled: true
    }

    MultiEffect {
        source: shadowSurface
        anchors.fill: shadowSurface
        shadowEnabled: true
        shadowBlur: 0.9
        blurMax: 48
        shadowColor: wallpaperWindow.palette.shadowLight
        shadowOpacity: wallpaperWindow.palette.shadowOpacity
        shadowHorizontalOffset: -10
        shadowVerticalOffset: -10
    }

    MultiEffect {
        source: shadowSurface
        anchors.fill: shadowSurface
        shadowEnabled: true
        shadowBlur: 0.9
        blurMax: 48
        shadowColor: wallpaperWindow.palette.shadowDark
        shadowOpacity: wallpaperWindow.palette.shadowOpacity
        shadowHorizontalOffset: 10
        shadowVerticalOffset: 10
    }
}
