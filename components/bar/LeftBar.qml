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
    property bool statusOpen: false
    property bool logoPanelOpen: false
    signal logoClicked()
    readonly property real contentOpacity: logoPanelOpen ? 0 : 1
    readonly property bool powerHovered: powerButton.hovered
    readonly property rect powerZone: Qt.rect(root.x, root.y + sidebarLayout.y + powerButton.y, root.width, powerButton.height)
    readonly property bool workspacesHovered: workspaceGroup.hovered
    readonly property bool statusHovered: statusGroup.hovered
    readonly property int statusTab: statusGroup.hoveredTab
    readonly property int hoveredWorkspaceId: workspaceGroup.hoveredWorkspaceId
    readonly property var workspaces: workspaceGroup.allWorkspaces
    readonly property rect workspaceZone: Qt.rect(root.x, root.y + sidebarLayout.y + workspaceGroup.y, root.width, workspaceGroup.height)
    readonly property rect statusZone: Qt.rect(root.x, root.y + sidebarLayout.y + statusGroup.y, root.width, statusGroup.height)

    ColumnLayout {
        id: sidebarLayout
        anchors.fill: parent
        anchors.topMargin: 4
        anchors.bottomMargin: 8
        spacing: 12

        Workspaces {
            id: workspaceGroup
            opacity: root.contentOpacity
            Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutCubic } }
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
            opacity: root.contentOpacity
            Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutCubic } }
            Layout.alignment: Qt.AlignHCenter
            palette: root.palette
        }

        Item {
            Layout.fillHeight: true
        }

        Tray {
            opacity: root.contentOpacity
            Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutCubic } }
            Layout.alignment: Qt.AlignHCenter
            palette: root.palette
        }

        Clock {
            opacity: root.contentOpacity
            Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutCubic } }
            Layout.alignment: Qt.AlignHCenter
            palette: root.palette
        }

        StatusIcons {
            id: statusGroup
            opacity: root.contentOpacity
            Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutCubic } }
            Layout.alignment: Qt.AlignHCenter
            palette: root.palette
            expanded: root.statusOpen
        }

        OsIcon {
            opacity: root.contentOpacity
            Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutCubic } }
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 6
            palette: root.palette
            onClicked: root.logoClicked()
        }

        Power {
            id: powerButton
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 6
            palette: root.palette
            expanded: root.powerOpen
            visible: false
        }
    }
}
