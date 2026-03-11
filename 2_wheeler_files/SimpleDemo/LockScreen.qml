import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0

Item {
    id: lockRoot
    signal unlocked()

    // 0=Create, 1=Confirm, 2=Locked
    property int mode: settings.savedPin === "" ? 0 : 2
    property string currentInput: ""
    property string firstPinInput: ""
    property int attemptsLeft: 5
    property bool isLockedOut: false

    Settings {
        id: settings
        property string savedPin: ""
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        z: 99999 // Always on top

        Gradient {
            GradientStop { position: 0.0; color: "#1a1a1a" }
            GradientStop { position: 1.0; color: "#000000" }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 80

            // --- HEADER TEXT ---
            Column {
                Layout.alignment: Qt.AlignHCenter
                spacing: 30
                Text {
                    text: isLockedOut ? "SYSTEM DISABLED" : (mode === 0 ? "Create Passcode" : (mode === 1 ? "Confirm Passcode" : "Enter Passcode"))
                    color: isLockedOut ? "#ff4444" : "white"
                    font.pixelSize: 100
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: isLockedOut ? "Try again in " + lockoutTimer.secondsRemaining + "s" : (mode < 2 ? "Set your secure PIN" : (attemptsLeft < 5 ? attemptsLeft + " attempts remaining" : "Please unlock system"))
                    color: (attemptsLeft < 3 || isLockedOut) ? "#ff4444" : "#888"
                    font.pixelSize: 40
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            // --- PIN DOTS ---
            Row {
                Layout.alignment: Qt.AlignHCenter; spacing: 40
                Repeater {
                    model: 4
                    Rectangle {
                        width: 40; height: 40; radius: 20
                        color: index < currentInput.length ? "#0072ff" : "transparent"
                        border.color: "white"; border.width: 4
                    }
                }
            }

            // --- KEYPAD ---
            GridLayout {
                id: keypad
                columns: 3; rowSpacing: 40; columnSpacing: 60
                enabled: !isLockedOut; opacity: isLockedOut ? 0.3 : 1.0

                Repeater {
                    model: ["1","2","3","4","5","6","7","8","9","","0","<"]
                    delegate: Item {
                        width: 250; height: 150
                        visible: modelData !== ""

                        Rectangle {
                            anchors.fill: parent; radius: 75
                            color: mouseArea.pressed ? "#333" : "transparent"
                            border.color: "#444"; border.width: 3
                            visible: modelData !== "" && modelData !== "<"

                            Text { text: modelData; color: "white"; font.pixelSize: 80; font.bold: true; anchors.centerIn: parent }
                        }

                        // Backspace Button
                        Text { visible: modelData === "<"; text: "<"; color: "white"; font.pixelSize: 100; font.bold: true; anchors.centerIn: parent }

                        MouseArea { id: mouseArea; anchors.fill: parent; onClicked: handleInput(modelData) }
                    }
                }
            }
        }
    }

    function handleInput(key) {
        if (key === "<") {
            if (currentInput.length > 0) currentInput = currentInput.substring(0, currentInput.length - 1)
        }
        else if (currentInput.length < 4) {
            currentInput += key; if (currentInput.length === 4) processPin()
        }
    }

    function processPin() {
        if (mode === 0) { firstPinInput = currentInput; currentInput = ""; mode = 1 }
        else if (mode === 1) {
            if (currentInput === firstPinInput) { settings.savedPin = currentInput; currentInput = ""; mode = 2 }
            else { currentInput = ""; firstPinInput = ""; mode = 0; shakeAnim.start() }
        }
        else if (mode === 2) {
            if (currentInput === settings.savedPin) { attemptsLeft = 5; currentInput = ""; lockRoot.unlocked() }
            else { attemptsLeft--; currentInput = ""; shakeAnim.start(); if (attemptsLeft <= 0) startLockout() }
        }
    }

    function startLockout() { isLockedOut = true; lockoutTimer.secondsRemaining = 30; lockoutTimer.start() }

    // --- NEW FUNCTION: RESET PASSWORD ---
    function resetPassword() {
        settings.savedPin = ""  // Clear saved PIN
        mode = 0                // Go to Create Mode
        currentInput = ""
        firstPinInput = ""
        attemptsLeft = 5
        isLockedOut = false
    }

    SequentialAnimation {
        id: shakeAnim
        NumberAnimation { target: keypad; property: "x"; to: keypad.x - 10; duration: 50 }
        NumberAnimation { target: keypad; property: "x"; to: keypad.x + 20; duration: 100 }
        NumberAnimation { target: keypad; property: "x"; to: keypad.x - 20; duration: 100 }
        NumberAnimation { target: keypad; property: "x"; to: keypad.x + 10; duration: 50 }
    }

    Timer {
        id: lockoutTimer
        interval: 1000; repeat: true; property int secondsRemaining: 30
        onTriggered: { secondsRemaining--; if (secondsRemaining <= 0) { stop(); isLockedOut = false; attemptsLeft = 5 } }
    }
}
