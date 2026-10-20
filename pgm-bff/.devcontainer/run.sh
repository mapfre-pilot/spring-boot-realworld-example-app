#!/usr/bin/env bash
# Arranca el BFF en el dev container: perfil SPRING_PROFILES_ACTIVE (local | pruebas | simulador), puerto 8080.
set -euo pipefail
cd "$(dirname "$0")/.."
exec mvn -q -f sources/pom.xml -DskipTests spring-boot:run -Dspring-boot.run.profiles="${SPRING_PROFILES_ACTIVE:-local}"
