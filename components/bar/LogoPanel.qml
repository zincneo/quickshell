pragma ComponentBehavior: Bound

import QtQuick
import ".." as C
import "logo" as Logo

// Left-edge panel opened by clicking the bottom logo. It grows out of the left
// border and is fused to the top and bottom borders. It closes once the pointer
// leaves the bar column or the panel.
C.Popout {
    id: root

    required property real screenHeight
    required property real leftThickness
    required property real verticalThickness
    required property var palette

    property bool opened: false
    signal actionRequested(string selectedAction)

    edge: "left"
    active: opened
    cornerRadius: 26
    expandedX: leftThickness
    expandedY: verticalThickness
    expandedWidth: 420
    expandedHeight: screenHeight - verticalThickness * 2
    contentOverhang: leftThickness
    openDuration: 600
    closeDuration: 800
    contentFadeDuration: 400
    closeEasing: Easing.Linear
    openEasing: Easing.OutBack
    triggerZone: Qt.rect(0, verticalThickness, leftThickness, screenHeight - verticalThickness * 2)

    // Grace period so brief pointer exits (or a quick re-entry) don't close the panel.
    Timer {
        id: closeTimer
        interval: 600
        onTriggered: root.opened = false
    }

    onHoveredChanged: {
        if (hovered)
            closeTimer.stop();
        else if (opened)
            closeTimer.restart();
    }

    function toggle(): void {
        opened = !opened;
    }

    Logo.LogoPanelContent {
        id: panelContent
        palette: root.palette
        leftThickness: root.leftThickness
        onActionRequested: selectedAction => root.actionRequested(selectedAction)
    }

    onOpenedChanged: {
        if (opened)
            panelContent.resetWorkspaceHover();
    }
}
