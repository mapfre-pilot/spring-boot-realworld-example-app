#!/usr/bin/env bash
# Arranque de PGM dentro del dev container (Podman): pgm/dev.sh up | bff | spa | test | build
# Perfil del BFF: PGM_PERFIL=local (datos sintéticos, por defecto) | pruebas (servicios reales según Configuración) | simulador
set -euo pipefail
cd "$(dirname "$0")/.."
PERFIL="${PGM_PERFIL:-local}"
export PGM_CONFIG_DIR="${PGM_CONFIG_DIR:-$PWD/pgm-config}"
mkdir -p "$PGM_CONFIG_DIR"
bff()  { echo "BFF perfil=$PERFIL  http://localhost:8080  (config en $PGM_CONFIG_DIR)"; mvn -q -f pgm-bff/sources/pom.xml -DskipTests spring-boot:run -Dspring-boot.run.profiles="$PERFIL"; }
spa()  { echo "SPA  http://localhost:4200  (proxy /api → BFF :8080)"; (cd pgm-spa && npx nx serve pgm-spa --host 0.0.0.0 --port 4200); }
case "${1:-up}" in
  bff) bff ;;
  spa) spa ;;
  up)
    trap 'kill 0' EXIT INT TERM
    bff & spa & wait ;;
  test)  mvn -q -f pgm-bff/sources/pom.xml verify && (cd pgm-spa && npx nx run-many --target=lint,test --projects=pgm-spa) ;;
  build) mvn -q -f pgm-bff/sources/pom.xml -DskipTests package && (cd pgm-spa && npx nx build pgm-spa --configuration=production) ;;
  *) echo "uso: pgm/dev.sh up|bff|spa|test|build"; exit 1 ;;
esac
