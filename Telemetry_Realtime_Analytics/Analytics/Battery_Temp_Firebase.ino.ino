#include <WiFi.h>
#include <Wire.h>
#include <Firebase_ESP_Client.h>
#include <math.h>

/* ================= WiFi ================= */
#define WIFI_SSID        "iSprout-NRE"
#define WIFI_PASSWORD    "Isprout@n-202$"

/* ================= Firebase ================= */
#define API_KEY          "AIzaSyCR_FwvqqMGctW9i6MNn4ZUAGcuIjxPAqQ"
#define DATABASE_URL     "https://edge-data-filtering-default-rtdb.asia-southeast1.firebasedatabase.app/"
#define USER_EMAIL       "tejaswini.kopperla@votarytech.com"
#define USER_PASSWORD    "Votarytech@2025"

/* ================= MPU6050 ================= */
#define MPU_ADDR 0x68   // AD0 -> GND

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

/* ================= Driving Behaviour ================= */
int harshAccelCount = 0;
int harshBrakeCount = 0;
int aggressiveCornerCount = 0;

String prevTilt = "flat";       // last counted tilt
String stableTilt = "flat";     // currently stable tilt
unsigned long lastStableTime = 0;
const unsigned long STABLE_DELAY = 800; // tilt must remain this long to be stable

/* ================= MPU Helper ================= */
int16_t read16(uint8_t reg)
{
    Wire.beginTransmission(MPU_ADDR);
    Wire.write(reg);
    Wire.endTransmission(false);
    Wire.requestFrom(MPU_ADDR, 2);
    int16_t high = Wire.read();
    int16_t low  = Wire.read();
    return (high << 8) | low;
}

void setup()
{
    Serial.begin(115200);

    // WiFi
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    Serial.print("Connecting to WiFi");
    while (WiFi.status() != WL_CONNECTED)
    {
        Serial.print(".");
        delay(500);
    }
    Serial.println("\nWiFi Connected ✅");

    // MPU6050
    Wire.begin(21, 22); // SDA=21, SCL=22
    delay(1000);
    Wire.beginTransmission(MPU_ADDR);
    Wire.write(0x6B);
    Wire.write(0x00); // Wake MPU6050
    Wire.endTransmission(true);
    Serial.println("MPU6050 Ready ✅");

    // Firebase
    config.api_key = API_KEY;
    config.database_url = DATABASE_URL;
    auth.user.email = USER_EMAIL;
    auth.user.password = USER_PASSWORD;
    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);

    Serial.println("System Ready 🚗\n");
}

void loop()
{
    // Read raw accelerometer
    int16_t x = read16(0x3B);
    int16_t y = read16(0x3D);
    int16_t z = read16(0x3F);

    float ax = x / 16384.0;
    float ay = y / 16384.0;
    float az = z / 16384.0;

    // Pitch / Roll
    float pitch = atan2(ax, sqrt(ay*ay + az*az)) * 180.0 / PI;
    float roll  = atan2(ay, sqrt(ax*ax + az*az)) * 180.0 / PI;

    // Determine tilt
    String currentTilt;
    if (pitch > 5)       currentTilt = "left";
    else if (pitch < -5) currentTilt = "right";
    else if (roll > 5)   currentTilt = "back";
    else if (roll < -5)  currentTilt = "front";
    else                  currentTilt = "flat";

    // If tilt changed, reset timer
    if (currentTilt != stableTilt)
    {
        stableTilt = currentTilt;
        lastStableTime = millis();
    }

    // Only count events if tilt has been stable for STABLE_DELAY
    if (millis() - lastStableTime > STABLE_DELAY && stableTilt != prevTilt)
    {
        Serial.print("Current Tilt: ");
        Serial.println(stableTilt);
        delay(500);

        // Driving behavior detection
        if (prevTilt == "flat" && stableTilt == "back")
        {
            harshAccelCount++;
            Serial.print("Harsh Acceleration: ");
            Serial.println(harshAccelCount);
            delay(500);
        }

        if (prevTilt == "flat" && stableTilt == "front")
        {
            harshBrakeCount++;
            Serial.print("Harsh Brake: ");
            Serial.println(harshBrakeCount);
            delay(500);
        }

        if ((prevTilt == "left" && stableTilt == "right") ||
            (prevTilt == "right" && stableTilt == "left"))
        {
            aggressiveCornerCount++;
            Serial.print("Aggressive Corner: ");
            Serial.println(aggressiveCornerCount);
            delay(500);
        }

        prevTilt = stableTilt;

        // Upload to Firebase
        Firebase.RTDB.setString(&fbdo, "/vehicle/tilt", stableTilt);
        Firebase.RTDB.setInt(&fbdo, "/driving/harsh_acceleration", harshAccelCount);
        Firebase.RTDB.setInt(&fbdo, "/driving/harsh_braking", harshBrakeCount);
        Firebase.RTDB.setInt(&fbdo, "/driving/aggressive_corner", aggressiveCornerCount);
    }

    delay(200); // small loop delay
}

