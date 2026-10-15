pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import ".." as C

ColumnLayout {
    id: root
    required property var palette
    spacing: 12

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: item
            required property var modelData
            property bool quitMode: false

            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18

            QsMenuOpener {
                id: opener
                menu: item.modelData.menu
            }

            // Triggers the app's own quit entry from its DBus menu, since the tray item exposes no PID.
            function quit(): void {
                const entry = opener.children.values.find(e => e.enabled && /quit|exit|退出|关闭/i.test(e.text));
                if (entry)
                    entry.triggered();
            }

            Image {
                anchors.fill: parent
                visible: !item.quitMode
                source: item.modelData.icon
                sourceSize.width: 36
                sourceSize.height: 36
                fillMode: Image.PreserveAspectFit
            }

            C.MaterialIcon {
                visible: item.quitMode
                width: 20
                height: 20
                x: Math.round((item.width - width) / 2)
                y: Math.round((item.height - height) / 2)
                text: "delete"
                size: 20
                color: root.palette.red
                renderType: Text.NativeRendering
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        item.quitMode = !item.quitMode;
                    } else if (item.quitMode) {
                        item.quit();
                        item.quitMode = false;
                    } else {
                        item.modelData.activate();
                    }
                }
            }
        }
    }
}
