import Quickshell
import QtQuick
import QtQuick.Effects
import Quickshell.Wayland
import Blobs
import "../themes" as Themes
import "../components" as Components
import "../components/PopoutDemo" as Demos

PanelWindow {
    id: frameWindow
    WlrLayershell.layer: WlrLayer.Top

    readonly property real leftThickness: 48
    readonly property real rightThickness: 12
    readonly property real verticalThickness: 12
    readonly property real innerRounding: 12
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

    // The center remains click-through; only the visible frame plus any expanded
    // popout are interactive.
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

        // Re-add each popout's current area so hovering it keeps it open.
        Region {
            x: topDown.px
            y: topDown.py
            width: topDown.gw
            height: topDown.gh
        }
        Region {
            x: topLeftRight.px
            y: topLeftRight.py
            width: topLeftRight.gw
            height: topLeftRight.gh
        }
        Region {
            x: leftRight.px
            y: leftRight.py
            width: leftRight.gw
            height: leftRight.gh
        }
        Region {
            x: leftBottomRight.px
            y: leftBottomRight.py
            width: leftBottomRight.gw
            height: leftBottomRight.gh
        }
        Region {
            x: bottomUp.px
            y: bottomUp.py
            width: bottomUp.gw
            height: bottomUp.gh
        }
        Region {
            x: bottomRightLeft.px
            y: bottomRightLeft.py
            width: bottomRightLeft.gw
            height: bottomRightLeft.gh
        }
        Region {
            x: rightLeft.px
            y: rightLeft.py
            width: rightLeft.gw
            height: rightLeft.gh
        }
        Region {
            x: rightTopDown.px
            y: rightTopDown.py
            width: rightTopDown.gw
            height: rightTopDown.gh
        }
    }

    // Shared blob group: the SDF shader fuses the inverted frame with any popout
    // blob that comes near a border, so panels appear to grow out of it.
    Item {
        id: blobLayer
        anchors.fill: parent

        BlobGroup {
            id: blobGroup
            color: frameWindow.palette.base
            smoothing: 32
        }

        // The frame: fills the border band and cuts a rounded hole in the
        // middle. Extended 50px beyond the window so the outer edge stays off
        // screen and the fill reaches the window edges cleanly.
        BlobInvertedRect {
            anchors.fill: parent
            anchors.margins: -50
            group: blobGroup
            radius: frameWindow.innerRounding
            borderLeft: frameWindow.leftThickness - anchors.margins
            borderRight: frameWindow.rightThickness - anchors.margins
            borderTop: frameWindow.verticalThickness - anchors.margins
            borderBottom: frameWindow.verticalThickness - anchors.margins
        }
    }

    // Neumorphic double shadow, matching the rest of the shell.
    MultiEffect {
        anchors.fill: blobLayer
        source: blobLayer
        shadowEnabled: true
        shadowBlur: 0.9
        blurMax: 48
        shadowColor: frameWindow.palette.crust
        shadowOpacity: 0.55
        shadowHorizontalOffset: -10
        shadowVerticalOffset: -10
    }

    MultiEffect {
        anchors.fill: blobLayer
        source: blobLayer
        shadowEnabled: true
        shadowBlur: 0.9
        blurMax: 48
        shadowColor: frameWindow.palette.crust
        shadowOpacity: 0.55
        shadowHorizontalOffset: 10
        shadowVerticalOffset: 10
    }

    // Crisp content for popouts is drawn here, above the shadow layer.
    Item {
        id: overlayLayer
        anchors.fill: parent
    }

    // --- Demo popouts: one per fusion/direction scenario. Content is empty;
    // they only demonstrate how to place and expand a popout. Remove in real use.
    Demos.TopDown {
        id: topDown
        blobLayer: blobLayer
        group: blobGroup
        overlayLayer: overlayLayer
        screenWidth: frameWindow.width
        screenHeight: frameWindow.height
        leftThickness: frameWindow.leftThickness
        rightThickness: frameWindow.rightThickness
        verticalThickness: frameWindow.verticalThickness
    }
    Demos.TopLeftRight {
        id: topLeftRight
        blobLayer: blobLayer
        group: blobGroup
        overlayLayer: overlayLayer
        screenWidth: frameWindow.width
        screenHeight: frameWindow.height
        leftThickness: frameWindow.leftThickness
        rightThickness: frameWindow.rightThickness
        verticalThickness: frameWindow.verticalThickness
    }
    Demos.LeftRight {
        id: leftRight
        blobLayer: blobLayer
        group: blobGroup
        overlayLayer: overlayLayer
        screenWidth: frameWindow.width
        screenHeight: frameWindow.height
        leftThickness: frameWindow.leftThickness
        rightThickness: frameWindow.rightThickness
        verticalThickness: frameWindow.verticalThickness
    }
    Demos.LeftBottomRight {
        id: leftBottomRight
        blobLayer: blobLayer
        group: blobGroup
        overlayLayer: overlayLayer
        screenWidth: frameWindow.width
        screenHeight: frameWindow.height
        leftThickness: frameWindow.leftThickness
        rightThickness: frameWindow.rightThickness
        verticalThickness: frameWindow.verticalThickness
    }
    Demos.BottomUp {
        id: bottomUp
        blobLayer: blobLayer
        group: blobGroup
        overlayLayer: overlayLayer
        screenWidth: frameWindow.width
        screenHeight: frameWindow.height
        leftThickness: frameWindow.leftThickness
        rightThickness: frameWindow.rightThickness
        verticalThickness: frameWindow.verticalThickness
    }
    Demos.BottomRightLeft {
        id: bottomRightLeft
        blobLayer: blobLayer
        group: blobGroup
        overlayLayer: overlayLayer
        screenWidth: frameWindow.width
        screenHeight: frameWindow.height
        leftThickness: frameWindow.leftThickness
        rightThickness: frameWindow.rightThickness
        verticalThickness: frameWindow.verticalThickness
    }
    Demos.RightLeft {
        id: rightLeft
        blobLayer: blobLayer
        group: blobGroup
        overlayLayer: overlayLayer
        screenWidth: frameWindow.width
        screenHeight: frameWindow.height
        leftThickness: frameWindow.leftThickness
        rightThickness: frameWindow.rightThickness
        verticalThickness: frameWindow.verticalThickness
    }
    Demos.RightTopDown {
        id: rightTopDown
        blobLayer: blobLayer
        group: blobGroup
        overlayLayer: overlayLayer
        screenWidth: frameWindow.width
        screenHeight: frameWindow.height
        leftThickness: frameWindow.leftThickness
        rightThickness: frameWindow.rightThickness
        verticalThickness: frameWindow.verticalThickness
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
