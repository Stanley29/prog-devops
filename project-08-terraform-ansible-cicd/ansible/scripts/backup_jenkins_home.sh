#!/bin/bash
set -e

JENKINS_HOME="/var/lib/jenkins"
BACKUP_FILE="/tmp/jenkins_home.tar.gz"
S3_BUCKET="{{ jenkins_s3_bucket_name }}"

systemctl stop jenkins

tar -czf "$BACKUP_FILE" "$JENKINS_HOME"

aws s3 cp "$BACKUP_FILE" "s3://$S3_BUCKET/jenkins_home.tar.gz"

systemctl start jenkins
