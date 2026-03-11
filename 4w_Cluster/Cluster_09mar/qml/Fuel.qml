
import QtQuick 2.9

Rectangle {
    width: 300
    height: 18
    radius: 9
    color: "#333"
    property real level: 0.5

    Rectangle {
        width: parent.width * level
        height: parent.height
        radius: 9
        color: level < 0.2 ? "red" : "green"
    }
}
