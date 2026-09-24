# Migración Tarificador Vida Ahorro (TVA)

Rama `feature/tva`: contiene exclusivamente el trabajo de análisis y migración de la
aplicación Appian **Tarificador Vida Ahorro** a un SPA Angular + backend basado en los
arquetipos corporativos.

Estructura:

- `docs/tva/` — análisis funcional/técnico de la aplicación Appian y planes de migración
  (ver [índice](docs/tva/README.md)).
- `arquetipos/` — arquetipos corporativos de referencia (front Angular, back Django).
- `tva-frontend/` — SPA Angular 21 (Material, signals, zoneless) — ver `tva-frontend/README.md`.
- `tva-backend/` — backend Django 5.2/DRF — ver `tva-backend/README.md`.
- `docker-compose.yml` — pila completa (frontend :8080, backend :8888, Postgres, Redis).

Arranque rápido: `docker compose up --build -d` → http://localhost:8080.
Guía completa: [docs/tva/11-guia-despliegue.md](docs/tva/11-guia-despliegue.md).
