#!/usr/bin/env bash
set -e

WILDFLY_VERSION=30.0.0.Final
INSTALL_DIR=/opt

apt-get update -y
apt-get install -y openjdk-17-jdk wget unzip

cd /tmp
wget https://github.com/wildfly/wildfly/releases/download//wildfly-.zip
unzip wildfly-.zip -d 
mv /wildfly- /wildfly

useradd -r -s /bin/false wildfly || true
chown -R wildfly:wildfly /wildfly

cat > /etc/systemd/system/wildfly.service << EOF
[Unit]
Description=WildFly Application Server
After=network.target

[Service]
Type=simple
User=wildfly
Group=wildfly
ExecStart=/opt/wildfly/bin/standalone.sh -b 0.0.0.0
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable wildfly
systemctl start wildfly