#!/bin/bash
set -euo pipefail

REALM="${KEYCLOAK_REALM}"
REALM_JSON="/opt/keycloak/data/import/realm.json"

if /opt/keycloak/bin/kcadm.sh get "realms/$REALM" > /dev/null 2>&1; then
  echo "[INFO] Realm already exists: $REALM"
else
  echo "[INFO] Creating realm: $REALM"
  /opt/keycloak/bin/kcadm.sh create realms -f "$REALM_JSON"
  echo "[SUCCESS] Realm created"
fi
