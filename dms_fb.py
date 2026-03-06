import cv2
import dlib
import time
import numpy as np
import atexit
from imutils import face_utils
from picamera2 import Picamera2
from flask import Flask, Response, jsonify, render_template

# ---------- FIREBASE ----------
import firebase_admin
from firebase_admin import credentials, db

# ---------------- CONFIG ----------------
PREDICTOR_PATH = "/home/votarytech/dms/models/shape_predictor_68_face_landmarks.dat"
EAR_THRESHOLD = 0.25
MAR_THRESHOLD = 0.75
DROWSY_MSG_TIME = 2
DROWSY_AUDIO_TIME = 5
YAWN_RESET_TIME = 10

# -------- FIREBASE CONFIG --------
FIREBASE_KEY_PATH = "/home/votarytech/firebase_key.json"
FIREBASE_DB_URL = "https://edge-data-filtering-default-rtdb.asia-southeast1.firebasedatabase.app/"

if not firebase_admin._apps:
    cred = credentials.Certificate(FIREBASE_KEY_PATH)
    firebase_admin.initialize_app(cred, {"databaseURL": FIREBASE_DB_URL})

# ---------------- CLEAR FIREBASE ON EXIT ----------------
def clear_dms_on_exit():
    try:
        db.reference("/DMS/status").set({
            "drowsy_msg": False,
            "drowsy_audio": False,
            "yawn_msg": False,
            "yawn_audio": False,
            "drowsy_text": "",
            "yawn_text": "",
            "online": False,
            "timestamp": time.time()
        })
        print("✅ DMS cleared in Firebase (offline)")
    except Exception as e:
        print("⚠️ Firebase clear failed:", e)

atexit.register(clear_dms_on_exit)

# ---------------- INIT ----------------
app = Flask(__name__)
detector = dlib.get_frontal_face_detector()
predictor = dlib.shape_predictor(PREDICTOR_PATH)

# ---------------- CAMERA ----------------
picam2 = Picamera2()
picam2.configure(picam2.create_video_configuration(
    main={"size": (640, 480), "format": "RGB888"}
))
picam2.start()

# ---------------- STATES ----------------
eye_close_start = None
drowsy_msg = False
drowsy_audio = False
yawn_count = 0
mouth_open_prev = False
yawn_msg = False
yawn_audio = False
yawn_last_time = None
last_firebase_time = 0

# ---------------- HELPERS ----------------
def eye_aspect_ratio(eye):
    A = np.linalg.norm(eye[1] - eye[5])
    B = np.linalg.norm(eye[2] - eye[4])
    C = np.linalg.norm(eye[0] - eye[3])
    return (A + B) / (2 * C) if C != 0 else 0

def mouth_aspect_ratio(mouth):
    A = np.linalg.norm(mouth[2] - mouth[10])
    B = np.linalg.norm(mouth[4] - mouth[8])
    C = np.linalg.norm(mouth[0] - mouth[6])
    return (A + B) / (2 * C) if C != 0 else 0

# ---------------- FLASK ----------------
@app.route("/")
def index():
    return render_template("index.html")

@app.route("/status")
def status():
    return jsonify({
        "drowsy_msg": drowsy_msg,
        "drowsy_audio": drowsy_audio,
        "yawn_msg": yawn_msg,
        "yawn_audio": yawn_audio
    })

# ---------------- MAIN STREAM ----------------
def generate_frames():
    global eye_close_start, drowsy_msg, drowsy_audio
    global yawn_count, mouth_open_prev, yawn_msg, yawn_audio, yawn_last_time
    global last_firebase_time

    while True:
        frame = picam2.capture_array()
        gray = cv2.cvtColor(frame, cv2.COLOR_RGB2GRAY)
        faces = detector(gray, 0)

        eyes_closed = False
        mouth_open = False

        for face in faces:
            shape = predictor(gray, face)
            pts = face_utils.shape_to_np(shape)

            ear = (eye_aspect_ratio(pts[36:42]) +
                   eye_aspect_ratio(pts[42:48])) / 2
            mar = mouth_aspect_ratio(pts[48:68])

            if ear < EAR_THRESHOLD:
                eyes_closed = True
            if mar > MAR_THRESHOLD:
                mouth_open = True

        now = time.time()

        # ---------------- DROWSINESS ----------------
        if eyes_closed and not mouth_open:
            if eye_close_start is None:
                eye_close_start = now

            elapsed = now - eye_close_start
            drowsy_msg = elapsed >= DROWSY_MSG_TIME
            drowsy_audio = elapsed >= DROWSY_AUDIO_TIME
        else:
            eye_close_start = None
            drowsy_msg = False
            drowsy_audio = False

        # ---------------- YAWN ----------------
        if mouth_open and not mouth_open_prev:
            yawn_count += 1
            yawn_last_time = now

        if yawn_last_time is not None and (now - yawn_last_time) > YAWN_RESET_TIME:
            yawn_count = 0
            yawn_last_time = None

        yawn_msg = yawn_count >= 2
        yawn_audio = (yawn_count >= 3) and mouth_open
        mouth_open_prev = mouth_open

        # ---------------- FIREBASE UPDATE ----------------
        if now - last_firebase_time > 0.5:
            drowsy_text = "Drowsiness detected" if drowsy_msg else ""
            yawn_text = "Yawn detected" if yawn_msg else ""

            db.reference("/DMS/status").set({
                "drowsy_msg": drowsy_msg,
                "drowsy_audio": drowsy_audio,
                "yawn_msg": yawn_msg,
                "yawn_audio": yawn_audio,
                "drowsy_text": drowsy_text,
                "yawn_text": yawn_text,
                "online": True,
                "timestamp": now
            })

            last_firebase_time = now

        ret, buffer = cv2.imencode(".jpg", frame)
        yield (b"--frame\r\nContent-Type: image/jpeg\r\n\r\n" +
               buffer.tobytes() + b"\r\n")

# ---------------- ROUTE ----------------
@app.route("/video_feed")
def video_feed():
    return Response(generate_frames(),
                    mimetype="multipart/x-mixed-replace; boundary=frame")

# ---------------- MAIN ----------------
if __name__ == "__main__":
    print("✅ DMS Firebase running with safe shutdown")
    app.run(host="0.0.0.0", port=5000, threaded=True)
