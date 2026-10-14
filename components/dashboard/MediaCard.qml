pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import ".." as C

Item {
    id: root
    required property var palette
    readonly property string font: "Rubik"

    readonly property MprisPlayer player: {
        const ps = Mpris.players.values;
        return ps.find(p => p.playbackState === MprisPlaybackState.Playing) ?? ps[0] ?? null;
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.min(parent.width - 16, 148)
            Layout.preferredHeight: Layout.preferredWidth
            radius: width / 2
            color: root.palette.surface1
            clip: true

            Image {
                id: art
                anchors.fill: parent
                source: root.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: status === Image.Ready
            }
            C.MaterialIcon {
                anchors.centerIn: parent
                visible: art.status !== Image.Ready
                text: "music_note"
                size: 46
                color: root.palette.subtext0
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.topMargin: 4
            horizontalAlignment: Text.AlignHCenter
            text: root.player?.trackTitle || "No media"
            color: root.palette.mauve
            font.family: root.font
            font.pixelSize: 15
            font.weight: Font.Medium
            elide: Text.ElideRight
        }
        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: root.player?.trackAlbum || ""
            color: root.palette.subtext0
            font.family: root.font
            font.pixelSize: 12
            elide: Text.ElideRight
            visible: text.length > 0
        }
        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: root.player?.trackArtist || ""
            color: root.palette.lavender
            font.family: root.font
            font.pixelSize: 12
            elide: Text.ElideRight
            visible: text.length > 0
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 6
            spacing: 12

            Ctl {
                palette: root.palette
                icon: "skip_previous"
                active: root.player?.canGoPrevious ?? false
                onTriggered: root.player?.previous()
            }
            Ctl {
                palette: root.palette
                icon: (root.player?.playbackState === MprisPlaybackState.Playing) ? "pause" : "play_arrow"
                primary: true
                active: root.player?.canTogglePlaying ?? false
                onTriggered: root.player?.togglePlaying()
            }
            Ctl {
                palette: root.palette
                icon: "skip_next"
                active: root.player?.canGoNext ?? false
                onTriggered: root.player?.next()
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    component Ctl: Rectangle {
        required property var palette
        required property string icon
        property bool primary: false
        property bool active: true
        signal triggered

        implicitWidth: primary ? 46 : 38
        implicitHeight: primary ? 46 : 38
        radius: width / 2
        color: primary ? palette.mauve : (ctlMouse.containsMouse ? palette.surface1 : "transparent")
        opacity: active ? 1 : 0.4

        C.MaterialIcon {
            anchors.centerIn: parent
            text: parent.icon
            size: parent.primary ? 24 : 20
            color: parent.primary ? palette.base : palette.text
            filled: true
        }

        MouseArea {
            id: ctlMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.triggered()
        }
    }
}
