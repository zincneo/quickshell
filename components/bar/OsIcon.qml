import QtQuick
import ".." as C

// Use the same clickable avatar as the dashboard, sized for the bar.
C.AvatarLogo {
    id: root

    required property var palette
    size: 28
}
