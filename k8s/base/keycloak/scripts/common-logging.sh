#!/bin/bash

log_info() {
  echo "[$(date -Iseconds)] [INFO] $*"
}

log_error() {
  echo "[$(date -Iseconds)] [ERROR] $*" >&2
}

log_success() {
  echo "[$(date -Iseconds)] [SUCCESS] $*"
}

log_warning() {
  echo "[$(date -Iseconds)] [WARNING] $*"
}