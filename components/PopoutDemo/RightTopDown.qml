pragma ComponentBehavior: Bound

import QtQuick
import ".." as Lib// 8. Fuse with the RIGHT-TOP corner, expand DOWN. Wide, slow.
Lib.Popout {
    id: root
    required property real screenWidth
    required property real screenHeight
    required property real leftThickness
    required property real rightThickness
    required property real verticalThickness

    edge: "top"
    expandedWidth: 300
    expandedHeight: 170
    openDuration: 520

    expandedX: screenWidth - rightThickness - expandedWidth
    expandedY: verticalThickness
    triggerZone: Qt.rect(expandedX, 0, expandedWidth, verticalThickness)
}
