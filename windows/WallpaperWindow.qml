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
    readonly property var palette: Themes.Macchiato

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

    Image {
        id: wallpaper
        x: wallpaperWindow.frameLeftInset + wallpaperWindow.wallpaperGap
        y: wallpaperWindow.frameVerticalInset + wallpaperWindow.wallpaperGap
        width: wallpaperWindow.width - wallpaperWindow.frameLeftInset
            - wallpaperWindow.frameRightInset - wallpaperWindow.wallpaperGap * 2
        height: wallpaperWindow.height - wallpaperWindow.frameVerticalInset * 2
            - wallpaperWindow.wallpaperGap * 2
        source: "file:///home/zinc/.wallpaper/sakura.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: false
    }

    Rectangle {
        id: roundedMask
        x: wallpaper.x
        y: wallpaper.y
        width: wallpaper.width
        height: wallpaper.height
        radius: 12
        // The mask only uses this item's opacity; a theme color keeps it opaque.
        color: wallpaperWindow.palette.text
        visible: false
        layer.enabled: true
    }

    Rectangle {
        id: shadowSurface
        x: wallpaper.x
        y: wallpaper.y
        width: wallpaper.width
        height: wallpaper.height
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
        shadowColor: wallpaperWindow.palette.crust
        shadowOpacity: 0.55
        shadowHorizontalOffset: -10
        shadowVerticalOffset: -10
    }

    MultiEffect {
        source: shadowSurface
        anchors.fill: shadowSurface
        shadowEnabled: true
        shadowBlur: 0.9
        blurMax: 48
        shadowColor: wallpaperWindow.palette.crust
        shadowOpacity: 0.55
        shadowHorizontalOffset: 10
        shadowVerticalOffset: 10
    }

    MultiEffect {
        source: wallpaper
        anchors.fill: wallpaper
        maskEnabled: true
        maskSource: roundedMask
    }
}
