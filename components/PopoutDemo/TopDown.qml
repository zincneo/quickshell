pragma ComponentBehavior: Bound

import QtQuick
import ".." as Lib// 1. Fuse with the TOP border, expand DOWN. Wide/short, offset left, fast.
Lib.Popout {
    id: root
    required property real screenWidth
    required property real screenHeight
    required property real leftThickness
    required property real rightThickness
    required property real verticalThickness

    edge: "top"
    expandedWidth: 360
    expandedHeight: 140
    openDuration: 600

    expandedX: leftThickness + 140
    expandedY: verticalThickness
    triggerZone: Qt.rect(expandedX, 0, expandedWidth, verticalThickness)
}
