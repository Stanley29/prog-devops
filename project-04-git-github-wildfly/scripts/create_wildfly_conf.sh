#!/bin/bash
set -e

echo "Creating /etc/wildfly/wildfly.conf..."

sudo bash -c 'cat > /etc/wildfly/wildfly.conf <<EOF
WILDFLY_CONFIG=standalone.xml
WILDFLY_MODE=standalone
WILDFLY_BIND=0.0.0.0
EOF'

echo "wildfly.conf created successfully."
