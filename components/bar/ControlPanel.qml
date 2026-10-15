pragma ComponentBehavior: Bound

import QtQuick
import ".." as C
import "controlpanel" as Panel

// Left-edge control panel toggled through IPC (Super+1). It grows out of the left
// border and is fused to the top and bottom borders.
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
    closeDuration: 600
    contentFadeDuration: 400
    closeEasing: Easing.Linear
    openEasing: Easing.OutBack
    triggerZone: Qt.rect(0, verticalThickness, leftThickness, screenHeight - verticalThickness * 2)
    hoverEnabled: false

    function toggle(): void {
        opened = !opened;
    }

    Panel.ControlPanelContent {
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
