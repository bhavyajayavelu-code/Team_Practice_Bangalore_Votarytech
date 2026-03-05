import os
import atexit
import time
from flask import Flask, Response, render_template_string, redirect, url_for
import cv2
import numpy as np
from picamera2 import Picamera2

# ---------- FIREBASE ----------
import firebase_admin
from firebase_admin import credentials, db

# ---------------- CONFIG ----------------
EMPTY_REF_PATH = "empty_ref.jpg"

ROI_X1, ROI_Y1, ROI_X2, ROI_Y2 = 30, 80, 610, 450

EMPTY_FG_RATIO_THRESHOLD = 0.05
CHILD_THRESHOLD = 0.09
ADULT_THRESHOLD = 0.28

STATE_HOLD_TIME = 1.5
CPD_TRIGGER_TIME = 5.0

CHILD_MIN_H_RATIO = 0.38
OBJECT_MAX_H_RATIO = 0.35

MOTION_WINDOW = 5
MOTION_THRESHOLD = 0.008
STABLE_REQUIRED = 6

# -------- FIREBASE CONFIG --------
FIREBASE_KEY_PATH = "/home/votarytech/firebase_key.json"
FIREBASE_DB_URL = "https://edge-data-filtering-default-rtdb.asia-southeast1.firebasedatabase.app/"

if not firebase_admin._apps:
    cred = credentials.Certificate(FIREBASE_KEY_PATH)
    firebase_admin.initialize_app(cred, {"databaseURL": FIREBASE_DB_URL})

# ---------------- CLEAR FIREBASE ON EXIT ----------------
def clear_oms_on_exit():
    try:
        db.reference("/OMS/status").set({
            "seat_status": "UNKNOWN",
            "airbag": "DEACTIVATED",
            "cpd": False,
            "online": False,
            "timestamp": time.time()
        })
        print("✅ OMS cleared in Firebase (offline)")
    except Exception as e:
        print("⚠️ Firebase clear failed:", e)

atexit.register(clear_oms_on_exit)

# ---------------- INIT ----------------
app = Flask(__name__)

picam2 = Picamera2()
picam2.configure(picam2.create_video_configuration(
    main={"size": (640, 480), "format": "RGB888"}))
picam2.start()

# ---------------- STATES ----------------
empty_ref_gray = None
last_status = "UNKNOWN"
last_change_time = time.time()

child_start_time = None
cpd_active = False
last_firebase_time = 0

prev_gray = None
motion_history = []
stable_counter = 0
pending_status = "UNKNOWN"

# ---------------- HELPERS ----------------
def airbag_status(status):
    return "ACTIVATED" if status == "ADULT" else "DEACTIVATED"

def load_reference():
    global empty_ref_gray
    if os.path.exists(EMPTY_REF_PATH):
        ref = cv2.imread(EMPTY_REF_PATH)
        roi_ref = ref[ROI_Y1:ROI_Y2, ROI_X1:ROI_X2]
        empty_ref_gray = cv2.cvtColor(roi_ref, cv2.COLOR_BGR2GRAY)
        empty_ref_gray = cv2.GaussianBlur(empty_ref_gray, (7, 7), 0)
        print("✅ Reference loaded")
    else:
        empty_ref_gray = None
        print("⚠️ No reference image found")

def capture_empty_reference():
    frame = picam2.capture_array()
    cv2.imwrite(EMPTY_REF_PATH, frame)
    load_reference()
    print("📸 Empty reference captured")

# ---------------- SHAPE METRICS ----------------
def blob_metrics(thresh):
    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    if not contours:
        return 0, 0, 0, 0, 1

    c = max(contours, key=cv2.contourArea)

    x, y, w, h = cv2.boundingRect(c)
    area = cv2.contourArea(c)
    rect_area = w * h

    density = area / rect_area if rect_area > 0 else 0
    rectangularity = area / rect_area if rect_area > 0 else 1
    cx = (x + w / 2) / thresh.shape[1]

    return w, h, density, cx, rectangularity

# ---------------- CLASSIFIER ----------------
def classify(fg_ratio, h_ratio, density, cx, rectangularity, motion):

    if fg_ratio < EMPTY_FG_RATIO_THRESHOLD:
        return "EMPTY"

    if rectangularity > 0.90:
        return "OBJECT"

    if motion < MOTION_THRESHOLD:
        return "OBJECT"

    if fg_ratio > ADULT_THRESHOLD and h_ratio > 0.55:
        return "ADULT"

    if h_ratio < OBJECT_MAX_H_RATIO:
        return "OBJECT"

    if fg_ratio > CHILD_THRESHOLD:
        if h_ratio > CHILD_MIN_H_RATIO and 0.20 < cx < 0.80 and density > 0.18:
            return "CHILD"

    return "OBJECT"

