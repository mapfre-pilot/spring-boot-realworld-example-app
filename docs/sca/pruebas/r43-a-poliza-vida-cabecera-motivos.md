# R43-A — Póliza Vida: cabecera y motivo/detalle/causa en SCA2

Sesión hija R43-A (Appian TEST, usuario de UI JJGONZ2). Contrato: `coordinacion-ronda43.md`. Pruebas UI del agente de pruebas: `r43-a-informe-testing-agent.md` (tablas campo a campo, catálogos vistos en pantalla y lista de capturas `img/r43-a-*.png`).

## 1. Resumen

| # | Punto del analista | Causa | Corrección | Resultado probado |
|---|---|---|---|---|
| 1 | Cabecera Vida 0005912432: «Tipo productor» «-» y «Clave producción» «/» | `SCA2_getCodAgenteVida` (copia de `SCA_getCodAgenteVida`) tenía la entrada `producersData` tipada con un **record type** en lugar del CDT `SCAC_DS_producersData`. Al convertir se perdía `producerCommissions` y el agente salía nulo. Sin agente, `SCA2_consultarClavevida` y `SCA2_consultarEstructuraComercial` no devolvían nada | Tipo de la entrada = `SCAC_DS_producersData` (múltiple), como en SCA. Expresión sin cambios | LCP: «AG» y «105333 / 5324209», igual que `SCA_obtenerDatosCabecera`. UI SCA2: ambos valores correctos en la 1.ª y la 2.ª apertura (caché) y en las 4 pestañas |
| 1b | «Temas funcionales y técnicos»: resto de la cabecera | Comparación campo a campo de `SCA_obtenerDatosCabecera` y `SCA2_obtenerDatosCabeceraLive` (tabla §3): tipo productor y clave eran las **únicas** diferencias | — | Las 4 pestañas iguales (LCP). Enlace GESVIDA igual en SCA y SCA2 (ver §6) |
| 2 | Alta Vida con motivo/detalle/causa de Autos | `SCA2_AltaSolicitudPage` sacaba la línea de negocio de `pObtenerPolizaFecha` (cía 41), que para Vida responde «CODIGO INEXISTENTE». Con el valor por defecto `1` llegaba Autos. SCA (`SCA_AltaSolicitudAnulacionEstrategicas`) usa `polizaVida → 3` | En Vida, `local!lineaNegocio` = `cons!SCA2_INT_LINEA_NEGOCIO_VIDA` (3) | LCP: catálogo de la línea 3 idéntico entre `SCA_consultar*` y `SCA2_consultar*` (§4). UI SCA2: motivo solo DECISION DE CLIENTE y detalles/causas de Vida |
| 3 | Alta Vida completa hasta la primera gestión (lo pide la ronda) | La página y el contexto del alta no tenían rama Vida (pendiente P1 de R9): faltaban clave de producción, compañía 3, ramo 101 y producto | Rama Vida en `SCA2_AltaSolicitudPage` y `SCA2_construirContextoAlta` (como `SCA_AltaSolicitudAnulacionEstrategicas`) | **No conseguido.** El formulario ya deja GUARDAR, pero CORE responde `4004 Datos insuficientes para la operacion` en `generarStudAnul` (3 pólizas Vida nuevas). Ver §5 |

## 2. Objetos (Appian TEST, solo SCA2)

