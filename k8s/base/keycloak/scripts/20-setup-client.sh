#!/bin/bash
set -euo pipefail

REALM="${KEYCLOAK_REALM}"
CLIENT_ID="${KEYCLOAK_CLIENT}"
OUTPUT_DIR="/opt/keycloak/data/secrets"

mkdir -p "$OUTPUT_DIR"

echo "[INFO] Configuring client: $CLIENT_ID"

CLIENT_UUID=$(/opt/keycloak/bin/kcadm.sh get clients \
  -r "$REALM" \
  -q clientId="$CLIENT_ID" \
  --fields id \
  --format csv | tail -n +2 || true)

if [[ -z "$CLIENT_UUID" ]]; then
  echo "[INFO] Creating client"

  /opt/keycloak/bin/kcadm.sh create clients -r "$REALM" \
    -s clientId="$CLIENT_ID" \
    -s enabled=true \
    -s serviceAccountsEnabled=true \
    -s publicClient=false \
    -s clientAuthenticatorType=client-secret

  CLIENT_UUID=$(/opt/keycloak/bin/kcadm.sh get clients \
    -r "$REALM" \
    -q clientId="$CLIENT_ID" \
    --fields id \
    --format csv | tail -n +2)

  echo "[SUCCESS] Client created: $CLIENT_UUID"
else
  echo "[INFO] Client already exists"
fi

echo "[INFO] Assigning service account roles"
for ROLE in manage-users view-users query-users; do
  /opt/keycloak/bin/kcadm.sh add-roles \
    -r "$REALM" \
    --uusername "service-account-$CLIENT_ID" \
    --cclientid realm-management \
    --rolename "$ROLE" || true
done

SECRET_FILE="$OUTPUT_DIR/client-secret.txt"
if [[ ! -f "$SECRET_FILE" ]]; then
  CLIENT_SECRET=$(/opt/keycloak/bin/kcadm.sh get \
    "clients/$CLIENT_UUID/client-secret" \
    -r "$REALM" \
    --fields value \
    --format csv | tail -n +2)

  echo -n "$CLIENT_SECRET" > "$SECRET_FILE"
  chmod 600 "$SECRET_FILE"
  echo "[SUCCESS] Client secret stored"
else
  echo "[INFO] Client secret already exists, skipping"
fi

touch /tmp/keycloak-ready
