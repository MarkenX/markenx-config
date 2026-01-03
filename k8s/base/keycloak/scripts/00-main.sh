#!/bin/bash
set -euo pipefail

SCRIPTS_DIR="/opt/keycloak/data/import"
PID_FILE="/tmp/keycloak.pid"

log() {
  echo "[$(date -Iseconds)] $*"
}

require_script() {
  local script="$1"
  if [[ ! -x "$script" ]]; then
    log "ERROR: Script not found or not executable: $script"
    exit 1
  fi
}

log "Starting Keycloak bootstrap sequence"

require_script "$SCRIPTS_DIR/00-start-keycloak.sh"
require_script "$SCRIPTS_DIR/10-setup-realm.sh"
require_script "$SCRIPTS_DIR/20-setup-client.sh"

log "Step 1/3: Starting Keycloak"
/opt/keycloak/data/import/00-start-keycloak.sh

log "Step 2/3: Setting up realm"
/opt/keycloak/data/import/10-setup-realm.sh

log "Step 3/3: Setting up client"
/opt/keycloak/data/import/20-setup-client.sh

if [[ ! -f "$PID_FILE" ]]; then
  log "ERROR: Keycloak PID file not found"
  exit 1
fi

KEYCLOAK_PID=$(cat "$PID_FILE")
log "Keycloak running with PID: $KEYCLOAK_PID"

terminate() {
  log "Received termination signal, shutting down Keycloak..."
  kill -TERM "$KEYCLOAK_PID" 2>/dev/null || true
  wait "$KEYCLOAK_PID" 2>/dev/null || true
  log "Keycloak stopped"
  exit 0
}

trap terminate SIGTERM SIGINT

log "Bootstrap completed, entering wait"
wait "$KEYCLOAK_PID"
