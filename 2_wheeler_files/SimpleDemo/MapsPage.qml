import QtQuick 2.15
import QtWebView 1.1
import QtQuick.Controls 2.15

Page {
    id: mapsPage
    // RED BACKGROUND: If map fails, you see Red (proving the app didn't crash)
    background: Rectangle { color: "red" }

    signal backClicked()

    WebView {
        id: mapWebView
        anchors.fill: parent
        // Note: Ensure AndroidManifest.xml has usesCleartextTraffic="true"
        url: "https://www.google.com/maps"

        onLoadingChanged: {
            if (loadRequest.status === WebView.LoadStartedStatus) {
                console.log("MAPS: Loading started...")
            } else if (loadRequest.status === WebView.LoadFailedStatus) {
                console.log("MAPS: Load FAILED! " + loadRequest.errorString)
            }
        }
    }

    // --- LOADING INDICATOR ---
    Rectangle {
        anchors.centerIn: parent
        width: 300; height: 80
        color: "#111318"; radius: 10
        visible: mapWebView.loadProgress < 100
        z: 99

        Row {
            anchors.centerIn: parent
            spacing: 20
            BusyIndicator { running: true }
            Text {
                text: "Loading... " + mapWebView.loadProgress + "%"
                color: "#3FFFD8"; font.pixelSize: 24; font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // --- BACK BUTTON ---
    Button {
        text: "< Back"
        anchors.top: parent.top; anchors.left: parent.left; anchors.margins: 20
        z: 99
        background: Rectangle { color: "#333"; radius: 10; opacity: 0.8 }
        contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 30; padding: 10 }
        onClicked: mapsPage.backClicked()
    }
}
