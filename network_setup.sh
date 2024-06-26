#!/bin/bash

# Script to change network configuration.
# Warning: this script may disrupt your network connection. Use with caution!

# Check for root privileges.
if [[ $EUID -ne 0 ]]; then
  echo "This script requires root privileges. Please run as root."
  exit 1
fi

# Define variables for configuration file and backup.
CONFIG_FILE="/etc/network/interfaces"
CONFIG_BACKUP="${CONFIG_FILE}.bak"

# Define variables for network interface and command line arguments.
INTERFACE="eth0" # Default interface, can be overridden by argument
NEW_IP="$1"
NEW_NETMASK="$2"
NEW_GATEWAY="$3"

# Backup the configuration file.
echo "Backing up configuration file: ${CONFIG_FILE} to ${CONFIG_BACKUP}"
cp ${CONFIG_FILE} ${CONFIG_BACKUP}

# Check if arguments are provided for all parameters.
if [[ -z "$NEW_IP" || -z "$NEW_NETMASK" || -z "$NEW_GATEWAY" ]]; then
  echo "Error: Missing arguments. Please provide new IP address, subnet mask, and gateway."
  echo "Usage: ./network_setup.sh <new_ip> <new_netmask> <new_gateway>"
  exit 1
fi

# Check if new IP address is valid.
if ! [[ "$NEW_IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
  echo "Error: Invalid IP address format: ${NEW_IP}"
  exit 1
fi

# Check if new subnet mask is valid.
if ! [[ "$NEW_NETMASK" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
  echo "Error: Invalid subnet mask format: ${NEW_NETMASK}"
  exit 1
fi

# Check if new gateway is valid.
if ! [[ "$NEW_GATEWAY" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
  echo "Error: Invalid gateway format: ${NEW_GATEWAY}"
  exit 1
fi

# Modify the configuration file using sed.
echo "Updating configuration file: ${CONFIG_FILE}"
sed -i "s/address.*$/address ${NEW_IP}/" ${CONFIG_FILE}
sed -i "s/netmask.*$/netmask ${NEW_NETMASK}/" ${CONFIG_FILE}
sed -i "s/gateway.*$/gateway ${NEW_GATEWAY}/" ${CONFIG_FILE}

# Apply changes and restart network service.
echo "Applying changes and restarting network service..."
systemctl restart networking
# Or use the appropriate command for your system, e.g.  /etc/init.d/networking restart

# Get the current network configuration using ip command.
echo "Current network configuration:"
ip addr show dev $INTERFACE | grep -E 'inet|inet6' | awk '{print $2}' | sed 's/\/.*//g'

# Print success message.
echo "Network configuration successfully changed!"
echo "New IP address: ${NEW_IP}"
echo "New subnet mask: ${NEW_NETMASK}"
echo "New gateway: ${NEW_GATEWAY}"
