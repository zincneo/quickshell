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
    property QtObject manager: null

    property string edge: "left"

    // Fully-open rect in window coordinates.
    property real expandedX: 0
    property real expandedY: 0
    property real expandedWidth: 260
    property real expandedHeight: 180

    property real cornerRadius: 18
    property real overlap: 8          // how far the blob sinks into the fused border
    property real openDuration: 600
    property real closeDuration: openDuration
    property int closeEasing: Easing.OutCubic
    // Content fades on its own timing so it disappears before the shell finishes collapsing.
    property real contentFadeDuration: 600
    property real contentOpacity: 0
    property int openEasing: Easing.OutCubic
    property real deformScale: 0      // 0 = no jelly (avoids edge detachment)
    // Extra width the content may use beyond the left edge of the panel (for
    // content that spans into the left bar area).
    property real contentOverhang: 0

    // Hover trigger zone (window coordinates) that opens the panel.
    property rect triggerZone: Qt.rect(0, 0, 0, 0)

    // Content shown inside the panel.
    default property alias content: contentInner.data

    readonly property bool horizontal: edge === "left" || edge === "right"
    // Global switch for hover-driven opening. Disabled for now; set to true to restore.
    property bool hoverOpenEnabled: false
    property bool hoverEnabled: true
    property bool triggerActive: false
    property bool active: false
    readonly property bool hovered: triggerHover.hovered || panelHover.hovered
    readonly property bool requestedOpen: active || (hoverOpenEnabled && hoverEnabled && (hovered || triggerActive))
    readonly property bool open: requestedOpen && (!manager || (manager.currentPanel === root && !manager.closing && !manager.blocked))
    property real expand: 0
    readonly property bool fullyClosed: expand === 0 && !expandAnimation.running

    onRequestedOpenChanged: {
        if (manager)
            Qt.callLater(manager.update, root);
    }
    // Driven explicitly instead of via a Behavior, so each transition uses the
    // open or close duration and easing it actually starts with.
    onOpenChanged: {
        expandAnimation.stop();
        expandAnimation.to = open ? 1 : 0;
        expandAnimation.duration = open ? openDuration : closeDuration;
        expandAnimation.easing.type = open ? openEasing : closeEasing;
        expandAnimation.start();
        contentFadeAnimation.stop();
        contentFadeAnimation.to = open ? 1 : 0;
        contentFadeAnimation.duration = contentFadeDuration;
        contentFadeAnimation.start();
    }

    NumberAnimation {
        id: contentFadeAnimation
        target: root
        property: "contentOpacity"
        easing.type: Easing.Linear
    }
    onFullyClosedChanged: {
        if (manager && fullyClosed)
            Qt.callLater(manager.update, root);
    }
    Component.onCompleted: {
        if (manager)
            Qt.callLater(manager.update, root);
    }

    NumberAnimation {
        id: expandAnimation
        target: root
        property: "expand"
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
        x: root.px - root.contentOverhang
        y: root.py
        width: root.gw + root.contentOverhang
        height: root.gh
        clip: true
        opacity: root.contentOpacity
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
            x: root.expandedX - root.px + root.contentOverhang
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
