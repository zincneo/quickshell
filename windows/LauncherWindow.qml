pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../themes" as Themes

PanelWindow {
    id: root

    readonly property var palette: Themes.ThemeManager.current
    readonly property string font: "Maple Mono NF CN"
    readonly property int rowHeight: 24
    readonly property int maxRows: 12
    readonly property int fontSize: 14
    readonly property int searchHeight: 30

    property bool open: false
    property int selectedIndex: 0

    readonly property var results: {
        const q = search.text.trim().toLowerCase();
        return DesktopEntries.applications.values
            .filter(e => !e.noDisplay && e.name && (q === "" || (e.name + " " + e.genericName + " " + e.keywords).toLowerCase().includes(q)))
            .sort((a, b) => a.name.localeCompare(b.name));
    }

    function show(): void {
        search.text = "";
        selectedIndex = 0;
        list.positionViewAtBeginning();
        open = true;
        search.forceActiveFocus();
    }

    function hide(): void {
        open = false;
    }

    function toggle(): void {
        open ? hide() : show();
    }

    function launch(index: int): void {
        const entry = results[index];
        if (entry) {
            entry.execute();
            hide();
        }
    }

    function moveSelection(step: int): void {
        if (results.length === 0)
            return;
        selectedIndex = (selectedIndex + step + results.length) % results.length;
        list.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    visible: open
    color: "transparent"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.toggle();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            onClicked: root.hide()
        }
    }

    Rectangle {
        id: card

        anchors.centerIn: parent
        width: 600
        height: 8 + root.searchHeight + 4 + root.maxRows * root.rowHeight + 12
        radius: 12
        color: root.palette.base
        border.width: 2
        border.color: root.palette.lavender

        ColumnLayout {
            id: column

            anchors.fill: parent
            anchors.topMargin: 8
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.bottomMargin: 12
            spacing: 4

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.searchHeight
                color: "transparent"

                Text {
                    id: prompt

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    text: "drun:"
                    color: root.palette.text
                    font.family: root.font
                    font.pixelSize: root.fontSize
                }

                TextInput {
                    id: search

                    anchors.fill: parent
                    anchors.leftMargin: prompt.width + 16
                    anchors.rightMargin: 60
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.palette.text
                    selectionColor: root.palette.lavender
                    selectedTextColor: root.palette.crust
                    font.family: root.font
                    font.pixelSize: root.fontSize
                    focus: root.open
                    clip: true

                    onTextChanged: root.selectedIndex = 0

                    Keys.onEscapePressed: root.hide()
                    Keys.onReturnPressed: root.launch(root.selectedIndex)
                    Keys.onEnterPressed: root.launch(root.selectedIndex)
                    Keys.onDownPressed: root.moveSelection(1)
                    Keys.onUpPressed: root.moveSelection(-1)
                    Keys.onTabPressed: root.moveSelection(1)
                    Keys.onBacktabPressed: root.moveSelection(-1)
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: prompt.right
                    anchors.leftMargin: 8
                    visible: search.text.length === 0
                    text: "Type to filter"
                    color: root.palette.overlay1
                    font.family: root.font
                    font.pixelSize: root.fontSize
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    text: root.results.length + "/" + DesktopEntries.applications.values.length
                    color: root.palette.overlay1
                    font.family: root.font
                    font.pixelSize: root.fontSize
                }

                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 2
                    spacing: 4
                    clip: true

                    Repeater {
                        model: Math.ceil(parent.width / 8)

                        Rectangle {
                            width: 4
                            height: 2
                            color: root.palette.text
                        }
                    }
                }
            }

            ListView {
                id: list

                Layout.fillWidth: true
                Layout.preferredHeight: root.maxRows * root.rowHeight
                Layout.leftMargin: 0
                clip: true
                interactive: false
                model: root.results
                currentIndex: root.selectedIndex

                ScrollBar.vertical: ScrollBar {
                    policy: list.contentHeight > list.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                    background: null
                    contentItem: Rectangle {
                        implicitWidth: 4
                        radius: 2
                        color: root.palette.lavender
                    }
                }
                delegate: Rectangle {
                    id: row

                    required property var modelData
                    required property int index

                    width: list.width - 8
                    height: root.rowHeight
                    radius: 0
                    color: index === root.selectedIndex ? root.palette.lavender : (index % 2 === 1 ? root.palette.mantle : "transparent")

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Text {
                            text: row.modelData.name
                            elide: Text.ElideRight
                            color: row.index === root.selectedIndex ? root.palette.base : root.palette.text
                            font.family: root.font
                            font.pixelSize: root.fontSize
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: text.length > 0
                            text: row.modelData.genericName ?? ""
                            elide: Text.ElideRight
                            font.italic: true
                            color: row.index === root.selectedIndex ? root.palette.base : root.palette.overlay1
                            font.family: root.font
                            font.pixelSize: root.fontSize
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: root.selectedIndex = row.index
                        onClicked: root.launch(row.index)
                    }
                }
            }
        }
    }
}
