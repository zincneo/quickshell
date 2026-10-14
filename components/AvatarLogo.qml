import QtQuick

Item {
    id: root

    property int logoIndex: 0
    property real size: 32

    implicitWidth: size
    implicitHeight: size

    Image {
        anchors.fill: parent
        source: "../assets/logo/catppuccin" + root.logoIndex + ".png"
        sourceSize.width: Math.ceil(width * 2)
        sourceSize.height: Math.ceil(height * 2)
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.logoIndex = 1 - root.logoIndex
    }
}
