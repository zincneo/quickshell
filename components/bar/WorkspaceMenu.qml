pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import ".." as C
import "../../services" as Svc

C.Popout {
    id: root
    required property var palette
    required property real screenWidth
    required property real screenHeight
    required property real leftThickness
    required property real rightThickness
    required property real verticalThickness
    property rect workspaceZone: Qt.rect(0, 0, 0, 0)
    property bool buttonHovered: false
    property bool blocked: false
    property int workspaceId: -1
    property int selectedId: -1
    property var workspaces: []

    readonly property var selectedWorkspace: workspaces.find(w => w.id === selectedId) ?? workspaces.find(w => w.id === workspaceId) ?? workspaces[0] ?? null
    readonly property var windows: Svc.Niri.windows.filter(w => w.workspaceId === selectedWorkspace?.id)

    edge: "left"
    expandedWidth: Math.min(440, screenWidth - leftThickness - rightThickness)
    expandedHeight: Math.min(460, screenHeight - verticalThickness * 2)
    expandedX: leftThickness
    expandedY: verticalThickness
    cornerRadius: 24
    hoverEnabled: !blocked
    triggerActive: buttonHovered
    triggerZone: workspaceZone

    onWorkspaceIdChanged: selectedId = workspaceId
    onOpenChanged: {
        if (open)
            selectedId = workspaceId >= 0 ? workspaceId : Svc.Niri.focusedId;
    }
    onSelectedIdChanged: windowList.contentY = 0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        RowLayout {
            spacing: 8
            C.MaterialIcon { text: "workspaces"; size: 26; color: root.palette.mauve }
            Text {
                text: "Workspaces"
                font.family: "Rubik"
                font.pixelSize: 20
                font.weight: Font.Medium
                color: root.palette.text
            }
        }

        ListView {
            id: workspaceList
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            orientation: ListView.Horizontal
            spacing: 8
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: root.workspaces
            currentIndex: root.workspaces.findIndex(w => w.id === root.selectedWorkspace?.id)
            onCurrentIndexChanged: {
                if (currentIndex >= 0)
                    positionViewAtIndex(currentIndex, ListView.Contain);
            }
            ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AsNeeded }

            delegate: Rectangle {
                id: workspace
                required property var modelData
                readonly property bool selected: modelData.id === root.selectedWorkspace?.id
                width: 44
                height: 44
                radius: 14
                color: selected ? root.palette.mauve : root.palette.surface0
                border.width: !selected && modelData.isActive ? 1 : 0
                border.color: root.palette.mauve
                Text {
                    anchors.centerIn: parent
                    text: workspace.modelData.idx
                    font.family: "Rubik"
                    font.pixelSize: 18
                    color: workspace.selected ? root.palette.base : root.palette.text
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: root.selectedId = workspace.modelData.id
                    onClicked: Svc.Niri.switchTo(workspace.modelData.idx)
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: (root.selectedWorkspace?.name || "Workspace " + (root.selectedWorkspace?.idx ?? "")) + " · " + root.windows.length + (root.windows.length === 1 ? " window" : " windows")
            elide: Text.ElideRight
            font.family: "Rubik"
            font.pixelSize: 14
            color: root.palette.subtext0
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Text {
                anchors.centerIn: parent
                visible: root.windows.length === 0
                text: "No windows on this workspace"
                font.family: "Rubik"
                font.pixelSize: 14
                color: root.palette.subtext0
            }

            ListView {
                id: windowList
                anchors.fill: parent
                model: root.windows
                clip: true
                spacing: 6
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                delegate: Rectangle {
                    id: windowRow
                    required property var modelData
                    readonly property var entry: modelData.appId ? DesktopEntries.heuristicLookup(modelData.appId) : null
                    width: ListView.view.width
                    height: 74
                    radius: 14
                    color: mouse.containsMouse ? root.palette.surface1 : (modelData.isFocused ? Qt.alpha(root.palette.mauve, 0.16) : root.palette.surface0)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 14
                        Item {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            Image {
                                id: appImage
                                anchors.fill: parent
                                source: windowRow.modelData.appId ? Quickshell.iconPath(windowRow.entry?.icon || windowRow.modelData.appId, "application-x-executable") : ""
                                sourceSize.width: 72
                                sourceSize.height: 72
                                fillMode: Image.PreserveAspectFit
                                visible: status === Image.Ready
                            }
                            C.MaterialIcon {
                                anchors.centerIn: parent
                                visible: !appImage.visible
                                text: "web_asset"
                                size: 34
                                color: root.palette.mauve
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3
                            Text {
                                Layout.fillWidth: true
                                text: windowRow.entry?.name || windowRow.modelData.appId || "Application"
                                elide: Text.ElideRight
                                font.family: "Rubik"
                                font.pixelSize: 16
                                color: root.palette.text
                            }
                            Text {
                                Layout.fillWidth: true
                                text: windowRow.modelData.title
                                elide: Text.ElideRight
                                font.family: "Rubik"
                                font.pixelSize: 13
                                color: root.palette.subtext0
                            }
                        }
                        C.MaterialIcon {
                            visible: windowRow.modelData.isFocused
                            text: "check_circle"
                            size: 20
                            color: root.palette.mauve
                        }
                    }
                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Svc.Niri.focusWindow(windowRow.modelData.id)
                    }
                }
            }
        }
    }
}