| Objeto | UUID | Antes | Después | Cambio |
|---|---|---|---|---|
| `SCA2_getCodAgenteVida` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052771` | v1 | **v2** | Tipo de la entrada `producersData`: record type → `SCAC_DS_producersData` (múltiple). Expresión idéntica (comparada) |
| `SCA2_AltaSolicitudPage` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | v47 | v48, **v49** | v48: línea de negocio 3 en Vida. v49: rama Vida con `SCA2_consultarPolizaVidaRiesgo`, agente/oficina Vida, `claveProduccion` (estructura comercial; si no hay, `idClaveProduccion` de la clave Vida), `codCia` 3, `codRamo` 101 y `codProducto` = `commercialProductCode`. Sin cambios en la espera síncrona de R42-A (diff limitado a esas locales) |
| `SCA2_construirContextoAlta` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056014` | v13 | **v14** | Rama Vida: no llama a `pObtenerPolizaFecha`/`consultarPolizas`; clave, `codInt`/`numDocumento` (API Clients), ramo, producto, compañía y compañía de reemplazo 3, nombre de producto y fechas de efecto/vencimiento del contrato Vida. Probado por LCP con Vida 0005912430 y Hogar 0731480121955 (Hogar sin cambios en la salida) |
| `SCA2_PreGenerarStudAnul` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053005` | v2 | v3 → **v4 (= v2)** | v3: `codCiaUsuario` null en Vida, como `SCA_PreGenerarStudAnul`, para comprobar el 4004. No lo resolvió (0005912462) y se **revirtió**: v4 tiene la misma expresión y entradas que v2 (comparado) |
| `SCA2_INT_LINEA_NEGOCIO_VIDA` (constante, nueva) | `_a-0000f0a4-c27c-8000-9d46-011c48011c48_5665479` | — | v1 | Integer 3 |
| `SCA2_INT_COD_CIA_VIDA` (constante, nueva) | `_a-0000f0a4-c27c-8000-9d46-011c48011c48_5665489` | — | v1 | Integer 3 |
| `SCA2_TXT_COD_RAMO_VIDA` (constante, nueva) | `_a-0000f0a4-c27c-8000-9d46-011c48011c48_5665495` | — | v1 | Text «101» |

Copias JSON de antes y después (lectura viva por LCP) en la máquina de la sesión (`~/r43/backup/`). La caché de cabecera no se tocó: la corrección está en la regla de origen y una fila nueva ya sale bien. No se modificó ningún objeto SCA/SCAC/CORE/CMP/NSE/ANL/SGD ni se borró nada.

## 3. Cabecera Vida 0005912432: SCA y SCA2 (LCP, `SCA_obtenerDatosCabecera` / `SCA2_obtenerDatosCabeceraLive`)

«SCA2 antes» es la lectura previa al cambio y «SCA2 después», la posterior a `SCA2_getCodAgenteVida` v2. `otrasSolicitudesCabecera` sale distinta solo porque entre las dos lecturas apareció en CORE la solicitud 15788717 (ver §7). `fechaUltimoSiniestro` lleva en Vida el enlace GESVIDA, en SCA y en SCA2.

| Pestaña.campo | SCA | SCA2 antes | SCA2 después | ¿Igual? |
|---|---|---|---|---|
| datosCliente.nombre | `EXA` | `EXA` | `EXA` | sí |
| datosCliente.apellidos | `MIVEFET GETTAJREV` | `MIVEFET GETTAJREV` | `MIVEFET GETTAJREV` | sí |
| datosCliente.nif | `85655488S` | `85655488S` | `85655488S` | sí |
| datosCliente.apoderado | — | — | — | sí |
| datosCliente.carterizado | `Sí` | `Sí` | `Sí` | sí |
| datosCliente.nuumaPropietario | `null` | `null` | `null` | sí |
| datosCliente.rsvPrima | — | — | — | sí |
| datosCliente.dtoIntegralidadNuevaProduccion | — | — | — | sí |
| datosCliente.treboles | `0,00` | `0,00` | `0,00` | sí |
| datosCliente.activoClubMapfre | `Sí` | `Sí` | `Sí` | sí |
| datosCliente.perfilClubMapfre | `Platino` | `Platino` | `Platino` | sí |
| datosCliente.tipoClienteValor | `47` | `47` | `47` | sí |
| datosCliente.tipoClienteDesc | `Platino` | `Platino` | `Platino` | sí |
| datosCliente.idCliente | `6549876` | `6549876` | `6549876` | sí |
| datosPoliza.numeroPoliza | `0005912432` | `0005912432` | `0005912432` | sí |
| datosPoliza.nombreProducto | `00409 - CreciVida` | `00409 - CreciVida` | `00409 - CreciVida` | sí |
| datosPoliza.vehiculo | ` /  / 0 años` | ` /  / 0 años` | ` /  / 0 años` | sí |
| datosPoliza.lineaNegocio | `Vida` | `Vida` | `Vida` | sí |
| datosPoliza.formaPago | `Anual` | `Anual` | `Anual` | sí |
| datosPoliza.fechaEfecto | `27/05/2026` | `27/05/2026` | `27/05/2026` | sí |
| datosPoliza.fechaVencimiento | `27/05/2027` | `27/05/2027` | `27/05/2027` | sí |
| datosPoliza.antiguedad | `1 años` | `1 años` | `1 años` | sí |
| datosPoliza.planPago | — | — | — | sí |
| datosPoliza.primaActualRenovacion | `1308.2€` | `1308.2€` | `1308.2€` | sí |
| datosPoliza.acuerdo | ` - ` | ` - ` | ` - ` | sí |
| datosPoliza.claveProduccion | `105333 / 5324209` | ` / ` | `105333 / 5324209` | sí |
| datosPoliza.tipoProductor | `AG` | — | `AG` | sí |
| datosPoliza.siniestrosAnoActual | `0` | `0` | `0` | sí |
| datosPoliza.fechaUltimoSiniestro | `https://webvida.pre.mapfre.net/WSS000AEjec/accesodirecto/WSS…` | `https://webvida.pre.mapfre.net/WSS000AEjec/accesodirecto/WSS…` | `https://webvida.pre.mapfre.net/WSS000AEjec/accesodirecto/WSS…` | sí |
| datosPoliza.dtoIntegralidadPoliza | `0` | `0` | `0` | sí |
| datosPoliza.ramo | `101` | `101` | `101` | sí |
| datosPoliza.cesionDeDerechos | `NO` | `NO` | `NO` | sí |
| datosPoliza.revalorizacion | `Constante` | `Constante` | `Constante` | sí |
| datosPoliza.sobrePrimas_SobreRiesgos | — | — | — | sí |
| otrasSolicitudesCabecera | — | — | `[{'fecSolicitud': '03/11/2026 13:34:00', 'numPoliza': '00059…` | **no** |
| datosContacto.via | `Calle` | `Calle` | `Calle` | sí |
| datosContacto.domicilio | `ALCALA` | `ALCALA` | `ALCALA` | sí |
| datosContacto.numero | `220` | `220` | `220` | sí |
| datosContacto.provincia | `Madrid` | `Madrid` | `Madrid` | sí |
| datosContacto.localidad | `MADRID` | `MADRID` | `MADRID` | sí |
| datosContacto.codPostal | `28011` | `28011` | `28011` | sí |
| datosContacto.telMovil | `636894702` | `636894702` | `636894702` | sí |
| datosContacto.telFijo | — | — | — | sí |
| datosContacto.correo | `aamunoz@minsait.com` | `aamunoz@minsait.com` | `aamunoz@minsait.com` | sí |
| datosContacto.piso | — | — | — | sí |
| datosContacto.puerta | `A` | `A` | `A` | sí |
| datosContacto.escalera | — | — | — | sí |
| datosContacto.pais | `ESPAÑA` | `ESPAÑA` | `ESPAÑA` | sí |

