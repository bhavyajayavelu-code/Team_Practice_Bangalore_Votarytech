#!/bin/sh
# ==============================
# FIREBASE CONFIG
# ==============================
API_KEY="AIzaSyCR_FwvqqMGctW9i6MNn4ZUAGcuIjxPAqQ"
DATABASE_URL="https://edge-data-filtering-default-rtdb.asia-southeast1.firebasedatabase.app
"
USER_EMAIL="tejaswini.kopperla@votarytech.com"
USER_PASSWORD="Votarytech@2025"
CURL="/ota_simulation/curl-firebase"
I2C_BUS=4
SENSOR_ADDR=0x49
TEMP_REG=0x00
THRESHOLD=28
chmod +x "$CURL" 2>/dev/null
# ==============================
# FIREBASE LOGIN
# ==============================
echo "Authenticating..."
AUTH_RESPONSE=$("$CURL" -k -sS -X POST \
-H "Content-Type: application/json" \
-d
"{\"email\":\"$USER_EMAIL\",\"password\":\"$USER_PASSWORD\",\"returnSecureToken\":true}"
\
"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$API_KEY")
ID_TOKEN=$(echo "$AUTH_RESPONSE" | sed -n 's/.*"idToken"[ ]*:[ ]*"\([^"]*\)".*/\1/p')
if [ -z "$ID_TOKEN" ]; then
echo "Firebase Authentication Failed"
exit 1
fi
echo "Firebase Authentication Successful"
# ==============================
# FUNCTIONS
# ==============================
update_temperature() {
VALUE=$1JSON_TEMP="\"$VALUE\""
$CURL -k -sS -X PUT -H "Content-Type: application/json" -d "$JSON_TEMP" \
​
"$DATABASE_URL/Sensor/temperature.json?auth=$ID_TOKEN" > /dev/null 2>&1
}
send_alert() {
JSON_ALERT="\"Temperature High\""
$CURL -k -sS -X PUT -H "Content-Type: application/json" -d "$JSON_ALERT" \
​
"$DATABASE_URL/Alerts/message.json?auth=$ID_TOKEN" > /dev/null 2>&1
}
delete_alert() {
$CURL -k -sS -X DELETE "$DATABASE_URL/Alerts/message.json?auth=$ID_TOKEN" >
/dev/null 2>&1
}
create_dtc() {
JSON='{"description":"Battery Temperature Sensor Fault","status":true}'
$CURL -k -sS -X PUT -H "Content-Type: application/json" -d "$JSON" \
​
"$DATABASE_URL/DTC/P0A1A.json?auth=$ID_TOKEN" > /dev/null 2>&1
}
delete_dtc() {
$CURL -k -sS -X DELETE "$DATABASE_URL/DTC/P0A1A.json?auth=$ID_TOKEN" >
/dev/null 2>&1
}
# ==============================
# MAIN LOOP
# ==============================
while true
do
RAW_TEMP=$(i2cget -y "$I2C_BUS" "$SENSOR_ADDR" "$TEMP_REG" w 2>/dev/null)
# -----------------------------
# SENSOR DISCONNECTED
# -----------------------------
if [ -z "$RAW_TEMP" ]; then
​
echo "Sensor Disconnected"
​
create_dtc
​
# Show DTC
​
update_temperature "--" # Show -- instead of value
​
delete_alert ​
# Ensure Alerts are NOT displayed when DTC present
​
sleep 3​
continue
fi
# -----------------------------
# SENSOR CONNECTED
# -----------------------------
delete_dtc
VAL=$((RAW_TEMP))
SWAP=$(( ((VAL & 0xFF) << 8) | ((VAL >> 8) & 0xFF) ))
[ "$SWAP" -ge 32768 ] && SWAP=$((SWAP - 65536))
TEMP_INT=$((SWAP / 128))
TEMP_FRAC=$(( (SWAP % 128) * 100 / 128 ))
[ "$TEMP_FRAC" -lt 0 ] && TEMP_FRAC=$(( -TEMP_FRAC ))
TEMP_VALUE=$(printf "%d.%02d°C" "$TEMP_INT" "$TEMP_FRAC")
echo "Temperature: $TEMP_VALUE"
update_temperature "$TEMP_VALUE"
# -----------------------------
# HIGH TEMPERATURE ALERT (≥ 28°C)
# -----------------------------
if [ "$TEMP_INT" -ge "$THRESHOLD" ]; then
​
send_alert
else
​
delete_alert
fi
sleep 3
done
