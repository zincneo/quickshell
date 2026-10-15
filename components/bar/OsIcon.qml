import QtQuick
import ".." as C
import "../../themes" as Themes

// Same avatar as the dashboard, sized for the bar; its image follows the theme.
C.AvatarLogo {
    id: root

    required property var palette
    size: 28
    logoIndex: Themes.ThemeManager.logoIndex
}
