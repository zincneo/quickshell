pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ".." as Bar
import "../../dashboard" as D

// Contents of the left control panel, stacked top to bottom:
// workspaces, date/user, calendar/weather (hidden while a list is open), then the quick panel.
ColumnLayout {
    id: root

    required property var palette
    required property real leftThickness

    readonly property real edgeGap: 20
    readonly property real verticalGap: 8
    readonly property real calendarRowHeight: 144
    signal actionRequested(string selectedAction)

    property real calendarHeight: quickPanel.pickerOpen || quickPanel.listExpanded ? 0 : calendarRowHeight
    Behavior on calendarHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    function resetWorkspaceHover(): void {
        workspaceTile.resetToFocused();
        quickPanel.currentIndex = quickPanel.audioTab;
    }

    x: edgeGap - leftThickness
    y: verticalGap
    width: parent.width + leftThickness - edgeGap * 2
    height: parent.height - verticalGap * 2
    spacing: 6

    PanelCard {
        Layout.fillWidth: true
        Layout.preferredHeight: workspaceTile.implicitHeight + 22
        palette: root.palette

        Bar.WorkspaceManager {
            id: workspaceTile

            anchors.fill: parent
            anchors.margins: 16
            anchors.bottomMargin: 6
            palette: root.palette
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 120
        Layout.minimumHeight: 120
        Layout.maximumHeight: 120
        spacing: 6

        PanelCard {
            Layout.preferredWidth: 88
            Layout.fillHeight: true
            palette: root.palette

            D.DateTimeCard {
                anchors.fill: parent
                palette: root.palette
            }
        }

        PanelCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            palette: root.palette

            D.UserCard {
                anchors.fill: parent
                palette: root.palette
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: root.calendarHeight
        Layout.minimumHeight: 0
        Layout.maximumHeight: root.calendarHeight
        visible: root.calendarHeight > 0.5
        clip: true
        spacing: 6

        PanelCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            palette: root.palette

            D.CalendarView {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 12
                palette: root.palette
            }
        }

        PanelCard {
            Layout.preferredWidth: root.calendarRowHeight
            Layout.fillHeight: true
            palette: root.palette

            D.WeatherCard {
                anchors.fill: parent
                palette: root.palette
            }
        }
    }

    QuickPanel {
        id: quickPanel

        Layout.fillWidth: true
        Layout.fillHeight: true
        palette: root.palette
        onRestartConfirmed: root.actionRequested("restart")
    }
}
