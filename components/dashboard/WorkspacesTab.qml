pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".." as C
import "../../services" as Svc

// Workspaces tab (niri IPC). Circles at the top (sorted by index); the current
// workspace has a red outer ring, a hovered circle turns red and previews its
// windows below. The window list is scrollable: hovering a row highlights it
// green, the actually-focused window gets a mauve accent, and clicking a row
// focuses that window (and its workspace).
Item {
    id: root
    required property var palette
    readonly property string font: "Rubik"

    // The workspace whose windows are shown below (and which is filled red).
    // Changes when a circle is hovered; it does NOT revert on hover-out - only
    // hovering another circle (or switching workspace) changes it.
    property int displayedWsId: -1
    readonly property var displayedWindows: Svc.Niri.windows.filter(w => w.workspaceId === root.displayedWsId)

    Component.onCompleted: root.displayedWsId = Svc.Niri.focusedId

    Connections {
        target: Svc.Niri
        function onFocusedIdChanged(): void {
            root.displayedWsId = Svc.Niri.focusedId;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 20
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        anchors.bottomMargin: 6
        spacing: 16

        // Workspace circles.
        Flow {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            spacing: 30

            Repeater {
                model: Svc.Niri.wsList

                delegate: Item {
                    id: tile
                    required property var modelData
                    readonly property bool current: modelData.id === Svc.Niri.focusedId
                    readonly property bool displayed: modelData.id === root.displayedWsId
                    width: 60
                    height: 60

                    // Red outer ring for the current workspace.
                    Rectangle {
                        anchors.centerIn: parent
                        width: 56
                        height: 56
                        radius: width / 2
                        color: "transparent"
                        border.width: tile.current ? 3 : 0
                        border.color: root.palette.red
                    }

                    // Circle fill (red for the displayed workspace).
                    Rectangle {
                        anchors.centerIn: parent
                        width: 44
                        height: 44
                        radius: width / 2
                        color: tile.displayed ? root.palette.red : (tile.modelData.count > 0 ? root.palette.surface2 : root.palette.surface1)

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: tile.modelData.idx
                            color: tile.displayed ? root.palette.base : root.palette.text
                            font.family: root.font
                            font.pixelSize: 17
                            font.weight: Font.DemiBold
                        }
                    }

                    // Window-count badge.
                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: 2
                        visible: tile.modelData.count > 0
                        implicitWidth: 18
                        implicitHeight: 18
                        radius: 9
                        color: root.palette.mauve
                        Text {
                            anchors.centerIn: parent
                            text: tile.modelData.count
                            color: root.palette.base
                            font.family: root.font
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }
                    }

                    // Hover/click only react within the inner circle itself.
                    MouseArea {
                        id: wsMouse
                        anchors.centerIn: parent
                        width: 44
                        height: 44
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        containmentMask: QtObject {
                            function contains(point: point): bool {
                                const r = wsMouse.width / 2;
                                const dx = point.x - r;
                                const dy = point.y - r;
                                return dx * dx + dy * dy <= r * r;
                            }
                        }
                        onEntered: root.displayedWsId = tile.modelData.id
                        onClicked: Svc.Niri.switchTo(tile.modelData.idx)
                    }
                }
            }
        }

        // Window list for the displayed workspace.
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 20
            color: root.palette.surface0

            Text {
                anchors.centerIn: parent
                visible: root.displayedWindows.length === 0
                text: "No windows on this workspace"
                color: root.palette.subtext0
                font.family: root.font
                font.pixelSize: 14
            }

            ListView {
                id: list
                anchors.fill: parent
                anchors.margins: 8
                clip: true
                spacing: 6
                boundsBehavior: Flickable.StopAtBounds
                model: root.displayedWindows

                ScrollBar.vertical: ScrollBar {
                    policy: list.contentHeight > list.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                }

                delegate: Rectangle {
                    id: row
                    required property var modelData
                    readonly property bool focused: modelData.isFocused
                    readonly property bool hovered: rowMouse.containsMouse

                    width: ListView.view.width
                    height: 54
                    radius: 14
                    color: hovered ? Qt.alpha(root.palette.green, 0.22) : (focused ? Qt.alpha(root.palette.mauve, 0.14) : "transparent")

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }

                    // Mauve accent bar for the actually-focused window.
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 10
                        anchors.bottomMargin: 10
                        width: 4
                        radius: 2
                        color: root.palette.mauve
                        visible: row.focused
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12

                        C.MaterialIcon {
                            text: "web_asset"
                            size: 24
                            color: row.hovered ? root.palette.green : (row.focused ? root.palette.mauve : root.palette.subtext0)
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                text: row.modelData.appId || "window"
                                color: row.focused ? root.palette.mauve : root.palette.text
                                font.family: root.font
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: row.modelData.title || ""
                                color: root.palette.subtext0
                                font.family: root.font
                                font.pixelSize: 12
                                elide: Text.ElideRight
                                visible: text.length > 0
                            }
                        }

                        C.MaterialIcon {
                            visible: row.focused
                            text: "check_circle"
                            size: 20
                            filled: true
                            color: root.palette.mauve
                        }
                    }

                    MouseArea {
                        id: rowMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Svc.Niri.focusWindow(row.modelData.id)
                    }
                }
            }
        }
    }
}
