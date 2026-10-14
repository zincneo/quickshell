pragma ComponentBehavior: Bound

import QtQuick
import ".." as Lib// 5. Fuse with the BOTTOM border, expand UP. Medium, offset right.
Lib.Popout {
    id: root
    required property real screenWidth
    required property real screenHeight
    required property real leftThickness
    required property real rightThickness
    required property real verticalThickness

    edge: "bottom"
    expandedWidth: 280
    expandedHeight: 190
    openDuration: 440

    expandedX: (screenWidth - expandedWidth) * 0.66
    expandedY: screenHeight - verticalThickness - expandedHeight
    triggerZone: Qt.rect(expandedX, screenHeight - verticalThickness, expandedWidth, verticalThickness)
}
