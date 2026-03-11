import QtQuick 2.9
import QtQuick.Window 2.2
import QtMultimedia 5.9

Rectangle {
    id: gearIndicator
    width: 200
    height: 50
    color: "transparent"

    // Current active gear
    property string currentGear: "P"

    Row {
        anchors.centerIn: parent
        spacing: 20

        Repeater {
            model: ["P", "R", "N", "D"]

            Text {
                text: modelData
                font.pixelSize: 28
                font.bold: true
                color: gearIndicator.currentGear === modelData ? "#00FF00" : "#AAAAAA"
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }
    }
}
