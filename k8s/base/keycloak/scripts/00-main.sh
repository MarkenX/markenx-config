#!/bin/bash
set -euo pipefail

SCRIPTS_DIR="/opt/keycloak/data/import"
PID_FILE="/tmp/keycloak.pid"

# Cargar funciones de logging comunes
source "${SCRIPTS_DIR}/common-logging.sh"

require_script() {
  local script="$1"
  if [[ ! -x "$script" ]]; then
    log_error "Script not found or not executable: $script"
    exit 1
  fi
}

log_info "Starting Keycloak bootstrap sequence"

# Validar que los scripts necesarios existan y sean ejecutables
require_script "$SCRIPTS_DIR/00-start-keycloak.sh"
require_script "$SCRIPTS_DIR/10-setup-realm.sh"
require_script "$SCRIPTS_DIR/20-setup-client.sh"

log_info "Step 1/3: Starting Keycloak"
"$SCRIPTS_DIR/00-start-keycloak.sh"
log_success "Keycloak started successfully"

log_info "Step 2/3: Setting up realm"
"$SCRIPTS_DIR/10-setup-realm.sh"
log_success "Realm configured successfully"

log_info "Step 3/3: Setting up client"
"$SCRIPTS_DIR/20-setup-client.sh"
log_success "Client configured successfully"

# Verificar que Keycloak haya creado el PID file
if [[ ! -f "$PID_FILE" ]]; then
  log_error "Keycloak PID file not found at $PID_FILE. Startup may have failed."
  exit 1
fi

KEYCLOAK_PID=$(cat "$PID_FILE")
log_info "Keycloak is running with PID: $KEYCLOAK_PID"

terminate() {
  log_info "Received termination signal, shutting down Keycloak gracefully..."
  kill -TERM "$KEYCLOAK_PID" 2>/dev/null || true
  wait "$KEYCLOAK_PID" 2>/dev/null || true
  log_success "Keycloak stopped gracefully"
  exit 0
}

trap terminate SIGTERM SIGINT

log_success "Bootstrap completed successfully"
log_info "Entering wait loop for Keycloak process (PID: $KEYCLOAK_PID)"

# Mantener el contenedor vivo siguiendo el proceso de Keycloak
wait "$KEYCLOAK_PID"