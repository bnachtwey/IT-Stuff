#!/bin/bash

# Check for required packages
check_package() {
    dpkg -s "$1" &> /dev/null || {
        echo "Error: Required package '$1' is not installed."
        echo "Install with: sudo apt install $1"
        exit 1
    }
}

check_package sudo
check_package network-manager

# Read user inputs
read -rp "Enter connection name: " conn_name
read -rp "Enter IP address with CIDR (e.g., 192.168.1.10/24): " ip_cidr
read -rp "Enter gateway: " gateway
read -rp "Enter DNS servers (space separated): " dns_servers
read -rp "Make this default connection? [y/N]: " default_choice

# Create connection (IPv4 only)
sudo nmcli connection add type ethernet con-name "$conn_name" ifname eth0 \
    ipv4.method manual ipv4.addresses "$ip_cidr" ipv4.gateway "$gateway" \
    ipv6.method disabled  # Disable IPv6 during creation

# Configure DNS and disable IPv6 (redundant but ensures proper setup)
sudo nmcli connection modify "$conn_name" \
    ipv4.dns "$dns_servers" \
    ipv6.method disabled  # Explicitly disable IPv6 again

# Set default connection
if [[ "$default_choice" =~ [yY] ]]; then
    sudo nmcli connection modify "$conn_name" connection.autoconnect yes
    sudo nmcli connection down "$conn_name" 2>/dev/null
    sudo nmcli connection up "$conn_name"
else
    sudo nmcli connection modify "$conn_name" connection.autoconnect no
fi

echo "Network configuration '$conn_name' created with IPv6 disabled."
