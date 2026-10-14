pragma ComponentBehavior: Bound

import QtQuick
import ".." as Lib// 2. Fuse with the TOP-LEFT corner, expand RIGHT. Square, slow.
Lib.Popout {
    id: root
    required property real screenWidth
    required property real screenHeight
    required property real leftThickness
    required property real rightThickness
    required property real verticalThickness

    edge: "left"
    expandedWidth: 200
    expandedHeight: 200
    openDuration: 600

    expandedX: leftThickness
    expandedY: verticalThickness
    triggerZone: Qt.rect(0, verticalThickness, leftThickness, expandedHeight)
}
