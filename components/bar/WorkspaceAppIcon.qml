pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import ".." as C
import "../../services" as Svc

Item {
    id: root
    required property var windowData
    required property var palette
    property int iconSize: 18
    property color fallbackColor: palette.subtext0
    property bool glow: false
    property int glowPad: glow ? 6 : 0
    readonly property var entry: windowData?.appId ? DesktopEntries.heuristicLookup(windowData.appId) : null

    implicitWidth: iconSize
    implicitHeight: iconSize

    // Glow lives in a centred child that may be larger than the layout slot,
    // so the icon's layout footprint never changes when glow toggles.
    Item {
        id: content
        anchors.centerIn: parent
        width: root.iconSize + root.glowPad * 2
        height: root.iconSize + root.glowPad * 2

        layer.enabled: root.glow
        layer.effect: ShaderEffect {
            property real time: 0
            property color colorA: root.palette.lavender
            property color colorB: root.palette.mauve
            property color colorC: root.palette.pink
            property color colorD: root.palette.sapphire
            property real glowRadius: root.glowPad * 0.7
            property real strength: 1.0
            property real warp: 0.35
            property vector2d texelSize: Qt.vector2d(1 / content.width, 1 / content.height)
            fragmentShader: Qt.resolvedUrl("shaders/glow.frag.qsb")

            NumberAnimation on time {
                from: 0
                to: 2 * Math.PI
                duration: 9000
                loops: Animation.Infinite
                running: root.glow
            }
        }

    Image {
        id: appImage
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize
        source: root.windowData?.appId ? Quickshell.iconPath(root.entry?.icon || root.windowData.appId, "application-x-executable") : ""
        sourceSize.width: root.iconSize * 2
        sourceSize.height: root.iconSize * 2
        fillMode: Image.PreserveAspectFit
        visible: status === Image.Ready
    }
    C.MaterialIcon {
        anchors.centerIn: parent
        visible: !appImage.visible
        text: "web_asset"
        size: root.iconSize
        color: root.fallbackColor
    }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Svc.Niri.focusWindow(root.windowData.id)
    }
}