# ---------------- DETECTION ----------------
def detect(frame):
    global last_status, last_change_time
    global prev_gray, motion_history
    global stable_counter, pending_status

    if empty_ref_gray is None:
        return "NO REF", 0, 0, 0

    roi = frame[ROI_Y1:ROI_Y2, ROI_X1:ROI_X2]
    gray = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)
    gray = cv2.GaussianBlur(gray, (7, 7), 0)

    diff = cv2.absdiff(empty_ref_gray, gray)
    _, thresh = cv2.threshold(diff, 25, 255, cv2.THRESH_BINARY)

    kernel = np.ones((3, 3), np.uint8)
    thresh = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel)

    fg_ratio = np.sum(thresh > 0) / thresh.size

    w, h, density, cx, rectangularity = blob_metrics(thresh)
    h_ratio = h / thresh.shape[0] if thresh.shape[0] else 0

    motion = 0
    if prev_gray is not None:
        motion_diff = cv2.absdiff(prev_gray, gray)
        motion = np.sum(motion_diff > 10) / motion_diff.size

    prev_gray = gray.copy()

    motion_history.append(motion)
    if len(motion_history) > MOTION_WINDOW:
        motion_history.pop(0)

    avg_motion = np.mean(motion_history)

    new_status = classify(fg_ratio, h_ratio, density, cx, rectangularity, avg_motion)

    if new_status == pending_status:
        stable_counter += 1
    else:
        pending_status = new_status
        stable_counter = 0

    if stable_counter < STABLE_REQUIRED:
        return last_status, fg_ratio, h_ratio, density

    now = time.time()
    if new_status != last_status and now - last_change_time < STATE_HOLD_TIME:
        return last_status, fg_ratio, h_ratio, density

    last_status = new_status
    last_change_time = now

    return new_status, fg_ratio, h_ratio, density

# ---------------- CPD ----------------
def update_cpd(status):
    global child_start_time, cpd_active
    now = time.time()

    if status == "CHILD":
        if child_start_time is None:
            child_start_time = now
        if now - child_start_time >= CPD_TRIGGER_TIME:
            cpd_active = True
    else:
        child_start_time = None
        cpd_active = False

    return cpd_active

# ---------------- FLASK ----------------
@app.route("/")
def index():
    return render_template_string("""
    <html><body style="background:black;color:white;text-align:center;">
    <h1>OMS Live Feed</h1>
    <img src="/video_feed" width="640" height="480"><br><br>
    <form action="/capture_empty" method="post">
    <button style="padding:10px;">Capture Empty Seat Reference</button>
    </form>
    </body></html>
    """)

@app.route("/capture_empty", methods=["POST"])
def cap():
    capture_empty_reference()
    return redirect(url_for("index"))

# ---------------- STREAM ----------------
def generate_frames():
    global last_firebase_time

    while True:
        frame = picam2.capture_array()

        status, fg, hr, dens = detect(frame)
        airbag = airbag_status(status)
        cpd = update_cpd(status)

        cv2.rectangle(frame, (ROI_X1, ROI_Y1), (ROI_X2, ROI_Y2), (0, 255, 0), 2)

        cv2.putText(frame, f"Seat: {status}", (20, 50),
                    cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 255), 2)

        # Show airbag text ONLY if not ADULT
        if status != "ADULT":
            cv2.putText(frame, f"Airbag: {airbag}", (20, 90),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 0), 2)

        if cpd:
            cv2.putText(frame, "⚠️ CHILD PRESENCE DETECTED!", (20, 130),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 0, 255), 2)

        now = time.time()

        if now - last_firebase_time > 0.5:

            if status == "ADULT":

                db.reference("/OMS/status").set({
                    "seat_status": status,
                    "airbag": "",
                    "cpd": cpd,
                    "online": True,
                    "timestamp": now
                })

            else:

                db.reference("/OMS/status").set({
                    "seat_status": status,
                    "airbag": airbag,
                    "cpd": cpd,
                    "online": True,
                    "timestamp": now
                })

            last_firebase_time = now

        ret, buffer = cv2.imencode(".jpg", frame)
        yield (b'--frame\r\nContent-Type: image/jpeg\r\n\r\n' +
               buffer.tobytes() + b'\r\n')

@app.route("/video_feed")
def video_feed():
    return Response(generate_frames(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

# ---------------- MAIN ----------------
if __name__ == "__main__":
    clear_oms_on_exit()
    load_reference()
    print("✅ OMS running")
    app.run(host="0.0.0.0", port=5000, threaded=True)