En la UI de SCA2 se comprobaron las 4 pestañas en la 1.ª y la 2.ª apertura: AG y «105333 / 5324209» en ambas (capturas `r43-a-sca2-vida-*-primera.png` / `-segunda.png`). En la UI de SCA (`/suite/sites/sca-site`) **no se pudo comparar**: SCA rechaza 0005912432 en la búsqueda y en el alta con «La póliza no es una póliza válida o no se encuentra disponible, por lo tanto, no se puede gestionar la anulación por SCA.» (`r43-a-sca-buscador-vida-rechazo.png`, `r43-a-sca-alta-vida-rechazo.png`). La comparación con SCA es, por tanto, la de las reglas (LCP).

Otras Vida: 0005912430 y 0005912434 dan productor vacío y clave «25064 / » **igual en SCA y en SCA2**. Su agente no tiene estructura comercial en TEST, así que es un dato de la póliza y no una diferencia. 0005912443, 0005912462 y 0005912469 dan AG y la clave completa.

## 4. Motivo, detalle y causa de Vida (línea 3)

Lectura LCP con el perfil de JJGONZ2 (CE_RM / CE_RM_OFICINA). `SCA_consultarMotivo/Detalle/Causa` y `SCA2_consultarMotivo/Detalle/Causa` devuelven **lo mismo** en las líneas 1, 2 y 3:

