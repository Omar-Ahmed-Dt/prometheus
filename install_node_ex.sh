#!/bin/bash

# Update package list
sudo apt update -y 

# Allow incoming traffic on port 9100
sudo ufw allow 9100
sudo ufw allow 9090

# Reload UFW rules
sudo ufw reload

# Download Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.2.2/node_exporter-1.2.2.linux-amd64.tar.gz

# Extract the downloaded archive
tar -xvf node_exporter-1.2.2.linux-amd64.tar.gz

# Move Node Exporter binary to /usr/local/bin/
sudo mv node_exporter-1.2.2.linux-amd64/node_exporter /usr/local/bin/

# Create Node Exporter user and set permissions
sudo useradd --no-create-home --shell /bin/false node_exporter

# Create Node Exporter service file
cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

# Reload systemd and start Node Exporter
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Clean up downloaded files
rm -rf node_exporter-1.2.2.linux-amd64.tar.gz node_exporter-1.2.2.linux-amd64
