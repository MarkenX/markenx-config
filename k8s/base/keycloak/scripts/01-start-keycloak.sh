#!/bin/bash
set -euo pipefail

# Determinar el directorio donde está este script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cargar funciones de logging comunes
source "${SCRIPT_DIR}/common-logging.sh"

KEYCLOAK_BASE_URL="${KEYCLOAK_SCHEME:-http}://${KEYCLOAK_HOST:-localhost}:8080"
ADMIN_USER="${KEYCLOAK_ADMIN:-admin}"
ADMIN_PASS="${KEYCLOAK_ADMIN_PASSWORD:-admin}"

log_info "Starting Keycloak in dev mode with realm import"
log_info "Keycloak URL: $KEYCLOAK_BASE_URL"
log_info "Admin user: $ADMIN_USER"

/opt/keycloak/bin/kc.sh start-dev --import-realm &
KC_PID=$!

# Exportar el PID para que el script bootstrap pueda acceder a él
export KC_PID

# Guardar el PID en el archivo esperado por el bootstrap (si no existe ya)
PID_FILE="/tmp/keycloak.pid"
echo "$KC_PID" > "$PID_FILE"

log_info "Keycloak started in background with PID: $KC_PID"
log_info "Waiting for Admin API to become available..."

until /opt/keycloak/bin/kcadm.sh config credentials \
  --server "$KEYCLOAK_BASE_URL" \
  --realm master \
  --user "$ADMIN_USER" \
  --password "$ADMIN_PASS" > /dev/null 2>&1; do

  sleep 2
done

log_success "Keycloak Admin API is ready at $KEYCLOAK_BASE_URL"
log_info "Startup script completed successfully"