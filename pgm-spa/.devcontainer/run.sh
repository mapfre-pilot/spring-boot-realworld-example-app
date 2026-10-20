#!/usr/bin/env bash
# Arranca la SPA en el dev container (dev-server Angular en 4200, proxy /api → PGM_BFF_URL).
set -euo pipefail
cd "$(dirname "$0")/.."
[ -d node_modules ] || npm ci --no-audit --no-fund
exec npx nx serve pgm-spa --host 0.0.0.0 --port 4200
