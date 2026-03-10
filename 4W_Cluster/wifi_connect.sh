#!/bin/sh

IFACE=wlan0
CONF_FILE=$(pwd)/wifi_remote.conf

echo "======================================"
echo " Remote WiFi Control: WiFi Connect "
echo "======================================"

echo "[1] Bringing WiFi interface UP..."
ip link set $IFACE up

echo "[2] Killing old wpa_supplicant (if any)..."
killall wpa_supplicant 2>/dev/null

echo "[3] Starting wpa_supplicant..."
wpa_supplicant -B -i $IFACE -c $CONF_FILE

sleep 5

echo "[4] Getting IP via DHCP..."
udhcpc -i $IFACE

echo "[5] WiFi Status:"
ip addr show $IFACE

echo "======================================"
echo " WiFi Connection Process Completed "
echo "======================================"
