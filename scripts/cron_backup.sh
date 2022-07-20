#!/usr/bin/env sh
BACKUP_DIR="/tmp/cron_backup/"
BACKUP_NAME="backup-$(date +%Y-%m-%d-%H-%M-%S)"
DIRECTORY_PATH="$1"
TARGET_DIRECTORY_PATH="$2"
MAX_ITERATIONS=10

if [[ -z "$DIRECTORY_PATH" || -z "$TARGET_DIRECTORY_PATH" ]]; then
  log "Usage: $0 <source-directory-path> <target-directory-path>"
  exit 1
fi

log() {
  echo "$(date +%Y-%m-%d-%H-%M-%S) [${2:-Warning}] - $1"
}

setBlockedFlag() {
  local iterations=1
  while [[ -f "${1}block.pid" ]]; do
    log "A Backup is already running, waiting... ${iterations}s"
    sleep 1
    iterations=$((iterations + 1))
    if [[ $iterations -gt ${2:-10} ]]; then
      log "Maximum number of iterations reached, exiting... it looks like the previous backup is stuck. Manual actions needed."
      exit 1
    fi
  done
  # Create block file, insert PID of current process and verify it was created or show an error
  (mkdir -p "${1}" && log $$ >"${1}block.pid") || {
    log "Error creating block file"
    exit 1
  }
}

removeBlockedFlag() {
  rm -f "${1}block.pid" || {
    log "Error removing block file. This will be an issue for future backups."
    exit 1
  }
}

setBlockedFlag "${BACKUP_DIR}" "${MAX_ITERATIONS}"

if [[ ! -d "$DIRECTORY_PATH" ]]; then
  log "Source directory does not exist or is not a directory"
  removeBlockedFlag "${BACKUP_DIR}"
  exit 1
fi

mkdir -p "${TARGET_DIRECTORY_PATH}" || {
  log "Error creating/accesing target backup directory."
  removeBlockedFlag "${BACKUP_DIR}"
  exit 1
}

#copy the directory to a temporary location creating needed directories
cp -r "${DIRECTORY_PATH}" "${BACKUP_DIR}${BACKUP_NAME}" || {
  log "Error copying directory to temporary location."
  removeBlockedFlag "${BACKUP_DIR}"
  exit 1
}

# tar the directory
tar -czf "${TARGET_DIRECTORY_PATH}${BACKUP_NAME}.tar.gz" -C "${BACKUP_DIR}" "${BACKUP_NAME}" || {
  log "Error creating tar archive."
  removeBlockedFlag "${BACKUP_DIR}"
  exit 1
}

removeBlockedFlag "${BACKUP_DIR}"
#remove the temporary directory
rm -rf "${BACKUP_DIR}" || {
  log "Warning: Temporary directory was not successfully removed."
}

log "Backup finished"
exit 0
