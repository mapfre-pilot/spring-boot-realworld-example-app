#!/usr/bin/env bash
# Dependencias npm de la SPA (opcionalmente NPM_CONFIG_REGISTRY = Azure Artifacts).
set -euo pipefail
cd "$(dirname "$0")/.."
if [ -n "${NPM_CONFIG_REGISTRY:-}" ]; then npm config set registry "${NPM_CONFIG_REGISTRY}"; fi
npm ci --no-audit --no-fund
echo "SPA lista: bash .devcontainer/run.sh  (proxy /api → ${PGM_BFF_URL:-http://localhost:8080})"