| Línea | Motivos | Detalles | Causas | SCA = SCA2 |
|---|---|---|---|---|
| 1 Autos | 3 (DECISION DE CLIENTE, DECISION DE LA ENTIDAD, DESAPARICION DEL RIESGO) | 9 | 23 | sí |
| 2 Hogar | 2 (DECISION DE CLIENTE, DECISION DE LA ENTIDAD) | 8 | 20 | sí |
| 3 Vida | 1 (DECISION DE CLIENTE) | 5 | 12 | sí |

Vida, motivo 1 → detalles 9 ASEGURADO NO DESEA SEGURO (30 COMPROMISOS), 4 MALA GESTION (12, 10, 11), 1 PRECIO (1 ME HA SUBIDO MUCHO LA PRIMA, 3, 2), 2 PRODUCTO (6, 34, 4, 33) y 10 VENTA/DESAPARICION DEL RIESGO (35 PRESTAMO DESAPARECIDO).

En la UI de SCA2 se ven **4 detalles y 9 causas**: falta MALA GESTION. No es una diferencia con SCA. Las dos páginas de alta de SCA (`SCA_AltaSolicitudAnulacion` y `SCA_AltaSolicitudAnulacionEstrategicas`) quitan el **2.º detalle** del desplegable cuando el motivo es 1 (`remove(detalleDD, 2)`), y SCA2 lo copia. En Autos y Hogar el 2.º es IMPAGO DEL SEGURO; en Vida es MALA GESTION. Se deja igual que SCA y queda como duda (§8).

## 5. Alta Vida completa: no conseguida

| Póliza | Cabecera | Alta | Resultado |
|---|---|---|---|
| 0005912430 | Confianza VIDA, «25064 / » | no se usa | Tiene la solicitud previa 15783812 en «Otras sol. Anulación» |
| 0005912434 | Confianza VIDA, «25064 / » | DECISION DE CLIENTE / ASEGURADO NO DESEA SEGURO / COMPROMISOS, A VENCIMIENTO | ALTA_ERROR «Datos insuficientes para la operacion» (paso generarStudAnul), PDTE-9158129 |
| 0005912443 | CreciVida, AG «10045 / 5266862» | DECISION DE CLIENTE / PRECIO / ME HA SUBIDO MUCHO LA PRIMA, A VENCIMIENTO | Mismo error, PDTE-735385 |
| 0005912462 | CreciVida, AG «86629 / 5252013» | igual, con PreGenerar v3 (`codCiaUsuario` null) | Mismo error, PDTE-735412 |

Con los cambios, el formulario Vida ya calcula la catalogación y la fecha y deja GUARDAR. La simulación y el popup pasan. Falla el servicio CORE `IGenerarContraAnul`: SOAP Fault `code 4004 «Datos insuficientes para la operacion»` (registrado en `SCA2 Error` con la petición completa).

Lo que se descartó:
- **Clave de producción**: 0005912434 enviaba la clave alternativa 0990881. Las Vida de 0005912443 y 0005912462 enviaron la de la estructura comercial (5266862 y 5252013, 7 dígitos, como las Vida que SCA dio de alta en TEST: 15787947, 15787948…). Mismo error.
- **Datos de usuario**: aplicada a los datos de 0005912443, la salida de `SCA_PreGenerarStudAnul` y la de `SCA2_PreGenerarStudAnul` solo se diferencian en `codCiaUsuario` (SCA null, SCA2 41). Con null (v3), mismo error.
- Lo que va a CORE coincide con lo que calcula SCA para Vida: compañía 3, ramo 101, producto, clave, `codInt`, sin `numApli` ni estructura DGT/subcentral/oficina (SCA las saca de `pObtenerPolizaFecha`, que no existe para Vida) y `prima` nula.

