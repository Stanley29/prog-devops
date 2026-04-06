#!/bin/bash
set -e

WILDFLY_VERSION=30.0.1.Final
WILDFLY_HOME=/opt/wildfly

echo "Downloading WildFly..."
cd /tmp
wget https://github.com/wildfly/wildfly/releases/download/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz

echo "Extracting..."
sudo tar xf wildfly-$WILDFLY_VERSION.tar.gz -C /opt
sudo mv /opt/wildfly-$WILDFLY_VERSION $WILDFLY_HOME

echo "Creating wildfly user..."
sudo useradd -r -s /bin/false wildfly || true
sudo chown -R wildfly:wildfly $WILDFLY_HOME

echo "Creating systemd service..."
sudo bash -c 'cat > /etc/systemd/system/wildfly.service <<EOF
[Unit]
Description=WildFly Application Server
After=network.target

[Service]
Type=simple
User=wildfly
Group=wildfly
ExecStart=/opt/wildfly/bin/launch.sh standalone standalone.xml 0.0.0.0
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

echo "Reloading systemd..."
sudo systemctl daemon-reload
sudo systemctl enable wildfly
sudo systemctl start wildfly

echo "WildFly installation completed."
