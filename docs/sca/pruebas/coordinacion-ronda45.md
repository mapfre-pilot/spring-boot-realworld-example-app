# Coordinación ronda 45 — 9.º «Análisis SCA2» (06/11) y pólizas Vida

Origen: documento de los analistas `../anexos/r45-Analisis_SCA2.docx` (texto: `../anexos/r45-Analisis_SCA2.txt`). Capturas en orden del documento: `../img/r45-analista-01.png` … `r45-analista-12.png`. Cuatro sesiones hijas en paralelo: R45-A, R45-B, R45-C, R45-D.

## Herramientas (MCP y LCP caídos desde el 05/11)
- El plugin DevMCP de TEST tiene el feature toggle `ae.dev-copilot-api.lcp-api-plugin = false` (`GET /suite/plugins/servlet/stateless/lcp-debug/`): `lcp-api/*` da 404 y el MCP rechaza todas las herramientas. Comprobar UNA vez al empezar (`getDevMcpVersionInfo` o `curl -u devin:… …/lcp-api/meta`); si responde, usar MCP/LCP como antes.
- Si no, **Deployment API v2** con la cabecera `appian-api-key: $APPIAN_TEST_DEPLOY_API_KEY` (secreto de org) sobre `https://mapfrespain-test.appiancloud.com/suite/deployment-management/v2`:
  1. Exportar la app SCA2 justo antes de editar: `POST /deployments` con `Action-Type: export` y `-F 'json={"exportType":"application","uuids":["_a-0000f069-4f37-8000-9cc8-011c48011c48_20050128"],"name":"SCA2 export R45-X"};type=application/json'` → sondear `GET /deployments/{uuid}/` hasta `COMPLETED` → descargar `packageZip`. Los objetos están en `content/<uuid>.xml` (nombre en `<name>`; PMs en `processModel/`).
  2. Editar SOLO el XML del objeto reservado (backup del original en `docs/sca/pruebas/backups-r45/`).
  3. Montar un ZIP parcial con `META-INF/MANIFEST.MF` + solo los XML cambiados (nunca `application/` ni objetos de otra sesión).
  4. `POST /inspections` (`Action-Type: inspect`, `json={"packageFileName":"x.zip"}`, `-F zipFile=@x.zip`) → 0 errores; después `POST /deployments` con `Action-Type: import` (`json={"name":"R45-X …","packageFileName":"x.zip"}`, `-F packageZip=@x.zip`) → revisar el log.
  5. Reexportar y comparar para confirmar la versión nueva. Probado el 06/11: export de SCA2 (673 ficheros) e inspección de un ZIP parcial de 1 objeto, ambos OK.
- Para PMs complejos o probar reglas: Appian Designer en el navegador (Playwright por CDP, ver memoria «lcp-devmcp»). Pruebas funcionales por la UI del site `sca2` (SCA real: `/suite/sites/sca-site`).

## Puntos del analista (literal resumido, con captura)
A1. (10) Vida: si la consulta de Vida no da la parte izquierda de la clave de producción (clave vida / clave tron) → «Póliza sin estructura comercial. No es posible realizar la solicitud.» y no se continúa, como SCA. Si solo falta la parte derecha, se puede continuar.
A2. (11-12) «DEVIN, igualito que SCA normal, está colocando mal la clave de producción de vida y de tron». Parte izquierda = `producerCode` + `salesOfficeCode` de `producersData` de la consulta de póliza (si `producerCode` = "1", usar el siguiente; si no hay otro → sin estructura comercial). Parte derecha = `codAgente` del servicio estructurasComerciales (`ES_AUAD_ESTRUAGE_SERVICIOS_REST_be-web/api/1.0/estructurasComerciales?codCompania=3&fecValidez=…&codAgenteVida=<producerCode>&codOficinaDirecta=<salesOfficeCode>`). Ejemplo 0006000731: producerCode 18472, salesOfficeCode 0372, codAgente 0035099; el analista escribe «esperado 18420372 / 0035099» (ver duda D1). Además el alta de esa póliza no guarda: `ALTA_ERROR – Datos insuficientes (paso: generarStudAnul)`.
A3. (09) Tras el alta, en «Su solicitud se ha generado correctamente. Acepte para abrir la gestión correspondiente», bloquear ACEPTAR una vez pulsado.
B1. (01-02) Acc. Adm. con el check «El cliente no entrega documentación» o sin informar los documentos necesarios → se anula al vencimiento (póliza 2729220153).
B2. (03-04) Nivel de cumplimiento 00000004 / 00000005 → flujo de pendiente de autorizar. Revisar la llamada a ANL y sus datos: `fechaSuplemento` se envía con la fecha de hoy; debe ser la fecha de anulación de SCA con la que se lanzó la simulación de la mecanización. (En la captura, NSE responde 4004 M519101 «Norma 58: debe ser revisada por la subcentral».)
B3. Respuestas: no está claro que haga falta esperar a NSE hasta 10 min (ANL resuelve la anulación como respuesta y luego lanza la finalización); 15788754: el analista no ve el proceso ANL ni trazas; buscar pólizas con controles técnicos 05/06 y probar a mano «pendiente de autorizar»; detallar en qué consiste la corrección de «Tipo catalogación» del alta wAutemis para que el analista decida (no implementar).
B4. (tabla, fila Cancelada) Si el usuario dice NO en la pantalla de Anulación/Suscripción → «Cancelada» (solicitud 14, mecanización 4), no mecanización incompleta.
C1. (05) Regresión Autemis acuerdo paso a Si24: al ir a anular tras la contra anulación sale el aviso de póliza de Si24; quitarlo si la solicitud ya se está tratando por Si24 en ese punto.
C2. (06) Después se va a Verti/Vencimiento pero no enlaza directamente con el componente de inducción.
C3. (07) Autemis acuerdo Si24 nivel 1: aparece el aviso de Si24 a un usuario de Si24 (SISANS). Póliza 0002729280594.
C4. (08) Contra anulación con usuario distinto de Red Mapfre (Si24, central, CCC): se puede finalizar sin documentos ni carta; FINALIZAR se activa en cuanto haya algún argumento de retención ejecutado como negativo.
D1. (tabla) Etiquetas y colores de la lista de solicitudes según `cod_tip_est_solic` / `cod_tip_est_mecaniza` (y gestión máx.): ver la tabla del anexo. En concreto, mecanización incompleta con solicitud 4/5 y mecanización 7 → «Mecanización enviada» (naranja), atendiendo a lo que devolvió la simulación.

