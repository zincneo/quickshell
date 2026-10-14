pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".." as C
import "../../services" as Svc

Item {
    id: root
    required property var palette
    required property Item pickerLayer
    property real windowX: 0
    property real windowY: 0
    property bool active: false
    property int selectedPicker: -1
    readonly property bool outputPicker: selectedPicker === 0
    readonly property var devices: outputPicker ? Svc.Audio.sinks : Svc.Audio.sources
    readonly property var currentDevice: outputPicker ? Svc.Audio.sink : Svc.Audio.source
    readonly property real pickerAnchor: (outputPicker ? outputControl.y : microphoneControl.y) + controls.y
    readonly property bool pickerHovered: pickerHover.hovered
    readonly property rect pickerRect: picker.visible ? Qt.rect(picker.x, picker.y, picker.width, picker.height) : Qt.rect(0, 0, 0, 0)

    onActiveChanged: {
        if (!active)
            selectedPicker = -1;
    }

    function togglePicker(index: int): void {
        selectedPicker = selectedPicker === index ? -1 : index;
    }

    ColumnLayout {
        id: controls
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        spacing: 16

        VolumeControl {
            id: outputControl
            label: "Volume"
            icon: Svc.Audio.muted || Svc.Audio.volume <= 0 ? "volume_off" : "volume_up"
            value: Svc.Audio.volume
            muted: Svc.Audio.muted || Svc.Audio.volume <= 0
            available: !!Svc.Audio.sink?.audio
            selector: 0
            onValueAdjusted: value => Svc.Audio.setVolume(value)
            onMuteRequested: Svc.Audio.toggleMute()
        }

        VolumeControl {
            id: microphoneControl
            label: "Microphone"
            icon: Svc.Audio.sourceMuted || Svc.Audio.sourceVolume <= 0 ? "mic_off" : "mic"
            value: Svc.Audio.sourceVolume
            muted: Svc.Audio.sourceMuted || Svc.Audio.sourceVolume <= 0
            available: !!Svc.Audio.source?.audio
            selector: 1
            onValueAdjusted: value => Svc.Audio.setSourceVolume(value)
            onMuteRequested: Svc.Audio.toggleSourceMute()
        }

        VolumeControl {
            label: "Brightness"
            icon: "brightness_6"
            value: Svc.Brightness.brightness
            minimum: 0.01
            available: Svc.Brightness.available
            onValueAdjusted: value => Svc.Brightness.setBrightness(value)
        }

        Text {
            Layout.fillWidth: true
            visible: Svc.Brightness.error !== ""
            text: Svc.Brightness.error
            font.family: "Rubik"
            font.pixelSize: 12
            color: root.palette.red
            wrapMode: Text.WordWrap
        }
    }

    // Draw above the compact panel without clipping; its input region and
    // hover state are included in the parent panel by StatusMenu/FrameWindow.
    Rectangle {
        id: picker
        parent: root.pickerLayer
        z: 10
        visible: root.active && root.selectedPicker >= 0
        width: Math.min(480, root.pickerLayer.width - root.windowX - 12)
        height: Math.min(240, root.windowY + root.pickerAnchor - 20, 58 + Math.max(1, root.devices.length) * 38)
        x: root.windowX
        y: Math.max(12, root.windowY + root.pickerAnchor - height - 8)
        radius: 16
        color: root.palette.base
        border.width: 3
        border.color: root.palette.lavender

        HoverHandler {
            id: pickerHover
            blocking: false
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onWheel: wheel => wheel.accepted = true
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Text {
                Layout.fillWidth: true
                text: root.outputPicker ? "Output device" : "Input device"
                font.family: "Rubik"
                font.pixelSize: 14
                font.weight: Font.Medium
                color: root.palette.text
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Text {
                    anchors.centerIn: parent
                    visible: root.devices.length === 0
                    text: "No devices available"
                    font.family: "Rubik"
                    font.pixelSize: 13
                    color: root.palette.subtext0
                }

                ListView {
                    id: deviceList
                    anchors.fill: parent
                    clip: true
                    model: root.devices
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    ButtonGroup { id: deviceGroup }

                    delegate: RadioButton {
                        id: device
                        required property var modelData
                        width: ListView.view.width
                        height: 38
                        ButtonGroup.group: deviceGroup
                        checked: root.currentDevice?.id === modelData.id
                        text: modelData.description || modelData.name || "Audio device"
                        onClicked: {
                            if (root.outputPicker)
                                Svc.Audio.selectSink(modelData);
                            else
                                Svc.Audio.selectSource(modelData);
                        }

                        indicator: C.MaterialIcon {
                            x: 4
                            y: (device.height - height) / 2
                            text: device.checked ? "radio_button_checked" : "radio_button_unchecked"
                            size: 20
                            color: device.checked ? root.palette.mauve : root.palette.subtext0
                        }
                        contentItem: Text {
                            leftPadding: 32
                            rightPadding: 6
                            text: device.text
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            font.family: "Rubik"
                            font.pixelSize: 13
                            color: device.checked ? root.palette.mauve : root.palette.text
                        }
                        background: Rectangle {
                            radius: 10
                            color: device.hovered ? root.palette.surface1 : "transparent"
                        }
                    }
                }
            }
        }
    }

    component VolumeControl: ColumnLayout {
        id: control
        required property string label
        required property string icon
        required property real value
        property real minimum: 0
        property bool available: true
        property bool muted: false
        property int selector: -1
        signal valueAdjusted(real value)
        signal muteRequested()

        Layout.fillWidth: true
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: control.label
                font.family: "Rubik"
                font.pixelSize: 14
                color: root.palette.text
            }
            Text {
                text: control.available ? Math.round(control.value * 100) + "%" : "Unavailable"
                font.family: "Rubik"
                font.pixelSize: 13
                color: root.palette.subtext0
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Slider {
                id: slider
                Layout.fillWidth: true
                implicitHeight: 36
                from: control.minimum
                to: 1
                value: control.value
                enabled: control.available
                opacity: enabled ? 1 : 0.5
                onMoved: control.valueAdjusted(value)

                background: Rectangle {
                    x: slider.leftPadding
                    y: (slider.height - height) / 2
                    width: slider.availableWidth
                    height: 6
                    radius: 3
                    color: root.palette.surface1
                    Rectangle {
                        width: parent.width * slider.visualPosition
                        height: parent.height
                        radius: parent.radius
                        color: root.palette.mauve
                    }
                }
                handle: Rectangle {
                    x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                    y: (slider.height - height) / 2
                    width: 16
                    height: 16
                    radius: 8
                    color: root.palette.mauve
                }
            }

            Item {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 36
                C.MaterialIcon {
                    anchors.centerIn: parent
                    text: control.icon
                    size: 24
                    weight: 700
                    color: control.muted ? root.palette.overlay1 : root.palette.mauve
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: control.available && control.selector >= 0
                    cursorShape: Qt.PointingHandCursor
                    onClicked: control.muteRequested()
                }
            }

            Item {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 36
                C.MaterialIcon {
                    anchors.centerIn: parent
                    visible: control.selector >= 0
                    text: "chevron_right"
                    rotation: root.selectedPicker === control.selector ? -90 : 0
                    size: 24
                    weight: 700
                    color: root.selectedPicker === control.selector ? root.palette.mauve : root.palette.subtext0
                    Behavior on rotation { NumberAnimation { duration: 150 } }
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: control.selector >= 0
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.togglePicker(control.selector)
                }
            }
        }
    }
}
