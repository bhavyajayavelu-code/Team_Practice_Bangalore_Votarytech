import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import com.votary.wifi 1.0

Item {
    id: wifiPageRoot
    signal backClicked()
    property bool isWifiOn: false

    // Real C++ Manager
    WifiManager {
        id: wifiManager
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 100
        radius: 30
        color: Qt.rgba(1,1,1,0.95)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 60
            spacing: 20

            // --- HEADER ---
            RowLayout {
                Layout.fillWidth: true
                height: 100

                // Back Button
                Text {
                    text: "<"
                    font.pixelSize: 80
                    font.bold: true
                    color: "#333"
                    MouseArea { anchors.fill: parent; onClicked: wifiPageRoot.backClicked() }
                }

                Item { Layout.fillWidth: true } // Spacer

                Text {
                    text: "Wi-Fi Control"
                    font.pixelSize: 60
                    font.bold: true
                    color: "#333"
                }

                Item { Layout.fillWidth: true } // Spacer

                // Toggle Switch (Blue)
                Rectangle {
                    width: 140; height: 70; radius: 35
                    color: wifiPageRoot.isWifiOn ? "#0072ff" : "#ccc"

                    Rectangle {
                        width: 60; height: 60; radius: 30; color: "white"
                        x: wifiPageRoot.isWifiOn ? 75 : 5; y: 5
                        Behavior on x { NumberAnimation { duration: 200 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            wifiPageRoot.isWifiOn = !wifiPageRoot.isWifiOn
                            if (wifiPageRoot.isWifiOn) wifiManager.scanForNetworks()
                            else wifiManager.disconnect()
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 2; color: "#aaa" }

            // --- STATUS & OFF STATE ---
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Off State UI
                Column {
                    anchors.centerIn: parent
                    visible: !wifiPageRoot.isWifiOn
                    spacing: 20
                    Text { text: "📡"; font.pixelSize: 100; opacity: 0.3; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: "Wi-Fi is Off"; font.pixelSize: 40; color: "#aaa"; anchors.horizontalCenter: parent.horizontalCenter }
                }

                // On State UI
                ColumnLayout {
                    anchors.fill: parent
                    visible: wifiPageRoot.isWifiOn

                    Text {
                        text: wifiManager.connectionStatus
                        font.pixelSize: 30; color: "#0072ff"; font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: wifiManager.wifiModel
                        spacing: 20

                        delegate: Rectangle {
                            width: parent.width; height: 100
                            color: "#eee"; radius: 10

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    // Use C++ isSecured flag (Automatic Connect for Open Networks)
                                    if (model.isSecured) {
                                        passwordDialog.ssid = model.ssid
                                        passwordDialog.open()
                                    } else {
                                        console.log("Connecting to Open Network: " + model.ssid)
                                        wifiManager.connectToNetwork(model.ssid, "")
                                    }
                                }
                            }

                            RowLayout {
                                anchors.fill: parent; anchors.margins: 20; spacing: 30
                                Text { text: "📶"; font.pixelSize: 40 }
                                Column {
                                    Text { text: model.ssid; font.bold: true; font.pixelSize: 32; color: "#333" }
                                    Text {
                                        text: (model.isSecured ? "Secured" : "Open") + " • Signal: " + model.signalLevel + "/4"
                                        font.pixelSize: 22; color: "#666"
                                    }
                                }
                                Item { Layout.fillWidth: true }
                                Text { visible: model.isSecured; text: "🔒"; font.pixelSize: 30; color: "#555" }
                                Text { text: ">"; font.pixelSize: 40; color: "#0072ff"; font.bold: true }
                            }
                        }
                    }
                }
            }
        }
    }

    // --- CUSTOM PASSWORD DIALOG ---
    Dialog {
        id: passwordDialog
        property string ssid: ""
        title: "Connect to " + ssid
        modal: true

        // FIX: Position at TOP to avoid keyboard
        y: 50
        x: (parent.width - width) / 2
        width: 600

        background: Rectangle {
            color: "white"; radius: 15
            border.color: "#ccc"; border.width: 1
        }

        // FIX: Custom Buttons inside content to ensure visibility
        contentItem: ColumnLayout {
            spacing: 20
            Label { text: "Enter Password:"; font.pixelSize: 24; color: "black" }

            TextField {
                id: passwordField
                Layout.fillWidth: true
                placeholderText: "Password"
                echoMode: TextInput.Password
                font.pixelSize: 24
                color: "black"
                background: Rectangle {
                    color: "#fff"
                    border.color: parent.activeFocus ? "#0072ff" : "#ccc"
                    border.width: 2; radius: 5
                }
            }

            // Custom Buttons Row
            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                Button {
                    text: "Cancel"
                    Layout.preferredWidth: 120
                    onClicked: {
                        passwordDialog.close()
                        passwordField.text = ""
                        passwordField.focus = false
                    }
                }

                Item { Layout.fillWidth: true } // Spacer

                Button {
                    text: "Connect"
                    Layout.preferredWidth: 150
                    background: Rectangle { color: "#0072ff"; radius: 5 }
                    contentItem: Text {
                        text: "Connect"; color: "white"; font.bold: true
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        wifiManager.connectToNetwork(passwordDialog.ssid, passwordField.text)
                        passwordDialog.close()
                        passwordField.text = ""
                        passwordField.focus = false
                    }
                }
            }
        }

        // Disable standard buttons
        standardButtons: Dialog.NoButton
    }
}