Hoy no hay referencia viva en SCA: SCA rechaza las Vida en la validación previa. **Queda pendiente** saber qué dato pide CORE para Vida (§8). Cada alta fallida dejó en `SCA2 Solicitud` su fila PDTE (estado ALTA, bandeja de errores), como cualquier otro error de alta. No se relanzaron.

## 6. Regresión y otros

| Caso | Resultado UI |
|---|---|
| Hogar 0731480121955 (nueva) | Cabecera INTERNET-TELEFO / Expertos / Telemática, clave 0507804; 2 motivos de Hogar. Alta **15788719** → primera gestión Contra anulación (pendiente, nivel 1). 2.ª apertura correcta |
| Autos 2002300311820 (nueva) | Cabecera RED AGEN / Expertos / No Telemática, clave 5273190; 3 motivos de Autos. Alta **15788720**: mensaje de éxito a unos 25 s; la Contra anulación tardó unos 100 s en abrirse sin reenviar nada. 2.ª apertura correcta |
| GESVIDA (0005912432) | El enlace se genera (`webvida.pre.mapfre.net/…/VJ0180009_Recibos…`), con la misma URL en SCA y en SCA2 (LCP). Desde la máquina de pruebas da `DNS_PROBE_FINISHED_NXDOMAIN` (dominio interno de MAPFRE): su apertura no queda validada |

## 7. No probado

- Primera gestión de una Vida y 2.ª apertura de la cabecera de una solicitud Vida creada: ninguna alta Vida llegó a crearse (§5).
- Comparación en la UI de SCA de la cabecera y los desplegables de Vida, porque SCA rechaza la póliza. Solo se comparó por LCP.
- Apertura real de GESVIDA (dominio interno, sin resolución DNS desde la máquina de pruebas).
- Las regresiones Autos/Hogar se hicieron antes de PreGenerar v3. v4 vuelve a ser igual que v2, así que no se repitieron.
- Ver en el buscador las filas PDTE de las Vida fallidas (no se consultó en la UI; están en `SCA2 Solicitud`).
- Observación: en CORE aparece para 0005912432 la solicitud **15788717** (03/11/2026 13:34, causa COMPROMISOS, resuelta 13:36:48, estado 4). No está en las tablas de SCA ni de SCA2, y R43-A no la creó: entre las dos lecturas solo se hicieron consultas LCP, sin UI. Indica que en TEST hay otro canal (¿GESVIDA/consulta de Vida?) que sí da de alta Vida en CORE.

## 8. Dudas para el analista

1. **Alta Vida en CORE**: con los datos que calcula SCA para Vida, CORE responde 4004 «Datos insuficientes». ¿Qué dato exige CORE para dar de alta una anulación de Vida (cía 3, ramo 101)? ¿`numApli`, prima, estructura comercial (DGT/subcentral/oficina directa), otro? ¿Se puede conseguir una petición correcta de un alta Vida (por ejemplo, la de la solicitud 15788717 de hoy sobre 0005912432)?
2. **Desplegable de detalle en Vida**: SCA y SCA2 quitan el 2.º detalle cuando el motivo es DECISION DE CLIENTE. En Autos/Hogar es IMPAGO DEL SEGURO; en Vida es **MALA GESTION** (causas 12, 10 y 11). ¿Debe verse MALA GESTION en Vida (y quitar IMPAGO por código y no por posición) o se mantiene como en SCA?
3. **Pólizas Vida sin estructura comercial** (0005912430, 0005912434): productor vacío y clave «25064 / », igual en SCA. ¿Es lo esperado o hay otra fuente para el tipo de productor de Vida?
4. **SCA TEST rechaza las Vida** («La póliza no es una póliza válida…»). ¿Por dónde hace el analista la «consulta de vida» para comparar?
