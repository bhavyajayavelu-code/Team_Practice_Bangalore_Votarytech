import QtQuick 2.9

Item {
    id: root
    width: 36
    height: 36

    // INPUTS
    property bool active: false
    property bool blink: true
    property string source: ""

    // BLINK TIMER (SDK SAFE)
    Timer {
        interval: 400
        running: root.active && root.blink
        repeat: true
        onTriggered: icon.opacity = (icon.opacity === 1 ? 0.3 : 1)
    }

    // FAKE GLOW (duplicate icon behind)
    Image {
        anchors.centerIn: parent
        source: root.source
        width: parent.width + 8
        height: parent.height + 8
        opacity: root.active ? 0.35 : 0
        visible: root.active
        smooth: true
    }

    // MAIN ICON
    Image {
        id: icon
        anchors.centerIn: parent
        source: root.source
        width: parent.width
        height: parent.height
        opacity: root.active ? 1 : 0.4
        smooth: true

        // Pulse effect
        SequentialAnimation on scale {
            running: root.active
            loops: Animation.Infinite
            NumberAnimation { to: 1.15; duration: 300 }
            NumberAnimation { to: 1.0; duration: 300 }
        }
    }
}
