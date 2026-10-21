# Reservas de datos de prueba — fase 1 (añadir una línea por sesión; `git pull --rebase` antes de `push`)

| Sesión | Fecha | Póliza | idSolicitud | Instancias/PM | Para qué |
|---|---|---|---|---|---|
| D | 2026-10-21 | 2002000024445 (NSE-Autos) | 15787499 | — (solo lectura, sin instancias) | Regresión antes/después de `SCA2_obtenerDatosCabecera` vía `/test` |
| D | 2026-10-21 | 0000006610576 (wAutemis) | 15787668 | — (solo lectura, sin instancias) | Regresión antes/después de `SCA2_obtenerDatosCabecera` vía `/test` |
| D | 2026-10-21 | 0732000028208 (NSE-Hogar) | 15788005 | — (solo lectura, sin instancias) | Regresión antes/después de `SCA2_obtenerDatosCabecera` vía `/test` |
| B | 2026-10-21 | 0001047017110 (wAutemis, clave 0280999) | 15788189 | SCA2 CMD Alta 12247493 | Propietario/carterización: gestor CE_RM (JJGONZ2) no propietario; regresión `nuumaEsPropietario`/Contra Anulación y sombra |
| B | 2026-10-21 | 0001047017112 (wAutemis, clave 0280999) | 15788190 | SCA2 CMD Alta 17484381 | Propietario/carterización: usuario SI24 (SISANS) no propietario; regresión y sombra |
| B | 2026-10-21 | — | — | Record `SCA2 Trazabilidad Cliente` filas 386-388 (operación `SOMBRA_PROPIETARIO_*`) | Filas de prueba de la regla de sombra; no borrar |
