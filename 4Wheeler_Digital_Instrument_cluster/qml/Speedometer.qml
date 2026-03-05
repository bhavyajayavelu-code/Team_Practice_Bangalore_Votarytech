
import QtQuick 2.9



Item {
    width: 260
    height: 260

    property real speed: 120
    property real maxSpeed: 260

    onSpeedChanged: speedCanvas.requestPaint()



    readonly property real startAngle: 135
    readonly property real sweepAngle: 270


    function angleFromSpeed(v) {
        return startAngle + (v / maxSpeed) * sweepAngle
    }

//    Canvas {
//        id: speedCanvas
//        anchors.fill: parent
//        onPaint: {
//            var ctx = getContext("2d")
//            ctx.clearRect(0,0,width,height)

//            var cx = width/2
//            var cy = height/2
//            var r  = 120

//            // ---- TOP GLOW ARC ----
//            ctx.beginPath()
//            ctx.arc(cx, cy, r, Math.PI*0.75, Math.PI*2.25)
//            ctx.lineWidth = 18
//            ctx.strokeStyle = "rgba(0,160,255,0.25)"
//            ctx.stroke()

//            // ---- MAIN RING ----
//            ctx.beginPath()
//            ctx.arc(cx, cy, r, Math.PI*0.75, Math.PI*2.25)
//            ctx.lineWidth = 6
//            ctx.strokeStyle = "PINK"//"#1EC8FF"
//            ctx.stroke()



//            // ---- TICKS ----
//            for (var v=0; v<=maxSpeed; v+=10) {
//                var a = angleFromSpeed(v) * Math.PI/180
//                var major = (v % 20 === 0)
//                var len = major ? 14 : 7

//                ctx.beginPath()
//                ctx.moveTo(cx + Math.cos(a)*(r-2),
//                           cy + Math.sin(a)*(r-2))
//                ctx.lineTo(cx + Math.cos(a)*(r-len),
//                           cy + Math.sin(a)*(r-len))
//                ctx.strokeStyle = "white"
//                ctx.lineWidth = major ? 2 : 1
//                ctx.stroke()

//                if (major) {
//                    ctx.font = "bold 12px Sans"
//                    ctx.fillStyle = "white"
//                    ctx.textAlign = "center"
//                    ctx.textBaseline = "middle"
//                    ctx.fillText(
//                        v,
//                        cx + Math.cos(a)*(r-30),
//                        cy + Math.sin(a)*(r-30)
//                    )
//                }
//            }
//        }
//    }
    Canvas {
        id: speedCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0,0,width,height)

            var cx = width/2
            var cy = height/2
            var r  = 120

            var startRad = startAngle * Math.PI/180
            var endRad = (startAngle + sweepAngle) * Math.PI/180
            var speedRad = angleFromSpeed(speed) * Math.PI/180

            // ---- TOP GLOW ARC ----
            ctx.beginPath()
            ctx.arc(cx, cy, r, startRad, endRad)
            ctx.lineWidth = 18
            ctx.strokeStyle = "rgba(0,160,255,0.25)"
            ctx.stroke()

            // ---- MAIN RING ----
            ctx.beginPath()
            ctx.arc(cx, cy, r, startRad, endRad)
            ctx.lineWidth = 6
            ctx.strokeStyle = "#1EC8FF"
            ctx.stroke()

            // ---- SPEED COLOR ARC (NEW ADDITION) ----
            var gaugeColor = "#1EC8FF"   // Blue default

            if (speed >= 120)
                gaugeColor = "red"
            else if (speed > 70)
                gaugeColor = "orange"

            ctx.beginPath()
            ctx.arc(cx, cy, r, startRad, speedRad)
            ctx.lineWidth = 14
            ctx.strokeStyle = gaugeColor
            ctx.lineCap = "round"
            ctx.stroke()

            // ---- TICKS ----
            for (var v=0; v<=maxSpeed; v+=10) {
                var a = angleFromSpeed(v) * Math.PI/180
                var major = (v % 20 === 0)
                var len = major ? 14 : 7

                ctx.beginPath()
                ctx.moveTo(cx + Math.cos(a)*(r-2),
                           cy + Math.sin(a)*(r-2))
                ctx.lineTo(cx + Math.cos(a)*(r-len),
                           cy + Math.sin(a)*(r-len))
                ctx.strokeStyle = "white"
                ctx.lineWidth = major ? 2 : 1
                ctx.stroke()

                if (major) {
                    ctx.font = "bold 12px Sans"
                    ctx.fillStyle = "white"
                    ctx.textAlign = "center"
                    ctx.textBaseline = "middle"
                    ctx.fillText(
                        v,
                        cx + Math.cos(a)*(r-30),
                        cy + Math.sin(a)*(r-30)
                    )
                }
            }
        }
    }


    // ---- DIGITAL SPEED ----
    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 10

        Text {
            text: speed
            font.pixelSize: 32
            font.bold: true
            color: "white"
        }

        Text {
            text: "km/h"
            font.pixelSize: 12
            color: "#AAA"
        }
    }
}
