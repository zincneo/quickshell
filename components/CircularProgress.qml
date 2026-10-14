import QtQuick
import QtQuick.Shapes

// Simple circular progress ring with a center content slot.
Item {
    id: root

    property real value: 0
    property color fgColour: "white"
    property color bgColour: "#40ffffff"
    property real strokeWidth: 6

    default property alias content: holder.data

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.bgColour
            strokeWidth: root.strokeWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: (root.width - root.strokeWidth) / 2
                radiusY: (root.height - root.strokeWidth) / 2
                startAngle: -90
                sweepAngle: 360
            }
        }
        ShapePath {
            strokeColor: root.fgColour
            strokeWidth: root.strokeWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: (root.width - root.strokeWidth) / 2
                radiusY: (root.height - root.strokeWidth) / 2
                startAngle: -90
                sweepAngle: 360 * Math.max(0, Math.min(1, root.value))
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
