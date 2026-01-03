#!/bin/bash
set -euo pipefail

# Determinar el directorio donde está este script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cargar funciones de logging comunes
source "${SCRIPT_DIR}/common-logging.sh"

# Variables de configuración
REALM="${KEYCLOAK_REALM:-myrealm}"
CLIENT_ID="${KEYCLOAK_CLIENT:-my-client}"
OUTPUT_DIR="/opt/keycloak/data/secrets"

# Crear directorio para secretos si no existe
mkdir -p "$OUTPUT_DIR"
chmod 700 "$OUTPUT_DIR"

log_info "Configuring client '$CLIENT_ID' in realm '$REALM'"

# Obtener UUID del cliente
log_info "Looking for existing client with clientId '$CLIENT_ID'..."

CLIENT_UUID=$(/opt/keycloak/bin/kcadm.sh get clients \
  -r "$REALM" \
  -q clientId="$CLIENT_ID" \
  --fields id \
  --format csv --noquotes | tail -n +2)

if [[ -z "$CLIENT_UUID" ]]; then
  log_info "Client '$CLIENT_ID' not found. Creating new client..."

  /opt/keycloak/bin/kcadm.sh create clients -r "$REALM" \
    -s clientId="$CLIENT_ID" \
    -s enabled=true \
    -s serviceAccountsEnabled=true \
    -s publicClient=false \
    -s clientAuthenticatorType=client-secret

  # Volver a obtener el UUID tras la creación
  CLIENT_UUID=$(/opt/keycloak/bin/kcadm.sh get clients \
    -r "$REALM" \
    -q clientId="$CLIENT_ID" \
    --fields id \
    --format csv --noquotes | tail -n +2)

  if [[ -z "$CLIENT_UUID" ]]; then
    log_error "Failed to retrieve UUID after creating client '$CLIENT_ID'"
    exit 1
  fi

  log_success "Client '$CLIENT_ID' created successfully (UUID: $CLIENT_UUID)"
else
  log_info "Client '$CLIENT_ID' already exists (UUID: $CLIENT_UUID)"
fi

# Asignar roles al service account del cliente
log_info "Assigning realm-management roles to service account of '$CLIENT_ID'..."

for ROLE in manage-users view-users query-users; do
  /opt/keycloak/bin/kcadm.sh add-roles \
    -r "$REALM" \
    --uusername "service-account-$CLIENT_ID" \
    --cclientid realm-management \
    --rolename "$ROLE" > /dev/null 2>&1 || log_warning "Role '$ROLE' already assigned or not available"
done

log_success "Service account roles assigned"

# Generar y guardar el client secret (solo si no existe)
SECRET_FILE="$OUTPUT_DIR/client-secret.txt"

if [[ ! -f "$SECRET_FILE" ]]; then
  log_info "Retrieving client secret for '$CLIENT_ID'..."

  CLIENT_SECRET=$(/opt/keycloak/bin/kcadm.sh get "clients/$CLIENT_UUID/client-secret" \
    -r "$REALM" \
    --fields value \
    --format csv --noquotes | tail -n +2)

  if [[ -z "$CLIENT_SECRET" ]]; then
    log_error "Failed to retrieve client secret for client UUID $CLIENT_UUID"
    exit 1
  fi

  echo -n "$CLIENT_SECRET" > "$SECRET_FILE"
  chmod 600 "$SECRET_FILE"

  log_success "Client secret generated and securely stored at $SECRET_FILE"
else
  log_info "Client secret already exists at $SECRET_FILE. Skipping generation."
fi

touch /tmp/keycloak-ready
log_success "Client configuration completed successfully"
log_info "Keycloak setup is now fully ready"