# Reservas de datos de prueba — fase 1 (añadir una línea por sesión; `git pull --rebase` antes de `push`)

| Sesión | Fecha | Póliza | idSolicitud | Instancias/PM | Para qué |
|---|---|---|---|---|---|
| D | 2026-10-21 | 2002000024445 (NSE-Autos) | 15787499 | — (solo lectura, sin instancias) | Regresión antes/después de `SCA2_obtenerDatosCabecera` vía `/test` |
| D | 2026-10-21 | 0000006610576 (wAutemis) | 15787668 | — (solo lectura, sin instancias) | Regresión antes/después de `SCA2_obtenerDatosCabecera` vía `/test` |
| D | 2026-10-21 | 0732000028208 (NSE-Hogar) | 15788005 | — (solo lectura, sin instancias) | Regresión antes/después de `SCA2_obtenerDatosCabecera` vía `/test` |
| B | 2026-10-21 | 0001047017110 (wAutemis, clave 0280999) | 15788189 | SCA2 CMD Alta 12247493 | Propietario/carterización: gestor CE_RM (JJGONZ2) no propietario; regresión `nuumaEsPropietario`/Contra Anulación y sombra |
| B | 2026-10-21 | 0001047017112 (wAutemis, clave 0280999) | 15788190 | SCA2 CMD Alta 17484381 | Propietario/carterización: usuario SI24 (SISANS) no propietario; regresión y sombra |
| B | 2026-10-21 | 0001047017113 (wAutemis, clave 0280999) | 15788210 | SCA2 CMD Alta 12247942 | Propietario/carterización: corrección clave de producción en Contra Anulación (v57) y constante en true; prueba UI y sombra |
| B | 2026-10-21 | — | — | Record `SCA2 Trazabilidad Cliente` filas 386-388 (operación `SOMBRA_PROPIETARIO_*`) | Filas de prueba de la regla de sombra; no borrar |
| A | 2026-10-21 | 2002500495555 (Autos, FLOTA, vence 31/12/2026) | 15788192 (alta 10:52 UTC, PM Alta) | Alta → CA N1 (aviso «flota/sin tratamiento SCA» aceptado) | Caducidad por nivel: hoy+7 (no propietario) → 2026-10-28; fecInicioNivel 10:52:53 |
| A | 2026-10-21 | 2002600000012 (Autos, FLOTA, vence 02/01/2027) | 15788202 (alta 11:45 UTC) | Alta → CA N1 | Caché cabecera: alta con `SCA2_USAR_CACHE_CABECERA` = false tras el cambio del Alta → fila `SCA2 Datos Cabecera` id 229 con 9 campos (igual que antes) |
| A | 2026-10-21 | 2002500478924 (Autos, vence 03/11/2026, acuerdo especial SI24) | 15788194 (alta 11:11 UTC) | Alta → CA N1 | Caducidad por nivel: hoy+7 = 2026-10-28 < vencimiento → sin tope |
| A | 2026-10-21 | 2002500378119 (Autos, vencida 27/08/2026) | 15788196 (alta 11:24 UTC); Caducar instancia 13307120 | Alta → CA N1 → `SCA2 CMD Caducar` arrancado a mano (BarridoCaducidad no la selecciona) | Caducidad por nivel: tope → caducidadTarea 2026-08-27; Caducar → estado `CADUCADA` (Transicion 1494 OK); integración CORE IGenerarContraAnul HTTP 500 (0999) |
| A | 2026-10-21 | 2002600007357 (Autos, vence 2027) | 15788193 (alta 10:59 UTC) | Alta → CA N1 → posponer → CA negativa → Gestión Verti/vencimiento finalizada → Mecanización (NO ejecutada) | Caducidad por nivel: hoy+7 = 2026-10-28; posponer (fechaDietario 28/10, contador 1) y negativa NO cambian caducidadTarea; sigue N1 |
| A | 2026-10-21 | 2002600009065 (Autos, vence 20/01/2027) | 15788195 (alta 11:20 UTC) | Alta → CA N1 | Caducidad por nivel: hoy+7 = 2026-10-28 |
| A | 2026-10-21 | 2002300392341 (Autos NSE, vencida 17/08/2026) | 15788204 (alta 11:49 UTC) | Alta → CA N1 | Caché cabecera: alta con constante = true (v12, solo durante la prueba; vuelta a false v13) → fila `SCA2 Datos Cabecera` id 230 completa, `origenCache` CACHE, `validaHasta` 2026-10-22 07:00; caducidadTarea tope 2026-08-17 |
| A | 2026-10-21 | 2002600005548 (Autos) | NO creada: ya tenía solicitud abierta antigua (no tocada) | — | descartada |
| E | 2026-10-21 | 0002729392590 (wAutemis) | 15788188 | Alta 678429; Decidir 13306893; CrearAccion 17484380 (tarea CA abierta) | Prueba funcional F01 tras delegar `SCA2_mapearDatosDecidirAccion` v4 en `SCA2_construirEntradaReglas` |
| E | 2026-10-21 | 0000023400212 (NSE-Autos) | 15788191 | Alta 14351538; Decidir 269114374; CrearAccion 17484392 (tarea AA abierta) | Prueba funcional F02 (ídem) |
| E | 2026-10-21 | 2002000157937, 0001047017109, 0730780285731, 0005726682097 | 15788155, 15788168, 15788163, 15788149 | — (solo lectura, sin instancias) | Regresión antes/después de `SCA2_mapearDatosDecidirAccion` vía `/test` |
| C | 2026-10-21 | — | — | Records `SCA2 Cat *` (tablas `sca2_cat_*`): carga CORE 14/22/146/343/17/100 filas; fila manual de prueba `ZZC1` en `SCA2 Cat Concepto` (id 18) creada y **borrada** al cierre | Catálogos Aurora: carga, comparación record vs SOAP y pruebas de la página de mantenimiento; las filas CORE no se borran |
| C | 2026-10-21 | 2002100649057, 2002200566753, 2002200566791 | — | — (solo lectura, `POST /interfaces/SCA2_AltaSolicitudPage/test`) | Medición de tiempo de apertura de Alta con la constante false/true (devuelta a false) |
