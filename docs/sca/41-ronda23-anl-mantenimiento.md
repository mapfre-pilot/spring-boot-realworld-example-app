# Ronda 23 — Diagnóstico de la página «Pendientes de autorizar (wAutemis)» y plan de pruebas con pólizas del analista

Fecha: 20/10/2026. Sesión padre: https://mapfre.devinenterprise.com/sessions/6f3b571d45154ca8bddc009fb360ba0c

## 1. Qué se revisó

El usuario sospechaba que, al pulsar AUTORIZAR / RECHAZAR en la página nueva de mantenimiento (`SCA2_MantenimientoPendientesAutorizar`, ronda 19), «los procesos de anulaciones no se están ejecutando bien». Se revisaron los modelos de ANL (`ANL Desbloquear`, `ANL Desbloquear proceso principal`, `ANL Alta`, `ANL Aceptar`), el `SCA2 CMD Mecanizar` (nodos 301–326 y 340) y la evidencia real en TEST: filas del record `ANL Anulacion`, eventos `ANL Evento Anulacion` / `ANL Evento Integracion` e instancias del PM `ANL Desbloquear`.

## 2. Cómo encaja la página en el ciclo ANL

```
SCA2 CMD Mecanizar
  nodo 340  Bloquear póliza en Central (NEW)        ← bloqueo previo (SCA lo hace igual)
  nodo 10   CORE crearAutorizacion
  nodo 301  ANL Alta  →  ANL Aceptar (Alta SGO si «A efecto»; Alta STCAT)
  nodo 324  ¿wAutemis pendiente de aceptar (Emisión 00000005/00000006)?
  nodos 302-304  espera 5 min + consulta fila ANL (ESTADO / DESBLOQUEO_ANULACION), hasta 288 veces
                                 ▲
  Página mantenimiento ──► PM ANL Desbloquear (mismos parámetros que la Web API «ANL Desbloquear SGO»)
       Update Anulacion → Desbloquear Poliza en Central (NEW) → [estado=1] Anular Poliza NEW
       → Cierre SGO y STCAT → Desbloquear proceso principal (SCA) → evento / CONCLUIDA
```

La Web API `ANL Desbloquear SGO` es un *passthrough* del JSON que envía SGO; la página replica exactamente esos parámetros (`idSolicitud`, `estado`, `desbloqueoAnulacion`, `nuumaNew`, `observacionesNew`, `sistema`, `nivelGestion`). `idOperacion` no lo envía SGO ni hace falta: «Cierre SGO y STCAT» toma `COD_OPER_STCAT` de la propia fila ANL.

## 3. Evidencia

### 3.1 Filas `ANL Anulacion` de las solicitudes probadas desde la página

| ID_ANULACION | Solicitud | Catalog. | COD_OPER_STCAT | COD_SGO | ESTADO | DESBLOQUEO | SISTEMA | OBSERVACIONES_NEW | CONCLUIDA |
|---|---|---|---|---|---|---|---|---|---|
| 2137 | 15788103 | 1 | 78726780 | — | 1 | S | SGO | Prueba Devin ronda 19 AUTORIZAR | false |
| 2139 | 15788105 | 1 | 78726781 | — | 2 | S | SGO | Prueba Devin ronda 19 RECHAZAR | false |
| 2141 | 15788111 | 4 (A efecto) | 78726783 | SGO11202610200000010 | 1 | S | SGO | Autorizada desde SCA2 mantenimiento | false |

Lectura: `ANL Alta`/`ANL Aceptar` sí se ejecutaron (hay operación STCAT y, en la «A efecto», alta SGO) y la página sí actualizó la fila (ESTADO/DESBLOQUEO/observaciones/usuario). Pero ninguna fila está CONCLUIDA y no existe ningún `ANL Evento Anulacion` para esos ids.

### 3.2 Instancias del PM `ANL Desbloquear` (uuid `0002eab3-dea6-8000-b85c-7f0000014e7a`)

| Proceso | Solicitud | Estado enviado | Iniciador | Duración | Resultado |
|---|---|---|---|---|---|
| 15412686 | 15788111 | 1 (autorizar) | JOSPENA 20/10 11:02 | 14 s | `errorDesbloquear`: HTTP 500 NEW PRE, fault 4004 **M555** «[DESBLOQUEAR] Error en central. Se ha producido un error al actualizar en BD la autorizacion/rechazo de una operacion pendiente de PCA» |
| 15413513 | 15787878 | 2 (rechazar) | GGALV10 20/10 14:57 | 13 s | fault 4004 **M511** «No se ha encontrado ninguna Póliza en Central que cumpla el criterio de selección» |

