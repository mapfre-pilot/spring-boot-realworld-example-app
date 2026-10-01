# Dev Container TVA

## Requisitos

- VS Code y la extensión **Dev Containers** (`ms-vscode-remote.remote-containers`).
- Docker Desktop iniciado.
- PAT de Azure Artifacts en la variable `AZURE_ARTIFACTS_NPM_PAT_B64`, configurada
  antes de abrir VS Code. En Windows, usa
  `setx AZURE_ARTIFACTS_NPM_PAT_B64 "<pat-base64>"` y reinicia VS Code. En macOS/Linux,
  exporta la variable en el perfil del shell y abre VS Code desde ese entorno.
- Para obtener el valor base64: `echo -n "<PAT>" | base64` en macOS/Linux, o
  `[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("<PAT>"))` en PowerShell.
  Opcionalmente, define `TVA_NPM_EMAIL`.

## Uso

1. Clona la rama `feature/tva` y abre la carpeta del repositorio en VS Code.
2. Ejecuta **Dev Containers: Reopen in Container**.
3. Espera a que se instalen las dependencias y se inicien Django y Angular.
4. Abre [http://localhost:4200](http://localhost:4200); VS Code también abre el
   navegador al detectar el puerto.

En la primera carga, elige `dev` en el selector de entorno. Para entrar, copia el token
de `.devcontainer/.tva-token` y pégalo en `/login`.

## Login SSO con EntraID (opcional)

No requiere secretos adicionales (la SPA usa PKCE y el backend solo valida el JWKS
público del tenant). Edita `tva-backend/.env` dentro del contenedor y descomenta el
bloque "EntraID" (`OAUTH_JWKS_URI`, `OAUTH_ISSUER`, `OAUTH_AUDIENCE`,
`OAUTH_DEFAULT_ROLES`) manteniendo `ENVIRONMENT=local`; reinicia el backend con
`bash .devcontainer/tva.sh stop && bash .devcontainer/tva.sh start` y comprueba que
`http://localhost:8888/api/tva/v1/salud/` devuelve `"oidc": true`. En el navegador
elige `local-sso` en el selector de entorno (o
`localStorage.setItem('OKCD_APPLICATION_ENVIRONMENT','local-sso')` y recarga) y entra
con un usuario del tenant. El contenedor necesita salida a `login.microsoftonline.com`.
Detalle en [docs/tva/11-guia-despliegue.md](../docs/tva/11-guia-despliegue.md).

## Comandos auxiliares

Desde la raíz del repositorio, ejecuta `bash .devcontainer/tva.sh` con uno de estos
subcomandos:

- `start`: inicia los servidores que no estén escuchando.
- `stop`: detiene los servidores iniciados por el contenedor.
- `logs`: sigue los registros de ambos servidores.
- `token`: genera un token nuevo y lo muestra.
- `status`: comprueba la API y el puerto del frontend.

Los registros se guardan en `/tmp/tva-logs/backend.log` y
`/tmp/tva-logs/frontend.log`.

## Solución de problemas

- **Falta el PAT**: configura `AZURE_ARTIFACTS_NPM_PAT_B64`, reinicia VS Code y ejecuta
  **Dev Containers: Rebuild Container**. El backend se prepara aunque el PAT no esté
  disponible, pero el frontend no se instala.
- **Puerto ocupado**: libera los puertos 4200 y 8888 en el equipo anfitrión y reinicia
  el contenedor.
- **Proxy corporativo**: configura el proxy en los ajustes de Docker Desktop para que
  los contenedores puedan acceder a los registros de paquetes.
