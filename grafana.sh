#!/bin/bash

# Update the package index
sudo apt update -y 

# Install necessary packages
sudo apt install -y software-properties-common

# Add the Grafana APT repository
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

# Add the GPG key
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

# Update the package index again
sudo apt update -y 

# Install Grafana
sudo apt install -y grafana

# Start and enable the Grafana service
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Print instructions
echo "Grafana has been installed and started. You can access it at http://localhost:3000"
echo "Default credentials: admin/admin"

# Additional message for enabling the service to start on boot
echo "To enable Grafana to start on boot, use: sudo systemctl enable grafana-server"

