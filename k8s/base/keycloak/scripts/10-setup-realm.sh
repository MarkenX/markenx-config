#!/bin/bash
set -e

REALM="${KEYCLOAK_REALM}"
REALM_JSON="/opt/keycloak/data/import/realm.json"

# Create realm if not exists
if ! /opt/keycloak/bin/kcadm.sh get "realms/$REALM" > /dev/null 2>&1; then
    echo "[INFO] Creating realm: $REALM"
    /opt/keycloak/bin/kcadm.sh create realms -f "$REALM_JSON"
    echo "[SUCCESS] Realm created"
else
    echo "[INFO] Realm already exists: $REALM"
fi