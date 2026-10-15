pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import ".." as C
import "../../services" as Svc

// Workspace overview: one chip per workspace. Hovering a chip previews the
// windows on that workspace below; clicking a chip switches to it.
ColumnLayout {
    id: root

    required property var palette

    property int hoveredId: Svc.Niri.wsList.find(w => w.isFocused)?.id ?? -1
    readonly property var hoveredWorkspace: Svc.Niri.wsList.find(w => w.id === hoveredId) ?? null
    readonly property var previewWindows: Svc.Niri.windowsOn(hoveredId)

    spacing: 10

    onHoveredIdChanged: windowList.contentY = 0

    // Called each time the panel opens: default to the focused workspace.
    function resetToFocused(): void {
        hoveredId = Svc.Niri.wsList.find(w => w.isFocused)?.id ?? -1;
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        // Same 48px footprint as a chip, so the icon centers on the circles' column.
        Item {
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            Layout.alignment: Qt.AlignTop

            C.MaterialIcon {
                anchors.centerIn: parent
                text: "workspaces"
                size: 36
                color: root.palette.mauve
            }
        }

        ListView {
            id: chipList
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            orientation: ListView.Horizontal
            clip: true
            spacing: 0
            boundsBehavior: Flickable.StopAtBounds
            model: Svc.Niri.wsList

            // 48px footprint: 36px circle plus a 6px halo pad, so the glow never shifts the layout.
            delegate: Item {
                id: chip
                required property var modelData

                readonly property int circleSize: 36
                readonly property int glowPad: 6
                readonly property bool hovered: chipMouse.containsMouse
                readonly property color normalColor: modelData.isActive ? Qt.alpha(root.palette.mauve, 0.16) : root.palette.mantle

                width: circleSize + glowPad * 2
                height: width

                Item {
                    id: chipContent
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height

                    layer.enabled: chip.modelData.isFocused || chip.hovered
                    layer.effect: ShaderEffect {
                        property real time: 0
                        property color colorA: root.palette.lavender
                        property color colorB: root.palette.mauve
                        property color colorC: root.palette.pink
                        property color colorD: root.palette.sapphire
                        property real glowRadius: chip.glowPad * 0.7
                        property real strength: 1.0
                        property real warp: 0.35
                        property vector2d texelSize: Qt.vector2d(1 / chipContent.width, 1 / chipContent.height)
                        property color haloTint: root.palette.haloTint
                        fragmentShader: Qt.resolvedUrl("shaders/glow.frag.qsb")

                        NumberAnimation on time {
                            from: 0
                            to: 2 * Math.PI
                            duration: 9000
                            loops: Animation.Infinite
                            running: chip.modelData.isFocused || chip.hovered
                        }
                    }

                // Multi-color fill: the same rotating conic blend as the glow ring, shown on hover.
                Rectangle {
                    anchors.centerIn: parent
                    width: chip.circleSize
                    height: chip.circleSize
                    radius: width / 2
                    color: chip.modelData.isFocused ? root.palette.surface1 : chip.normalColor

                    Behavior on color {
                        ColorAnimation { duration: 300 }
                    }

                    ShaderEffect {
                        anchors.fill: parent
                        opacity: chip.hovered ? 1 : 0
                        visible: opacity > 0.01
                        property real time: 0
                        property color colorA: root.palette.lavender
                        property color colorB: root.palette.mauve
                        property color colorC: root.palette.pink
                        property color colorD: root.palette.sapphire
                        property vector2d size: Qt.vector2d(width, height)
                        property real cornerRadius: chip.circleSize / 2
                        fragmentShader: Qt.resolvedUrl("shaders/fill.frag.qsb")

                        Behavior on opacity {
                            NumberAnimation { duration: 300 }
                        }

                        NumberAnimation on time {
                            from: 0
                            to: 2 * Math.PI
                            duration: 9000
                            loops: Animation.Infinite
                            running: chip.hovered
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: chip.modelData.idx
                        font.family: "Rubik"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: chip.hovered ? root.palette.base : root.palette.text
                    }
                }
                }

                MouseArea {
                    id: chipMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: root.hoveredId = chip.modelData.id
                    onClicked: Svc.Niri.switchTo(chip.modelData.idx)
                }
            }
        }
    }

    Text {
        Layout.fillWidth: true
        text: (root.hoveredWorkspace?.name || "Workspace " + (root.hoveredWorkspace?.idx ?? "")) + " · " + root.previewWindows.length + (root.previewWindows.length === 1 ? " window" : " windows")
        elide: Text.ElideRight
        font.family: "Rubik"
        font.pixelSize: 13
        font.weight: Font.Bold
        color: root.palette.subtext0
    }

    Item {
        Layout.fillWidth: true
        // Rows are 48px delegates (36px row + 6px glow pad each side) with -6 spacing, so visible gaps are 6px.
        // The 6px top margin plus the glow pad keeps the top gap equal to the row gap, and the bottom pad matches it.
        Layout.preferredHeight: 6 + 4 * 48 - 3 * 6

        Text {
            anchors.centerIn: parent
            visible: root.previewWindows.length === 0
            text: "No windows on this workspace"
            font.family: "Rubik"
            font.pixelSize: 10
            color: root.palette.subtext0
        }

        ListView {
            id: windowList
            anchors.fill: parent
            model: root.previewWindows
            clip: true
            spacing: -6
            topMargin: 6
            bottomMargin: 0
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            delegate: Item {
                id: windowRow
                required property var modelData
                readonly property var entry: modelData.appId ? DesktopEntries.heuristicLookup(modelData.appId) : null
                readonly property bool hovered: rowMouse.containsMouse
                readonly property int rowHeight: 36
                readonly property int glowPad: 6

                width: ListView.view.width
                height: rowHeight + glowPad * 2

                Item {
                    id: rowContent
                    anchors.fill: parent

                    layer.enabled: windowRow.modelData.isFocused || windowRow.hovered
                    layer.effect: ShaderEffect {
                        property real time: 0
                        property color colorA: root.palette.lavender
                        property color colorB: root.palette.mauve
                        property color colorC: root.palette.pink
                        property color colorD: root.palette.sapphire
                        property real glowRadius: windowRow.glowPad * 0.7
                        property real strength: 1.0
                        property real warp: 0.35
                        property vector2d texelSize: Qt.vector2d(1 / rowContent.width, 1 / rowContent.height)
                        property color haloTint: root.palette.haloTint
                        fragmentShader: Qt.resolvedUrl("shaders/glow.frag.qsb")

                        NumberAnimation on time {
                            from: 0
                            to: 2 * Math.PI
                            duration: 9000
                            loops: Animation.Infinite
                            running: windowRow.modelData.isFocused || windowRow.hovered
                        }
                    }

                    Rectangle {
                        id: rowBg
                        anchors.fill: parent
                        anchors.margins: windowRow.glowPad
                        radius: 10
                        color: windowRow.modelData.isFocused ? root.palette.surface1 : root.palette.mantle

                        Behavior on color {
                            ColorAnimation { duration: 300 }
                        }

                        ShaderEffect {
                            anchors.fill: parent
                            opacity: windowRow.hovered ? 1 : 0
                            visible: opacity > 0.01
                            property real time: 0
                            property color colorA: root.palette.lavender
                            property color colorB: root.palette.mauve
                            property color colorC: root.palette.pink
                            property color colorD: root.palette.sapphire
                            property vector2d size: Qt.vector2d(width, height)
                            property real cornerRadius: 10
                            fragmentShader: Qt.resolvedUrl("shaders/fill_flow.frag.qsb")

                            Behavior on opacity {
                                NumberAnimation { duration: 300 }
                            }

                            NumberAnimation on time {
                                from: 0
                                to: 2 * Math.PI
                                duration: 4000
                                loops: Animation.Infinite
                                running: windowRow.hovered
                            }
                        }
                    }

                    RowLayout {
                        anchors.fill: rowBg
                        anchors.margins: 8
                        spacing: 8

                        Image {
                            Layout.preferredWidth: 22
                            Layout.preferredHeight: 22
                            sourceSize.width: 44
                            sourceSize.height: 44
                            fillMode: Image.PreserveAspectFit
                            source: windowRow.modelData.appId ? Quickshell.iconPath(windowRow.entry?.icon || windowRow.modelData.appId, "application-x-executable") : ""
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text {
                                Layout.fillWidth: true
                                text: windowRow.entry?.name || windowRow.modelData.appId || "Application"
                                elide: Text.ElideRight
                                font.family: "Rubik"
                                font.pixelSize: 11
                                color: windowRow.hovered ? root.palette.base : root.palette.text
                            }
                            Text {
                                Layout.fillWidth: true
                                text: windowRow.modelData.title
                                elide: Text.ElideRight
                                font.family: "Rubik"
                                font.pixelSize: 9
                                color: windowRow.hovered ? root.palette.base : root.palette.subtext0
                            }
                        }
                    }
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Svc.Niri.focusWindow(windowRow.modelData.id)
                }
            }
        }
    }
}
