#!/usr/bin/env bash
# Dependencias Maven del BFF en el volumen ~/.m2 (opcionalmente vía MAVEN_MIRROR = Azure Artifacts / mirror corporativo).
set -euo pipefail
cd "$(dirname "$0")/.."
if [ -n "${MAVEN_MIRROR:-}" ]; then
  mkdir -p ~/.m2
  printf '<settings><mirrors><mirror><id>mapfre</id><mirrorOf>central</mirrorOf><url>%s</url></mirror></mirrors></settings>' "$MAVEN_MIRROR" > ~/.m2/settings.xml
fi
mvn -q -f sources/pom.xml -DskipTests dependency:go-offline || echo "(aviso) go-offline incompleto; mvn descargará lo que falte al compilar"
echo "BFF listo: bash .devcontainer/run.sh  (perfil SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE:-local})"
