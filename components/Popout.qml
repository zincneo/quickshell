pragma ComponentBehavior: Bound

import QtQuick
import Blobs

// A hover-expand popout whose blob background fuses with a window border and
// grows out of it.
//
// Model: the fused edge stays pinned to the border (and overlaps a little into
// it so the SDF always merges); the panel grows from zero along `edge`'s
// perpendicular direction. This avoids any gap between the panel and the border
// during the animation, and collapses cleanly to a sliver at the border.
//
//   edge = "left"   -> pinned to left border,   grows right
//   edge = "right"  -> pinned to right border,  grows left
//   edge = "top"    -> pinned to top border,    grows down
//   edge = "bottom" -> pinned to bottom border, grows up
//
// Set `expandedX/Y/Width/Height` to the fully-open rect (its fused edge flush
// with the border inner edge; make an adjacent edge flush too for a corner
// fusion). Content is reparented above the shadow and revealed as it grows.
Item {
    id: root

    anchors.fill: parent

    required property Item blobLayer
    required property BlobGroup group
    required property Item overlayLayer

    property string edge: "left"

    // Fully-open rect in window coordinates.
    property real expandedX: 0
    property real expandedY: 0
    property real expandedWidth: 260
    property real expandedHeight: 180

    property real cornerRadius: 18
    property real overlap: 8          // how far the blob sinks into the fused border
    property real openDuration: 260
    property real deformScale: 0      // 0 = no jelly (avoids edge detachment)

    // Hover trigger zone (window coordinates) that opens the panel.
    property rect triggerZone: Qt.rect(0, 0, 0, 0)

    // Content shown inside the panel.
    default property alias content: contentInner.data

    readonly property bool horizontal: edge === "left" || edge === "right"
    readonly property bool open: triggerHover.hovered || panelHover.hovered
    property real expand: open ? 1 : 0

    Behavior on expand {
        NumberAnimation {
            duration: root.openDuration
            easing.type: Easing.OutCubic
        }
    }

    // Visible (on-screen) rect of the panel at the current growth.
    readonly property real gw: horizontal ? expandedWidth * expand : expandedWidth
    readonly property real gh: horizontal ? expandedHeight : expandedHeight * expand
    readonly property real px: edge === "right" ? expandedX + expandedWidth - gw : expandedX
    readonly property real py: edge === "bottom" ? expandedY + expandedHeight - gh : expandedY

    // Blob rect, extended into the fused border by `overlap` so it always merges.
    // When collapsed it is detached from the group entirely, so it contributes
    // nothing to the border SDF (otherwise a tiny bulge shows at the edge).
    readonly property BlobRect blobItem: BlobRect {
        id: blob
        parent: root.blobLayer
        group: root.expand > 0.001 ? root.group : null
        x: root.px - (root.edge === "left" ? root.overlap : 0)
        y: root.py - (root.edge === "top" ? root.overlap : 0)
        implicitWidth: root.gw + (root.horizontal ? root.overlap : 0)
        implicitHeight: root.gh + (root.horizontal ? 0 : root.overlap)
        radius: root.cornerRadius
        deformScale: root.deformScale
        visible: root.expand > 0.001
    }

    // Crisp content, above the shadow layer. The clip grows with the panel while
    // the inner content stays pinned to the expanded rect, so it is revealed
    // (not scaled) as the panel grows.
    readonly property Item contentClip: Item {
        id: contentHolder
        parent: root.overlayLayer
        x: root.px
        y: root.py
        width: root.gw
        height: root.gh
        clip: true
        opacity: root.expand
        visible: opacity > 0.01

        transform: Matrix4x4 {
            matrix: blob.deformMatrix
        }

        // Keeps the popout open while hovering its content. A HoverHandler is
        // passive, so child items (buttons, lists) still receive their own hover.
        HoverHandler {
            id: panelHover
            enabled: root.expand > 0.01
        }

        Item {
            id: contentInner
            x: root.expandedX - root.px
            y: root.expandedY - root.py
            width: root.expandedWidth
            height: root.expandedHeight
        }
    }

    // Border trigger hover (HoverHandler, passive).
    readonly property Item triggerItem: Item {
        parent: root
        x: root.triggerZone.x
        y: root.triggerZone.y
        width: root.triggerZone.width
        height: root.triggerZone.height

        HoverHandler {
            id: triggerHover
        }
    }
}