## Reparto y objetos propios (reservar en la tabla antes de editar; liberar con vN→vM)
- **R45-A Vida y alta**: A1, A2, A3. `SCA2_getCodAgenteVida`, `SCA2_consultaClaveVida`, `SCA2_consultarClavevida`, `SCA2_consultaClave*`, `SCA2_obtenerEstructuraComercial`, `SCA2_consultarEstructuraComercial`, `SCA2_obtenerDatosCabeceraLive` (solo la parte Vida), `SCA2_construirContextoAlta`, `SCA2_PreGenerarStudAnul`, `SCA2_AltaSolicitudPage`, integraciones/constantes SCA2 nuevas de estructuras comerciales.
- **R45-B ANL / mecanización**: B1-B4. `SCA2_AccionesAdministrativas*`, `SCA2_MecanizacionPrincipal`, PMs `SCA2 CMD Mecanizar`, `…MecanizarNSE`, `…CompletarAccion`, `…Decidir`, `…CrearAccion`, `…Finalizar`, reglas de llamada a ANL (`SCA2_obtenerAnulacion`, constructores de la petición ANL).
- **R45-C Si24**: C1-C4. Interfaces y reglas de contra anulación (`SCA2_ContraAnulacion*`, condición de FINALIZAR), aviso Si24 de la cabecera/detalle, condición y enlace de Verti/Vencimiento → inducción (si hay que tocar un PM de R45-B, pedirlo en la tabla y esperar a que esté libre).
- **R45-D Lista de solicitudes**: D1. Reglas de etiqueta/color de estado (`SCA2_textoEstadoSolicitud` y las del buscador/lista y tarjetas del detalle), constantes nuevas.
Si un objeto no está en tu lista y otra sesión lo tiene reservado: no tocarlo.

## Pólizas
- Del analista, solo consulta (no crear solicitudes): 2729220153, 0002729280594, 0006000731, 0002729325304, 0007889200464.
- Altas nuevas: R45-A `polizas/bloque-R45-A-vida.txt` (636 Vida); R45-B `bloque-R45-B.txt`; R45-C `bloque-R45-C.txt`; R45-D `bloque-R45-D.txt`. Anotar cada póliza usada en `polizas/REGISTRO.md`. No usar 0732400126663.

## Reglas
- Solo objetos SCA2. Prohibido modificar SCA/SCAC/CORE/GAIA/PRE/CMP/NSE/ANL/SGD/Documentum. Nunca PRO. No tocar solicitudes antiguas; probar siempre con solicitudes e instancias nuevas.
- Paridad con SCA salvo donde el analista pide otra cosa (A2: SCA también lo hace mal → marcar «no comparable»).
- Lectura viva (export) → backup → cambio mínimo → reexport y comparación. Literales en constantes `SCA2_*`. Conservar el encadenado/síncrono de R42 y lo de R44.
- No dejar rastro de «Devin» en datos ni textos visibles.

## Objetos en edición
| Objeto | Sesión | Estado |
|---|---|---|

## Dudas abiertas para el usuario/analista
- D1: ¿la parte izquierda es `producerCode`‖`salesOfficeCode` = 184720372, o 18420372 como escribe el analista?
- D2: «Revisar los estados que ha pasado Pedro en el otro correo»: no tenemos ese correo.
