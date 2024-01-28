#!/bin/bash

# Update package list
sudo apt update -y 

# Install necessary dependencies
sudo apt install wget -y 

# Allow incoming traffic on port 9090 (assuming UFW is already installed)
sudo ufw allow 9090

# Reload UFW rules
sudo ufw reload

# Download Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.30.3/prometheus-2.30.3.linux-amd64.tar.gz

# Extract the downloaded archive
tar -xvf prometheus-2.30.3.linux-amd64.tar.gz

# Move Prometheus binaries to /usr/local/bin/
sudo mv prometheus-2.30.3.linux-amd64/{prometheus,promtool} /usr/local/bin/

# Create a Prometheus configuration file
cat <<EOF | sudo tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF

# Create Prometheus user and set permissions
sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus /var/lib/prometheus
sudo chmod 775 /etc/prometheus /var/lib/prometheus

# Start Prometheus as a service
cat <<EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=default.target
EOF

# Reload systemd and start Prometheus
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

# Clean up downloaded files
rm -rf prometheus-2.30.3.linux-amd64.tar.gz prometheus-2.30.3.linux-amd64
