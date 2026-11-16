# Coordinación ronda 49 (SCA2, Appian TEST)

Origen: informe del analista `docs/sca/anexos/r49/Informe_incidencias_SCA_polizas_y_mensajes.docx` (texto en `.txt` y capturas en `capturas/`).

Protocolo (igual que R48): `git pull` → reservar aquí (commit + push) → leer versión viva → backup en `backups-r49/` → cambio mínimo → justo antes de guardar, `git pull` y comprobar que la versión viva es la de tu copia → guardar → reexportar y comparar → liberar con versión antes→después.

| Sesión | Alcance |
|---|---|
| R49-A | INC-06: bloqueo tras ACEPTAR después del aviso de espera (2002600074290) |
| R49-B | INC-05: búsqueda e histórico incoherentes (2001900000562, 0002729391736) |
| R49-C | Validaciones del alta frente a SCA: INC-01, INC-02, INC-03, OBS-01, OBS-03 |
| R49-D | Gestión frente a SCA: INC-04, INC-07, OBS-02 |
| R49-E | Error `repeat` -1 en `SCA2_obtenerTipoPoliza` al buscar por póliza (2002600074085) |

## Objetos en edición

| Objeto | UUID | Sesión | Estado | Versión antes→después | Nota |
|---|---|---|---|---|---|
| IF `SCA2_Buscador` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055660` | R49-B | Liberado | v36→v37 | Normalizar nº de póliza (trim + ceros a la izquierda) como SCA |
| ER `SCA2_obtenerTipoPoliza` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052969` | R49-E | Liberado | v2→v3 | `repeat(tointeger(max(0, 13 - len(...))))`: no falla con 14+ caracteres; hasta 13 igual. No toca `SCA2_Buscador` |
| ER `SCA2_construirContextoAlta` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056014` | R49-D | Liberado | v18→v19 | INC-04: `codProducto` NSE (Verti/Hogar) como `SCA_AltaSolicitudAnulacionEstrategicas`; sin cambios de textos |
