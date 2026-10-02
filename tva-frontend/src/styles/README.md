# Estilos globales TVA

No hay SCSS por componente: todos los estilos viven en estos parciales
globales, cargados desde `src/styles.scss` en este orden:

1. `_tokens` — variables CSS MAPFRE, breakpoints (`$bp-md`, `$bp-sm`) y mixins `md`/`sm`.
2. `_layout` — reset, tipografía, tarjetas, estructura `.pagina` (shell flex-column).
3. `_forms` / `_tables` — formularios y tablas (incl. `.tabla-scroll` responsive).
4. `_shell` — cabecera, migas de pan y botonera sticky.
5. `_ui` — componentes compartidos de `shared/ui`.
6. `_pages` / `_sesion` — páginas y pantallas de la sesión.
7. `_utilities` — utilidades (`.chip-estado`, etc.).

Regla: cada bloque se espacia por el selector host del componente
(`app-x .clase`), nunca `:host` ni `::ng-deep`.
