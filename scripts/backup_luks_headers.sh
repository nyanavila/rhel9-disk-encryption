#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="/root/luks_header_backups"
HOSTNAME=$(hostname -s)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "${BACKUP_DIR}"
chmod 700 "${BACKUP_DIR}"

for DEV in $(lsblk -lno NAME,FSTYPE | awk '$2=="crypto_LUKS" {print $1}'); do
    TARGET_DEV="/dev/${DEV}"
    BACKUP_FILE="${BACKUP_DIR}/${HOSTNAME}_${DEV}_header_${TIMESTAMP}.bin"

    echo "[*] Creating LUKS header backup for ${TARGET_DEV}..."
    cryptsetup luksHeaderBackup "${TARGET_DEV}" --header-backup-file "${BACKUP_FILE}"
    chmod 600 "${BACKUP_FILE}"
    echo "[+] Header saved to ${BACKUP_FILE}"
done
