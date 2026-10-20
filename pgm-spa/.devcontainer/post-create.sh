#!/usr/bin/env bash
# Dependencias npm de la SPA (opcionalmente NPM_CONFIG_REGISTRY = Azure Artifacts).
set -euo pipefail
cd "$(dirname "$0")/.."
if [ -n "${NPM_CONFIG_REGISTRY:-}" ]; then npm config set registry "${NPM_CONFIG_REGISTRY}"; fi
sudo chown "$(id -u):$(id -g)" node_modules 2>/dev/null || true
lock_sha="$(sha256sum package-lock.json | cut -d' ' -f1)"
if [ -f node_modules/.pgm-lock.sha ] && [ "$(cat node_modules/.pgm-lock.sha)" = "$lock_sha" ]; then
  echo "Dependencias SPA sin cambios; se omite npm ci."
else
  npm ci --no-audit --no-fund
  printf '%s\n' "$lock_sha" > node_modules/.pgm-lock.sha
fi
echo "SPA lista: bash .devcontainer/run.sh  (proxy /api → ${PGM_BFF_URL:-http://localhost:8080})"
