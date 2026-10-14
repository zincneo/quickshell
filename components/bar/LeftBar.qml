import QtQuick
import QtQuick.Layouts

// The left vertical bar, mirroring caelestia's entry order:
// logo, workspaces, [spacer], activeWindow, [spacer], tray, clock, statusIcons, power.
Item {
    id: root

    required property var palette
    property string outputName: ""
    property bool powerOpen: false
    property bool workspacesOpen: false
    readonly property bool powerHovered: powerButton.hovered
    readonly property bool workspacesHovered: workspaceGroup.hovered
    readonly property int hoveredWorkspaceId: workspaceGroup.hoveredWorkspaceId
    readonly property var workspaces: workspaceGroup.allWorkspaces
    readonly property rect workspaceZone: Qt.rect(root.x, root.y + sidebarLayout.y + workspaceGroup.y, root.width, workspaceGroup.height)

    ColumnLayout {
        id: sidebarLayout
        anchors.fill: parent
        anchors.topMargin: 4
        anchors.bottomMargin: 8
        spacing: 12

        OsIcon {
            Layout.alignment: Qt.AlignHCenter
            palette: root.palette
        }

        Workspaces {
            id: workspaceGroup
            Layout.alignment: Qt.AlignHCenter
            palette: root.palette
            outputName: root.outputName
            maxHeight: Math.min(300, root.height * 0.35)
            expanded: root.workspacesOpen
        }

        Item {
            Layout.fillHeight: true
        }

        ActiveWindow {
            Layout.alignment: Qt.AlignHCenter
            palette: root.palette
        }

        Item {
            Layout.fillHeight: true
        }

        Tray {
            Layout.alignment: Qt.AlignHCenter
            palette: root.palette
        }

        Clock {
            Layout.alignment: Qt.AlignHCenter
            palette: root.palette
        }

        StatusIcons {
            Layout.alignment: Qt.AlignHCenter
            palette: root.palette
        }

        Power {
            id: powerButton
            Layout.alignment: Qt.AlignHCenter
            palette: root.palette
            expanded: root.powerOpen
        }
    }
}
