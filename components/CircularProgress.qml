import QtQuick
import QtQuick.Shapes

// Simple circular progress ring with a center content slot.
Item {
    id: root

    property real value: 0
    property color fgColour: "white"
    property color bgColour: "#40ffffff"
    property real strokeWidth: 6
    property real startAngle: -90
    property real sweepAngle: 360
    property real spacing: 0
    readonly property real clampedValue: Math.max(0, Math.min(1, isNaN(value) ? 0 : value))
    readonly property real size: Math.min(width, height)
    readonly property real arcRadius: Math.max(0, (size - strokeWidth) / 2)
    readonly property real gapAngle: spacing > 0 ? (spacing + strokeWidth) / Math.max(1, arcRadius) * 180 / Math.PI : 0
    readonly property real remainingAngle: Math.max(0, sweepAngle * (1 - clampedValue) - gapAngle)

    default property alias content: holder.data

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.remainingAngle > 0 ? root.bgColour : "transparent"
            strokeWidth: root.remainingAngle > 0 ? root.strokeWidth : 0
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.arcRadius
                radiusY: root.arcRadius
                startAngle: root.startAngle + root.clampedValue * root.sweepAngle + root.gapAngle
                sweepAngle: root.remainingAngle
            }
        }
        ShapePath {
            strokeColor: root.clampedValue > 0 ? root.fgColour : "transparent"
            strokeWidth: root.clampedValue > 0 ? root.strokeWidth : 0
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.arcRadius
                radiusY: root.arcRadius
                startAngle: root.startAngle
                sweepAngle: root.sweepAngle * root.clampedValue
            }
        }
    }

    Item {
        id: holder
        anchors.fill: parent
    }

    Behavior on value {
        NumberAnimation {
            duration: 500
            easing.type: Easing.OutCubic
        }
    }
}
