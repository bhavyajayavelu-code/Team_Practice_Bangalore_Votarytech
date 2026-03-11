import QtQuick 2.15
import QtQuick.Controls 2.15
import QtBluetooth 5.15

Item {
    id: btPageRoot

    // PROPERTIES
    property var bluetoothModel
    signal backClicked()

    property bool isBtOn: false
    property bool isScanning: false

    Rectangle {
        anchors.fill: parent
        anchors.margins: 100
        radius: 30
        color: Qt.rgba(1,1,1,0.95)

        Column {
            anchors.fill: parent; anchors.margins: 60; spacing: 40

            // --- HEADER ---
            Item {
                width: parent.width; height: 100

                // Back Button
                // CHANGE: Replaced "←" with "<"
                Text {
                    text: "<"; font.pixelSize: 80; font.bold: true
                    anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                    MouseArea { anchors.fill: parent; onClicked: btPageRoot.backClicked() }
                }

                // Title
                Text { text: "Bluetooth"; font.pixelSize: 60; font.bold: true; anchors.centerIn: parent }

                // Toggle Switch
                Rectangle {
                    width: 140; height: 70; radius: 35
                    color: btPageRoot.isBtOn ? "#0072ff" : "#ccc"
                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        width: 60; height: 60; radius: 30; color: "white"
                        x: btPageRoot.isBtOn ? 75 : 5; y: 5
                        Behavior on x { NumberAnimation { duration: 200 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            btPageRoot.isBtOn = !btPageRoot.isBtOn

                            if (btPageRoot.isBtOn) {
                                // --- FORCE POP-UP LOGIC ---
                                console.log("Requesting Bluetooth Enable...")

                                // METHOD 1: The Standard "Turn On" Request
                                // This is the most reliable way to get the pop-up on Android 10
                                Qt.openUrlExternally("intent:#Intent;action=android.bluetooth.adapter.action.REQUEST_ENABLE;end")

                                // METHOD 2: Also try "Make Visible" (Chained)
                                // We call this after a small delay to ensure the first pop-up handles the "ON" part
                                popupTimer.start()

                                // Start Scan UI
                                btPageRoot.isScanning = true
                                if(bluetoothModel) bluetoothModel.running = true
                                scanTimer.restart()

                            } else {
                                console.log("Stopping Scan...")
                                btPageRoot.isScanning = false
                                if(bluetoothModel) bluetoothModel.running = false
                            }
                        }
                    }
                }
            }

            Rectangle { width: parent.width; height: 2; color: "#aaa" }

            // --- STATUS TEXT ---
            Item {
                width: parent.width; height: 50
                Text { visible: !btPageRoot.isBtOn; text: "Bluetooth is OFF"; font.pixelSize: 40; color: "#888"; anchors.centerIn: parent }
                Text { visible: btPageRoot.isBtOn && btPageRoot.isScanning; text: "Scanning..."; font.pixelSize: 40; color: "#0072ff"; anchors.centerIn: parent }
            }

            // --- DEVICE LIST ---
            ListView {
                visible: btPageRoot.isBtOn
                width: parent.width; height: 400
                clip: true
                model: bluetoothModel
                spacing: 20

                delegate: Rectangle {
                    width: parent.width; height: 100
                    color: "#eee"; radius: 10
                    Row {
                        x: 20; anchors.verticalCenter: parent.verticalCenter; spacing: 30
                        Text { text: "📱"; font.pixelSize: 40 }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Text { text: (model.name && model.name !== "") ? model.name : "Unknown Device"; font.bold: true; font.pixelSize: 36; color: "#333" }
                            Text { text: model.address ? model.address : ""; font.pixelSize: 24; color: "#666" }
                        }
                    }
                }
            }
        }
    }

    // Timer to trigger the second intent (Make Visible)
    Timer {
        id: popupTimer
        interval: 1000 // Wait 1 second after asking to Turn ON
        onTriggered: {
             console.log("Requesting Discoverable Mode...")
             Qt.openUrlExternally("intent:#Intent;action=android.bluetooth.adapter.action.REQUEST_DISCOVERABLE;i.android.bluetooth.adapter.extra.DISCOVERABLE_DURATION=300;end")
        }
    }

    // Auto-stop scanning
    Timer {
        id: scanTimer; interval: 15000
        onTriggered: { btPageRoot.isScanning = false; if(bluetoothModel) bluetoothModel.running = false }
    }
}
