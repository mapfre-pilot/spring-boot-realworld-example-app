#!/usr/bin/env bash
# Arranca el BFF en el dev container: perfil SPRING_PROFILES_ACTIVE (local | pruebas | simulador), puerto 8080.
# Sin -q: se ve el progreso de Maven (compila y arranca en 1-3 min; termina con "Started PgmBffApplication").
set -euo pipefail
cd "$(dirname "$0")/.."
echo "BFF: compilando y arrancando (perfil ${SPRING_PROFILES_ACTIVE:-local}); espera a 'Started PgmBffApplication'..."
exec mvn -B -f sources/pom.xml -DskipTests spring-boot:run -Dspring-boot.run.profiles="${SPRING_PROFILES_ACTIVE:-local}"
