import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtBluetooth 5.15

Window {
    id: root
    visible: true
    width: 2560
    height: 1440
    visibility: Window.FullScreen
    title: qsTr("Votary Ultimate Cluster 2K")
    color: "#000000"

    // --- 1. THEME VARIABLES ---
    property color bgStart: "#2bc0e4"       // Default Ocean
    property color bgEnd: "#eaecc6"
    property color sidebarColor: "#ffffff"
    property color iconColor: "#333333"
    property color activeIconColor: "#0072ff"
    property color textColor: "#000000"
    property string activeFont: "Helvetica"

    property string currentView: "splash"
    property int batteryPercent: 82
    property string currentTime: "12:00 PM"
    property string currentDate: "Jan 01"

    // BRIGHTNESS PROPERTY
    property real appBrightness: 1.0

    // GLOBAL BLUETOOTH STATE
    property bool bluetoothGlobalState: false

    // --- [REAL WORLD] BLUETOOTH SCANNER ---
    BluetoothDiscoveryModel {
        id: realBtModel
        running: false
        discoveryMode: BluetoothDiscoveryModel.DeviceDiscovery
        onErrorChanged: {
            if (error != BluetoothDiscoveryModel.NoError) {
                console.log("Bluetooth Error: " + error)
            }
        }
    }

    // --- 2. SCALER ---
    Item {
        id: scaler
        width: 2560
        height: 1440
        anchors.centerIn: parent

        // *** CRITICAL FIX FOR BLACK SCREEN ***
        property real scaleRatio: Math.min(root.width / width, root.height / height)
        scale: scaleRatio > 0 ? scaleRatio : 0.5

        layer.enabled: true
        layer.smooth: true

        // --- 3. SPLASH SCREEN ---
        Rectangle {
            id: splashScreen
            anchors.fill: parent
            color: "black"
            z: 9999
            visible: root.currentView === "splash"

            Column {
                anchors.centerIn: parent
                spacing: 20
                Text {
                    text: "Welcome to"
                    font.pixelSize: 80
                    color: "gray"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: "VOTARY"
                    font.pixelSize: 200
                    font.bold: true
                    color: "orange"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        // --- 4. MAIN CONTAINER ---
        Rectangle {
            id: clusterContainer
            anchors.fill: parent
            color: sidebarColor

            // Hide dashboard if Splash OR Lock screen is active
            visible: root.currentView !== "splash" && root.currentView !== "lock"

            Row {
                anchors.fill: parent

                // --- SIDEBAR ---
                Rectangle {
                    width: 350
                    height: parent.height
                    color: root.sidebarColor
                    z: 10

                    Column {
                        anchors.fill: parent
                        anchors.topMargin: 100
                        spacing: 20

                        // VEHICLE BUTTON
                        Item {
                            width: parent.width
                            height: 250
                            Rectangle {
                                anchors.fill: parent
                                color: root.currentView === "vehicle" ? Qt.rgba(0,0,0,0.05) : "transparent"
                            }
                            Column {
                                anchors.centerIn: parent
                                spacing: 15

                                // --- FIXED CANVAS ---
                                Canvas {
                                    id: vehicleIconCanvas
                                    width: 100
                                    height: 80
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    property string activeColor: root.currentView === "vehicle" ? root.activeIconColor : root.iconColor
                                    onActiveColorChanged: requestPaint()

                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.clearRect(0, 0, width, height);
                                        ctx.strokeStyle = activeColor;
                                        ctx.fillStyle = activeColor;
                                        ctx.lineWidth = 5;
                                        ctx.lineCap = "round"; ctx.lineJoin = "round";
                                        ctx.beginPath();
                                        // Wheels
                                        ctx.moveTo(35, 60); ctx.arc(25, 60, 10, 0, Math.PI * 2, true);
                                        ctx.moveTo(85, 60); ctx.arc(75, 60, 10, 0, Math.PI * 2, true);
                                        // Body
                                        ctx.moveTo(25, 60); ctx.lineTo(40, 40);
                                        ctx.lineTo(60, 40); ctx.lineTo(70, 25);
                                        // Handlebar
                                        ctx.moveTo(65, 25); ctx.lineTo(75, 25);
                                        // Fork
                                        ctx.moveTo(70, 25); ctx.lineTo(75, 60);
                                        ctx.stroke();
                                    }
                                }

                                Text {
                                    text: "VEHICLE"
                                    font.pixelSize: 24
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: root.currentView === "vehicle" ? root.activeIconColor : root.iconColor
                                }
                            }
                            MouseArea { anchors.fill: parent; onClicked: root.currentView = "vehicle" }
                        }

                        // --- [ADDED] MAPS/NAVIGATION BUTTON ---
                        Item {
                            width: parent.width
                            height: 250
                            Rectangle {
                                anchors.fill: parent
                                color: root.currentView === "maps" ? Qt.rgba(0,0,0,0.05) : "transparent"
                            }
                            Column {
                                anchors.centerIn: parent
                                spacing: 15
                                Text {
                                    text: "🌍"
                                    font.pixelSize: 80
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: root.currentView === "maps" ? root.activeIconColor : root.iconColor
                                }
                                Text {
                                    text: "NAVIGATION"
                                    font.pixelSize: 24
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: root.currentView === "maps" ? root.activeIconColor : root.iconColor
                                }
                            }
                            MouseArea { anchors.fill: parent; onClicked: root.currentView = "maps" }
                        }

                        // SETTINGS BUTTON
                        Item {
                            width: parent.width
                            height: 250
                            Rectangle {
                                anchors.fill: parent
                                color: (root.currentView === "settings" || root.currentView === "bluetooth" || root.currentView === "wifi") ? Qt.rgba(0,0,0,0.05) : "transparent"
                            }
                            Column {
                                anchors.centerIn: parent
                                spacing: 15
                                Text {
                                    text: "⚙️"
                                    font.pixelSize: 80
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: (root.currentView === "settings" || root.currentView === "bluetooth" || root.currentView === "wifi") ? root.activeIconColor : root.iconColor
                                }
                                Text {
                                    text: "SETTINGS"
                                    font.pixelSize: 24
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: (root.currentView === "settings" || root.currentView === "bluetooth" || root.currentView === "wifi") ? root.activeIconColor : root.iconColor
                                }
                            }
                            MouseArea { anchors.fill: parent; onClicked: root.currentView = "settings" }
                        }

                        // LOCK BUTTON
                        Item {
                            width: parent.width
                            height: 250
                            Column {
                                anchors.centerIn: parent
                                spacing: 15
                                Text {
                                    text: "🔒"
                                    font.pixelSize: 80
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: root.iconColor
                                }
                                Text {
                                    text: "LOCK"
                                    font.pixelSize: 24
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: root.iconColor
                                }
                            }
                            MouseArea { anchors.fill: parent; onClicked: root.currentView = "lock" }
                        }
                    }
                    Rectangle { width: 1; height: parent.height; color: "#ccc"; anchors.right: parent.right }
                }

                // --- RIGHT MAIN DISPLAY ---
                Rectangle {
                    id: mainDisplay
                    width: parent.width - 350
                    height: parent.height
                    clip: true

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: root.bgStart }
                        GradientStop { position: 1.0; color: root.bgEnd }
                    }

                    // ===============================================
                    //             VEHICLE DASHBOARD
                    // ===============================================
                    Item {
                        id: viewVehicle
                        anchors.fill: parent
                        visible: root.currentView === "vehicle"

                        // --- 1. TOP HEADER ---
                        Item {
                            width: parent.width - 100
                            height: 150
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter

                            Column {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: root.currentTime
                                    font.pixelSize: 48
                                    font.bold: true
                                    color: root.textColor
                                    font.family: root.activeFont
                                }
                                Text {
                                    text: root.currentDate
                                    font.pixelSize: 24
                                    color: root.textColor
                                    opacity: 0.7
                                    font.family: root.activeFont
                                }
                            }

                            // B. CENTER: Battery
                            Item {
                                width: 200
                                height: 80
                                anchors.centerIn: parent
                                Rectangle {
                                    width: 160
                                    height: 70
                                    anchors.centerIn: parent
                                    color: "transparent"
                                    border.color: root.textColor
                                    border.width: 4
                                    radius: 10
                                    Rectangle {
                                        x: 5; y: 5
                                        height: parent.height - 10
                                        width: (parent.width - 10) * (root.batteryPercent / 100)
                                        color: root.batteryPercent > 20 ? "#39ff14" : "red"
                                        radius: 6
                                    }
                                    Text {
                                        text: root.batteryPercent + "%"
                                        anchors.centerIn: parent
                                        color: (root.batteryPercent > 50) ? "black" : root.textColor
                                        font.bold: true
                                        font.pixelSize: 32
                                    }
                                }
                                Rectangle {
                                    width: 10; height: 30
                                    color: root.textColor
                                    anchors.left: parent.right
                                    anchors.leftMargin: -20
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            // C. RIGHT: Temp
                            Row {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 30
                                Text {
                                    text: "28°C"
                                    font.pixelSize: 48
                                    font.bold: true
                                    color: root.textColor
                                    font.family: root.activeFont
                                }
                            }
                        }

                        // --- 2. MIDDLE SECTION ---
                        Item {
                            id: speedoBox
                            width: 600; height: 500
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -30
                            Column {
                                anchors.centerIn: parent
                                spacing: -20
                                Text {
                                    id: speedText
                                    text: "0"
                                    font.pixelSize: 450
                                    font.bold: true
                                    color: root.textColor
                                    font.family: "Courier"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: "km/h"
                                    font.pixelSize: 50
                                    font.bold: true
                                    color: root.textColor
                                    opacity: 0.7
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }

                        Rectangle {
                            width: 400; height: 250
                            radius: 30
                            color: Qt.rgba(0,0,0, 0.2)
                            anchors.left: parent.left
                            anchors.leftMargin: 80
                            anchors.verticalCenter: parent.verticalCenter
                            Column {
                                anchors.centerIn: parent
                                spacing: 10
                                Text {
                                    text: "▲"
                                    rotation: 90
                                    font.pixelSize: 80
                                    color: root.activeIconColor
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text { text: "200 m"; font.pixelSize: 60; font.bold: true; color: root.textColor; anchors.horizontalCenter: parent.horizontalCenter }
                                Text { text: "Turn Right"; font.pixelSize: 32; color: root.textColor; anchors.horizontalCenter: parent.horizontalCenter }
                            }
                        }

                        // --- 3. BOTTOM BAR ---
                        Item {
                            width: parent.width - 200
                            height: 150
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 60
                            anchors.horizontalCenter: parent.horizontalCenter

                            Rectangle {
                                id: tripBox
                                width: 550; height: 110
                                radius: 55
                                color: Qt.rgba(1,1,1, 0.2)
                                anchors.centerIn: parent
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 50
                                    Column {
                                        Text { text: "TRIP"; font.pixelSize: 20; color: root.textColor; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                                        Text { text: "45.2"; font.pixelSize: 36; font.bold: true; color: root.textColor; font.family: "Courier" }
                                    }
                                    Rectangle { width: 2; height: 50; color: root.textColor }
                                    Column {
                                        Text { text: "ODO"; font.pixelSize: 20; color: root.textColor; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                                        Text { text: "12450"; font.pixelSize: 36; font.bold: true; color: root.textColor; font.family: "Courier" }
                                    }
                                }
                            }

                            Text {
                                text: "◄"
                                font.pixelSize: 140
                                color: leftBlinkTimer.running && leftBlinkTimer.on ? "#39ff14" : Qt.rgba(0,0,0,0.2)
                                anchors.right: tripBox.left; anchors.rightMargin: 100
                                anchors.verticalCenter: parent.verticalCenter
                                MouseArea { anchors.fill: parent; onClicked: toggleLeft() }
                            }
                            Text {
                                text: "►"
                                font.pixelSize: 140
                                color: rightBlinkTimer.running && rightBlinkTimer.on ? "#39ff14" : Qt.rgba(0,0,0,0.2)
                                anchors.left: tripBox.right; anchors.leftMargin: 100
                                anchors.verticalCenter: parent.verticalCenter
                                MouseArea { anchors.fill: parent; onClicked: toggleRight() }
                            }
                        }

                        // --- 4. BLUETOOTH INDICATOR ---
                        Item {
                            anchors.right: parent.right; anchors.bottom: parent.bottom
                            anchors.rightMargin: 80; anchors.bottomMargin: 80
                            width: 120; height: 120
                            visible: root.bluetoothGlobalState || realBtModel.running
                            Rectangle { anchors.fill: parent; radius: 60; color: "#0072ff" }
                            Canvas {
                                anchors.fill: parent
                                onPaint: {
                                    var ctx = getContext("2d");
                                    var w = width; var h = height;
                                    ctx.strokeStyle = "white"; ctx.lineWidth = 7;
                                    ctx.lineCap = "round"; ctx.lineJoin = "round";
                                    ctx.beginPath();
                                    ctx.moveTo(w * 0.35, h * 0.28); ctx.lineTo(w * 0.65, h * 0.55);
                                    ctx.lineTo(w * 0.50, h * 0.72); ctx.lineTo(w * 0.50, h * 0.22);
                                    ctx.lineTo(w * 0.65, h * 0.38); ctx.lineTo(w * 0.35, h * 0.65);
                                    ctx.stroke();
                                }
                            }
                        }
                    }

                    // ===============================================
                    //             SETTINGS VIEW
                    // ===============================================
                    Item {
                        id: viewSettings
                        anchors.fill: parent
                        visible: root.currentView === "settings"

                        Rectangle {
                            anchors.fill: parent; anchors.margins: 100
                            radius: 30; color: Qt.rgba(1,1,1,0.9)

                            Column {
                                anchors.fill: parent; anchors.margins: 60
                                spacing: 40

                                Row {
                                    spacing: 30; anchors.left: parent.left
                                    Text {
                                        text: "<"; font.pixelSize: 80; font.bold: true
                                        anchors.verticalCenter: parent.verticalCenter
                                        MouseArea { anchors.fill: parent; onClicked: root.currentView = "vehicle" }
                                    }
                                    Text {
                                        text: "Settings"; font.pixelSize: 60; font.bold: true
                                        font.family: root.activeFont
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                Rectangle { width: parent.width; height: 2; color: "#aaa" }

                                Text { text: "Select Theme"; font.pixelSize: 32; color: "#555" }
                                Row {
                                    spacing: 30
                                    Rectangle {
                                        width: 250; height: 100; radius: 15; color: "#2bc0e4"
                                        Text { text: "Ocean"; color: "white"; anchors.centerIn: parent; font.pixelSize: 32; font.bold: true }
                                        MouseArea { anchors.fill: parent; onClicked: setTheme("ocean") }
                                    }
                                    Rectangle {
                                        width: 250; height: 100; radius: 15; color: "#333333"
                                        Text { text: "Dark"; color: "white"; anchors.centerIn: parent; font.pixelSize: 32; font.bold: true }
                                        MouseArea { anchors.fill: parent; onClicked: setTheme("dark") }
                                    }
                                    Rectangle {
                                        width: 250; height: 100; radius: 15; color: "#43a047"
                                        Text { text: "Eco"; color: "white"; anchors.centerIn: parent; font.pixelSize: 32; font.bold: true }
                                        MouseArea { anchors.fill: parent; onClicked: setTheme("eco") }
                                    }
                                }

                                // --- FIXED CUSTOM BRIGHTNESS SLIDER ---
                                Rectangle { width: parent.width; height: 2; color: "#aaa" }
                                Text { text: "Dashboard Brightness"; font.pixelSize: 32; color: "#555" }

                                Item {
                                    width: parent.width; height: 80

                                    // Track
                                    Rectangle {
                                        id: sliderTrack
                                        width: 600; height: 60; radius: 30; color: "#444"
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        clip: true

                                        // Fill
                                        Rectangle {
                                            id: sliderFill
                                            height: parent.height
                                            width: Math.max(60, parent.width * root.appBrightness)
                                            color: root.activeIconColor
                                            radius: 30

                                            // Icon
                                            Text {
                                                text: "☀"; font.pixelSize: 40; color: "white"
                                                anchors.left: parent.left; anchors.leftMargin: 20
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            onPositionChanged: {
                                                var val = mouseX / width;
                                                if (val < 0.1) val = 0.1;
                                                if (val > 1.0) val = 1.0;
                                                root.appBrightness = val;
                                            }
                                            onPressed: {
                                                var val = mouseX / width;
                                                if (val < 0.1) val = 0.1;
                                                if (val > 1.0) val = 1.0;
                                                root.appBrightness = val;
                                            }
                                        }
                                    }
                                    // Text
                                    Text {
                                        text: Math.round(root.appBrightness * 100) + "%"
                                        font.pixelSize: 32; font.bold: true; color: "#555"
                                        anchors.left: sliderTrack.right; anchors.leftMargin: 30
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                // --- BLUETOOTH LINK ---
                                Rectangle { width: parent.width; height: 2; color: "#aaa" }
                                Item {
                                    width: parent.width; height: 80
                                    MouseArea { anchors.fill: parent; onClicked: root.currentView = "bluetooth" }
                                    Row {
                                        anchors.fill: parent
                                        Text { width: parent.width - 100; text: "Bluetooth Settings"; font.pixelSize: 40; color: "#333"; anchors.verticalCenter: parent.verticalCenter }
                                        Text { width: 100; text: ">"; font.pixelSize: 60; font.bold: true; color: "#333"; horizontalAlignment: Text.AlignRight; anchors.verticalCenter: parent.verticalCenter }
                                    }
                                }

                                // --- WIFI LINK ---
                                Rectangle { width: parent.width; height: 2; color: "#aaa" }
                                Item {
                                    width: parent.width; height: 80
                                    MouseArea { anchors.fill: parent; onClicked: root.currentView = "wifi" }
                                    Row {
                                        anchors.fill: parent
                                        Text { width: parent.width - 100; text: "Wi-Fi Settings"; font.pixelSize: 40; color: "#333"; anchors.verticalCenter: parent.verticalCenter }
                                        Text { width: 100; text: ">"; font.pixelSize: 60; font.bold: true; color: "#333"; horizontalAlignment: Text.AlignRight; anchors.verticalCenter: parent.verticalCenter }
                                    }
                                }

                                // --- CHANGE PASSWORD LINK (NEW!) ---
                                Rectangle { width: parent.width; height: 2; color: "#aaa" }
                                Item {
                                    width: parent.width; height: 80
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            // Reset the password logic inside LockScreen and go there
                                            lockScreen.resetPassword()
                                            root.currentView = "lock"
                                        }
                                    }
                                    Row {
                                        anchors.fill: parent
                                        Text { width: parent.width - 100; text: "Change Password"; font.pixelSize: 40; color: "#333"; anchors.verticalCenter: parent.verticalCenter }
                                        Text { width: 100; text: ">"; font.pixelSize: 60; font.bold: true; color: "#333"; horizontalAlignment: Text.AlignRight; anchors.verticalCenter: parent.verticalCenter }
                                    }
                                }
                            }
                        }
                    }

                    BluetoothPage {
                        id: btView
                        anchors.fill: parent
                        visible: root.currentView === "bluetooth"
                        bluetoothModel: realBtModel
                        isBtOn: root.bluetoothGlobalState
                        onBackClicked: root.currentView = "settings"
                        onIsBtOnChanged: root.bluetoothGlobalState = isBtOn
                    }

                    WifiPage {
                        id: wifiView
                        anchors.fill: parent
                        visible: root.currentView === "wifi"
                        onBackClicked: root.currentView = "settings"
                    }

                    // --- [ADDED] MAPS PAGE ---
                    MapsPage {
                        id: viewMaps
                        anchors.fill: parent
                        visible: root.currentView === "maps"
                        onBackClicked: root.currentView = "vehicle"
                    }
                }
            }
        }

        LockScreen {
            id: lockScreen
            anchors.fill: parent
            visible: root.currentView === "lock"
            onUnlocked: root.currentView = "vehicle"
        }
    }

    Rectangle {
        id: dimmerOverlay; anchors.fill: parent; color: "black"; opacity: 1.0 - root.appBrightness; z: 99999; visible: opacity > 0
    }

    Timer { interval: 1500; running: true; repeat: false; onTriggered: root.currentView = "lock" }
    Timer { interval: 60000; running: true; repeat: true; triggeredOnStart: true; onTriggered: { var date = new Date(); root.currentTime = date.toLocaleTimeString(Qt.locale(), "h:mm AP") } }
    Timer { interval: 150; running: root.currentView === "vehicle"; repeat: true; onTriggered: { var current = parseInt(speedText.text); var diff = Math.floor(Math.random() * 8) - 2; var next = current + diff; if (next < 0) next = 0; if (next > 120) next = 120; speedText.text = next.toString() } }
    Timer { id: leftBlinkTimer; interval: 500; repeat: true; property bool on: false; onTriggered: on = !on }
    Timer { id: rightBlinkTimer; interval: 500; repeat: true; property bool on: false; onTriggered: on = !on }
    function toggleLeft() { if (leftBlinkTimer.running) { leftBlinkTimer.stop(); leftBlinkTimer.on = false } else { leftBlinkTimer.start(); rightBlinkTimer.stop(); rightBlinkTimer.on = false } }
    function toggleRight() { if (rightBlinkTimer.running) { rightBlinkTimer.stop(); rightBlinkTimer.on = false } else { rightBlinkTimer.start(); leftBlinkTimer.stop(); leftBlinkTimer.on = false } }
    Timer { id: scanTimer; interval: 15000; onTriggered: { realBtModel.running = false } }
    Timer {
        id: autoBluetoothStarter; interval: 3000; running: true; repeat: false
        onTriggered: {
            console.log("Auto-triggering Bluetooth Request...");
            Qt.openUrlExternally("intent:#Intent;action=android.bluetooth.adapter.action.REQUEST_DISCOVERABLE;i.android.bluetooth.adapter.extra.DISCOVERABLE_DURATION=300;end")
        }
    }

    function setTheme(theme) {
        if (theme === "dark") { root.bgStart = "#232526"; root.bgEnd = "#414345"; root.sidebarColor = "#2c3e50"; root.iconColor = "#ccc"; root.activeIconColor = "#fff"; root.textColor = "#ffffff" }
        else if (theme === "eco") { root.bgStart = "#11998e"; root.bgEnd = "#38ef7d"; root.sidebarColor = "#ffffff"; root.iconColor = "#333"; root.activeIconColor = "#11998e"; root.textColor = "#000000" }
        else { root.bgStart = "#2bc0e4"; root.bgEnd = "#eaecc6"; root.sidebarColor = "#ffffff"; root.iconColor = "#333"; root.activeIconColor = "#0072ff"; root.textColor = "#000000" }
    }
}
