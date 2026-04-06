#!/bin/sh

if [ "$1" = "domain" ]; then
    /opt/wildfly/bin/domain.sh -c $2 -b $3
else
    /opt/wildfly/bin/standalone.sh -c $2 -b $3
fi
