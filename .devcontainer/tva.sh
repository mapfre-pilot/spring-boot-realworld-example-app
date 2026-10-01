#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR=/tmp/tva-logs

log() {
  printf '[tva] %s\n' "$*"
}

generate_token() {
  local token
  token="$(cd "$ROOT/tva-backend/sources" && poetry run python manage.py crear_token_local \
    --usuario operador1 --roles TVA_USUARIO,TVA_ADMIN_PORTAL --horas 24)"
  printf '%s\n' "$token" > "$ROOT/.devcontainer/.tva-token"
  chmod 600 "$ROOT/.devcontainer/.tva-token"
  printf '%s\n' "$token"
}

stop_server() {
  local name="$1"
  local pid_file="$LOG_DIR/${name}.pid"
  if [[ -f "$pid_file" ]]; then
    local pid
    pid="$(<"$pid_file")"
    if [[ "$pid" =~ ^[0-9]+$ ]]; then
      kill -TERM -- "-$pid" 2>/dev/null || kill -TERM "$pid" 2>/dev/null || true
    fi
    rm -f "$pid_file"
    log "Servidor $name detenido."
  fi
}

case "${1:-}" in
  start)
    bash "$ROOT/.devcontainer/start-tva.sh"
    ;;
  stop)
    stop_server frontend
    stop_server backend
    ;;
  logs)
    mkdir -p "$LOG_DIR"
    touch "$LOG_DIR/backend.log" "$LOG_DIR/frontend.log"
    tail -f "$LOG_DIR/backend.log" "$LOG_DIR/frontend.log"
    ;;
  token)
    generate_token
    ;;
  status)
    log "Backend:"
    curl -fsS http://localhost:8888/api/tva/v1/salud/ || true
    printf '\n'
    if python - 4200 <<'PY'
import socket
import sys

with socket.socket() as sock:
    sock.settimeout(0.3)
    sys.exit(0 if sock.connect_ex(("127.0.0.1", int(sys.argv[1]))) == 0 else 1)
PY
    then
      log "Frontend escuchando en el puerto 4200."
    else
      log "Frontend no disponible en el puerto 4200."
    fi
    ;;
  *)
    printf 'Uso: bash .devcontainer/tva.sh {start|stop|logs|token|status}\n' >&2
    exit 2
    ;;
esac
