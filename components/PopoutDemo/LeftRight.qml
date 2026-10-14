pragma ComponentBehavior: Bound

import QtQuick
import ".." as Lib// 3. Fuse with the LEFT border, expand RIGHT. Tall/narrow, offset up.
Lib.Popout {
    id: root
    required property real screenWidth
    required property real screenHeight
    required property real leftThickness
    required property real rightThickness
    required property real verticalThickness

    edge: "left"
    expandedWidth: 200
    expandedHeight: 300
    openDuration: 300

    expandedX: leftThickness
    expandedY: verticalThickness + 90
    triggerZone: Qt.rect(0, expandedY, leftThickness, expandedHeight)
}
