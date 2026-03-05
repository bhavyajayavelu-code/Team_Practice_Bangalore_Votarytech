import QtQuick 2.9
import QtQuick.Window 2.2
import QtMultimedia 5.9


Window {
    id: root
        visible: true
        width: 1080
        height: 600
        color: "black"
        property bool leftIndicatorOn: false
        property bool rightIndicatorOn: false
        property bool seatBeltOn: true
        property bool batteryWarning: true
        property bool parkingBrakeOn: true
        property bool airbagWarning: true
        property bool tempWarningOn: false



        // ===== STARTUP SELF TEST =====
        property bool startupSelfTest: true
        property bool startupBlinkState: true


        // Firebase Temperature
        property real firebaseTemperature: 0
        property bool tempBlinking: false
        property int blinkElapsed: 0


        // -------- ODOMETER --------
        property int odometer: 100        // start value
        property int odoStep: 100         // increment step
        property int maxOdometer: 100000  // max limit

        // -------- RANGE --------
        property int rangeKm: 0           // start from 0
        property int rangeStep: 10        // increment step
        property int maxRange: 400        // max range


        //property int rangeKm: 115

        // =========================
        // Engine Temperature
        // =========================
        property real engineTemp: 75          // current temperature
        property real tempThreshold: 90       // warning threshold



        property bool hazardOn: false

        //property int indicatorStatus: 0

        property bool leftBlinkVisible: true
        property bool rightBlinkVisible: true
        property bool hazardBlinkVisible: true



        property bool batterySensorFault: false
        property bool batteryBlink: false
        property string batteryAlertMessage: ""

        // ===== DMS ALERT =====
        property bool drowsyMsg: false
        property string drowsyText: ""

        property bool yawnMsg: false
        property string yawnText: ""


        // ===== OMS STATUS =====
        property string seatStatus: ""
        property string airbagStatus: ""


        property bool airbagBlink: false
        property bool airbagBlinkVisible: true


       property string firebaseAlertMessage: ""


        // ===== DTC =====
        property string dtcDescription: ""
        property bool dtcActive: false
        // ===== ULTRASONIC =====
        property bool ultrasonicFCW: false
        property real ultrasonicDistance: 0
        property string ultrasonicAlert: ""

    Rectangle {
        id: logoSplash
        anchors.fill: parent
        color: "white"   // background for splash
        z: 10            // ensures it appears on top of everything

        Image {
            source: "qrc:/assets/icons/VotaryTech.svg"   // make sure this matches your .qrc path
            anchors.centerIn: parent
            width: 1000
            height: 350
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
    }



    Rectangle {
        id: clusterUI
        anchors.fill: parent
        color: "black"
        visible: false   // hide initially
        width: 1280
        height: 480


    Camera {
        id: clusterCamera
        deviceId:  ""
        captureMode: Camera.CaptureVideo
    }
    Component.onCompleted: {
        clusterCamera.start()
    }


    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "#00BFFF"
        border.width: 6
        radius: 40
        enabled: false
    }

    // =========================
    // Top Bar
    // =========================
    Rectangle {
        width: parent.width
        height: 60
        color: "transparent"


//        // Engine icon (replacing ABS)
//        Image {
//            source: "qrc:/assets/icons/engine.png"
//            width: 36
//            height: 36
//            anchors.right: parent.right
//            anchors.rightMargin: 20
//            anchors.verticalCenter: parent.verticalCenter
//        }
        // =========================
        // Time & Date (Center of Top Bar)
        // =========================
        Column {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 18


        Text {
            id: timeText
            // 12-hour format with AM/PM
            text: Qt.formatTime(new Date(), "hh:mm AP")
            color: "white"
            font.pixelSize: 38
            font.bold: true
        }

        Text {
            id: dateText
            text: Qt.formatDate(new Date(), "dd MMM yyyy")
            color: "#AAAAAA"
            font.pixelSize: 20
            anchors.left: parent.left
            anchors.leftMargin: 30
        }
    }

        // LEFT INDICATOR
        Text {
            id: leftIndicator
            text: "\u25C0"
            color: "#00FF00"
            font.pixelSize: 60
            anchors.left: parent.left
            anchors.leftMargin: 70
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 40

         //   visible: leftIndicatorOn && leftBlinkVisible

        visible: (startupSelfTest ? startupBlinkState : (leftIndicatorOn && leftBlinkVisible))
           }

        // HAZARD ICON BETWEEN LEFT INDICATOR AND CLOCK
        Image {
            id: hazardIcon
            source: "qrc:/assets/icons/hazard.svg"  // replace with your hazard icon path
            width: 48
            height: 48
            anchors.verticalCenter: leftIndicator.verticalCenter
            anchors.left: leftIndicator.right
            anchors.leftMargin: 150   // adjust this to move it closer/farther from the left indicator
            //visible: hazardOn && hazardBlinkVisible  // you can toggle this with a property like hazardOn
            visible: (startupSelfTest ? startupBlinkState : (hazardOn && hazardBlinkVisible))

            opacity: 1
        }

        // RIGHT INDICATOR
        Text {
            id: rightIndicator
            text: "\u25B6"
            color: "#00FF00"
            font.pixelSize: 60
            anchors.right: parent.right
            anchors.rightMargin: 70
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 40

         //   visible: rightIndicatorOn && rightBlinkVisible
            visible: (startupSelfTest ? startupBlinkState : (rightIndicatorOn && rightBlinkVisible))

        }

    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 90
        spacing: 30


        Row {
            spacing: 80   // reduced to fit camera
            anchors.horizontalCenterOffset: -40

            // LEFT – Speedometer
            Speedometer {
                id: speedo
                speed: 70
            }

            // CENTER – LIVE CAMERA VIEW
            Rectangle {
                id: cameraBox
                width: 320
                height: 200
                radius: 14
                color: "black"
                border.color: "#00BFFF"
                border.width: 2
                z: 5

                VideoOutput {
                    anchors.fill: parent
                    source: clusterCamera
                    fillMode: VideoOutput.PreserveAspectCrop
                    visible: true
                }
                // === Text Overlay ===
                    Rectangle {
                        width: parent.width
                        height: 40
                        color: Qt.rgba(0, 0, 0, 0.5)// semi-transparent background
                        anchors.bottom: parent.bottom
                        radius: 8

                        Text {
                            id: cameraText
                            text: "DMS Camera Active"   // you can change dynamically
                            color: "white"
                            font.pixelSize: 18
                            anchors.centerIn: parent
                        }
                    }
            }

            Column {
                spacing: 10
                anchors.verticalCenter: parent.verticalCenter


                // -------- Tachometer --------
                Tachometer {
                    id: tacho
                    rpm: 3500
                }

                // -------- ODOMETER + RANGE (SIDE BY SIDE) --------
                Row {
                    spacing: 40
                    anchors.horizontalCenter: parent.horizontalCenter

                    // ---- ODOMETER ----
                    Column {
                        spacing: 4

                        Text {
                            text: "Odometer"
                            color: "#AAAAAA"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Row {
                            spacing: 6

                            Text {
                                text: odometer
                                color: "white"
                                font.pixelSize: 28
                                font.bold: true
                            }

                            Text {
                                text: "km"
                                color: "#CCCCCC"
                                font.pixelSize: 14
                                anchors.baseline: parent.children[0].baseline
                            }
                        }
                    }

                    // ---- RANGE ----
                    Column {
                        spacing: 4

                        Text {
                            text: "Range"
                            color: "#AAAAAA"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Row {
                            spacing: 6

                            Text {
                                text: rangeKm
                                color: "white"
                                font.pixelSize: 28
                                font.bold: true
                            }

                            Text {
                                text: "km"
                                color: "#CCCCCC"
                                font.pixelSize: 14
                                anchors.baseline: parent.children[0].baseline
                            }
                        }
                    }
                }
            }

        }

        GearIndicator {
            id: gearIndicator
            currentGear: "P"
        }
    }

    Row {
        id: warningIcons
        spacing: 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 130
        z: 20


        Image {
            source: "qrc:/assets/icons/seat-belt.svg"
            width: 50
            height: 50
            visible: seatBeltOn

            opacity: startupSelfTest
                        ? (startupBlinkState ? 1 : 0.2)
                        : 1

            //color: "red"
        }

        Image {
            source: "qrc:/assets/icons/battery4.svg"
            width: 50
            height: 50
            visible: batteryWarning
            opacity: startupSelfTest
                         ? (startupBlinkState ? 1 : 0.2)
                         : (batteryBlink ? 0.2 : 1)
        }

        Image {
            source: "qrc:/assets/icons/drive-brake.svg"
            width: 50
            height: 50
            visible: parkingBrakeOn
            opacity: startupSelfTest
                        ? (startupBlinkState ? 1 : 0.2)
                        : 1
            //color: "red"
        }

        Image {
            id: airbagIcon
            source: "qrc:/assets/icons/airbag.svg"
            width: 50
            height: 50
            visible: airbagWarning

            opacity: startupSelfTest
                     ? (startupBlinkState ? 1 : 0.2)
                     : (airbagBlink ? (airbagBlinkVisible ? 1 : 0.2) : 1)
        }
        Image {
            id: tempWarningIcon
            source: "qrc:/assets/icons/thermometer.svg"
            width: 50
            height: 50
            visible: true
           // opacity: 1  // Start in stable state
            opacity: startupSelfTest
                         ? (startupBlinkState ? 1 : 0.2)
                         : opacity    // existing temperature logic continues
            }
        }

    // =========================
    // Battery Temperature
    // =========================
    Text {
        id: batteryTempText
        text: "Battery Temp: " + firebaseTemperature.toFixed(1) + "°C"
        color: firebaseTemperature >= 28 ? "red" : "white"
        font.pixelSize: 26
        font.bold: true

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: warningIcons.bottom
        anchors.topMargin: 25
    }


    // =========================
    // Firebase Alert Message
    // =========================
    Text {
        id: firebaseAlertText
        text: firebaseAlertMessage
        color: "red"
        font.pixelSize: 26
        font.bold: true

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: batteryTempText.bottom
        anchors.topMargin: 8

        visible: firebaseAlertMessage !== ""
    }


    // =========================
    // DTC DISPLAY
    // =========================
    Text {
        id: dtcText
        text: dtcDescription
        color: "red"
        font.pixelSize: 26
        font.bold: true

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: firebaseAlertText.visible
                     ? firebaseAlertText.bottom
                     : batteryTempText.bottom
        anchors.topMargin: 8

        visible: dtcActive
    }




    // =========================
    // DMS ALERT TEXT
    // =========================
    Text {
        id: dmsAlertText
        text: drowsyMsg ? drowsyText :
              yawnMsg ? yawnText : ""

        color: "red"
        font.pixelSize: 24
        font.bold: true

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 380
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40

        visible: drowsyMsg || yawnMsg
    }


    // =========================
    // OMS DISPLAY TEXT
    Text {
        id: omsStatusText

        text: seatStatus.toUpperCase() === "ADULT"
              ? "ADULT"
              : seatStatus + " | Airbag: " + airbagStatus

        color: airbagStatus === "ACTIVATED" ? "#00FF00" : "red"
        font.pixelSize: 20
        font.bold: true

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 340
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40

        visible: seatStatus !== ""
    }


    // =========================
    // ULTRASONIC ALERT DISPLAY
    // =========================
    Text {
        id: ultrasonicAlertText
        text: ultrasonicAlert
        color: "red"
        font.pixelSize: 26
        font.bold: true

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10

        visible: ultrasonicAlert !== ""
    }


    // =========================
    // Demo Animation (Optional)
    // =========================
    Timer {
        interval: 90
        running: true
        repeat: true
        onTriggered: {
            speedo.speed = (speedo.speed + 1) % 180
            tacho.rpm = (tacho.rpm + 50) % 8000
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            var gears = ["P", "R", "N", "D"]
            var index = gears.indexOf(gearIndicator.currentGear)
            gearIndicator.currentGear = gears[(index + 1) % gears.length]
        }
    }

    //==================================LOGO SPLASH===========================
//    Timer {
//        interval: 2500   // 2.5 seconds splash
//        running: true
//        repeat: false

//        onTriggered: {
//            logoSplash.visible = false
//            clusterUI.visible = true
//        }
//    }


    Timer {
        interval: 2500
        running: true
        repeat: false

        onTriggered: {
            logoSplash.visible = false
            clusterUI.visible = true

            // START SELF TEST
            startupSelfTest = true
            startupBlinkState = true
            startupBlinkTimer.start()
            startupEndTimer.start()
        }
    }




    Timer {
        interval: 1000   // update every second
        running: true
        repeat: true

        onTriggered: {

            // -------- ODOMETER LOGIC --------
            odometer += odoStep
            if (odometer > maxOdometer) {
                odometer = 100
            }

            // -------- RANGE LOGIC --------
            rangeKm += rangeStep
            if (rangeKm > maxRange) {
                rangeKm = 0
            }
        }
    }


   // Temperature icon
    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            engineTemp += 2

            // Turn warning ON once
            if (engineTemp >= tempThreshold) {
                tempWarningOn = true
            }

            // Reset temperature value (demo only)
            if (engineTemp > 110) {
                engineTemp = 70
                // ❌ DO NOT reset tempWarningOn here
            }
        }
    }

    // Timer to handle Firebase data polling
    Timer {
        id: firebasePollTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var xhr = new XMLHttpRequest()
            xhr.onreadystatechange = function () {
                if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText)
                        // ===== ULTRASONIC DATA =====
                        if (data.Ultrasonic) {

                            ultrasonicFCW = data.Ultrasonic.FCW === true
                            ultrasonicDistance = parseFloat(data.Ultrasonic.distance) || 0
                            ultrasonicAlert = data.Ultrasonic.alert || ""

                        } else {
                            ultrasonicFCW = false
                            ultrasonicDistance = 0
                            ultrasonicAlert = ""
                        }

                        // ===== ALERT MESSAGE FROM FIREBASE =====
                        if (data.Alerts && data.Alerts.message && data.Alerts.message !== "") {
                            firebaseAlertMessage = data.Alerts.message
                        } else {
                            firebaseAlertMessage = ""
                        }


                        if (data.car_indicators) {

                            leftIndicatorOn  = data.car_indicators.left_indicator === true
                            rightIndicatorOn = data.car_indicators.right_indicator === true
                            hazardOn         = data.car_indicators.hazard === true

                            // Hazard overrides individual indicators
                            if (hazardOn) {
                                leftIndicatorOn = true
                                rightIndicatorOn = true
                            }


                        }
                        // ===== DMS STATUS =====
                        if (data.DMS && data.DMS.status) {

                            if (data.DMS.status.online === true) {

                                drowsyMsg  = data.DMS.status.drowsy_msg === true
                                drowsyText = data.DMS.status.drowsy_text || ""

                                yawnMsg    = data.DMS.status.yawn_msg === true
                                yawnText   = data.DMS.status.yawn_text || ""

                            } else {

                                drowsyMsg  = false
                                yawnMsg    = false
                                drowsyText = ""
                                yawnText   = ""
                            }
                        }

                        // ===== OMS STATUS =====
                        if (data.OMS && data.OMS.status) {

                            if (data.OMS.status.online === true) {

                                // Show status only when online
                                seatStatus   = data.OMS.status.seat_status || ""
                                airbagStatus = data.OMS.status.airbag || ""

                                // Blink when DEACTIVATED
                                if (airbagStatus && airbagStatus.toUpperCase() === "DEACTIVATED") {

                                    airbagBlink = true

                                    if (!airbagBlinkTimer.running)
                                        airbagBlinkTimer.start()

                                } else {

                                    airbagBlink = false
                                    airbagBlinkTimer.stop()
                                    airbagBlinkVisible = true
                                }

                            } else {

                                // When OMS is offline → hide everything
                                seatStatus   = ""
                                airbagStatus = ""

                                airbagBlink = false
                                airbagBlinkTimer.stop()
                                airbagBlinkVisible = true
                            }

                        } else {

                            // If OMS block missing
                            seatStatus   = ""
                            airbagStatus = ""

                            airbagBlink = false
                            airbagBlinkTimer.stop()
                            airbagBlinkVisible = true
                        }
                        // ===== DTC FROM FIREBASE (SHOW ONLY DESCRIPTION) =====
                        dtcActive = false
                        dtcDescription = ""

                        if (data.DTC && typeof data.DTC === "object") {

                            for (var code in data.DTC) {

                                var dtcItem = data.DTC[code]

                                // Show only when:
                                // 1. status is true
                                // 2. description exists
                                // 3. description is not empty

                                if (dtcItem.status === true &&
                                    dtcItem.description &&
                                    dtcItem.description.trim() !== "") {

                                    dtcActive = true
                                    dtcDescription = dtcItem.description   // ✅ ONLY DESCRIPTION
                                    break   // show only first active DTC
                                }
                            }
                        }

                        if (data.Sensor && data.Sensor.temperature !== undefined) {
                            firebaseTemperature = parseFloat(data.Sensor.temperature)

                            // -------- Battery sensor fault (-127) --------
                            if (firebaseTemperature === -127) {
                                batterySensorFault = true
                                batteryAlertMessage = "Alert - Battery temperature sensor fault"
                                batteryBlink = true
                                if (!batteryBlinkTimer.running)
                                    batteryBlinkTimer.start()
                                return
                            }

                            // Check if temperature is above 28°C
                            if (firebaseTemperature > 28) {

                                tempBlinking = true
                                if (!blinkTimer.running)
                                    blinkTimer.start()

                            } else {

                                tempBlinking = false
                                blinkTimer.stop()
                                tempWarningIcon.opacity = 1
                            }

                        }
                    } catch (e) {
                        console.log("Firebase parse error")
                    }
                }
            }

            xhr.open("GET", "https://edge-data-filtering-default-rtdb.asia-southeast1.firebasedatabase.app/.json")
            xhr.send()
        }
    }

    // Timer for blinking the thermometer icon
    Timer {
        id: blinkTimer
        interval: 500
        repeat: true
        onTriggered: {
            if (tempBlinking) {
                // Toggle icon opacity to create blinking effect
                tempWarningIcon.opacity = (tempWarningIcon.opacity === 1 ? 0.2 : 1)
            }
        }
    }

    Timer {
        id: firebaseTimer
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            console.log("TEMP =", firebaseTemperature)

            if (firebaseTemperature >= 28) {
                tempBlinking = true
                if (!blinkTimer.running) blinkTimer.start()  // Start blinking if not already
            } else {
                tempBlinking = false
                blinkTimer.stop()   // Stop blinking if temperature is below threshold
                tempWarningIcon.opacity = 1  // Stable state
            }
        }
    }

    Timer {
        id: batteryBlinkTimer
        interval: 500
        repeat: true
        running: batteryBlink
        onTriggered: {
            batteryBlink = !batteryBlink
        }
    }
    Timer {
        id: indicatorBlinkTimer
        interval: 500
        repeat: true
        running: leftIndicatorOn || rightIndicatorOn || hazardOn

        onTriggered: {

            // LEFT
            if (leftIndicatorOn)
                leftBlinkVisible = !leftBlinkVisible
            else
                leftBlinkVisible = true

            // RIGHT
            if (rightIndicatorOn)
                rightBlinkVisible = !rightBlinkVisible
            else
                rightBlinkVisible = true

            // HAZARD ICON
            if (hazardOn)
                hazardBlinkVisible = !hazardBlinkVisible
            else
                hazardBlinkVisible = true
        }
    }

    Timer {
        id: startupBlinkTimer
        interval: 500          // blink speed
        repeat: true
        running: false

        onTriggered: {
            startupBlinkState = !startupBlinkState
        }
    }

    Timer {
        id: startupEndTimer
        interval: 2000         // total self-test duration
        repeat: false

        onTriggered: {
            startupSelfTest = false
            startupBlinkTimer.stop()

            // restore stable states
            startupBlinkState = true
        }
    }
    Timer {
        id: airbagBlinkTimer
        interval: 500
        repeat: true
        running: airbagBlink

        onTriggered: {
            airbagBlinkVisible = !airbagBlinkVisible
        }
    }

 }

}
