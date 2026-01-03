#!/bin/bash
set -e

# Execute scripts in order
/opt/keycloak/data/import/00-start-keycloak.sh
/opt/keycloak/data/import/10-setup-realm.sh
/opt/keycloak/data/import/20-setup-client.sh

# Wait for Keycloak process
KEYCLOAK_PID=$(cat /tmp/keycloak.pid 2>/dev/null)
if [ -n "$KEYCLOAK_PID" ]; then
    echo "=== Keycloak running on PID: $KEYCLOAK_PID ==="
    # Loop to keep the script alive while Keycloak is running
    while kill -0 "$KEYCLOAK_PID" 2>/dev/null; do
        sleep 5
    done
    echo "[INFO] Keycloak process terminated"
fi
