#include <Arduino.h>
#include <WiFi.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <Firebase_ESP_Client.h>
#include <Wire.h>
#include <math.h>

#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

/* ================= WiFi Credentials ================= */
#define WIFI_SSID        "iSprout-NRE"
#define WIFI_PASSWORD    "Isprout@n-202$"

/* ================= Firebase Credentials ================= */
#define API_KEY          "AIzaSyCR_FwvqqMGctW9i6MNn4ZUAGcuIjxPAqQ"
#define DATABASE_URL     "https://edge-data-filtering-default-rtdb.asia-southeast1.firebasedatabase.app/"
#define USER_EMAIL       "tejaswini.kopperla@votarytech.com"
#define USER_PASSWORD    "Votarytech@2025"

/* ================= Temperature Sensor ================= */
#define ONE_WIRE_BUS     15

/* ================= Indicator Pins ================= */
#define LEFT_INDICATOR_PIN   4
#define RIGHT_INDICATOR_PIN  5

/* ================= MPU6050 ================= */
#define MPU_ADDR 0x68

/* ================= Objects ================= */
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

/* ================= Timing ================= */
unsigned long lastSend = 0;
const unsigned long interval = 5000;

/* ================= Driving Behaviour ================= */
int harshAccelCount = 0;
int harshBrakeCount = 0;
int aggressiveCornerCount = 0;

String prevTilt = "flat";

unsigned long lastHarshAccelTime = 0;
unsigned long lastHarshBrakeTime = 0;
unsigned long lastAggCornerTime  = 0;

const unsigned long EVENT_DELAY = 2000;

/* ================= Diagnostics ================= */
#define DTC_BATTERY_TEMP_SENSOR_FAULT "P0A1A"

bool dtc_active = false;
unsigned long fault_start_time = 0;
const unsigned long FAULT_CONFIRM_TIME = 3000;

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

/* ================= Diagnostics ================= */
void diagnostics_check_temperature(float temperatureC)
{
    bool fault_condition =
        (temperatureC == DEVICE_DISCONNECTED_C ||
         temperatureC < -40.0 ||
         temperatureC > 125.0);

    if (fault_condition)
    {
        if (!dtc_active)
        {
            if (fault_start_time == 0)
                fault_start_time = millis();

            if (millis() - fault_start_time >= FAULT_CONFIRM_TIME)
            {
                dtc_active = true;
                Serial.println("🚨 DTC SET: P0A1A");

                Firebase.RTDB.setBool(&fbdo, "/dtc/P0A1A/status", true);
                Firebase.RTDB.setString(&fbdo,
                    "/dtc/P0A1A/description",
                    "Battery Temperature Sensor Fault");
                Firebase.RTDB.setInt(&fbdo,
                    "/dtc/P0A1A/timestamp",
                    millis());
            }
        }
    }
    else
    {
        fault_start_time = 0;

        if (dtc_active)
        {
            Serial.println("✅ DTC CLEARED: P0A1A");
            Firebase.RTDB.setBool(&fbdo, "/dtc/P0A1A/status", false);
        }

        dtc_active = false;
    }
}

void setup()
{
    Serial.begin(115200);

    pinMode(LEFT_INDICATOR_PIN, INPUT_PULLUP);
    pinMode(RIGHT_INDICATOR_PIN, INPUT_PULLUP);

    /* ---------- WiFi ---------- */
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    while (WiFi.status() != WL_CONNECTED)
        delay(500);

    /* ---------- Sensors ---------- */
    sensors.begin();
    Wire.begin(21, 22);

    Wire.beginTransmission(MPU_ADDR);
    Wire.write(0x6B);
    Wire.write(0x00);
    Wire.endTransmission();

    /* ---------- Firebase ---------- */
    config.api_key = API_KEY;
    config.database_url = DATABASE_URL;
    auth.user.email = USER_EMAIL;
    auth.user.password = USER_PASSWORD;

    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);

    Serial.println("System Ready");
}

void loop()
{
    if (millis() - lastSend < interval)
        return;

    lastSend = millis();

    /* ================= TEMPERATURE ================= */
    sensors.requestTemperatures();
    float temperatureC = sensors.getTempCByIndex(0);
    Firebase.RTDB.setFloat(&fbdo, "/sensor/temperature", temperatureC);
    diagnostics_check_temperature(temperatureC);

    /* ================= INDICATORS ================= */
    bool leftOn   = (digitalRead(LEFT_INDICATOR_PIN) == LOW);
    bool rightOn  = (digitalRead(RIGHT_INDICATOR_PIN) == LOW);
    bool hazardOn = leftOn && rightOn;

    Firebase.RTDB.setBool(&fbdo, "/vehicle/indicator/left", leftOn);
    Firebase.RTDB.setBool(&fbdo, "/vehicle/indicator/right", rightOn);
    Firebase.RTDB.setBool(&fbdo, "/vehicle/indicator/hazard", hazardOn);

    /* ================= MPU6050 ================= */
    int16_t x = read16(0x3B);
    int16_t y = read16(0x3D);
    int16_t z = read16(0x3F);

    float ax = x / 16384.0;
    float ay = y / 16384.0;
    float az = z / 16384.0;

    float pitch = atan2(ax, sqrt(ay * ay + az * az)) * 180.0 / PI;
    float roll  = atan2(ay, sqrt(ax * ax + az * az)) * 180.0 / PI;

    String tilt;
    if (pitch > 5)       tilt = "left";
    else if (pitch < -5) tilt = "right";
    else if (roll > 5)   tilt = "back";
    else if (roll < -5)  tilt = "front";
    else                 tilt = "flat";

    /* ================= Driving Behaviour ================= */
    if (prevTilt == "flat" && tilt == "back" &&
        millis() - lastHarshAccelTime > EVENT_DELAY)
    {
        harshAccelCount++;
        lastHarshAccelTime = millis();
    }

    if (prevTilt == "flat" && tilt == "front" &&
        millis() - lastHarshBrakeTime > EVENT_DELAY)
    {
        harshBrakeCount++;
        lastHarshBrakeTime = millis();
    }

    if ((prevTilt == "left" && tilt == "right") ||
        (prevTilt == "right" && tilt == "left"))
    {
        if (millis() - lastAggCornerTime > EVENT_DELAY)
        {
            aggressiveCornerCount++;
            lastAggCornerTime = millis();
        }
    }

    prevTilt = tilt;

    /* ================= Firebase Upload ================= */
    Firebase.RTDB.setString(&fbdo, "/vehicle/tilt", tilt);
    Firebase.RTDB.setInt(&fbdo, "/driving/harsh_acceleration", harshAccelCount);
    Firebase.RTDB.setInt(&fbdo, "/driving/harsh_braking", harshBrakeCount);
    Firebase.RTDB.setInt(&fbdo, "/driving/aggressive_corner", aggressiveCornerCount);

    Serial.println("Tilt: " + tilt);
}




