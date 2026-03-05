
import QtQuick 2.9



Item {
    width: parent.width
    height: 50

    Text {
        text: "←"
        color: "green"
        font.pixelSize: 30
        anchors.left: parent.left
        anchors.leftMargin: 40
    }

    Text {
        text: "ABS"
        color: "yellow"
        font.pixelSize: 20
        anchors.right: parent.right
        anchors.rightMargin: 40
    }
}
