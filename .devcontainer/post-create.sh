#!/usr/bin/env bash
# Se ejecuta una vez al crear el dev container: dependencias de BFF y SPA en los volúmenes de caché.
set -euo pipefail
cd "$(dirname "$0")/.."
if [ -n "${MAVEN_MIRROR:-}" ]; then
  mkdir -p ~/.m2
  cat > ~/.m2/settings.xml <<XML
<settings><mirrors><mirror><id>mapfre</id><mirrorOf>central</mirrorOf><url>${MAVEN_MIRROR}</url></mirror></mirrors></settings>
XML
fi
if [ -n "${NPM_CONFIG_REGISTRY:-}" ]; then npm config set registry "${NPM_CONFIG_REGISTRY}"; fi
echo "== BFF: dependencias Maven"
mvn -q -f pgm-bff/sources/pom.xml -DskipTests dependency:go-offline || echo "(aviso) go-offline incompleto; mvn descargará lo que falte al compilar"
echo "== SPA: npm ci"
npm ci --prefix pgm-spa --no-audit --no-fund
echo "== Listo. Arranca con: pgm/dev.sh up   (o bff / spa por separado)"
