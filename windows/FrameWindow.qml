import Quickshell
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell.Wayland
import "../themes" as Themes
import "../components" as Components

PanelWindow {
    id: frameWindow
    WlrLayershell.layer: WlrLayer.Top

    readonly property real leftThickness: 48
    readonly property real rightThickness: 12
    readonly property real verticalThickness: 12
    readonly property var palette: Themes.Macchiato

    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    color: "transparent"
    aboveWindows: true
    focusable: false
    exclusionMode: ExclusionMode.Ignore

    // The center remains click-through; only the visible frame is interactive.
    mask: Region {
        width: frameWindow.width
        height: frameWindow.height

        Region {
            x: frameWindow.leftThickness
            y: frameWindow.verticalThickness
            width: frameWindow.width - frameWindow.leftThickness - frameWindow.rightThickness
            height: frameWindow.height - frameWindow.verticalThickness * 2
            intersection: Intersection.Subtract
        }
    }

    Shape {
        id: borderSurface
        anchors.fill: parent

        ShapePath {
            fillRule: ShapePath.OddEvenFill
            fillColor: frameWindow.palette.base
            strokeColor: "transparent"
            strokeWidth: -1

            PathRectangle {
                width: borderSurface.width
                height: borderSurface.height
                radius: 0
            }

            PathRectangle {
                x: frameWindow.leftThickness
                y: frameWindow.verticalThickness
                width: borderSurface.width - frameWindow.leftThickness - frameWindow.rightThickness
                height: borderSurface.height - frameWindow.verticalThickness * 2
                radius: 12
            }
        }
    }

    MultiEffect {
        anchors.fill: borderSurface
        source: borderSurface
        shadowEnabled: true
        shadowBlur: 0.9
        blurMax: 48
        shadowColor: frameWindow.palette.crust
        shadowOpacity: 0.55
        shadowHorizontalOffset: -10
        shadowVerticalOffset: -10
    }

    MultiEffect {
        anchors.fill: borderSurface
        source: borderSurface
        shadowEnabled: true
        shadowBlur: 0.9
        blurMax: 48
        shadowColor: frameWindow.palette.crust
        shadowOpacity: 0.55
        shadowHorizontalOffset: 10
        shadowVerticalOffset: 10
    }

    Components.Time {
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            topMargin: frameWindow.verticalThickness
            bottomMargin: frameWindow.verticalThickness
        }
        width: frameWindow.leftThickness
        palette: frameWindow.palette
    }
}
