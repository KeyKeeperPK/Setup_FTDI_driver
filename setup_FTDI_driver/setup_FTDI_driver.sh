#!/bin/bash

set -e

# Define download URL and temp paths
FTDI_URL="https://ftdichip.com/wp-content/uploads/2025/03/libftd2xx-linux-arm-v7-sf-1.4.33.tgz"
FTDI_TGZ="/tmp/ft4222.tgz"
FTDI_DIR="/tmp/ftdidir"

echo "==> Downloading FTDI FT4222 driver..."
wget -O "$FTDI_TGZ" "$FTDI_URL"

echo "==> Extracting driver archive..."
mkdir -p "$FTDI_DIR"
tar -xzf "$FTDI_TGZ" -C "$FTDI_DIR"

echo "==> Copying .so libraries to /usr/local/lib..."
find "$FTDI_DIR" -name "*.so" -exec cp {} /usr/local/lib/ \;

echo "==> Setting executable permission on libftd2xx.so..."
chmod +x /usr/local/lib/libftd2xx.so || true

echo "==> Updating linker cache..."
ldconfig

echo "==> Cleaning up temporary files..."
rm -rf "$FTDI_TGZ" "$FTDI_DIR"

# Create udev rule
echo "==> Creating udev rule for FTDI device..."
cat <<EOF | tee /etc/udev/rules.d/99-ftdi.rules > /dev/null
# FTDI FT4222 device
SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6010", MODE="0666", GROUP="plugdev", SYMLINK+="ftdi_ft4222"
EOF

# Reload udev rules and trigger
echo "==> Reloading udev rules..."
udevadm control --reload
udevadm trigger

echo "==> FTDI driver and udev rule installation complete."

# Show if device is available
echo "==> Looking for FTDI device node in /dev..."
ls /dev/ftdi_ft4222 /dev/ttyUSB* 2>/dev/null || echo "No FTDI device currently detected."

