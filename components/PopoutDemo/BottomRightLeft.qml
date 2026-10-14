pragma ComponentBehavior: Bound

import QtQuick
import ".." as Lib// 6. Fuse with the BOTTOM-RIGHT corner, expand LEFT. Small, fastest.
Lib.Popout {
    id: root
    required property real screenWidth
    required property real screenHeight
    required property real leftThickness
    required property real rightThickness
    required property real verticalThickness

    edge: "right"
    expandedWidth: 220
    expandedHeight: 170
    openDuration: 160

    expandedX: screenWidth - rightThickness - expandedWidth
    expandedY: screenHeight - verticalThickness - expandedHeight
    triggerZone: Qt.rect(screenWidth - rightThickness, expandedY, rightThickness, expandedHeight)
}
