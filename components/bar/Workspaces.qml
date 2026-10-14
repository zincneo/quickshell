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
    readonly property int currentIndex: Math.max(0, allWorkspaces.findIndex(w => w.id === Svc.Niri.focusedId || w.isActive));
    readonly property int groupStart: Math.floor(currentIndex / 5) * 5
    readonly property var shownWorkspaces: allWorkspaces.slice(groupStart, groupStart + 5)

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
        anchors.margins: 4
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
                    readonly property var windows: Svc.Niri.windows.filter(w => w.workspaceId === modelData.id)
                    Layout.fillWidth: true
                    spacing: 4

                    Item {
                        Layout.fillWidth: true
                        implicitHeight: 28

                        Rectangle {
                            anchors.centerIn: parent
                            width: workspace.current ? 26 : 8
                            height: width
                            radius: workspace.current || !workspace.windows.length ? width / 2 : 2
                            color: workspace.current ? root.palette.mauve : (workspace.windows.length ? root.palette.subtext0 : root.palette.surface2)
                            C.MaterialIcon {
                                anchors.centerIn: parent
                                visible: workspace.current
                                text: "adjust"
                                size: 20
                                color: root.palette.base
                            }
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
                        model: workspace.windows.slice(0, 5)
                        delegate: Item {
                            id: windowIcon
                            required property var modelData
                            readonly property var entry: modelData.appId ? DesktopEntries.heuristicLookup(modelData.appId) : null
                            Layout.alignment: Qt.AlignHCenter
                            implicitWidth: 24
                            implicitHeight: 24

                            Image {
                                id: appImage
                                anchors.centerIn: parent
                                width: 22
                                height: 22
                                source: windowIcon.modelData.appId ? Quickshell.iconPath(windowIcon.entry?.icon || windowIcon.modelData.appId, "application-x-executable") : ""
                                sourceSize.width: 44
                                sourceSize.height: 44
                                fillMode: Image.PreserveAspectFit
                                visible: status === Image.Ready
                            }
                            C.MaterialIcon {
                                anchors.centerIn: parent
                                visible: !appImage.visible
                                text: "web_asset"
                                size: 22
                                color: root.palette.subtext0
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: root.hoveredWorkspaceId = workspace.modelData.id
                                onClicked: Svc.Niri.focusWindow(windowIcon.modelData.id)
                            }
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        visible: workspace.windows.length > 5
                        text: "+" + (workspace.windows.length - 5)
                        font.family: "Rubik"
                        font.pixelSize: 11
                        color: root.palette.subtext0
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
