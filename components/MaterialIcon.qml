import QtQuick

// A Material Symbols Rounded icon. `text` is the ligature name (e.g. "dashboard").
// Requires the `material-symbols` font.
Text {
    id: root

    property real size: 24
    property bool filled: false
    property real weight: 400

    font.family: "Material Symbols Rounded"
    font.pixelSize: size
    font.weight: root.weight
    font.variableAxes: ({
            FILL: filled ? 1 : 0,
            wght: root.weight,
            opsz: size
        })

    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
}
