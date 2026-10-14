pragma ComponentBehavior: Bound

import QtQuick
import ".." as Lib// 4. Fuse with the LEFT-BOTTOM corner, expand RIGHT. Wide/short.
Lib.Popout {
    id: root
    required property real screenWidth
    required property real screenHeight
    required property real leftThickness
    required property real rightThickness
    required property real verticalThickness

    edge: "left"
    expandedWidth: 320
    expandedHeight: 150
    openDuration: 240

    expandedX: leftThickness
    expandedY: screenHeight - verticalThickness - expandedHeight
    triggerZone: Qt.rect(0, expandedY, leftThickness, expandedHeight)
}
