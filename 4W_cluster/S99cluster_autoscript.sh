#!/bin/sh

############################################
# CAR CLUSTER FAST AUTO START SCRIPT
# Board : OKT507-C
############################################

exec > /root/startup_log.txt 2>&1

echo "======================================="
echo "        CAR CLUSTER FAST STARTUP       "
echo "======================================="

date

########################################
# 1. WAIT FOR FRAMEBUFFER
########################################

echo "[1] Waiting for framebuffer..."

COUNT=0
while [ ! -e /dev/fb0 ]
do
    sleep 0.2
    COUNT=$((COUNT+1))
    [ $COUNT -gt 50 ] && break
done

echo "Framebuffer ready"

########################################
# 2. WAIT FOR INPUT DEVICE
########################################

echo "[2] Waiting for input subsystem..."

COUNT=0
while [ ! -e /dev/input/event0 ]
do
    sleep 0.2
    COUNT=$((COUNT+1))
    [ $COUNT -gt 30 ] && break
done

echo "Input system ready"

########################################
# 3. DISABLE FRAMEBUFFER CONSOLE
########################################

echo "[3] Disabling framebuffer console..."

echo 0 > /sys/class/vtconsole/vtcon1/bind 2>/dev/null

########################################
# 4. SET QT ENVIRONMENT
########################################

echo "[4] Setting QT environment..."

export QT_QPA_PLATFORM=linuxfb
export QT_QPA_FB_DEVICE=/dev/fb0
export QT_QPA_PLATFORM_PLUGIN_PATH=/usr/lib/qt/plugins
export QT_QPA_FONTDIR=/usr/lib/fonts
export XDG_RUNTIME_DIR=/tmp/runtime-root

########################################
# 5. START WIFI + INTERNET TIME
########################################

echo "[5] Starting WiFi in background..."

(
IFACE=wlan0
CONF_FILE=/root/wifi_remote.conf

echo "Waiting for WiFi interface..."

COUNT=0
while [ ! -d /sys/class/net/$IFACE ]
do
    sleep 0.3
    COUNT=$((COUNT+1))
    [ $COUNT -gt 20 ] && exit
done

ip link set $IFACE up

killall wpa_supplicant 2>/dev/null

echo "Starting wpa_supplicant..."

wpa_supplicant -B -i $IFACE -c $CONF_FILE

sleep 2

echo "Getting IP address..."

udhcpc -i $IFACE

echo "Syncing internet time..."

ntpd -q -p pool.ntp.org

hwclock -w

echo "WiFi + Internet ready"

) &

########################################
# 6. FIREBASE CONNECTION
########################################

echo "[6] Connecting to Firebase..."

(
curl -k https://edge-data-filtering-default-rtdb.asia-southeast1.firebasedatabase.app/.json
echo "Firebase connection done"
) &

########################################
# 7. START CAR CLUSTER
########################################

echo "[7] Starting Car Cluster..."

killall car_cluster_Mar09 2>/dev/null

sleep 1

/usr/bin/car_cluster_Mar09 &

########################################
# 8. LOG START TIME
########################################

echo "[8] Cluster launched at:"
date

echo "=========== STARTUP FINISHED =========="
