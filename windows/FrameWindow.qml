import Quickshell
import QtQuick
import QtQuick.Effects
import Quickshell.Wayland
import Blobs
import "../themes" as Themes
import "../components" as Components
import "../components/dashboard" as Dashboard

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

        // Re-add the dashboard's current area so it stays interactive when open.
        Region {
            x: dashboard.px
            y: dashboard.py
            width: dashboard.gw
            height: dashboard.gh
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

    // Top-center dropdown dashboard (hover the top border, center).
    Dashboard.Dashboard {
        id: dashboard

        blobLayer: blobLayer
        group: blobGroup
        overlayLayer: overlayLayer
        palette: frameWindow.palette

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
