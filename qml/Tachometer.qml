import QtQuick 2.9

Item {
    width: 260
    height: 260

    property real rpm: 5000
    property real maxRpm: 8000
    property real redline: 6000
    onRpmChanged: tachoCanvas.requestPaint()

    readonly property real startAngle: 135
    readonly property real sweepAngle: 270

    function angleFromRpm(v) {
        return startAngle + (v / maxRpm) * sweepAngle
    }

//    Canvas {

//        anchors.fill: parent
//        onPaint: {
//            var ctx = getContext("2d")
//            ctx.clearRect(0,0,width,height)

//            var cx = width/2
//            var cy = height/2
//            var r  = 120

//            // ---- ORANGE GLOW ----
//            ctx.beginPath()
//            ctx.arc(cx, cy, r, Math.PI*0.75, Math.PI*2.25)
//            ctx.lineWidth = 18
//            ctx.strokeStyle = "rgba(255,120,0,0.25)"
//            ctx.stroke()

//            // ---- MAIN RING ----
//            ctx.beginPath()
//            ctx.arc(cx, cy, r, Math.PI*0.75, Math.PI*2.25)
//            ctx.lineWidth = 6
//            ctx.strokeStyle = "#FF8C00"
//            ctx.stroke()

//            // ---- REDLINE ----
//            var redStart = angleFromRpm(redline) * Math.PI/180
//            ctx.beginPath()
//            ctx.arc(cx, cy, r, redStart, Math.PI*2.25)
//            ctx.lineWidth = 6
//            ctx.strokeStyle = "#FF2A2A"
//            ctx.stroke()
//            // ----odometer COLOR ARC (NEW ADDITION) ----
//            var gaugeColor = "#1EC8FF"   // Blue default


//            // ---- TICKS ----
//            for (var v=0; v<=maxRpm; v+=200) {
//                var a = angleFromRpm(v) * Math.PI/180
//                var major = (v % 1000 === 0)
//                var len = major ? 14 : 7

//                ctx.beginPath()
//                ctx.moveTo(cx + Math.cos(a)*(r-2),
//                           cy + Math.sin(a)*(r-2))
//                ctx.lineTo(cx + Math.cos(a)*(r-len),
//                           cy + Math.sin(a)*(r-len))
//                ctx.strokeStyle = v>=redline ? "#FF2A2A" : "white"
//                ctx.lineWidth = major ? 2 : 1
//                ctx.stroke()

//                if (major) {
//                    ctx.fillStyle = "white"
//                    ctx.font = "bold 12px Sans"
//                    ctx.textAlign = "center"
//                    ctx.fillText(
//                        v/1000,
//                        cx + Math.cos(a)*(r-30),
//                        cy + Math.sin(a)*(r-30)
//                    )
//                }
//            }
//        }
//    }
    Canvas {
        id: tachoCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0,0,width,height)

            var cx = width/2
            var cy = height/2
            var r  = 120

            var startRad = startAngle * Math.PI/180
            var endRad = (startAngle + sweepAngle) * Math.PI/180
            var rpmRad = angleFromRpm(rpm) * Math.PI/180

            // ---- ORANGE GLOW ----
            ctx.beginPath()
            ctx.arc(cx, cy, r, startRad, endRad)
            ctx.lineWidth = 18
            ctx.strokeStyle = "rgba(255,120,0,0.25)"
            ctx.stroke()

            // ---- MAIN RING ----
            ctx.beginPath()
            ctx.arc(cx, cy, r, startRad, endRad)
            ctx.lineWidth = 6
            ctx.strokeStyle = "#FF8C00"
            ctx.stroke()

            // ---- REDLINE ZONE ----
            var redStart = angleFromRpm(redline) * Math.PI/180
            ctx.beginPath()
            ctx.arc(cx, cy, r, redStart, endRad)
            ctx.lineWidth = 10
            ctx.strokeStyle = "#FF2A2A"
            ctx.stroke()

            // ---- RPM PROGRESS ARC (Needle Replacement) ----
            var gaugeColor = "#1EC8FF"//"#FF8C00"   // default orange

            if (rpm >= redline)
                gaugeColor = "red"
            else if (rpm >= 4000)
                gaugeColor = gaugeColor = "orange"

            ctx.beginPath()
            ctx.arc(cx, cy, r, startRad, rpmRad)
            ctx.lineWidth = 14
            ctx.strokeStyle = gaugeColor
            ctx.lineCap = "round"
            ctx.stroke()

            // ---- TICKS ----
            for (var v=0; v<=maxRpm; v+=200) {
                var a = angleFromRpm(v) * Math.PI/180
                var major = (v % 1000 === 0)
                var len = major ? 14 : 7

                ctx.beginPath()
                ctx.moveTo(cx + Math.cos(a)*(r-2),
                           cy + Math.sin(a)*(r-2))
                ctx.lineTo(cx + Math.cos(a)*(r-len),
                           cy + Math.sin(a)*(r-len))
                ctx.strokeStyle = v>=redline ? "#FF2A2A" : "white"
                ctx.lineWidth = major ? 2 : 1
                ctx.stroke()

                if (major) {
                    ctx.fillStyle = "white"
                    ctx.font = "bold 12px Sans"
                    ctx.textAlign = "center"
                    ctx.fillText(
                        v/1000,
                        cx + Math.cos(a)*(r-30),
                        cy + Math.sin(a)*(r-30)
                    )
                }
            }
        }
    }

//    Rectangle {
//        width: 6
//        height: 110
//        radius: 3
//        color: "pink"

//        x: parent.width/2 - width/2
//        y: parent.height/2 - height

//        transformOrigin: Item.Bottom
//        rotation: angleFromRpm(rpm) - 270
//    }

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 30
        spacing: 25

        // ---- RPM VALUE ----
        Text {
            text: rpm
            font.pixelSize: 32
            font.bold: true
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "RPM"
            font.pixelSize: 12
            color: "#AAA"
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // ---- AVG + RANGE (SIDE BY SIDE) ----
//        Row {
//            spacing: 30
//            anchors.horizontalCenter: parent.horizontalCenter

//            Column {
//                spacing: 2
//                Text {
//                    text: "Avg fuel"
//                    font.pixelSize: 12
//                    color: "#AAA"
//                }
//                Text {
//                    text: avgFuelEconomy + " km/L"
//                    font.pixelSize: 16
//                    font.bold: true
//                    color: "white"
//                }
//            }

//            Column {
//                spacing: 2
//                Text {
//                    text: "Range"
//                    font.pixelSize: 12
//                    color: "#AAA"
//                }
//                Text {
//                    text: rangeKm + " km"
//                    font.pixelSize: 16
//                    font.bold: true
//                    color: "white"
//                }
//            }
//        }
    }

}
