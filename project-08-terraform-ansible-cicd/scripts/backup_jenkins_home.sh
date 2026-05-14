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

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 /var/lib/jenkins jenkins-home-backup-bucket-08"
  exit 1
fi

JENKINS_HOME="$1"
S3_BUCKET="$2"

if [ ! -d "$JENKINS_HOME" ]; then
  log_error "JENKINS_HOME directory does not exist: $JENKINS_HOME"
  exit 1
fi

if ! command -v aws >/dev/null 2>&1; then
  log_error "aws CLI is not installed"
  exit 1
fi

if ! aws s3 ls "s3://$S3_BUCKET" >/dev/null 2>&1; then
  log_error "S3 bucket does not exist or is not accessible: $S3_BUCKET"
  exit 1
fi

TS="$(date -u +%Y-%m-%dT%H-%M-%S)"
ARCHIVE="/tmp/jenkins_home_${TS}.tar.gz"

log_info "Starting backup of $JENKINS_HOME to S3 bucket $S3_BUCKET"
log_info "Creating archive $ARCHIVE"
tar -czf "$ARCHIVE" -C / "$(echo "$JENKINS_HOME" | sed "s|^/||")"

S3_OBJECT="s3://$S3_BUCKET/jenkins_home_${TS}.tar.gz"
log_info "Uploading archive to $S3_OBJECT"
if aws s3 cp "$ARCHIVE" "$S3_OBJECT"; then
  log_info "Backup successfully uploaded to $S3_OBJECT"
  rm -f "$ARCHIVE"
  log_info "Temporary archive removed: $ARCHIVE"
  exit 0
else
  log_error "Failed to upload backup to S3"
  exit 1
fi
