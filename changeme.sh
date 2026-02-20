#!/bin/bash

# Hardcoded Infrastructure
GATEWAY="192.168.222.2"
DNS_SERVERS="1.1.1.1,1.0.0.3"

if [ "$EUID" -ne 0 ]; then 
  echo "Error: Need root."
  exit 1
fi

echo "--- VM Migration Tool (UUID Mode) ---"

# --- Backend Check ---
if systemctl is-active --quiet wicked; then
    read -p "wicked detected. Switch to NetworkManager? (y/n): " switch_net
    if [[ "$switch_net" == "y" ]]; then
        systemctl disable --now wicked >/dev/null 2>&1
        systemctl enable --now NetworkManager >/dev/null 2>&1
        sleep 2
    else
        exit 1
    fi
fi

# --- Identify the Connection ---
# This finds the UUID of the active connection on the first ethernet device
CON_UUID=$(nmcli -t -f UUID,TYPE connection show --active | grep ethernet | head -n1 | cut -d: -f1)

if [ -z "$CON_UUID" ]; then
    echo "Error: Could not find an active Ethernet connection profile."
    exit 1
fi

echo "Active Connection UUID: $CON_UUID"

echo "1) Change IP"
echo "2) Change Hostname"
echo "3) Do both"
read -p "Selection [1-3]: " choice

case $choice in
    1|3)
        read -p "Enter new IP (e.g., 192.168.222.152): " USER_IP
        [[ "$USER_IP" != */* ]] && USER_IP="$USER_IP/24"
        
        echo "Applying config to UUID $CON_UUID..."
        nmcli con mod "$CON_UUID" ipv4.addresses "$USER_IP" ipv4.gateway "$GATEWAY" ipv4.dns "$DNS_SERVERS" ipv4.method manual
        
        echo "Cycling connection..."
        nmcli con up "$CON_UUID"
        ;;
esac

case $choice in
    2|3)
        read -p "Enter new FQDN: " NEW_HOST
        OLD_HOST=$(hostname)
        hostnamectl set-hostname "$NEW_HOST"
        sed -i "s/$OLD_HOST/$NEW_HOST/g" /etc/hosts
        echo "Hostname updated."
        ;;
esac

# Verification
echo -e "\n--- Verification ---"
ip addr show | grep "inet " | grep -v "127.0.0.1"
ping -c 2 $GATEWAY &> /dev/null && echo "Gateway Reachable: YES" || echo "Gateway Reachable: NO"
