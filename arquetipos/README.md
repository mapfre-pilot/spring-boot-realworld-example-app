# Arquetipos corporativos de referencia

Copia de los dos arquetipos facilitados por el equipo (documentos Appian TEST
`…_5463656` "SCA2 spa" y `…_5463643` "SCA2 tvaBackend") que sirven de base para la
construcción del SPA y del backend de TVA. Se incluyen tal cual, salvo:

- `frontend-angular/`: se omite la caché `.nx/workspace-data` (artefacto local sin valor).
- `backend-django/security-metadata.toml`: el correo del responsable se sustituye por un
  placeholder al ser este repositorio público.

| Carpeta | Origen | Contenido |
|---|---|---|
| `frontend-angular/` | SCA2 spa (50 KB) | Workspace Nx 23 + Angular 21.2, pnpm 11.10, `@mapfre-tech/nx-angular`, Jest/Spectator, ESLint, workflows reusables front |
| `backend-django/` | SCA2 tvaBackend (33 KB) | Arquetipo Contenedores Django 5.2 (`archetypeVersion` 1.12.1), Poetry, DRF + simplejwt + drf-spectacular, extensiones `arch-ram-lib-django-*`, Docker, workflows reusables |

El análisis detallado y su aplicación a TVA está en
[`docs/tva/10-plan-migracion-arquetipos.md`](../docs/tva/10-plan-migracion-arquetipos.md).
