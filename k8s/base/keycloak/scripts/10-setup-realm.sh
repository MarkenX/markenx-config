#!/bin/bash
set -euo pipefail

# Determinar el directorio donde está este script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cargar funciones de logging comunes
source "${SCRIPT_DIR}/common-logging.sh"

# Variables de configuración
REALM="${KEYCLOAK_REALM:-master}"  # Valor por defecto opcional, ajusta si es necesario
REALM_JSON="/opt/keycloak/data/import/realm.json"

# Validar que el archivo JSON del realm exista
if [[ ! -f "$REALM_JSON" ]]; then
  log_error "Realm configuration file not found: $REALM_JSON"
  exit 1
fi

log_info "Checking if realm '$REALM' already exists..."

if /opt/keycloak/bin/kcadm.sh get "realms/$REALM" > /dev/null 2>&1; then
  log_info "Realm '$REALM' already exists. Skipping creation."
else
  log_info "Realm '$REALM' does not exist. Creating from $REALM_JSON..."

  if /opt/keycloak/bin/kcadm.sh create realms -f "$REALM_JSON"; then
    log_success "Realm '$REALM' created successfully"
  else
    log_error "Failed to create realm '$REALM'"
    exit 1
  fi
fi

log_info "Realm setup completed"