# Ronda 22 — Tercer «Análisis SCA2» del analista (20/10/2026)

Fuente: `Analisis SCA2.docx` (texto en `sca2work/r22/analisis.txt`, capturas `r22/media/`). Cinco puntos; los cuatro primeros son resultados de
sus pruebas sobre lo aplicado en la ronda 20; el quinto es una corrección funcional del propio analista.

## 1. Acciones Administrativas sin botón RETOMAR (póliza 0002729296240 → solicitud 15788109)

**Causa (verificada):** la tarea AA 292 estaba asignada a otro usuario (JOSPENA). En `SCA2_DetalleSolicitud` la fila de botones sólo se mostraba si
`SCA2_puedeGestionarTarea` devolvía true (admin | asignado = usuario | sin asignar y grupo/nivel) y además RETOMAR exigía `asignadoA = loggedInUser()`.
En SCA (`SCA_DetalleAccionesAdministrativas`) RETOMAR y REASIGNAR se ven para cualquiera mientras la gestión siga abierta.

**Corrección:** `SCA2_DetalleSolicitud` v55 → v57: el permiso se evalúa como si la tarea no estuviera asignada (grupo/nivel) y RETOMAR + REASIGNAR se
muestran juntos con la gestión abierta (como SCA).

## 2. Bloqueo NEW no visible al pulsar ANULAR PÓLIZA (póliza 0005726682910 → solicitud 15788111)

**Lo que sí ocurrió:** el flujo pendiente de autorizar funcionó entero: ANL 2141 creada a las 10:39 con `OBSERVACIONES=00000005`, autorizada desde la
página de mantenimiento («Autorizada desde SCA2 mantenimiento», 11:04), mecanización actualizada → nivel 2 → finalizada.

**Causa del bloqueo ausente (verificada llamando a la integración con los datos de 15788111):** NEW devolvía HTTP 500, código 4004
`(BLOQUEAR) 01- Parámetro de entrada vacío o inválido - MOTIVO - DETALLE - CAUSA`: el nodo «Bloquear póliza en Central (NEW)» enviaba los códigos CORE
sin traducir ni rellenar (Motivo 1, Detalle 5, Causa 14). NEW/ANL usan los códigos traducidos de 8 dígitos (00000001 / 00000004 / 00000012).

**Corrección:** `SCA2 CMD Mecanizar` nodo 340: el cuerpo se construye desde `SCA2_construirSolicitudAnulacionAnlTraducida` (códigos traducidos,
perfil/nuuma, fecha). Repetida la llamada con los datos corregidos ya no hay error de parámetros; NEW PRE devuelve «Invalid SOAP fault content /
UNKNOWN_ERROR» para esa póliza, que ya estaba anulada a las 11:04. **Falta** verlo con un caso nuevo de Autemis pendiente de autorizar.

## 3. Salto a nivel 2: CORE «Datos insuficientes para la operación» (póliza 0002729373066 → solicitud 15788118)

**Causa (verificada):** no era el nuuma vacío (ese cambio ya no estaba en TEST). `SCA2 CMD Decidir` sobrescribe `Datos Perfiles Pca` con el grupo
destino que devuelve el motor (`CE_MF_BK / CE_MF_BK_EXPERTOSI24`) y `SCA2_altaGestionCore` enviaba a CORE ese perfil con el nuuma del finalizador
(JJGONZ2) → CORE lo rechaza. SCA (`SCA_ContraAnulacion`) envía el perfil del usuario que gestiona, con el remap `CE_MF_SI24_EXPERTO → CE_MF_SI24`.

**Corrección:** `SCA2_altaGestionCore` v5 → v6: en nivel > 1 el `infoUsuario` lleva perfil/subperfil del usuario (Datos Solicitud
`canaldeejecucion` / `perfilredmapfre`) + remap SI24 de SCA; nuuma = perfiles.nuuma ?? estado.usuario. El «-» hasta retomar lo da el Detalle
(`SCA2 Tarea.fechaCaptura`, ronda 20).

## 4. SI24 + acuerdos: `anulaTecnico` / `anulaExperto` false en el JSON de mecanizar (solicitud 15788120, póliza 0005888549030)

