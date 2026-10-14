pragma ComponentBehavior: Bound

import QtQuick
import ".." as Lib// 7. Fuse with the RIGHT border, expand LEFT. Tall/narrow, offset down.
Lib.Popout {
    id: root
    required property real screenWidth
    required property real screenHeight
    required property real leftThickness
    required property real rightThickness
    required property real verticalThickness

    edge: "right"
    expandedWidth: 210
    expandedHeight: 330
    openDuration: 600

    expandedX: screenWidth - rightThickness - expandedWidth
    expandedY: screenHeight - verticalThickness - expandedHeight - 70
    triggerZone: Qt.rect(screenWidth - rightThickness, expandedY, rightThickness, expandedHeight)
}
