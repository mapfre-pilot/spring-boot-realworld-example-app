#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR=/tmp/tva-logs
mkdir -p "$LOG_DIR"
touch "$LOG_DIR/backend.log" "$LOG_DIR/frontend.log"

log() {
  printf '[tva] %s\n' "$*"
}

port_listening() {
  python - "$1" <<'PY'
import socket
import sys

with socket.socket() as sock:
    sock.settimeout(0.3)
    sys.exit(0 if sock.connect_ex(("127.0.0.1", int(sys.argv[1]))) == 0 else 1)
PY
}

start_background() {
  local name="$1"
  local port="$2"
  shift 2
  local pid_file="$LOG_DIR/${name}.pid"

  if port_listening "$port"; then
    log "El servidor $name ya escucha en el puerto $port."
    return
  fi

  nohup setsid bash -c "$*" >> "$LOG_DIR/${name}.log" 2>&1 < /dev/null &
  echo "$!" > "$pid_file"
  log "Servidor $name iniciado en segundo plano (puerto $port)."
}

start_background backend 8888 \
  "cd '$ROOT/tva-backend/sources' && exec env ENVIRONMENT=local poetry run python manage.py runserver 0:8888"

if [[ -x "$ROOT/tva-frontend/node_modules/.bin/nx" ]]; then
  start_background frontend 4200 \
    "cd '$ROOT/tva-frontend' && exec pnpm exec nx serve tva --port 4200"
else
  log "Frontend omitido: no existe node_modules/.bin/nx (revisa la configuración del PAT)."
fi

token="$(cd "$ROOT/tva-backend/sources" && poetry run python manage.py crear_token_local \
  --usuario operador1 --roles TVA_USUARIO,TVA_ADMIN_PORTAL --horas 24)"
printf '%s\n' "$token" > "$ROOT/.devcontainer/.tva-token"
chmod 600 "$ROOT/.devcontainer/.tva-token"

log "TVA disponible en http://localhost:4200 (frontend) y http://localhost:8888 (API)."
log "Token de acceso guardado en .devcontainer/.tva-token; pégalo en /login y elige dev en el selector."
log "Registros: /tmp/tva-logs/backend.log y /tmp/tva-logs/frontend.log."
