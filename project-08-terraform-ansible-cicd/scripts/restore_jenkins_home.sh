#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/var/log/jenkins_backup.log"

log() {
  local level="$1"; shift
  local msg="$*"
  local ts="$(date -u +%Y-%m-%dT%H:%M:%S)"
  echo "[$ts] [$level] $msg" | tee -a "$LOG_FILE"
}

log_info()  { log "INFO"  "$@"; }
log_warn()  { log "WARN"  "$@"; }
log_error() { log "ERROR" "$@"; }

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 /var/lib/jenkins jenkins-home-backup-bucket-08 jenkins_home_YYYY-MM-DDTHH-MM-SS.tar.gz"
  exit 1
fi

JENKINS_HOME="$1"
S3_BUCKET="$2"
ARCHIVE_NAME="$3"

if [ ! -d "$JENKINS_HOME" ]; then
  log_error "JENKINS_HOME directory does not exist: $JENKINS_HOME"
  exit 1
fi

if ! command -v aws >/dev/null 2>&1; then
  log_error "aws CLI is not installed"
  exit 1
fi

S3_OBJECT="s3://$S3_BUCKET/$ARCHIVE_NAME"
TMP_ARCHIVE="/tmp/jenkins_home_restore.tar.gz"

log_info "Restoring JENKINS_HOME from $S3_OBJECT to $JENKINS_HOME"
if ! aws s3 cp "$S3_OBJECT" "$TMP_ARCHIVE"; then
  log_error "Failed to download archive from S3: $S3_OBJECT"
  exit 1
fi

if systemctl is-active --quiet jenkins; then
  log_info "Stopping Jenkins service before restore"
  systemctl stop jenkins
fi

log_info "Extracting archive to /"
tar -xzf "$TMP_ARCHIVE" -C /

log_info "Setting ownership on $JENKINS_HOME"
chown -R jenkins:jenkins "$JENKINS_HOME"

rm -f "$TMP_ARCHIVE"
log_info "Temporary archive removed: $TMP_ARCHIVE"

log_info "Starting Jenkins service"
systemctl start jenkins
log_info "JENKINS_HOME restore completed successfully"
exit 0
