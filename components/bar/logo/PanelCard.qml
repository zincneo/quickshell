pragma ComponentBehavior: Bound

import QtQuick

// Rounded surface shared by every card in the logo panel.
Rectangle {
    required property var palette

    radius: 20
    color: palette.surface0
}
