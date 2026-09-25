#!/bin/sh
# Reduce assets/environments.json al entorno destino (TVA_ENV) siguiendo el
# patrón ngx-multienvironment: con una sola clave no se muestra el selector.
set -e
ENV="${TVA_ENV:-pro}"
FILE=/usr/share/nginx/html/assets/environments.json
if ! jq -e --arg e "$ENV" 'has($e)' "$FILE" > /dev/null; then
  echo "entrypoint: entorno '$ENV' no existe en environments.json" >&2
  exit 1
fi
TMP=$(mktemp)
jq --arg e "$ENV" '{($e): .[$e]}' "$FILE" > "$TMP"
mv "$TMP" "$FILE"
exec nginx -g 'daemon off;'
