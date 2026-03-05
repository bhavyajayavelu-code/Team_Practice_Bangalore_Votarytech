import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebView 1.1
import QtMultimedia 5.15
import QtQuick.Window 2.0
import QtGraphicalEffects 1.15
import Votary.Network 1.0

ApplicationWindow {
    id: root
    width: 1024
    height: 600
    visible: true
    title: "Ultra-Realistic Automotive Infotainment"
    color: "#000000"

    // Theme properties
    property bool darkTheme: true
    property double brightness: 1.0
    property string activeApp: "dashboard"
    property string activeRightPaneApp: "musicView"  // Music by default on power-on

    // Dynamic data properties
    property int batteryLevel: 85
    property real speed: 65.5
    property int power: 0
    property int temperature: 22
    property int range: 320
    property string temperatureStatus: "Normal"
    property color temperatureColor: "#3FFFD8"
    property string temperatureMessage: ""

    // Media Player Properties
    property string currentTrack: "Midnight City"
    property string currentArtist: "M83"
    property bool isPlaying: true

    // Theme-aware colors
    property color textColor: darkTheme ? "#FFFFFF" : "#000000"
    property color secondaryTextColor: darkTheme ? "#AAAAAA" : "#666666"
    property color backgroundColor: darkTheme ? "#0A0A0A" : "#E0E0E0"
    property color panelColor: darkTheme ? "#151515" : "#F0F0F0"
    property color accentColor: "#3FFFD8"

    // Sidebar icons (SQUARE, no text) - Added mirrorView
    property var sidebarIcons: [
        {icon: "📷", app: "cameraView", color: "#3FFFD8"},
        {icon: "📻", app: "musicView", color: "#2196F3"},
        {icon: "🎶", app: "mediaView", color: "#9C27B0"},
        {icon: "🇬", app: "browserView", color: "#4285F4"},
        {icon: "🛒", app: "playstoreView", color: "#34A853"},
        {icon: "🌡", app: "climateView", color: "#FF7043"},
        {icon: "🎮", app: "phoneView", color: "#FF9800"},
        {icon: "📱", app: "mirrorView", color: "#F98201"},
        {icon: "🚨", app: "ecallView", color: "#0C1432"},
        {icon: "⚙", app: "settingsView", color: "#9C27B0"}
    ]


    // Boot screen timer (2 seconds for image)
    Timer {
        id: bootTimer
        interval: 2000
        onTriggered: {
            // Hide boot screen with image, show black screen
            bootScreen.visible = false
            blackScreen.visible = true

            // Start 2 second timer for black screen
            blackScreenTimer.start()
        }
    }

    // Black screen timer (0.5 seconds for welcome message)
    Timer {
        id: blackScreenTimer
        interval: 500
        onTriggered: {
            // Hide black screen, show main application
            blackScreen.visible = false
            scaler.visible = true
        }
    }

    Component.onCompleted: {
        bootTimer.start()
    }

    // Boot Screen Component - White with Image (3 seconds)
    Rectangle {
        id: bootScreen
        anchors.fill: parent
        color: "#F8FAFC"
        visible: true
        z: 100

        // Subtle gradient background
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#F8FAFC" }
                GradientStop { position: 1.0; color: "#F1F5F9" }
            }
        }

        // Main Container with shadow
        Rectangle {
            id: mainCard
            width: 700
            height: 400
            anchors.centerIn: parent
            color: "#FFFFFF"
            radius: 20
            opacity: 0
            scale: 0.95

            // Shadow
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                radius: 30
                samples: 61
                color: "#00000020"
                verticalOffset: 5
            }

            // Entrance animation
            ParallelAnimation {
                running: true
                NumberAnimation {
                    target: mainCard
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 1000
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: mainCard
                    property: "scale"
                    from: 0.95
                    to: 1
                    duration: 1000
                    easing.type: Easing.OutBack
                }
            }

            // Content
            Column {
                anchors.centerIn: parent
                spacing: 40

                // Logo with floating effect
                Item {
                    id: logoContainer
                    width: 300
                    height: 150
                    anchors.horizontalCenter: parent.horizontalCenter

                    Image {
                        id: votaryLogo
                        source: "qrc:/icons/votary.png"
                        anchors.centerIn: parent
                        width: 250
                        height: 125
                        fillMode: Image.PreserveAspectFit
                        opacity: 0

                        SequentialAnimation {
                            running: true
                            PauseAnimation { duration: 300 }
                            NumberAnimation {
                                target: votaryLogo
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: 800
                            }
                        }

                        // Floating animation
                        ParallelAnimation {
                            running: true
                            loops: Animation.Infinite
                            NumberAnimation {
                                target: votaryLogo
                                property: "y"
                                from: votaryLogo.y
                                to: votaryLogo.y - 5
                                duration: 2000
                                easing.type: Easing.InOutSine
                            }
                            NumberAnimation {
                                target: votaryLogo
                                property: "y"
                                from: votaryLogo.y - 5
                                to: votaryLogo.y
                                duration: 2000
                                easing.type: Easing.InOutSine
                            }
                        }
                    }

                    // Ornamental dots around logo
                    Repeater {
                        model: 8
                        Rectangle {
                            width: 6
                            height: 6
                            radius: 3
                            color: "#3B82F6"
                            opacity: 0.3

                            property real angle: (index * 45) * Math.PI / 180
                            x: logoContainer.width/2 + 140 * Math.cos(angle) - width/2
                            y: logoContainer.height/2 + 140 * Math.sin(angle) - height/2

                            SequentialAnimation {
                                running: true
                                PauseAnimation { duration: 800 + index * 150 }
                                NumberAnimation {
                                    target: this
                                    property: "opacity"
                                    from: 0
                                    to: 0.3
                                    duration: 400
                                }
                            }
                        }
                    }
                }

                // Company Name with elegant typography
                Column {
                    spacing: 8
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        id: companyName
                        text: "VOTARY"
                        color: "#1E293B"
                        font.pixelSize: 42
                        font.bold: true
                        font.letterSpacing: 4
                        anchors.horizontalCenter: parent.horizontalCenter
                        opacity: 0

                        SequentialAnimation {
                            running: true
                            PauseAnimation { duration: 800 }
                            NumberAnimation {
                                target: companyName
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: 600
                            }
                        }
                    }

                    Text {
                        id: softechSolutions
                        text: "SOFTECH SOLUTIONS"
                        color: "#64748B"
                        font.pixelSize: 20
                        font.letterSpacing: 6
                        anchors.horizontalCenter: parent.horizontalCenter
                        opacity: 0

                        SequentialAnimation {
                            running: true
                            PauseAnimation { duration: 1200 }
                            NumberAnimation {
                                target: softechSolutions
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: 600
                            }
                        }
                    }

                    // Elegant divider
                    Rectangle {
                        id: elegantDivider
                        width: 0
                        height: 2
                        color: "#3B82F6"
                        anchors.horizontalCenter: parent.horizontalCenter
                        opacity: 0.8

                        SequentialAnimation {
                            running: true
                            PauseAnimation { duration: 1600 }
                            NumberAnimation {
                                target: elegantDivider
                                property: "width"
                                from: 0
                                to: 200
                                duration: 800
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }
        }

        // Status Text at bottom
        Text {
            text: "Initializing System Components"
            color: "#64748B"
            font.pixelSize: 16
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 60
            opacity: 0

            SequentialAnimation {
                running: true
                PauseAnimation { duration: 2000 }
                NumberAnimation {
                    target: this
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 600
                }
            }
        }

        // Progress indicator (circular)
        Item {
            width: 40
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30
            opacity: 0

            SequentialAnimation {
                running: true
                PauseAnimation { duration: 2200 }
                NumberAnimation {
                    target: this
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 400
                }
            }

            Rectangle {
                id: progressRing
                width: parent.width
                height: parent.height
                radius: width / 2
                color: "transparent"
                border.color: "#E2E8F0"
                border.width: 3
            }

            Rectangle {
                id: progressArc
                width: parent.width - 6
                height: parent.height - 6
                radius: width / 2
                color: "transparent"
                border.color: "#3B82F6"
                border.width: 3
                opacity: 0

                property real startAngle: 0

                SequentialAnimation {
                    running: true
                    PauseAnimation { duration: 2400 }
                    NumberAnimation {
                        target: progressArc
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 300
                    }
                }

                Canvas {
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();

                        var centerX = width / 2;
                        var centerY = height / 2;
                        var radius = Math.min(centerX, centerY) - 2;

                        ctx.beginPath();
                        ctx.lineWidth = 3;
                        ctx.strokeStyle = "#3B82F6";
                        ctx.arc(centerX, centerY, radius,
                                progressArc.startAngle,
                                progressArc.startAngle + Math.PI * 1.5);
                        ctx.stroke();
                    }

                    RotationAnimation {
                        target: progressArc
                        property: "startAngle"
                        from: 0
                        to: Math.PI * 2
                        duration: 2000
                        loops: Animation.Infinite
                        running: true
                    }
                }
            }
        }
    }

    // =========== BLACK SCREEN COMPONENT ===========
    Rectangle {
        id: blackScreen
        anchors.fill: parent
        color: "#000000"
        visible: false  // Initially hidden
        z: 101  // Higher than boot screen

        // "Welcome To Votary" text in middle
        /*Text {
            text: "Welcome To Votary..."
            color: "#FFFFFF"
            font.pixelSize: 36
            font.bold: true
            anchors.centerIn: parent

            // Fade in animation
            SequentialAnimation {
                running: true
                NumberAnimation {
                    target: this
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 500
                }
                PauseAnimation { duration: 1000 }
                NumberAnimation {
                    target: this
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 500
                }
            }
        }*/
    }

    // SCALER ITEM - Auto-fit for any resolution
    Item {
        id: scaler
        width: 1024  // Original design width
        height: 600  // Original design height
        anchors.centerIn: parent
        visible: false

        // Auto-fit calculation for ANY resolution
        property real scaleRatio: Math.min(root.width / width, root.height / height)
        scale: scaleRatio > 0 ? scaleRatio : 0.5

        layer.enabled: true
        layer.smooth: true

        // MAIN APPLICATION CONTAINER
        Rectangle {
            id: mainContainer
            anchors.fill: parent
            color: darkTheme ? "#0F0A0F" : "#F0F0F0"  // Theme-aware gap color

            Row {
                anchors.fill: parent
                anchors.margins: 10  // Space around all panels
                spacing: 15  // Space between panels

                // =============================================
                // LEFT SIDEBAR DOCK (8%) - CIRCULAR CORNERS
                // =============================================
                Rectangle {
                    id: sidebar
                    width: parent.width * 0.08  // 8%
                    height: parent.height
                    color: darkTheme ? "#080808" : "#E8E8E8"  // Theme-aware
                    radius: 20  // Circular corners

                    // For hardware-accelerated clipping
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: sidebar.width
                            height: sidebar.height
                            radius: sidebar.radius
                        }
                    }

                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        // Time and Date Display
                        Column {
                            width: parent.width
                            height: 65
                            spacing: 2

                            // Time Display
                            Text {
                                id: sidebarTime
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                color: darkTheme ? accentColor : "#000000"  // Theme-aware
                                font.pixelSize: 15
                                font.bold: true
                                font.family: "Audiowide"

                                Timer {
                                    interval: 1000
                                    running: true
                                    repeat: true
                                    onTriggered: {
                                        var now = new Date()
                                        var hours = now.getHours().toString().padStart(2, '0')
                                        var minutes = now.getMinutes().toString().padStart(2, '0')
                                        sidebarTime.text = hours + ":" + minutes
                                    }
                                }
                            }

                            // Date Display
                            Text {
                                id: sidebarDate
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                color: darkTheme ? accentColor : "#000000"  // Theme-aware
                                font.pixelSize: 14
                                font.bold: true
                                font.family: "Audiowide"

                                Timer {
                                    interval: 60000  // Update every minute
                                    running: true
                                    repeat: true
                                    onTriggered: {
                                        var now = new Date()
                                        var day = now.getDate().toString().padStart(2, '0')
                                        var month = (now.getMonth() + 1).toString().padStart(2, '0')
                                        var year = now.getFullYear().toString().slice(2)  // Last 2 digits
                                        sidebarDate.text = day + "/" + month + "/" + year
                                    }
                                    triggeredOnStart: true  // Run immediately
                                }
                            }
                        }

                        // Spacer
                        Item {
                            width: parent.width
                            height: 5
                        }

                        // SCROLLABLE Circular Icons Area
                        Flickable {
                            id: iconFlickable
                            width: parent.width
                            height: parent.height - 110  // Adjusted for date
                            contentHeight: iconColumn.height
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds

                            Column {
                                id: iconColumn
                                width: parent.width
                                spacing: 15

                                Repeater {
                                    model: sidebarIcons

                                    Rectangle {
                                        property string iconApp: modelData.app
                                        property string iconSymbol: modelData.icon
                                        property color iconColor: modelData.color

                                        width: 60
                                        height: 60
                                        radius: 30  // CIRCULAR
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        color: activeRightPaneApp === iconApp ? iconColor : (darkTheme ? "#1A1A1A" : "#F0F0F0")  // Theme-aware
                                        border.color: activeRightPaneApp === iconApp ? "#FFFFFF" : (darkTheme ? "#333333" : "#DDDDDD")  // Theme-aware
                                        border.width: 2

                                        Text {
                                            text: iconSymbol
                                            anchors.centerIn: parent
                                            color: activeRightPaneApp === iconApp ? "#000000" : (darkTheme ? "#FFFFFF" : "#333333")  // Theme-aware
                                            font.pixelSize: 24
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                activeRightPaneApp = iconApp
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Border to highlight rounded corners
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: parent.radius
                        border.color: darkTheme ? "#333333" : "#CCCCCC"  // Theme-aware
                        border.width: 2
                    }
                }

                // =============================================
                // LEFT PANE - GOOGLE MAPS (49%) - CIRCULAR CORNERS
                // =============================================
                Rectangle {
                    id: leftPane
                    width: parent.width * 0.49  // 49% (reduced from 50% for space)
                    height: parent.height
                    color: "#101010"
                    radius: 20  // Circular corners

                    // For hardware-accelerated clipping
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: leftPane.width
                            height: leftPane.height
                            radius: leftPane.radius
                        }
                    }

                    // Google Maps WebView - FULL SCREEN
                    WebView {
                        id: mapsView
                        anchors.fill: parent
                        anchors.margins: 2  // Small margin to avoid border overlap
                        url: "https://www.google.com/maps/dir///@12.9851654,77.7323209,15z?entry=ttu&g_ep=EgoyMDI2MDIwOS4wIKXMDSoASAFQAw%3D%3D"

                        onLoadingChanged: {
                            if (loadRequest.status === WebView.LoadSucceededStatus) {
                                console.log("Maps loaded successfully")
                                // Inject refresh button after maps load
                                injectRefreshButton()
                            }
                        }

                        // Function to inject refresh button
                        function injectRefreshButton() {
                            mapsView.runJavaScript(`
                                // Remove existing button if any
                                var existingBtn = document.getElementById('mapsRefreshBtn');
                                if (existingBtn) {
                                    existingBtn.remove();
                                }

                                // Create refresh button
                                var refreshBtn = document.createElement('button');
                                refreshBtn.id = 'mapsRefreshBtn';
                                refreshBtn.innerHTML = '↻';
                                refreshBtn.style.position = 'fixed';
                                refreshBtn.style.bottom = '20px';
                                refreshBtn.style.left = '20px';
                                refreshBtn.style.width = '45px';
                                refreshBtn.style.height = '45px';
                                refreshBtn.style.backgroundColor = '#3FFFD8';
                                refreshBtn.style.color = '#000000';
                                refreshBtn.style.border = 'none';
                                refreshBtn.style.borderRadius = '50%';
                                refreshBtn.style.fontSize = '24px';
                                refreshBtn.style.fontWeight = 'bold';
                                refreshBtn.style.zIndex = '9999';
                                refreshBtn.style.cursor = 'pointer';
                                refreshBtn.style.boxShadow = '0 4px 8px rgba(0,0,0,0.3)';

                                // Add hover effect
                                refreshBtn.onmouseover = function() {
                                    this.style.transform = 'scale(1.1)';
                                    this.style.boxShadow = '0 6px 12px rgba(0,0,0,0.4)';
                                };
                                refreshBtn.onmouseout = function() {
                                    this.style.transform = 'scale(1)';
                                    this.style.boxShadow = '0 4px 8px rgba(0,0,0,0.3)';
                                };

                                // Add click handler - reloads maps from start
                                refreshBtn.onclick = function() {
                                    // Show loading indicator
                                    this.innerHTML = '⟳';
                                    this.style.backgroundColor = '#2196F3';

                                    // Reload to initial maps URL
                                    window.location.href = 'https://www.google.com/maps/dir///@12.9851654,77.7323209,15z?entry=ttu&g_ep=EgoyMDI2MDIwOS4wIKXMDSoASAFQAw%3D%3D';

                                    // Reset button after 2 seconds
                                    setTimeout(function() {
                                        refreshBtn.innerHTML = '↻';
                                        refreshBtn.style.backgroundColor = '#3FFFD8';
                                    }, 2000);
                                };

                                // Add to page
                                document.body.appendChild(refreshBtn);

                                // Ensure button stays on top
                                var observer = new MutationObserver(function() {
                                    if (!document.body.contains(refreshBtn)) {
                                        document.body.appendChild(refreshBtn);
                                    }
                                });
                                observer.observe(document.body, { childList: true });
                            `);
                        }
                    }

                    // Border to highlight rounded corners
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: parent.radius
                        border.color: darkTheme ? "#333333" : "#CCCCCC"  // Theme-aware
                        border.width: 2
                    }
                }

                // =============================================
                // RIGHT PANE - DYNAMIC CONTENT (38%) - CIRCULAR CORNERS
                // =============================================
                Rectangle {
                    id: rightPane
                    width: parent.width * 0.38  // 38% (reduced from 40% for space at end)
                    height: parent.height
                    color: panelColor  // Already theme-aware
                    radius: 20  // Circular corners

                    // For hardware-accelerated clipping
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: rightPane.width
                            height: rightPane.height
                            radius: rightPane.radius
                        }
                    }

                    // Loader for dynamic content - MUSIC BY DEFAULT
                    Loader {
                        id: rightPaneLoader
                        anchors.fill: parent
                        anchors.margins: 2  // Small margin
                        sourceComponent: {
                            switch(activeRightPaneApp) {
                                case "cameraView": return cameraView
                                case "musicView": return musicView
                                case "mediaView": return mediaView
                                case "browserView": return browserView
                                case "playstoreView": return playstoreView
                                case "climateView": return climateView
                                case "phoneView": return phoneView
                                case "mirrorView": return mirrorView
                                case "ecallView": return ecallView
                                case "settingsView": return settingsView
                                default: return musicView
                            }
                        }
                    }

                    // Border to highlight rounded corners
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: parent.radius
                        border.color: darkTheme ? "#333333" : "#CCCCCC"  // Theme-aware
                        border.width: 2
                    }
                }

                // =============================================
                // SPACE AFTER RIGHT PANE (Creates visual breathing room)
                // =============================================
                Item {
                    width: parent.width * 0.03  // 3% space at the end
                    height: parent.height
                }
            }
        }
    }

    // =============================================
    // RIGHT PANE COMPONENTS - ALL WITH CIRCULAR CORNERS
    // =============================================

    // Camera View Component
    Component {
        id: cameraView
        Rectangle {
            color: panelColor
            anchors.fill: parent

            Column {
                anchors.centerIn: parent
                width: parent.width * 0.8
                spacing: 40

                // Camera icon/image
                Rectangle {
                    width: 200
                    height: 200
                    radius: 20
                    color: darkTheme ? "#1A1A1A" : "#E0E0E0"  // Theme-aware
                    border.color: accentColor
                    border.width: 3
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        text: "📷"
                        font.pixelSize: 100
                        anchors.centerIn: parent
                    }

                    // Pulsing animation
                    SequentialAnimation {
                        running: true
                        loops: Animation.Infinite

                        NumberAnimation {
                            target: this.parent
                            property: "scale"
                            from: 1.0
                            to: 1.05
                            duration: 1000
                        }

                        NumberAnimation {
                            target: this.parent
                            property: "scale"
                            from: 1.05
                            to: 1.0
                            duration: 1000
                        }
                    }
                }

                // Coming soon message
                Column {
                    width: parent.width
                    spacing: 15

                    Text {
                        text: "📡 Camera System"
                        color: accentColor
                        font.pixelSize: 25
                        font.bold: true
                        font.family: "Audiowide"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "COMING SOON"
                        color: textColor  // Theme-aware
                        font.pixelSize: 35
                        font.bold: true
                        font.family: "Audiowide"
                        anchors.horizontalCenter: parent.horizontalCenter

                        // Glitch effect animation
                        SequentialAnimation {
                            running: true
                            loops: Animation.Infinite

                            PropertyAnimation {
                                target: this
                                property: "opacity"
                                from: 1.0
                                to: 0.7
                                duration: 200
                            }

                            PropertyAnimation {
                                target: this
                                property: "opacity"
                                from: 0.7
                                to: 1.0
                                duration: 200
                            }

                            PauseAnimation { duration: 2000 }
                        }
                    }
                }

                // Progress indicator
                Rectangle {
                    width: parent.width * 0.6
                    height: 6
                    radius: 3
                    color: darkTheme ? "#333333" : "#CCCCCC"  // Theme-aware
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        width: parent.width * 0.4
                        height: parent.height
                        radius: 3
                        color: accentColor

                        SequentialAnimation {
                            running: true
                            loops: Animation.Infinite

                            PropertyAnimation {
                                target: this
                                property: "width"
                                from: parent.width * 0.1
                                to: parent.width * 0.9
                                duration: 2000
                            }

                            PropertyAnimation {
                                target: this
                                property: "width"
                                from: parent.width * 0.9
                                to: parent.width * 0.1
                                duration: 2000
                            }
                        }
                    }
                }
            }

            // Back to dashboard button
            Rectangle {
                width: 120
                height: 40
                radius: 8
                color: accentColor
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: "⬅ Back"
                    color: "#000000"
                    font.pixelSize: 16
                    font.bold: true
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Returning to dashboard")
                        activeRightPaneApp = "mediaPlayer"
                    }
                }
            }
        }
    }

    // ============ RADIO FM =============
    Component {
        id: musicView
        Rectangle {
            id: musicPlayerScreen
            color: panelColor
            anchors.fill: parent

            property bool isPlaying: false
            property string currentStation: "Red FM 93.5"
            property real volume: 0.7
            property int currentStationIndex: 0

            property var radioStations:
                [
                    {
                        name: "Radio BollyFM",
                        url: "http://stream.radiobollyfm.in:8201/;stream.mp3",
                        genre: "Hindi / Bollywood",
                        icon: "🎶"
                    },
                    {
                    "name": "Retro Song",
                    "url": "qrc:/audio/retro.mp3",
                    "genre": "Hindi Songs (Backup)",
                    "icon": "🎶"
                    }
                ]

            MediaPlayer {
                id: radioPlayer
                volume: musicPlayerScreen.volume
                source: musicPlayerScreen.radioStations[0].url

                onPlaying: {
                    musicPlayerScreen.isPlaying = true
                    console.log("✅ PLAYING: " + musicPlayerScreen.currentStation)
                }
                onPaused: {
                    musicPlayerScreen.isPlaying = false
                }
                onError: {
                    console.log("Error: " + errorString)
                    musicPlayerScreen.isPlaying = false
                }
            }

            Column {
                anchors.centerIn: parent
                width: parent.width * 0.95
                spacing: 25

                // Radio Station Display
                Item {
                    width: 180
                    height: 180
                    anchors.horizontalCenter: parent.horizontalCenter

                    // WAVEFORM BACKGROUND EFFECT
                    Canvas {
                        id: waveformCanvas
                        anchors.fill: parent
                        visible: musicPlayerScreen.isPlaying

                        property real amplitude: 0.5
                        property real frequency: 0.5
                        property real phase: 0

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();

                            // Draw waveform background
                            ctx.strokeStyle = "#7B1FA2";
                            ctx.lineWidth = 2;
                            ctx.globalAlpha = 0.3;

                            ctx.beginPath();

                            var centerX = width / 2;
                            var centerY = height / 2;
                            var radius = 70;

                            for (var i = 0; i <= 360; i++) {
                                var angle = i * Math.PI / 180;
                                var wave = amplitude * Math.sin(frequency * angle + phase);
                                var r = radius + wave * 20;
                                var x = centerX + r * Math.cos(angle);
                                var y = centerY + r * Math.sin(angle);

                                if (i === 0) {
                                    ctx.moveTo(x, y);
                                } else {
                                    ctx.lineTo(x, y);
                                }
                            }

                            ctx.closePath();
                            ctx.stroke();
                        }

                        // Animate waveform
                        SequentialAnimation {
                            running: musicPlayerScreen.isPlaying
                            loops: Animation.Infinite

                            ParallelAnimation {
                                NumberAnimation {
                                    target: waveformCanvas
                                    property: "phase"
                                    from: 0
                                    to: Math.PI * 2
                                    duration: 2000
                                }
                                NumberAnimation {
                                    target: waveformCanvas
                                    property: "amplitude"
                                    from: 0.3
                                    to: 0.7
                                    duration: 1500
                                }
                            }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: waveformCanvas
                                    property: "phase"
                                    from: Math.PI * 2
                                    to: Math.PI * 4
                                    duration: 2000
                                }
                                NumberAnimation {
                                    target: waveformCanvas
                                    property: "amplitude"
                                    from: 0.7
                                    to: 0.3
                                    duration: 1500
                                }
                            }
                        }

                        Component.onCompleted: requestPaint()
                    }

                    // PULSING RINGS EFFECT
                    Repeater {
                        model: musicPlayerScreen.isPlaying ? 3 : 0

                        Rectangle {
                            id: ring
                            width: 160
                            height: 160
                            radius: width / 2
                            color: "transparent"
                            border.color: index === 0 ? "#4CAF50" :
                                        index === 1 ? "#7B1FA2" :
                                                    "#FF9800"
                            border.width: 2
                            anchors.centerIn: parent
                            opacity: 0

                            PropertyAnimation {
                                id: ringAnim
                                target: ring
                                property: "scale"
                                from: 0.8
                                to: 1.3
                                duration: 2000 + index * 500
                                running: musicPlayerScreen.isPlaying
                                loops: Animation.Infinite
                            }

                            PropertyAnimation {
                                target: ring
                                property: "opacity"
                                from: 0.8
                                to: 0
                                duration: 2000 + index * 500
                                running: musicPlayerScreen.isPlaying
                                loops: Animation.Infinite
                            }
                        }
                    }

                    // Main Station Container with BOUNCE effect
                    Rectangle {
                        id: stationArtContainer
                        width: 160
                        height: 160
                        radius: 20
                        anchors.centerIn: parent
                        color: darkTheme ? "#1A1A1A" : "#F0F0F0"  // Theme-aware

                        // Bounce animation
                        SequentialAnimation {
                            id: bounceAnim
                            running: musicPlayerScreen.isPlaying
                            loops: Animation.Infinite

                            ParallelAnimation {
                                NumberAnimation {
                                    target: stationArtContainer
                                    property: "scale"
                                    from: 1.0
                                    to: 1.03
                                    duration: 600
                                    easing.type: Easing.OutBack
                                }
                                NumberAnimation {
                                    target: stationArtContainer
                                    property: "y"
                                    from: stationArtContainer.y
                                    to: stationArtContainer.y - 5
                                    duration: 600
                                    easing.type: Easing.OutBack
                                }
                            }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: stationArtContainer
                                    property: "scale"
                                    from: 1.03
                                    to: 1.0
                                    duration: 600
                                    easing.type: Easing.InBack
                                }
                                NumberAnimation {
                                    target: stationArtContainer
                                    property: "y"
                                    from: stationArtContainer.y - 5
                                    to: stationArtContainer.y
                                    duration: 600
                                    easing.type: Easing.InBack
                                }
                            }
                            PauseAnimation { duration: 800 }
                        }

                        // Station Art with Gradient
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 3
                            radius: 17
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#2196F3" }	// Blue
                                GradientStop { position: 0.5; color: "#9C27B0" }	// Purple
                                GradientStop { position: 1.0; color: "#673AB7" }	// Deep Purple
                            }

                            // Shimmer Effect
                            Rectangle {
                                id: shimmer
                                width: parent.width * 0.3
                                height: parent.height
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "transparent" }
                                    GradientStop { position: 0.5; color: "#FFFFFF" }
                                    GradientStop { position: 1.0; color: "transparent" }
                                }
                                opacity: 0
                                rotation: 30

                                SequentialAnimation {
                                    running: musicPlayerScreen.isPlaying
                                    loops: Animation.Infinite
                                    PauseAnimation { duration: 2000 }
                                    ParallelAnimation {
                                        NumberAnimation {
                                            target: shimmer
                                            property: "opacity"
                                            from: 0
                                            to: 0.3
                                            duration: 800
                                        }
                                        NumberAnimation {
                                            target: shimmer
                                            property: "x"
                                            from: -shimmer.width
                                            to: parent.width + shimmer.width
                                            duration: 1200
                                            easing.type: Easing.InOutQuad
                                        }
                                    }
                                    NumberAnimation {
                                        target: shimmer
                                        property: "opacity"
                                        from: 0.3
                                        to: 0
                                        duration: 400
                                    }
                                }
                            }

                            Column {
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    text: musicPlayerScreen.radioStations[musicPlayerScreen.currentStationIndex].icon
                                    font.pixelSize: 60
                                    color: "#FFFFFF"
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    // Floating animation
                                    SequentialAnimation {
                                        running: musicPlayerScreen.isPlaying
                                        loops: Animation.Infinite

                                        ParallelAnimation {
                                            NumberAnimation {
                                                target: this
                                                property: "y"
                                                from: this.y
                                                to: this.y - 5
                                                duration: 1500
                                                easing.type: Easing.InOutSine
                                            }
                                            NumberAnimation {
                                                target: this
                                                property: "scale"
                                                from: 1.0
                                                to: 1.1
                                                duration: 1500
                                            }
                                        }
                                        ParallelAnimation {
                                            NumberAnimation {
                                                target: this
                                                property: "y"
                                                from: this.y - 5
                                                to: this.y
                                                duration: 1500
                                                easing.type: Easing.InOutSine
                                            }
                                            NumberAnimation {
                                                target: this
                                                property: "scale"
                                                from: 1.1
                                                to: 1.0
                                                duration: 1500
                                            }
                                        }
                                    }
                                }

                                Text {
                                    text: "FM RADIO"
                                    color: "#FFFFFF"
                                    font.pixelSize: 14
                                    font.bold: true
                                    font.family: "Audiowide"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }

                    // MUSIC BARS EFFECT
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -10
                        spacing: 3
                        visible: musicPlayerScreen.isPlaying

                        Repeater {
                            model: 5

                            Rectangle {
                                width: 6
                                height: 10
                                radius: 1
                                color: index === 0 ? "#FF5722" :
                                    index === 1 ? "#FF9800" :
                                    index === 2 ? "#4CAF50" :
                                    index === 3 ? "#2196F3" :
                                                    "#9C27B0"

                                SequentialAnimation {
                                    running: musicPlayerScreen.isPlaying
                                    loops: Animation.Infinite

                                    PropertyAnimation {
                                        target: this
                                        property: "height"
                                        from: 10
                                        to: 40 + Math.random() * 20
                                        duration: 300 + Math.random() * 200
                                        easing.type: Easing.OutQuad
                                    }
                                    PropertyAnimation {
                                        target: this
                                        property: "height"
                                        from: 40 + Math.random() * 20
                                        to: 10
                                        duration: 300 + Math.random() * 200
                                        easing.type: Easing.InQuad
                                    }
                                    PauseAnimation { duration: Math.random() * 300 }
                                }
                            }
                        }
                    }
                }

                // Station Info
                Column {
                    width: parent.width
                    spacing: 10

                    Text {
                        text: musicPlayerScreen.currentStation
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        color: textColor  // Theme-aware
                        font.pixelSize: 22
                        font.bold: true
                        font.family: "Audiowide"
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight

                        // Text glow animation
                        SequentialAnimation {
                            running: musicPlayerScreen.isPlaying
                            loops: Animation.Infinite
                            NumberAnimation {
                                target: this
                                property: "opacity"
                                from: 0.8
                                to: 1.0
                                duration: 1000
                            }
                            NumberAnimation {
                                target: this
                                property: "opacity"
                                from: 1.0
                                to: 0.8
                                duration: 1000
                            }
                        }
                    }

                    Text {
                        text: musicPlayerScreen.radioStations[musicPlayerScreen.currentStationIndex].genre
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        color: secondaryTextColor  // Theme-aware
                        font.pixelSize: 14
                        font.family: "Roboto"
                    }

                    // Live Status Indicator
                    Rectangle {
                        width: 70
                        height: 25
                        radius: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: musicPlayerScreen.isPlaying ? "#4CAF50" : "#666666"

                        Row {
                            anchors.centerIn: parent
                            spacing: 4

                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: "#FFFFFF"
                                anchors.verticalCenter: parent.verticalCenter
                                opacity: musicPlayerScreen.isPlaying ? 1.0 : 0.5

                                SequentialAnimation {
                                    running: musicPlayerScreen.isPlaying
                                    loops: Animation.Infinite
                                    NumberAnimation {
                                        target: this
                                        property: "scale"
                                        from: 1.0
                                        to: 1.5
                                        duration: 800
                                    }
                                    NumberAnimation {
                                        target: this
                                        property: "scale"
                                        from: 1.5
                                        to: 1.0
                                        duration: 800
                                    }
                                }
                            }

                            Text {
                                text: musicPlayerScreen.isPlaying ? "LIVE" : "OFFLINE"
                                color: "#FFFFFF"
                                font.pixelSize: 10
                                font.bold: true
                                font.family: "Roboto"
                            }
                        }
                    }
                }

                // Control Buttons
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 25

                    // Previous Station
                    Rectangle {
                        width: 55
                        height: 55
                        radius: 27
                        color: darkTheme ? "#333333" : "#E0E0E0"  // Theme-aware

                        Text {
                            text: "◀◀"
                            anchors.centerIn: parent
                            color: darkTheme ? "#FFFFFF" : "#000000"  // Theme-aware
                            font.pixelSize: 22
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var newIndex = (musicPlayerScreen.currentStationIndex - 1 + 2) % 2
                                musicPlayerScreen.currentStationIndex = newIndex
                                musicPlayerScreen.currentStation = musicPlayerScreen.radioStations[newIndex].name
                                radioPlayer.stop()
                                radioPlayer.source = musicPlayerScreen.radioStations[newIndex].url
                                radioPlayer.play()
                            }

                            onPressed: parent.scale = 0.9
                            onReleased: parent.scale = 1.0
                        }

                        Behavior on scale {
                            NumberAnimation { duration: 100 }
                        }
                    }

                    // Play/Pause Button
                    Rectangle {
                        width: 70
                        height: 70
                        radius: 35
                        color: musicPlayerScreen.isPlaying ? "#4CAF50" : accentColor

                        Text {
                            text: musicPlayerScreen.isPlaying ? "⏸" : "▶"
                            anchors.centerIn: parent
                            color: "#000000"
                            font.pixelSize: 28
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (musicPlayerScreen.isPlaying) {
                                    radioPlayer.pause()
                                } else {
                                    radioPlayer.play()
                                }
                            }

                            onPressed: parent.scale = 0.9
                            onReleased: parent.scale = 1.0
                        }

                        Behavior on scale {
                            NumberAnimation { duration: 100 }
                        }
                    }

                    // Next Station
                    Rectangle {
                        width: 55
                        height: 55
                        radius: 27
                        color: darkTheme ? "#333333" : "#E0E0E0"  // Theme-aware

                        Text {
                            text: "▶▶"
                            anchors.centerIn: parent
                            color: darkTheme ? "#FFFFFF" : "#000000"  // Theme-aware
                            font.pixelSize: 22
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var newIndex = (musicPlayerScreen.currentStationIndex + 1) % 2
                                musicPlayerScreen.currentStationIndex = newIndex
                                musicPlayerScreen.currentStation = musicPlayerScreen.radioStations[newIndex].name
                                radioPlayer.stop()
                                radioPlayer.source = musicPlayerScreen.radioStations[newIndex].url
                                radioPlayer.play()
                            }

                            onPressed: parent.scale = 0.9
                            onReleased: parent.scale = 1.0
                        }

                        Behavior on scale {
                            NumberAnimation { duration: 100 }
                        }
                    }
                }

                // Station Selector
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "STATIONS"
                        color: secondaryTextColor  // Theme-aware
                        font.pixelSize: 12
                        font.bold: true
                        font.family: "Audiowide"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 15

                        Repeater {
                            model: musicPlayerScreen.radioStations

                            Rectangle {
                                width: 80
                                height: 50
                                radius: 8
                                color: musicPlayerScreen.currentStationIndex === index ? "#4CAF50" : (darkTheme ? "#1A1A1A" : "#F0F0F0")  // Theme-aware
                                border.color: musicPlayerScreen.currentStationIndex === index ? "#FFFFFF" : (darkTheme ? "#333333" : "#DDDDDD")  // Theme-aware
                                border.width: 2

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Text {
                                        text: modelData.icon
                                        font.pixelSize: 16
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    Text {
                                        text: "STATION " + (index + 1)
                                        color: musicPlayerScreen.currentStationIndex === index ? "#000000" : (darkTheme ? textColor : "#333333")  // Theme-aware
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        musicPlayerScreen.currentStationIndex = index
                                        musicPlayerScreen.currentStation = modelData.name
                                        radioPlayer.stop()
                                        radioPlayer.source = modelData.url
                                        radioPlayer.play()
                                    }

                                    onPressed: parent.scale = 0.95
                                    onReleased: parent.scale = 1.0
                                }

                                Behavior on scale {
                                    NumberAnimation { duration: 100 }
                                }
                            }
                        }
                    }
                }

                // Volume Control
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    width: parent.width * 0.9

                    Text {
                        text: "🔈"
                        color: secondaryTextColor  // Theme-aware
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Slider {
                        id: volumeSliderRadio
                        width: parent.width - 50
                        from: 0
                        to: 1.0
                        value: musicPlayerScreen.volume

                        background: Rectangle {
                            x: parent.leftPadding
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            implicitWidth: 150
                            implicitHeight: 5
                            width: parent.availableWidth
                            height: implicitHeight
                            radius: 2
                            color: darkTheme ? "#333333" : "#CCCCCC"  // Theme-aware

                            Rectangle {
                                width: parent.width * musicPlayerScreen.volume
                                height: parent.height
                                color: "#4CAF50"
                                radius: 2
                            }
                        }

                        handle: Rectangle {
                            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            implicitWidth: 20
                            implicitHeight: 20
                            radius: 10
                            color: darkTheme ? "#FFFFFF" : "#F0F0F0"  // Theme-aware
                            border.color: "#4CAF50"
                            border.width: 2
                        }

                        onValueChanged: {
                            musicPlayerScreen.volume = value
                            radioPlayer.volume = value
                        }
                    }

                    Text {
                        text: "🔊"
                        color: secondaryTextColor  // Theme-aware
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }

    // ================== YOUTUBE MUSIC ==================
    Component {
        id: mediaView
        Rectangle {
            color: panelColor
            anchors.fill: parent

            WebView {
                id: media
                anchors.fill: parent
                anchors.margins: 2  // Small margin
                url: "https://music.youtube.com/"

                onLoadingChanged: {
                    if (loadRequest.status === WebView.LoadSucceededStatus) {
                        console.log("YouTube Music loaded successfully")
                    }
                }
            }
        }
    }

    // ================ BROWSER ====================
    Component {
        id: browserView
        Rectangle {
            color: panelColor
            anchors.fill: parent

            WebView {
                id: browser
                anchors.fill: parent
                anchors.margins: 2  // Small margin
                url: "https://www.google.com/?ion=1"

                onLoadingChanged: {
                    if (loadRequest.status === WebView.LoadSucceededStatus) {
                        console.log("Browser loaded successfully")
                    }
                }
            }
        }
    }

    // ============== PLAY STORE ===============
    Component {
        id: playstoreView
        Rectangle {
            color: panelColor
            anchors.fill: parent

            WebView {
                id: playStore
                anchors.fill: parent
                anchors.margins: 2  // Small margin
                url: "https://play.google.com/store"

                onLoadingChanged: {
                    if (loadRequest.status === WebView.LoadSucceededStatus) {
                        console.log("Play Store loaded successfully")
                    }
                }
            }
        }
    }

    // =================== CLIMATE =====================
    // Component {
    // 	id: climateView
    // 	Rectangle {
    //     	color: panelColor
    //     	anchors.fill: parent

    //     	Column {
    //         	anchors.centerIn: parent
    //         	spacing: 15
    //         	width: parent.width * 0.9

    //         	Text {
    //             	text: "🌡️ Climate Control"
    //             	color: temperatureColor
    //             	font.pixelSize: 18
    //             	font.bold: true
    //             	anchors.horizontalCenter: parent.horizontalCenter
    //         	}

    //         	Rectangle {
    //             	width: 120
    //             	height: 120
    //             	radius: 60
    //             	color: backgroundColor  // Theme-aware
    //             	border.color: temperatureColor
    //             	border.width: 3
    //             	anchors.horizontalCenter: parent.horizontalCenter

    //             	Text {
    //                 	text: temperature + "°C"
    //                 	color: temperatureColor
    //                 	font.pixelSize: 26
    //                 	font.bold: true
    //                 	anchors.centerIn: parent
    //             	}
    //         	}

    //         	Row {
    //             	spacing: 15
    //             	anchors.horizontalCenter: parent.horizontalCenter

    //             	Button {
    //                 	text: "Cool"
    //                 	width: 50; height: 35
    //                 	background: Rectangle {
    //                     	color: "#3FFFD8"
    //                     	radius: 5
    //                 	}
    //                 	onClicked: temperature = Math.max(15, temperature - 5)
    //             	}

    //             	Button {
    //                 	text: "Auto"
    //                 	width: 50; height: 35
    //                 	background: Rectangle {
    //                     	color: darkTheme ? "#FFFFFF" : "#333333"  // Theme-aware
    //                     	radius: 5
    //                 	}
    //             	}

    //             	Button {
    //                 	text: "Heat"
    //                 	width: 50; height: 35
    //                 	background: Rectangle {
    //                     	color: "#FF7043"
    //                     	radius: 5
    //                 	}
    //                 	onClicked: temperature = Math.min(65, temperature + 5)
    //             	}
    //         	}
    //     	}
    // 	}
    // }
    Component {
        id: climateView
        Rectangle {
            color: panelColor
            anchors.fill: parent

            property string dashboardUrl: {
                if (Qt.platform.os === "android") {
                    return "file:///android_asset/dashboard.html";
                } else if (Qt.platform.os === "ios") {
                    return "file:///dashboard.html";
                } else { // For desktop - use absolute path
                    return "file:///home/votarytech/Desktop/qt%20qml/updtd_ivi_24feb/updtd_ivi_13_02/333333/android/assets/dashboard.html";
                }
            }

            WebView {
                id: playStore
                anchors.fill: parent
                anchors.margins: 2
                url: dashboardUrl  // SET THE URL HERE

                onLoadingChanged: {
                    if (loadRequest.status === WebView.LoadSucceededStatus) {
                        console.log("Dashboard loaded successfully on", Qt.platform.os)
                    } else if (loadRequest.status === WebView.LoadFailedStatus) {
                        console.log("Failed to load:", loadRequest.errorString)
                    }
                }
            }
        }
    }

    // ============= PHONE GAME VIEW ================
    Component {
        id: phoneView
        Rectangle {
            color: panelColor
            anchors.fill: parent

            WebView {
                id: phone
                anchors.fill: parent
                anchors.margins: 2  // Small margin
                url: "https://neave.com/"

                // Inject navigation buttons EVERY TIME page loads
                onLoadingChanged: {
                    if (loadRequest.status === WebView.LoadSucceededStatus) {
                        console.log("Game loaded successfully")
                        injectNavigationButtons()
                    }
                }

                // Function to inject navigation buttons
                function injectNavigationButtons() {
                    phone.runJavaScript(`
                        // Remove existing navigation bar if any
                        var existingNav = document.getElementById('phone-nav-bar');
                        if (existingNav) {
                            existingNav.remove();
                        }

                        // Create navigation bar
                        var navBar = document.createElement('div');
                        navBar.id = 'phone-nav-bar';
                        navBar.style.position = 'fixed';
                        navBar.style.top = '10px';
                        navBar.style.right = '10px';
                        navBar.style.zIndex = '9999';
                        navBar.style.display = 'flex';
                        navBar.style.gap = '10px';

                        // Back button
                        var backBtn = document.createElement('button');
                        backBtn.innerHTML = '←';
                        backBtn.style.width = '35px';
                        backBtn.style.height = '35px';
                        backBtn.style.backgroundColor = '#3FFFD8';
                        backBtn.style.border = 'none';
                        backBtn.style.borderRadius = '5px';
                        backBtn.style.fontSize = '18px';
                        backBtn.style.color = 'white';
                        backBtn.style.cursor = 'pointer';
                        backBtn.style.boxShadow = '0 2px 5px rgba(0,0,0,0.3)';

                        // Add hover effect
                        backBtn.onmouseover = function() {
                            this.style.transform = 'scale(1.1)';
                            this.style.boxShadow = '0 4px 8px rgba(0,0,0,0.4)';
                        };
                        backBtn.onmouseout = function() {
                            this.style.transform = 'scale(1)';
                            this.style.boxShadow = '0 2px 5px rgba(0,0,0,0.3)';
                        };

                        backBtn.onclick = function(e) {
                            e.preventDefault();
                            e.stopPropagation();
                            if (window.history.length > 1) {
                                window.history.back();
                            } else {
                                window.location.href = 'https://neave.com/';
                            }
                        };

                        // Reload button
                        var reloadBtn = document.createElement('button');
                        reloadBtn.innerHTML = '↻';
                        Object.keys(backBtn.style).forEach(key => {
                            if (key !== 'onclick' && key !== 'onmouseover' && key !== 'onmouseout') {
                                reloadBtn.style[key] = backBtn.style[key];
                            }
                        });
                        reloadBtn.onmouseover = backBtn.onmouseover;
                        reloadBtn.onmouseout = backBtn.onmouseout;
                        reloadBtn.onclick = function(e) {
                            e.preventDefault();
                            e.stopPropagation();
                            location.reload();
                        };

                        // Close button
                        var closeBtn = document.createElement('button');
                        closeBtn.innerHTML = '✕';
                        Object.keys(backBtn.style).forEach(key => {
                            if (key !== 'onclick' && key !== 'onmouseover' && key !== 'onmouseout' && key !== 'backgroundColor') {
                                closeBtn.style[key] = backBtn.style[key];
                            }
                        });
                        closeBtn.style.backgroundColor = '#FF4444';
                        closeBtn.onmouseover = backBtn.onmouseover;
                        closeBtn.onmouseout = backBtn.onmouseout;
                        closeBtn.onclick = function(e) {
                            e.preventDefault();
                            e.stopPropagation();
                            // Signal to QML to close
                            window.location.hash = '#close';
                        };

                        navBar.appendChild(backBtn);
                        navBar.appendChild(reloadBtn);
                        navBar.appendChild(closeBtn);
                        document.body.appendChild(navBar);

                        // Ensure buttons stay even after navigation
                        var observer = new MutationObserver(function() {
                            if (!document.body.contains(navBar)) {
                                document.body.appendChild(navBar);
                            }
                        });
                        observer.observe(document.body, { childList: true });
                    `);
                }

                // Check for close signal from JavaScript
                onUrlChanged: {
                    if (phone.url.toString().indexOf('#close') !== -1) {
                        activeRightPaneApp = "mediaPlayer"
                    }
                }

                // Initial injection when component loads
                Component.onCompleted: {
                    if (phone.loadProgress === 100) {
                        injectNavigationButtons();
                    }
                }
            }
        }
    }

    // ================= SCREEN MIRROR VIEW ==================
    Component {
        id: mirrorView
        Rectangle {
            id: mirrorScreen
            color: "black"
            anchors.fill: parent

            property bool mirroring: false
            property bool fullScreenMode: false

            // Full screen mirroring view (shown when mirroring is active)
            Rectangle {
                id: fullScreenMirror
                anchors.fill: parent
                color: "black"
                visible: fullScreenMode

                // Full screen mirrored image
                Image {
                    id: fullScreenImage
                    anchors.fill: parent
                    anchors.bottomMargin: 30  // Space for control bar
                    fillMode: Image.PreserveAspectFit
                    cache: false
                    source: "image://mirror/live"
                }

                // Mobile-style control bar at bottom
                Rectangle {
                    id: fullScreenControls
                    width: parent.width
                    height: 30
                    color: "#111"
                    anchors.bottom: parent.bottom
                    opacity: 0.9

                    // Gradient overlay for better visibility
                    LinearGradient {
                        anchors.fill: parent
                        start: Qt.point(0, 0)
                        end: Qt.point(0, parent.height)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#111111DD" }
                            GradientStop { position: 1.0; color: "#111111FF" }
                        }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 30

                        // Exit Full Screen button (small)
                        /*Rectangle {
                            width: 45
                            height: 45
                            radius: 8
                            color: "#333333"

                            Text {
                                text: "◁"
                                color: "#3FFFD8"
                                font.pixelSize: 18
                                font.bold: true
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    fullScreenMode = false
                                }
                                onPressed: parent.scale = 0.9
                                onReleased: parent.scale = 1.0
                            }

                            Behavior on scale {
                                NumberAnimation { duration: 100 }
                            }
                        }*/

                        // Stop Mirroring button (small)
                        Rectangle {
                            width: 50
                            height: 20
                            radius: 5
                            color: "#FF11FF"

                            Text {
                                text: "STOP"
                                color: "#FFFFFF"
                                font.pixelSize: 12
                                font.bold: true
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    MirrorManager.stopMirroring()
                                    mirrorScreen.mirroring= false
                                    fullScreenMode = false
                                }
                                onPressed: parent.scale = 0.9
                                onReleased: parent.scale = 1.0
                            }

                            Behavior on scale {
                                NumberAnimation { duration: 100 }
                            }
                        }

                        // LIVE status indicator (small)
                        Rectangle {
                            width: 65
                            height: 25
                            radius: 12
                            color: "#4CAF50"

                            Row {
                                anchors.centerIn: parent
                                spacing: 5

                                Rectangle {
                                    width: 6
                                    height: 6
                                    radius: 3
                                    color: "#FFFFFF"
                                    anchors.verticalCenter: parent.verticalCenter

                                    SequentialAnimation {
                                        running: true
                                        loops: Animation.Infinite
                                        NumberAnimation {
                                            target: this
                                            property: "opacity"
                                            from: 1.0
                                            to: 0.3
                                            duration: 800
                                        }
                                        NumberAnimation {
                                            target: this
                                            property: "opacity"
                                            from: 0.3
                                            to: 1.0
                                            duration: 800
                                        }
                                    }
                                }

                                Text {
                                    text: "LIVE"
                                    color: "#000000"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }
                        }
                    }

                    // IP info at bottom left (small)
                    Text {
                        text: NetworkManager.isConnected ?
                            NetworkManager.ipAddress : "No IP"
                        color: "#3FFFD8"
                        font.pixelSize: 10
                        font.bold: true
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Network type at bottom right (small)
                    Text {
                        text: NetworkManager.isConnected ?
                            NetworkManager.networkType : "No Network"
                        color: "#AAAAAA"
                        font.pixelSize: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Tap to show/hide controls (optional)
                /*MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        fullScreenControls.visible = !fullScreenControls.visible
                    }
                }*/
            }

            // Normal view (shown when not in full screen)
            Column {
                anchors.fill: parent
                spacing: 10
                visible: !fullScreenMode

                // Title
                Text {
                    text: "📱 Screen Mirroring"
                    color: "#3FFFD8"
                    font.pixelSize: 22
                    font.bold: true
                    font.family: "Audiowide"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 20
                }

                // IP Address Display Section
                Rectangle {
                    width: parent.width - 40
                    height: 90
                    radius: 15
                    color: "#111"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 70

                    Column {
                        anchors.centerIn: parent
                        spacing: 5
                        width: parent.width * 0.9

                        // Network Status
                        Row {
                            spacing: 10
                            anchors.horizontalCenter: parent.horizontalCenter

                            Rectangle {
                                width: 10
                                height: 10
                                radius: 5
                                color: NetworkManager.isConnected ? "#4CAF50" : "#FF4444"
                                anchors.verticalCenter: parent.verticalCenter

                                SequentialAnimation {
                                    running: NetworkManager.isConnected
                                    loops: Animation.Infinite
                                    NumberAnimation {
                                        target: this
                                        property: "opacity"
                                        from: 1.0
                                        to: 0.3
                                        duration: 1000
                                    }
                                    NumberAnimation {
                                        target: this
                                        property: "opacity"
                                        from: 0.3
                                        to: 1.0
                                        duration: 1000
                                    }
                                }
                            }

                            Text {
                                text: NetworkManager.isConnected ?
                                    NetworkManager.networkType + " Connected" :
                                    "No Network"
                                color: NetworkManager.isConnected ? "#4CAF50" : "#FF4444"
                                font.pixelSize: 14
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // IP Address
                        Text {
                            text: NetworkManager.isConnected ? NetworkManager.ipAddress : "No IP Address"
                            color: "#3FFFD8"
                            font.pixelSize: 28
                            font.bold: true
                            font.family: "Monospace"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        // Port Info
                        Text {
                            text: NetworkManager.isConnected ?
                                "Port: 8080 • " + NetworkManager.networkName :
                                "Connect to Wi-Fi or Ethernet"
                            color: "#AAA"
                            font.pixelSize: 12
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                // Preview display area
                Rectangle {
                    id: display
                    width: parent.width - 40
                    height: parent.height - 230
                    color: "#111"
                    radius: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 175

                    Image {
                        id: mirrorViewImage
                        anchors.fill: parent
                        anchors.margins: 5
                        fillMode: Image.PreserveAspectFit
                        cache: false
                        source: mirrorScreen.mirroring ? "image://mirror/live" : ""

                        // Show placeholder when not mirroring
                        Rectangle {
                            anchors.fill: parent
                            color: "#222"
                            radius: 8
                            visible: !mirrorScreen.mirroring

                            Column {
                                anchors.centerIn: parent
                                spacing: 20
                                width: parent.width * 0.8

                                Text {
                                    text: NetworkManager.isConnected ? "📱" : "📶"
                                    font.pixelSize: 60
                                    color: NetworkManager.isConnected ? "#666" : "#FF4444"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: NetworkManager.isConnected ? "Ready for Mirroring" : "Connect to Network"
                                    color: NetworkManager.isConnected ? "#3FFFD8" : "#FF4444"
                                    font.pixelSize: 20
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    width: parent.width
                                    text: NetworkManager.isConnected ?
                                        "1. Connect phone to same " + NetworkManager.networkType + "\n" +
                                        "2. Open mirroring app on phone\n" +
                                        "3. Enter IP: " + NetworkManager.ipAddress + ":8080\n" +
                                        "4. Tap 'Start Mirroring' below" :
                                        "Please connect to Wi-Fi or Ethernet\n" +
                                        "to enable screen mirroring"
                                    color: "#AAA"
                                    font.pixelSize: 14
                                    wrapMode: Text.WordWrap
                                    horizontalAlignment: Text.AlignHCenter
                                    lineHeight: 1.4
                                }
                            }
                        }
                    }
                }

                // Control buttons in normal mode
                Row {
                    spacing: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 20

                    Rectangle {
                        width: 140
                        height: 50
                        radius: 10
                        color: mirrorScreen.mirroring ? "#FF4444" :
                            NetworkManager.isConnected ? "#4CAF50" : "#666"
                        enabled: NetworkManager.isConnected

                        Text {
                            text: mirrorScreen.mirroring ? "Stop Mirroring" :
                                NetworkManager.isConnected ? "Start Mirroring" : "No Network"
                            color: "#000"
                            font.pixelSize: 14
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (mirrorScreen.mirroring) {
                                    MirrorManager.stopMirroring()
                                    mirrorScreen.mirroring = false
                                } else if (NetworkManager.isConnected) {
                                    MirrorManager.startMirroring()
                                    mirrorScreen.mirroring = true
                                    fullScreenMode = true  // Go directly to full screen
                                }
                            }
                            onPressed: parent.scale = enabled ? 0.95 : 1.0
                            onReleased: parent.scale = 1.0
                        }

                        Behavior on scale {
                            NumberAnimation { duration: 100 }
                        }
                    }

                    // Status indicator
                    Rectangle {
                        width: 120
                        height: 50
                        radius: 10
                        color: mirrorScreen.mirroring ? "#4CAF50" : "#666"

                        Row {
                            anchors.centerIn: parent
                            spacing: 8

                            Rectangle {
                                width: 10
                                height: 10
                                radius: 5
                                color: mirrorScreen.mirroring ? "#FFFFFF" : "#999"
                                anchors.verticalCenter: parent.verticalCenter

                                SequentialAnimation {
                                    running: mirrorScreen.mirroring
                                    loops: Animation.Infinite
                                    NumberAnimation {
                                        target: this
                                        property: "opacity"
                                        from: 1.0
                                        to: 0.3
                                        duration: 800
                                    }
                                    NumberAnimation {
                                        target: this
                                        property: "opacity"
                                        from: 0.3
                                        to: 1.0
                                        duration: 800
                                    }
                                }
                            }

                            Text {
                                text: mirrorScreen.mirroring ? "ACTIVE" : "INACTIVE"
                                color: mirrorScreen.mirroring ? "#000" : "#AAA"
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }
                    }
                }
            }

            // Handle image updates
            Connections {
                target: MirrorManager
                function onFrameUpdated() {
                    if (mirrorScreen.mirroring) {
                        if (fullScreenMode) {
                            fullScreenImage.source = ""
                            fullScreenImage.source = "image://mirror/live"
                        } else {
                            mirrorViewImage.source = ""
                            mirrorViewImage.source = "image://mirror/live"
                        }
                    }
                }
            }

            // Clean up when component is destroyed
            Component.onDestruction: {
                if (mirrorScreen.mirroring) {
                    MirrorManager.stopMirroring()
                }
            }

            Component.onCompleted: {
                // Refresh network info when screen loads
                if (typeof NetworkManager !== 'undefined') {
                    NetworkManager.refreshNetworkInfo()
                }
            }
        }
    }

    // ================ E-CALL ====================
    Component {
        id: ecallView
        Rectangle {
            anchors.fill: parent
            color: "black"

            Column {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.8

                Text {
                    text: "🚨 EMERGENCY CALL SYSTEM 🚨"
                    color: "white"
                    font.pixelSize: 24
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width
                    wrapMode: Text.WordWrap
                }

                // Vehicle ID input
                Row {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        text: "Vehicle ID:"
                        color: "white"
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        id: vehicleIdInput
                        text: "OKT507C-001"
                        width: 200
                        color: "white"
                        background: Rectangle {
                            color: "#333"
                            radius: 5
                        }
                        onTextChanged: CallManager.vehicleId = text
                    }
                }

                // Current location display
                Rectangle {
                    width: parent.width
                    height: 60
                    color: "#222"
                    radius: 10
                    visible: CallManager.currentLocation !== ""

                    Column {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: "📍 Current Location"
                            color: "#888"
                            font.pixelSize: 12
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: CallManager.currentLocation
                            color: "lightblue"
                            font.pixelSize: 14
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                // Emergency button
                Button {
                    id: emergencyButton
                    text: "🚨 EMERGENCY CALL + SMS 🚨"
                    width: parent.width
                    height: 120

                    background: Rectangle {
                        color: emergencyButton.pressed ? "#8B0000" : "red"
                        radius: 30
                        border.color: "white"
                        border.width: 3
                        opacity: emergencyButton.enabled ? 1.0 : 0.5
                    }

                    contentItem: Column {
                        spacing: 5
                        anchors.centerIn: parent

                        Text {
                            text: parent.parent.text
                            color: "white"
                            font.pixelSize: 20
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            width: parent.parent.width
                            wrapMode: Text.WordWrap
                        }

                        Text {
                            text: "Call + SMS with GPS Location"
                            color: "yellow"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            width: parent.parent.width
                        }
                    }

                    onClicked: {
                        console.log("🚨 EMERGENCY BUTTON PRESSED!")
                        emergencyButton.enabled = false
                        statusText.text = "🚨 EMERGENCY ACTIVATED - Sending call and SMS with location..."

                        // Trigger full emergency sequence
                        CallManager.triggerEmergency("9182540633")
                    }

                    Connections {
                        target: CallManager

                        function onEmergencyTriggered(number, location) {
                            console.log("✅ Emergency triggered for:", number, "at:", location)
                            statusText.text = "✅ Emergency call and SMS sent!\nLocation: " + location
                            emergencyButton.enabled = true
                        }

                        function onCallFailed(number, reason) {
                            console.log("❌ Emergency failed:", reason)
                            statusText.text = "❌ Failed: " + reason
                            emergencyButton.enabled = true
                        }
                    }
                }

                // Status display
                Text {
                    id: statusText
                    text: "Press button for emergency call + SMS with location"
                    color: "gray"
                    font.pixelSize: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                // GPS status indicator
                Text {
                    text: CallManager.currentLocation ? "📍 GPS Active" : "⏳ Acquiring GPS..."
                    color: CallManager.currentLocation ? "lightgreen" : "yellow"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            // Start location updates when view is loaded
            Component.onCompleted: {
                CallManager.startLocationUpdates()
            }

            Component.onDestruction: {
                CallManager.stopLocationUpdates()
            }
        }
    }

    // ================= SETTINGS VIEW ==================
    Component {
        id: settingsView
        Rectangle {
            color: panelColor
            anchors.fill: parent

            Flickable {
                anchors.fill: parent
                contentHeight: settingsColumn.height
                clip: true

                Column {
                    id: settingsColumn
                    width: parent.width
                    spacing: 10
                    padding: 10

                    Text {
                        text: "⚙️ Settings"
                        color: "#3FFFD8"
                        font.pixelSize: 18
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    // Display Settings
                    Rectangle {
                        width: parent.width - 20
                        height: 120
                        radius: 10
                        color: backgroundColor  // Theme-aware
                        anchors.horizontalCenter: parent.horizontalCenter

                        Column {
                            anchors.fill: parent
                            padding: 10
                            spacing: 10

                            Text {
                                text: "Display Settings"
                                color: textColor  // Theme-aware
                                font.pixelSize: 14
                                font.bold: true
                            }

                            Row {
                                width: parent.width
                                spacing: 15

                                Column {
                                    spacing: 5
                                    width: 120

                                    Text {
                                        text: "Brightness: " + Math.round(brightness * 100) + "%"
                                        color: secondaryTextColor  // Theme-aware
                                        font.pixelSize: 11
                                    }

                                    Slider {
                                        width: parent.width
                                        from: 0.1
                                        to: 1.0
                                        value: brightness
                                        onValueChanged: brightness = value

                                        background: Rectangle {
                                            x: parent.leftPadding
                                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                            implicitWidth: 100
                                            implicitHeight: 3
                                            width: parent.availableWidth
                                            height: implicitHeight
                                            radius: 1
                                            color: darkTheme ? "#444444" : "#CCCCCC"

                                            Rectangle {
                                                width: parent.width * brightness
                                                height: parent.height
                                                color: "#3FFFD8"
                                                radius: 1
                                            }
                                        }

                                        handle: Rectangle {
                                            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                            implicitWidth: 14
                                            implicitHeight: 14
                                            radius: 7
                                            color: parent.pressed ? "#3FFFD8" : "#FFFFFF"
                                            border.color: "#3FFFD8"
                                            border.width: 2
                                        }
                                    }
                                }

                                Column {
                                    spacing: 5

                                    Text {
                                        text: "Theme"
                                        color: secondaryTextColor  // Theme-aware
                                        font.pixelSize: 11
                                    }

                                    Switch {
                                        checked: darkTheme
                                        onCheckedChanged: darkTheme = checked
                                        text: checked ? "Dark" : "Light"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // =============================================
    // BRIGHTNESS CONTROL OVERLAY
    // =============================================
    Rectangle {
        id: brightnessOverlay
        anchors.fill: parent
        color: "#000000"
        opacity: 1.0 - brightness  // Inverted: 0 opacity at 1.0 brightness, 0.9 opacity at 0.1 brightness
        z: 9998  // Just below the boot/black screens but above everything else
        enabled: false  // Don't block mouse events
        visible: scaler.visible && brightness < 1.0  // Only show when main UI is visible and brightness is less than 100%

        // Make sure overlay doesn't interfere with boot screens
        onVisibleChanged: {
            if (visible) {
                z = 9998
            } else {
                z = -1
            }
        }
    }
}
