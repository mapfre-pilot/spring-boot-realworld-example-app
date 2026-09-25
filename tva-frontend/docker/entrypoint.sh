#!/bin/sh
# Genera assets/env.js con el entorno activo (TVA_ENV) para initMultiEnvironmentApp.
set -e
printf 'window.okcdApplicationEnvironment = { env: "%s" };\n' "${TVA_ENV:-pro}" \
  > /usr/share/nginx/html/assets/env.js
exec nginx -g 'daemon off;'
