#!/bin/sh
# ==========================================================
# REMOTE TELEMATICS MASTER INDICATOR CONTROL
# Version: 13022026
# Author: Naveen Kumar
# Description:
# Optimized single Firebase fetch (reduces latency)
# Controls LEFT, RIGHT, and HAZARD indicators
# Designed for fast response (<1 second)
# ==========================================================
LOGFILE=/run/media/mmcblk0p6/remote_telematics_13022026.log
exec >> $LOGFILE 2>&1
echo "===== REMOTE TELEMATICS 13022026 STARTED AT $(date) ====="
# ----------------------------------------------------------
# Base Directory
")
# ----------------------------------------------------------
BASE_DIR=/run/media/mmcblk0p6/remote_telematics_naveen_13022026
2)
CURL_BIN=$BASE_DIR/curl-firebase
INDICATORS_URL=$(cat $BASE_DIR/INDICATORS_URL.txt)
# ----------------------------------------------------------
# GPIO Definitions
# ----------------------------------------------------------
LEFT_GPIO=226
RIGHT_GPIO=227
")
# ----------------------------------------------------------
# Export GPIOs
# ----------------------------------------------------------
echo $LEFT_GPIO > /sys/class/gpio/export 2>/dev/null
echo $RIGHT_GPIO > /sys/class/gpio/export 2>/dev/null
echo out > /sys/class/gpio/gpio$LEFT_GPIO/direction
echo out > /sys/class/gpio/gpio$RIGHT_GPIO/direction
# ----------------------------------------------------------
# Wait for Network Ready
# ----------------------------------------------------------
echo "Waiting for PPP IP..."
while true
do
IP=$(ifconfig ppp0 2>/dev/null | grep "inet " | awk '{print $2}')
[ -n "$IP" ] && break
sleep 1
doneecho "PPP Ready: $IP"
while ! route -n | grep -q '^0.0.0.0'; do
sleep 1
done
echo "Default route ready"
while ! ping -c 1 8.8.8.8 >/dev/null 2>&1; do
sleep 1
done
2)
echo "Internet Ready"
")
sleep 2
echo "=== INDICATOR CONTROL LOOP STARTED ==="
# ----------------------------------------------------------
# MAIN LOOP
# ----------------------------------------------------------
")
while true
do
# ------------------------------------------------------
# Fetch ALL indicators in single HTTPS request
# ------------------------------------------------------
DATA=$($CURL_BIN -s -k --connect-timeout 2 --max-time 3 "$INDICATORS_URL")
# Extract values
L=$(echo "$DATA" | grep -o '"left_indicator":[^,}]*' | cut -d: -f2)
R=$(echo "$DATA" | grep -o '"right_indicator":[^,}]*' | cut -d: -f2)
H=$(echo "$DATA" | grep -o '"hazard":[^,}]*' | cut -d: -f2)
# ------------------------------------------------------
# HAZARD MODE (Continuous Blink)
# ------------------------------------------------------
if [ "$H" = "true" ]; then
echo "Hazard mode active"
while true
do
# Turn ON (active low)
echo 0 > /sys/class/gpio/gpio$LEFT_GPIO/value
echo 0 > /sys/class/gpio/gpio$RIGHT_GPIO/value
sleep 0.3
# Turn OFF
echo 1 > /sys/class/gpio/gpio$LEFT_GPIO/value
echo 1 > /sys/class/gpio/gpio$RIGHT_GPIO/valuesleep 0.3
")
# Re-fetch only hazard quickly
DATA=$($CURL_BIN -s -k --connect-timeout 2 --max-time 3 "$INDICATORS_URL")
H=$(echo "$DATA" | grep -o '"hazard":[^,}]*' | cut -d: -f2)
# If hazard turned OFF → break blinking
[ "$H" != "true" ] && break
done
continue
fi
# ------------------------------------------------------
# LEFT INDICATOR
# ------------------------------------------------------
if [ "$L" = "true" ]; then
echo 0 > /sys/class/gpio/gpio$LEFT_GPIO/value
else
echo 1 > /sys/class/gpio/gpio$LEFT_GPIO/value
fi
2)
# ------------------------------------------------------
# RIGHT INDICATOR
# ------------------------------------------------------
")
if [ "$R" = "true" ]; then
echo 0 > /sys/class/gpio/gpio$RIGHT_GPIO/value
else
echo 1 > /sys/class/gpio/gpio$RIGHT_GPIO/value
fi
2)
# Polling interval (FAST)
sleep 0.5
done
")