**Causa (verificada):** `SCA2_ContraAnulacionOpciones` sí calculaba true (SISANS es SI24, codClaseAgt = 33) y lo pasaba al modal, pero
`SCA2_ContraAnulacionModalSiNo` (cadena FINALIZAR de la ronda 10) construía su propio resultado con `anulaExpertos/anulaTecnicos` sólo para CCC/CCR y
descartaba los valores recibidos → Datos Solicitud `mcaanulaexperto/mcaanulatecnico = false` → el JSON del motor llevaba false.

**Corrección:** `SCA2_ContraAnulacionModalSiNo` v5 → v6: fuera de CCC/CCR toma `ri!data.anulaExpertos / anulaTecnicos` (los calculados en Opciones).

## 5. Corrección funcional del analista: inducción VERTI tras la Contra Anulación, no en Mecanización

Texto del analista: «El servicio de decisión contacto se tiene que lanzar después de la contra anulación finalizada negativa al igual que el servicio de
decisión de mecanizar y montar la pantalla de selección de inducción a VERTI tras la contra anulación. Tras seleccionar las opciones de la pantalla de
inducción VERTI, se navega o no a la mecanización dependiendo de lo que devolvió Mecanizar. Tras la finalización de las acciones administrativas y la
anulación fuera de norma no se lanza el servicio de contactos, sólo el de reglas de mecanizar. La inducción a VERTI sólo desde contra anulación.»

Diseño previsto (pendiente de implementar y probar; ver `r22/NOTAS.md` §P5): `SCA2 CMD CrearAccion`, al venir de una Contra Anulación negativa,
llama a `SCA2_determinarContacto`; si hay VERTI/VENCIMIENTO crea la tarea VERTI (token `CA:<acción>|<destino>|<nivel>`) antes de crear la de
mecanización; la pantalla Verti, al CONTINUAR, lanza la inducción (CMP) si procede y reanuda `CrearAccion` con la acción decidida (MECANIZAR → pantalla
de mecanización; otra → nivel/fin). `SCA2_MecanizacionPrincipal` deja de mostrar/lanzar la inducción (sólo confirmación + ANULAR PÓLIZA);
AA y Anulación fuera de norma no llaman a contacto.

## 6. Objetos tocados en esta ronda
| Objeto | Tipo | Versión | Cambio |
|---|---|---|---|
| SCA2_DetalleSolicitud | Interfaz | v55 → v57 | RETOMAR/REASIGNAR con gestión abierta aunque la tarea esté asignada a otro |
| SCA2 CMD Mecanizar | Proceso | nodo 340 | Bloqueo NEW con códigos traducidos de 8 dígitos (ANL traducida) |
| SCA2_altaGestionCore | Regla | v5 → v6 | Nivel > 1: perfil/subperfil del usuario + remap SI24 (paridad SCA) |
| SCA2_ContraAnulacionModalSiNo | Interfaz | v5 → v6 | Usa anulaExpertos/anulaTecnicos calculados por Opciones fuera de CCC |

Backups antes/después en `sca2work/r22/`.

## 7. Aviso: sesión paralela sobre los mismos objetos (20/10, ~14:00)
Durante esta ronda otra sesión ha subido a TEST cambios marcados «R22 #4» y «R22 #5»: `SCA2_ContraAnulacionOpciones` v54 (marcas del motor vía
`CMD CompletarAccion`), `SCA2 CMD CrearAccion` (40 nodos, tarea VERTI previa con token `VERTI-PRE`), `SCA2_VertiVencimientoPrincipal` v12 y
`SCA2_MecanizacionPrincipal` v17 (selección VERTI en el token de la tarea de mecanización). Es decir, el punto 5 ya está siendo implementado por
esa sesión y el punto 4 tiene dos correcciones solapadas (ModalSiNo v6 de esta sesión + Opciones v54 de la otra). Esta sesión NO toca esos objetos
hasta que el usuario decida quién sigue con cada punto. Efecto visto en la prueba B: al relanzar `CrearAccion` de 15788118, la nueva lógica creó la
tarea VERTI previa (tarea 303) en lugar de la Contra Anulación de nivel 2, por lo que B no es concluyente.
