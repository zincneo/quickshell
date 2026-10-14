pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

ColumnLayout {
    id: root
    required property var palette
    spacing: 12

    Repeater {
        model: SystemTray.items

        delegate: Image {
            id: item
            required property var modelData
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
            source: modelData.icon
            sourceSize.width: 36
            sourceSize.height: 36
            fillMode: Image.PreserveAspectFit

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton)
                        item.modelData.secondaryActivate();
                    else
                        item.modelData.activate();
                }
            }
        }
    }
}
