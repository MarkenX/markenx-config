#!/bin/bash
set -e

KEYCLOAK_BASE_URL="${KEYCLOAK_SCHEME}://${KEYCLOAK_HOST}:8080"
ADMIN_USER="${KEYCLOAK_ADMIN}"
ADMIN_PASS="${KEYCLOAK_ADMIN_PASSWORD}"

# Start Keycloak in background with realm import
/opt/keycloak/bin/kc.sh start-dev --import-realm &
echo $! > /tmp/keycloak.pid
echo "[INFO] Keycloak started with PID: $(cat /tmp/keycloak.pid)"

# Wait for Admin API to be ready
until /opt/keycloak/bin/kcadm.sh config credentials \
    --server "$KEYCLOAK_BASE_URL" \
    --realm master \
    --user "$ADMIN_USER" \
    --password "$ADMIN_PASS" > /dev/null 2>&1; do
    echo "[INFO] Admin API not in ${KEYCLOAK_BASE_URL} ready, retrying..."
    sleep 2
done
echo "[SUCCESS] Admin login successful"