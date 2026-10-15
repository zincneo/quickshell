pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import ".." as C
import "../../services" as Svc

Rectangle {
    id: root
    required property var palette
    property string outputName: ""
    property real maxHeight: 300
    property bool expanded: false
    property int hoveredWorkspaceId: -1
    readonly property bool hovered: hoverArea.containsMouse
    readonly property var allWorkspaces: {
        const local = Svc.Niri.wsList.filter(w => w.output === outputName);
        return local.length ? local : Svc.Niri.wsList;
    }
    readonly property int currentIndex: Math.max(0, allWorkspaces.findIndex(w => w.id === Svc.Niri.focusedId || w.isActive))
    readonly property int shownStart: Math.max(0, Math.min(currentIndex - 1, allWorkspaces.length - 3))
    readonly property var shownWorkspaces: allWorkspaces.slice(shownStart, shownStart + 3)

    implicitWidth: 32
    implicitHeight: Math.min(maxHeight, workspaceColumn.implicitHeight + 16)
    radius: width / 2
    color: root.palette.surface0
    opacity: expanded ? 0 : 1
    Behavior on opacity {
        NumberAnimation { duration: 400; easing.type: Easing.InOutCubic }
    }
    visible: allWorkspaces.length > 0

    Flickable {
        id: scroll
        anchors.fill: parent
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        enabled: !root.expanded
        contentWidth: width
        contentHeight: workspaceColumn.implicitHeight + 8
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        ColumnLayout {
            id: workspaceColumn
            y: 4
            width: scroll.width
            spacing: 8

            Repeater {
                id: workspaceRepeater
                model: root.shownWorkspaces

                delegate: ColumnLayout {
                    id: workspace
                    required property var modelData
                    readonly property bool current: modelData.id === Svc.Niri.focusedId || modelData.isActive
                    readonly property var windows: Svc.Niri.windowsOn(modelData.id)
                    readonly property int focusIndex: windows.findIndex(w => w.isFocused)
                    readonly property int windowStart: Math.max(0, Math.min(focusIndex - 2, windows.length - 5))
                    readonly property var shownWindows: current && focusIndex >= 0 ? windows.slice(windowStart, windowStart + 5) : []
                    Layout.fillWidth: true
                    spacing: 8

                    Item {
                        Layout.fillWidth: true
                        implicitHeight: 26

                        Rectangle {
                            anchors.centerIn: parent
                            width: 8
                            height: width
                            radius: width / 2
                            color: workspace.current ? root.palette.lavender : root.palette.surface2
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.hoveredWorkspaceId = workspace.modelData.id
                            onClicked: Svc.Niri.switchTo(workspace.modelData.idx)
                        }
                    }

                    Repeater {
                        model: workspace.shownWindows

                        delegate: WorkspaceAppIcon {
                            Layout.alignment: Qt.AlignHCenter
                            required property var modelData
                            windowData: modelData
                            palette: root.palette
                            fallbackColor: modelData.isFocused ? root.palette.lavender : root.palette.subtext0
                            glow: modelData.isFocused
                        }
                    }
                }
            }
        }
    }

    // This input area stays visible even while the capsule content is hidden.
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.PointingHandCursor
        onEntered: {
            for (let i = 0; i < workspaceRepeater.count; ++i) {
                const workspace = workspaceRepeater.itemAt(i);
                const point = workspace.mapFromItem(root, mouseX, mouseY);
                if (point.y >= 0 && point.y < workspace.height) {
                    root.hoveredWorkspaceId = workspace.modelData.id;
                    return;
                }
            }
            root.hoveredWorkspaceId = root.allWorkspaces[root.currentIndex]?.id ?? -1;
        }
    }
}
