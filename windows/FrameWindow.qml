import Quickshell
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell.Wayland

PanelWindow {
    id: frameWindow
    WlrLayershell.layer: WlrLayer.Top

    readonly property real leftThickness: 32
    readonly property real rightThickness: 12
    readonly property real verticalThickness: 12

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

    // The center remains click-through; only the visible frame is in the mask.
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

    // Full-screen surface with its center cut out, like ContentWindow's
    // inverted border surface. This keeps the desktop visible underneath.
    Shape {
        id: borderSurface
        anchors.fill: parent

        ShapePath {
            fillRule: ShapePath.OddEvenFill
            fillColor: "#24273a"
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

    // Opposing dark shadows preserve the original neumorphic depth without a light highlight.
    MultiEffect {
        anchors.fill: borderSurface
        source: borderSurface
        shadowEnabled: true
        shadowBlur: 0.9
        blurMax: 48
        shadowColor: "#181926"
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
        shadowColor: "#181926"
        shadowOpacity: 0.55
        shadowHorizontalOffset: 10
        shadowVerticalOffset: 10
    }
}
