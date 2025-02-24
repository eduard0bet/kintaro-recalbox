#!/bin/bash

# Colors for messages
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Kintaro Controller Installation...${NC}"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root${NC}"
    echo "Try: sudo $0"
    exit 1
fi

# Check if it's a Raspberry Pi
if ! grep -q "Raspberry Pi" /proc/cpuinfo; then
    echo -e "${RED}This script only works on Raspberry Pi${NC}"
    exit 1
fi

# Mount system in write mode
echo "Mounting system in write mode..."
mount -o remount,rw /

# Create temporary directory
TMP_DIR=$(mktemp -d)
cd $TMP_DIR

# Download files
echo "Downloading files..."
curl -sSL https://raw.githubusercontent.com/eduard0bet/kintaro-recalbox/refs/heads/release/Kintaro/kintaro.py -o kintaro.py
curl -sSL https://raw.githubusercontent.com/eduard0bet/kintaro-recalbox/refs/heads/release/S100kintaro.sh -o S100kintaro.sh

if [ ! -f kintaro.py ] || [ ! -f S100kintaro.sh ]; then
    echo -e "${RED}Error downloading files${NC}"
    exit 1
fi

# Create directory structure
echo "Creating directories..."
mkdir -p /opt/Kintaro

# Copy files
echo "Copying files..."
cp -f kintaro.py /opt/Kintaro/
cp -f S100kintaro.sh /etc/init.d/

# Set permissions
echo "Setting permissions..."
chmod 755 /opt/Kintaro/kintaro.py
chmod 755 /etc/init.d/S100kintaro.sh

# Clean temporary directory
echo "Cleaning temporary files..."
cd /
rm -rf $TMP_DIR

# Verify installation
if [ -f /opt/Kintaro/kintaro.py ] && [ -f /etc/init.d/S100kintaro.sh ]; then
    echo -e "${GREEN}                                                                      ${NC}"
    echo -e "${GREEN}    ░▒▒▒░      ░░░░░                                                  ${NC}"
    echo -e "${GREEN}    ░███▒     ░▒███░░           ░░░░                                  ${NC}"
    echo -e "${GREEN}    ░███▒      ░░▒░░            ▓██░                                  ${NC}"
    echo -e "${GREEN}    ░███▒░▒███░▒██▓░░████████▒░██████▒░▓██████░░ ███▓██░░▓█████▓░░    ${NC}"
    echo -e "${GREEN}    ░███▒███▒░ ▒██▓░░███▒░▒███░░▓██▒░░░░▒░░░▓██░░████▒░▒███░░▒███▒░   ${NC}"
    echo -e "${GREEN}    ░██████▓░░ ▒██▓░░███░ ░███░ ▓██░ ░░▓███████▒░███░  ▓██▒░ ░▒██▒░   ${NC}"
    echo -e "${GREEN}    ░███▒▓███░ ▒██▓░░███░ ░███░ ▒██▓░░███░░░███▒░███░  ▒███▒░▓███░░   ${NC}"
    echo -e "${GREEN}    ░▓██░░░███▒▒██▓░░███░ ░▓██░ ░▓███▒░▓███▓▓██▒░███░   ░▒█████▒░░    ${NC}"
    echo -e "${GREEN}                                                                      ${NC}"
    echo -e "${GREEN}Installation completed successfully${NC}"
    echo -e "${GREEN}System will reboot in 5 seconds...${NC}"
    sleep 5
    reboot
else
    echo -e "${RED}Installation failed${NC}"
    exit 1
fi