#!/bin/bash
set -euo pipefail

JENKINS_HOME="$1"
BUCKET="$2"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H-%M-%SZ")
ARCHIVE="/tmp/${TIMESTAMP}_jenkins_home_backup.tar.gz"
LOGFILE="/var/log/jenkins_backup.log"

systemctl stop jenkins
tar -czf "$ARCHIVE" -C "$JENKINS_HOME" .
aws s3 cp "$ARCHIVE" "s3://$BUCKET/"
systemctl start jenkins

echo "[$(date -u)] Backup completed: $ARCHIVE" >> "$LOGFILE"

