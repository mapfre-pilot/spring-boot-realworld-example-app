#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NPM_REGISTRY_PREFIX="//pkgs.dev.azure.com/devopsmapfre/devopsmapfre/_packaging/releases/npm/registry/:"
NPMRC="${HOME}/.npmrc"

log() {
  printf '[tva] %s\n' "$*"
}

SUDO=()
if sudo -n true 2>/dev/null; then
  SUDO=(sudo)
fi

log "Preparando los volúmenes del frontend."
"${SUDO[@]}" chown -R vscode:vscode \
  "$ROOT/tva-frontend/node_modules" \
  "$HOME/.local/share/pnpm"

log "Activando Corepack y pnpm 11.21.0."
if ! command -v pnpm >/dev/null 2>&1; then
  "${SUDO[@]}" env "PATH=$PATH" corepack enable
fi
COREPACK_ENABLE_DOWNLOAD_PROMPT=0 corepack prepare pnpm@11.21.0 --activate
pnpm config set store-dir "$HOME/.local/share/pnpm/store" --location=user
log "Configurado el almacén de pnpm en el volumen persistente."

if [[ -n "${AZURE_ARTIFACTS_NPM_PAT_B64:-}" ]]; then
  log "Configurando autenticación de Azure Artifacts en ~/.npmrc."
  npmrc_tmp="$(mktemp "${HOME}/.npmrc.XXXXXX")"
  if [[ -f "$NPMRC" ]]; then
    awk -v prefix="$NPM_REGISTRY_PREFIX" '
      index($0, prefix) == 1 &&
        ($0 ~ /:(username|_password|email|always-auth)=/) { next }
      { print }
    ' "$NPMRC" > "$npmrc_tmp"
  fi
  {
    printf '%susername=mapfre\n' "$NPM_REGISTRY_PREFIX"
    printf '%s_password=%s\n' "$NPM_REGISTRY_PREFIX" "$AZURE_ARTIFACTS_NPM_PAT_B64"
    printf '%semail=%s\n' "$NPM_REGISTRY_PREFIX" "${TVA_NPM_EMAIL:-}"
    printf '%salways-auth=true\n' "$NPM_REGISTRY_PREFIX"
  } >> "$npmrc_tmp"
  chmod 600 "$npmrc_tmp"
  mv "$npmrc_tmp" "$NPMRC"
else
  log "AVISO: falta el PAT de Azure Artifacts; se omitirá la instalación del frontend."
  cat <<'WARNING'
[tva] Antes de abrir VS Code, configura AZURE_ARTIFACTS_NPM_PAT_B64 en el equipo anfitrión.
[tva] Windows (PowerShell): setx AZURE_ARTIFACTS_NPM_PAT_B64 "<pat-base64>"
[tva] macOS/Linux: export AZURE_ARTIFACTS_NPM_PAT_B64="<pat-base64>" en el perfil del shell.
[tva] Para codificar un PAT: echo -n "<PAT>" | base64
[tva] PowerShell: [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("<PAT>"))
[tva] Después, reinicia VS Code y ejecuta "Dev Containers: Rebuild Container".
WARNING
fi

log "Instalando las dependencias del backend Django."
cd "$ROOT/tva-backend/sources"
poetry install
if [[ ! -f "$ROOT/tva-backend/.env" ]]; then
  cp "$ROOT/tva-backend/.env.sample" "$ROOT/tva-backend/.env"
  log "Creado tva-backend/.env desde .env.sample."
fi

log "Esperando a PostgreSQL."
for intento in $(seq 1 60); do
  if pg_isready -h postgres -p 5432 -U tva -d tva >/dev/null 2>&1; then
    break
  fi
  if [[ "$intento" -eq 60 ]]; then
    log "ERROR: PostgreSQL no está disponible después de 60 segundos."
    exit 1
  fi
  sleep 1
done

log "Aplicando migraciones y cargando parámetros iniciales."
poetry run python manage.py migrate
poetry run python manage.py cargar_parametros

if [[ -n "${AZURE_ARTIFACTS_NPM_PAT_B64:-}" ]]; then
  log "Instalando las dependencias del frontend Angular."
  cd "$ROOT/tva-frontend"
  pnpm install --frozen-lockfile
else
  log "Instalación del frontend omitida: configura el PAT y reconstruye el contenedor."
fi

log "Preparación completada."
