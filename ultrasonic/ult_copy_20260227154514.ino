#include <WiFi.h>
#include <Firebase_ESP_Client.h>

/* ================= WiFi ================= */
#define WIFI_SSID        "iSprout-NRE"
#define WIFI_PASSWORD    "Isprout@n-202$"

/* ================= Firebase ================= */
#define API_KEY          "AIzaSyCR_FwvqqMGctW9i6MNn4ZUAGcuIjxPAqQ"
#define DATABASE_URL     "https://edge-data-filtering-default-rtdb.asia-southeast1.firebasedatabase.app/"
#define USER_EMAIL       "tejaswini.kopperla@votarytech.com"
#define USER_PASSWORD    "Votarytech@2025"

/* ================= Ultrasonic Pins ================= */
#define TRIG 5
#define ECHO 18

long duration;
float distance;

/* ================= Firebase Objects ================= */
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

void setup() {

  Serial.begin(115200);

  pinMode(TRIG, OUTPUT);
  pinMode(ECHO, INPUT);

  /* ---------- WiFi Connect ---------- */
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");

  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }

  Serial.println("\nWiFi Connected");

  /* ---------- Firebase Config ---------- */
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  Serial.println("Connecting to Firebase...");

  while (auth.token.uid == "") {
    Serial.print(".");
    delay(500);
  }

  Serial.println("\nFirebase Connected");
}

void loop() {

  /* ---------- Trigger Ultrasonic ---------- */
  digitalWrite(TRIG, LOW);
  delayMicroseconds(2);

  digitalWrite(TRIG, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG, LOW);

  duration = pulseIn(ECHO, HIGH, 30000);

  if (duration == 0) {
    Serial.println("No object detected");
    delay(1000);
    return;
  }

  distance = duration * 0.034 / 2;

  Serial.print("Distance: ");
  Serial.print(distance);
  Serial.println(" cm");

  /* ---------- Send to Firebase ---------- */
  if (Firebase.ready()) {

    // Always send distance
    Firebase.RTDB.setFloat(&fbdo, "/Ultrasonic/distance", distance);

    // Forward Collision Condition
    if (distance < 20) {

      Firebase.RTDB.setString(&fbdo, "/Ultrasonic/alert", "Forward Collision");

      Serial.println("⚠ Forward Collision Alert Sent!");

    } 
    else {

      // Remove alert when safe
      Firebase.RTDB.deleteNode(&fbdo, "/Ultrasonic/alert");

      Serial.println("Safe Distance - No Alert");

    }

  } 
  else {
    Serial.println("Firebase not ready");
  }

  Serial.println("----------------------------------");

  delay(1000);
}