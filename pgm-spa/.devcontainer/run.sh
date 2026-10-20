#!/usr/bin/env bash
# Arranca la SPA en el dev container (dev-server Angular en 4200, proxy /api → PGM_BFF_URL).
set -euo pipefail
cd "$(dirname "$0")/.."
if [ ! -x node_modules/.bin/nx ]; then bash .devcontainer/post-create.sh; fi
exec npx nx serve pgm-spa --host 0.0.0.0 --port 4200
