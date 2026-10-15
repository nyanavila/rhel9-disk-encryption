#!/usr/bin/env bash
set -euo pipefail

VAULT_ADDR="${VAULT_ADDR:-https://vault.corp.internal:8200}"
VAULT_TOKEN=$(cat /etc/vault/token)
HOSTNAME=$(hostname -f)
DEVICE="${1:-/dev/mapper/vg00-lv_root}"
PASSPHRASE="${2:-}"

if [[ -z "${PASSPHRASE}" ]]; then
    echo "Usage: $0 <device> <admin_passphrase>"
    exit 1
fi

LUKS_UUID=$(cryptsetup luksUUID "${DEVICE}")

echo "[*] Escrowing Keyslot 0 admin credentials to HashiCorp Vault..."
curl -s -X POST \
     -H "X-Vault-Token: ${VAULT_TOKEN}" \
     -H "Content-Type: application/json" \
     -d "{\"data\": {\"hostname\": \"${HOSTNAME}\", \"device\": \"${DEVICE}\", \"uuid\": \"${LUKS_UUID}\", \"admin_key\": \"${PASSPHRASE}\"}}" \
     "${VAULT_ADDR}/v1/secret/data/rhel-encryption/${HOSTNAME}"

echo "[+] Credentials successfully escrowed."
