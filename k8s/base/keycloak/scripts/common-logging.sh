#!/bin/bash

readonly RESET='\033[0m'
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'

log_info() {
  echo -e "[$(date -Iseconds)] $$ {YELLOW}[INFO] $${RESET} $*"
}

log_error() {
  echo -e "[$(date -Iseconds)] $$ {RED}[ERROR] $${RESET} $*" >&2
}

log_success() {
  echo -e "[$(date -Iseconds)] $$ {GREEN}[SUCCESS] $${RESET} $*"
}

log_warning() {
  echo -e "[$(date -Iseconds)] $$ {YELLOW}[WARNING] $${RESET} $*"
}