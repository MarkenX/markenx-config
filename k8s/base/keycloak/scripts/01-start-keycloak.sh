#!/bin/bash
set -euo pipefail

KEYCLOAK_BASE_URL="${KEYCLOAK_SCHEME}://${KEYCLOAK_HOST}:8080"
ADMIN_USER="${KEYCLOAK_ADMIN}"
ADMIN_PASS="${KEYCLOAK_ADMIN_PASSWORD}"

echo "[INFO] Starting Keycloak with realm import"
/opt/keycloak/bin/kc.sh start-dev --import-realm &
KC_PID=$!

echo "[INFO] Waiting for Keycloak Admin API..."
until /opt/keycloak/bin/kcadm.sh config credentials \
  --server "$KEYCLOAK_BASE_URL" \
  --realm master \
  --user "$ADMIN_USER" \
  --password "$ADMIN_PASS" > /dev/null 2>&1; do
  sleep 2
done

echo "[SUCCESS] Admin API ready"
export KC_PID
