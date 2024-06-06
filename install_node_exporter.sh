#!/bin/bash

# Prometheus Node Exporter Installation Script
# This script installs Prometheus Node Exporter on a Linux system,
# sets it up as a systemd service, and ensures it's running.

# Function to check the last command status and exit on failure
check_status() {
  if [ $? -ne 0 ]; then
    echo "Error occurred in the previous command. Exiting."
    exit 1
  fi
}

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Please use sudo."
  exit 1
fi

# Detect the operating system
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$ID
else
  echo "Unsupported operating system."
  exit 1
fi

# Variables
VERSION="1.8.1"  # Change this to the latest version if needed
USER="prometheus"
GROUP="prometheus"
DOWNLOAD_URL="https://github.com/prometheus/node_exporter/releases/download/v$VERSION/node_exporter-$VERSION.linux-amd64.tar.gz"

# Update package list and install necessary packages
case $OS in
  ubuntu|debian)
    echo "Updating package list..."
    apt-get update
    check_status

    echo "Installing wget and tar..."
    apt-get install -y wget tar
    check_status
    ;;
  centos|fedora|rhel)
    echo "Installing wget and tar..."
    yum install -y wget tar
    check_status
    ;;
  *)
    echo "Unsupported operating system: $OS"
    exit 1
    ;;
esac

# Create system group and user for node_exporter
echo "Creating system group and user for node_exporter..."
if ! getent group $GROUP > /dev/null 2>&1; then
  groupadd --system $GROUP
  check_status
else
  echo "Group $GROUP already exists."
fi

if ! id -u $USER > /dev/null 2>&1; then
  useradd --system -g $GROUP --no-create-home --shell /sbin/nologin $USER
  check_status
else
  echo "User $USER already exists."
fi

# Download and extract Node Exporter
echo "Downloading Node Exporter version $VERSION..."
wget $DOWNLOAD_URL
check_status

echo "Extracting Node Exporter..."
tar -xvf node_exporter-$VERSION.linux-amd64.tar.gz
check_status

# Move the binaries to /usr/local/bin
echo "Moving Node Exporter binaries to /usr/local/bin..."
mv node_exporter-$VERSION.linux-amd64/node_exporter /usr/local/bin/
check_status

# Set permissions
echo "Setting permissions for Node Exporter binaries..."
chown $USER:$GROUP /usr/local/bin/node_exporter
check_status

# Clean up downloaded files
echo "Cleaning up..."
rm -rf node_exporter-$VERSION.linux-amd64.tar.gz node_exporter-$VERSION.linux-amd64

# Create systemd service file
echo "Creating systemd service file for Node Exporter..."
cat <<EOF | tee /etc/systemd/system/node-exporter.service
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$GROUP
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF
check_status

# Reload systemd daemon and start Node Exporter service
echo "Reloading systemd daemon..."
systemctl daemon-reload
check_status

echo "Enabling Node Exporter service..."
systemctl enable node-exporter
check_status

echo "Starting Node Exporter service..."
systemctl start node-exporter
check_status

# Check Node Exporter service status
# echo "Checking Node Exporter service status..."
# systemctl status node_exporter

echo "Node Exporter installation completed successfully."
