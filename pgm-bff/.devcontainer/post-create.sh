#!/usr/bin/env bash
# Dependencias Maven del BFF en el volumen ~/.m2 (opcionalmente vía MAVEN_MIRROR = Azure Artifacts / mirror corporativo).
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p ~/.m2
if [ -n "${MAVEN_MIRROR:-}" ]; then
  printf '<settings><mirrors><mirror><id>mapfre</id><mirrorOf>central</mirrorOf><url>%s</url></mirror></mirrors></settings>' "$MAVEN_MIRROR" > ~/.m2/settings.xml
fi
pom_sha="$(sha256sum sources/pom.xml | cut -d' ' -f1)"
if [ -f ~/.m2/.pgm-pom.sha ] && [ "$(cat ~/.m2/.pgm-pom.sha)" = "$pom_sha" ]; then
  echo "Dependencias Maven sin cambios; se omite dependency:go-offline."
elif mvn -q -f sources/pom.xml -DskipTests dependency:go-offline; then
  printf '%s\n' "$pom_sha" > ~/.m2/.pgm-pom.sha
else
  echo "(aviso) go-offline incompleto; mvn descargará lo que falte al compilar"
fi
echo "BFF listo: bash .devcontainer/run.sh  (perfil SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE:-local})"