En ambos casos el PM sale por `Error?` → fin tras «Desbloquear Poliza en Central»: no ejecuta «Anular Poliza NEW», «Cierre SGO y STCAT», ni escribe el evento/CONCLUIDA. `errorAnularNew` y `resultAnularNew` quedan vacíos; `idProcesoDesbloquear` = 0 (no hay proceso principal de SCA que desbloquear porque la solicitud es de SCA2).

### 3.3 Eventos de integración recientes

Los `ANL Evento Integracion` 27366–27388 (integraciones 12879–12889, 20/10 13:27–13:51) son los bloqueos NEW de las pruebas R22; uno con error 4004 «M518 Para realizar reserva de primas la fecha de anulación no puede ser al efecto ni al vencimiento» (15788111, con reserva de prima y fecha a efecto).

## 4. Conclusión

1. **La página funciona**: lanza el PM correcto con los parámetros correctos y la fila ANL se actualiza; SCA2 detecta el cambio en el siguiente sondeo y reanuda la mecanización.
2. **Lo que falla es la integración con Central/NEW (PRE)** en el propio `ANL Desbloquear`:
   - M555 en 15788111: Central no tenía la «operación pendiente de PCA» porque el **bloqueo previo** (nodo 340 de `CMD Mecanizar`) había fallado con los códigos motivo/detalle/causa sin traducir (defecto corregido en R22 con `SCA2_construirSolicitudAnulacionAnlTraducida`). Es decir, el desbloqueo sólo puede completar si el bloqueo se hizo bien → hay que repetir el ciclo con una póliza wAutemis **nueva**.
   - M511 en 15787878: póliza inexistente en Central PRE (dato antiguo).
3. **Diferencia SCA/SCA2 a decidir**: SCA2 reanuda la mecanización en cuanto la fila ANL tiene ESTADO/DESBLOQUEO (nodo 304), aunque `ANL Desbloquear` falle después; SCA espera a que ANL concluya y le mande el «Desbloquear proceso principal». Propuesta (no aplicada): que el nodo 304 exija además CONCLUIDA=true o la existencia del evento de autorización/rechazo, o que `ANL Desbloquear` marque un error visible en la bandeja de SCA2 cuando NEW falle. Pendiente de respuesta del analista.
4. No se ha modificado ningún objeto en esta revisión.

## 5. Gotchas de consulta (LCP)

- `ANL Anulacion.ID_SOLICITUD` es Text: en `a!queryFilter(operator:"in")` hay que pasar `{"15788103", …}`; con enteros devuelve «No se puede aplicar el operador [IN]».
- Las referencias de campo `'recordType!{…}Tipo.fields.{…}CAMPO'` deben cerrar comilla; una comilla perdida produce «Invalid double value 3e» (interpreta parte del UUID como número).
- Instancias de un PM: `GET /process-models/{uuid}/processes?status=all` y `GET /processes/{id}` (incluye `variables`).

## 6. Pruebas delegadas en sesiones hijas (pólizas del analista)

El analista avisa de que las pólizas son de «alta probabilidad», no certeza: cada hija prueba en orden hasta que una cumpla la casuística y anota las que no.

| Hija | Sesión | Cometido | Pólizas | Informe |
|---|---|---|---|---|
| R23-A | https://mapfre.devinenterprise.com/sessions/f7c1e09a292540bda9a8909f099f33a4 | wAutemis «A efecto»: bloqueo NEW corregido, pendiente de autorizar, AUTORIZAR / RECHAZAR / CANCELAR desde mantenimiento, instancia de `ANL Desbloquear` nodo a nodo, comparación con SCA | columna «Wautemis a Efecto» de `SCA2PolizasPRE.ods` | `pruebas/r23-a-autemis-anl.md` |
| R23-B | https://mapfre.devinenterprise.com/sessions/477506ddf3fa486aa784bfc7a5376775 | NSE recién emitidas, a futuro y renovadas: catalogación, motor, mecanización NSE, etiquetas | `SCA2PolNSEPre.ods` | `pruebas/r23-b-nse.md` |
| R23-C | https://mapfre.devinenterprise.com/sessions/49ba1937072d488dbbaaacd31c201ff7 | wAutemis «que derivan»: CA negativa → Verti previa → gestión nivel 2 CORE (altaGestionCore v6) → RETOMAR SISANS → mecanización SI24+acuerdos; comparación con SCA | columna «Wautemis que derivan» | `pruebas/r23-c-nivel2-verti.md` |

La columna «M021 Polizas pendientes en SCA» no se usa para altas (ya tienen solicitud abierta); queda para comprobar el mensaje de «solicitud abierta» si hace falta.

Resultados consolidados: §7 (se completa al terminar las hijas).
