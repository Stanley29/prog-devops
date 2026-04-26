#!/bin/bash
set -e

apt update -y
apt install -y openjdk-17-jdk apache2 wget unzip

cd /opt
wget https://github.com/wildfly/wildfly/releases/download/30.0.1.Final/wildfly-30.0.1.Final.zip
unzip wildfly-30.0.1.Final.zip
mv wildfly-30.0.1.Final wildfly

cat <<EOF >/etc/systemd/system/wildfly.service
[Unit]
Description=WildFly Application Server
After=network.target

[Service]
Type=simple
ExecStart=/opt/wildfly/bin/standalone.sh -b 0.0.0.0
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable wildfly
systemctl start wildfly

systemctl enable apache2
systemctl start apache2
