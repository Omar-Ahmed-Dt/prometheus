#!/bin/bash

mkdir alertmanager
cd alertmanager

wget https://github.com/prometheus/alertmanager/releases/download/v0.26.0/alertmanager-0.26.0.linux-amd64.tar.gz

sudo tar -xvf alertmanager-0.26.0.linux-amd64.tar.gz

sudo mkdir /var/lib/alertmanager
cd alertmanager-0.26.0.linux-amd64
sudo mv * /var/lib/alertmanager
cd /var/lib/alertmanager/
sudo chown -R prometheus:prometheus /var/lib/alertmanager
sudo chown -R prometheus:prometheus /var/lib/alertmanager/*
sudo chown -R 755  /var/lib/alertmanager
sudo chown -R 755  /var/lib/alertmanager/*

cat <<EOF | sudo tee /etc/systemd/system/alertmanager.service
[Unit]
Description=Prometheus Alert Manager
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/var/lib/alertmanager/alertmanager --storage.path="/var/lib/alertmanager/data" --config.file="/var/lib/alertmanager/alertmanager.yml"

SyslogIdentifier=prometheus_alert_manager
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start alertmanager
sudo systemctl enable alertmanager
sudo systemctl status  alertmanager


