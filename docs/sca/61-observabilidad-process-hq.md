# 61 — Observabilidad de SCA2 en Process HQ (ronda 36)

Entorno: Appian TEST (`mapfrespain-test`). Solo afecta a objetos SCA2. SCA, SCAC, CORE, CMP, NSE, ANL y SGD no se tocan.

## 1. Objetivo
Ver en Process HQ el recorrido real de cada solicitud de SCA2: qué comandos se ejecutan, en qué orden, cuánto tardan, dónde se repiten y dónde se paran o fallan. Sirve para detectar puntos de dolor y para preparar la migración desde SCA.

## 2. Proceso dado de alta en Process HQ
| Elemento | Valor |
|---|---|
| Proceso | `SCA2 Solicitudes` (Process HQ › Process Insights) |
| Casos | record `SCA2 Solicitud` (uno por solicitud) |
| Eventos | record `SCA2 Transicion` (uno por comando ejecutado) |
| Actividad | `comando` (SCA2 CMD Alta, Decidir, CrearAccion, CompletarAccion, Mecanizar, Finalizar, Posponer…) |
| Fecha del evento | `fecha` (fin del comando) |
| Usuario del evento | `usuario` (renombrado «Usuario Evento») |
| Otros datos del evento | estado origen y destino, resultado, detalle, clave de idempotencia, processId, `duracionMs` |
| Relación caso-evento | `idSolicitud` (en el evento se renombró «Id Solicitud Evento») |
| Actualización | diaria a las 03:00 (Europe/Madrid); también se puede lanzar a mano |
| Acceso | grupo `Arquitectura Appian` como Analista |

Requisitos que hubo que cumplir:
- Ser administrador de datos (data steward) de `SCA2 Solicitud`, `SCA2 Transicion`, `SCA2 Tarea` y `SCA2 Error` (Process HQ › Gobernanza de datos).
- No repetir nombres de atributos entre caso y evento. En el evento se renombraron `Id` → «Id Transicion», `Id Solicitud` → «Id Solicitud Evento» y `Usuario` → «Usuario Evento».
- La API LCP de TEST no permite crear procesos, informes ni paneles (devuelve 501): todo se configura por pantalla.

Carga inicial: 327 de 338 solicitudes (Process HQ descarta las que no tienen transiciones) y 2.120 transiciones. Mediana por caso: 4 min 37 s; media: 2 h 30 min (datos de pruebas, no representativos).

## 3. Cambios en SCA2 (detrás de constante)
| Objeto | Cambio |
|---|---|
| Constante nueva `SCA2_USAR_OBSERVABILIDAD` (Booleano, `true`) | Interruptor. Con `false` todo vuelve al comportamiento anterior. |
| Regla nueva `SCA2_calcularDuracionMs(inicio)` | Milisegundos entre `inicio` y `now()`; `null` si la constante es `false` o `inicio` está vacío. |
| PM `SCA2 CMD Alta`, `CrearAccion`, `Decidir`, `CompletarAccion`, `Finalizar`, `MecanizarNSE`, `Posponer` | En cada escritura de `SCA2 Transicion` se añade `duracionMs: rule!SCA2_calcularDuracionMs(inicio: pp!starttime)`. Nada más cambia. |
| PM `SCA2 CMD Posponer` | `comando`: `if(cons!SCA2_USAR_OBSERVABILIDAD, "SCA2 CMD Posponer", pp!name)`. Antes se grababa con la fecha pegada y cada Posponer salía como una actividad distinta en el mapa. |

Se siguió el protocolo: lectura viva, copia de seguridad JSON, cambio mínimo, guardado y relectura comparando nodo a nodo. En cada modelo solo cambiaron los nodos que escriben `SCA2 Transicion`, y las variables de proceso son idénticas.

Ampliación (petición: tabla de servicios sí; Caducar/Mecanizar «la mejor opción sin afectar a la lógica»; no unificar estados de tarea):
| Objeto | Cambio |
|---|---|
| PM `SCA2 CMD Caducar` (3 escrituras) y `SCA2 CMD Mecanizar` (5 escrituras) | Se añade `duracionMs` a las escrituras de `SCA2 Transicion`. Para poder guardarlos se quitó la variable local `local!o` (llamada a `SCA2_insertarObservaciones` que nunca se usaba) de `modifiedBy` en «Write Caducada» y «Write Éxito»; se mantiene `pp!initiator`. Appian solo evalúa las variables locales que se usan, así que esa observación nunca se grababa: el comportamiento real no cambia. |
| Record nuevo `SCA2 Llamada Servicio` (tabla `sca2_llamada_servicio`, relación N:1 con `SCA2 Solicitud`, inversa `llamadasServicio`) | Una fila por llamada a servicio externo: solicitud, comando, nodo, servicio (integración), resultado OK/ERROR, código HTTP, mensaje de error (máx. 255), `processId`, inicio, fin y `duracionMs`. No guarda peticiones ni respuestas. |
| 14 nodos de llamada en 6 PM: `Alta` (1), `CompletarAccion` (3), `Mecanizar` (3), `MecanizarNSE` (3), `Caducar` (1), `Finalizar` (1) | En el nodo de llamada se recogen hora de inicio y fin, éxito, código HTTP y mensaje en 6 variables de proceso nuevas (`llamadaInicio`, `llamadaFin`, `llamadaOk`, `llamadaHttp`, `llamadaMsg`, `llamadaWrErr`). Detrás se inserta un paso «Registrar llamada …» (Write Records) que solo escribe si `SCA2_USAR_OBSERVABILIDAD` es `true`, con «parar si hay error» desactivado: si falla el registro, el proceso sigue igual. El paso enlaza con el mismo destino que tenía la llamada. |

Sin cubrir: `SCA2 CMD ObtenerDocumentoGD` (`consultaDocumento`) y las llamadas hechas dentro de pasos de script («Guardar impresion CA», «Bloquear póliza en Central (NEW)»).

Corrección posterior: el mensaje de error se truncaba a 1.000 caracteres, pero la columna `MENSAJE_ERROR` es VARCHAR(255). Se cambió el truncado a 255 en los 14 nodos para que una llamada con error largo no deje de registrarse.

No hecho (por decisión): unificar COMPLETADA/FINALIZADA en `SCA2 Tarea`.

Efecto secundario detectado: después de guardar los modelos con LCP, los comandos que se lanzan solos desde otro proceso (Decidir y CrearAccion tras el alta) graban como usuario `devin`; antes grababan `deployment.user`. Appian los ejecuta con el usuario que publicó por última vez el modelo que los lanza. Para que vuelva a salir `deployment.user`, hay que republicar esos modelos con ese usuario (por ejemplo, con un despliegue por paquete).

## 4. Prueba con solicitudes nuevas (TEST, usuario JJGONZ2)
| Paso | Resultado |
|---|---|
| Alta póliza Hogar `0731800026902` → solicitud `15788563` | Transición `SCA2 CMD Alta` con `duracionMs` 10.936 |
| Decidir y CrearAccion automáticos | `duracionMs` 5.405 y 3.674; estados ALTA → DECIDIDA → EN_ACCION |
| POSPONER desde la contra anulación | Comando grabado como `SCA2 CMD Posponer` (sin fecha), `duracionMs` 4.681, EN_ACCION → PENDIENTE |

| Alta póliza Autos `2002100002294` → solicitud `15788581` (Desaparición del riesgo / Baja de vehículo / Baja temporal) | Alta 11.053 ms; llamada `SCA2_generarStudAnul` OK, HTTP 200, 798 ms |
| Acciones administrativas: «el cliente no entrega documentación» → FINALIZAR | CompletarAccion 5.440 ms → Decidir (MECANIZAR) → CrearAccion (PDTE_MECANIZAR) |
| ANULAR PÓLIZA | Mecanizar 5.440 y 6.272 ms (2 transiciones); llamada `SCA2_guardarMecanizacionIntegracion` OK, 200, 191 ms; después CrearAccion → Decidir → CrearAccion → Finalizar 5.011 ms; llamada `SCA2_finalizarSolicitudIntegracion` OK, 200, 1.630 ms. Solicitud FINALIZADA |

Comprobado en la misma solicitud: tareas ACCIONES ADMINISTRATIVAS (COMPLETADA) y MECANIZAR (FINALIZADA) cerradas como siempre, sin errores nuevos en `SCA2 Error`. Las ramas de CompletarAccion con llamada (autorización, contra anulación PCA) no se recorrieron en esta prueba. Caducar no se ha probado con una solicitud nueva (no hay barrido de caducidad activo en SCA2).

Coste: el paso de registro es un insert de una fila pequeña por llamada (1 a 3 por comando). En las duraciones de los comandos no se aprecia diferencia: la variación normal entre ejecuciones (por ejemplo, Decidir, que no tiene llamadas instrumentadas, entre 5,3 y 9,9 s) es mayor que lo que pueda añadir el insert. El record está sincronizado; con volumen real conviene purgar filas antiguas.

No se tocaron solicitudes antiguas. Póliza anotada en `pruebas/polizas/REGISTRO.md`.

## 5. Qué se puede ver en Process HQ
- Mapa del proceso (niveles Básico a Completo): caminos reales, bucles (Decidir y CrearAccion repetidos), tiempos entre pasos.
- Variantes: recorridos más frecuentes y recorridos raros.
- Con `duracionMs` (solo en solicitudes nuevas): cuánto tarda cada comando.
- Tiempos y errores por servicio externo: record `SCA2 Llamada Servicio` (fuera del proceso de Process HQ; se consulta como record o en informes sobre él).
- Datos de caso para filtrar: estado, nivel, grupo, canal, origen y línea de negocio.

Limitaciones:
- Las transiciones antiguas no tienen duración.
- Errores y tareas no forman parte del mapa: se analizan como datos relacionados del caso.
- Los tiempos de servicios externos no existen hasta que se cree el registro de llamadas.

## 6. Vistas e indicadores creados (Process Insights, proceso «SCA2 Solicitudes»)
Vistas fijadas (datos a 29/10, 329 solicitudes):

| Vista | Filtro (Estado Solicitud) | Solicitudes | Duración mediana / media |
|---|---|---|---|
| Solicitudes cerradas | CADUCADA, CANCELADA, FINALIZADA, FINALIZADA_POSITIVO | 119 | 6m 27s / 2h 52m |
| Solicitudes abiertas | distinto de los cuatro anteriores | 210 | 3m 11s / 2h 16m |
| Solicitudes en error | ERROR, ERROR_DECISION | 14 | 4m 29s / 5h 14m |
| Pendientes de mecanizar | PDTE_MECANIZAR | 38 | 8m 13s / 6h 34m |

Indicadores (KPI) fijados en «Todos los casos»:

| KPI | Tipo | Valor |
|---|---|---|
| Duración mediana del caso | Duración (estándar) | 4m 32s |
| Duración promedio del caso | Duración (estándar) | 2h 29m |
| Media de aplazamientos por solicitud | Agregación, promedio de `Contador Posponer` | 1,05 |
| % solicitudes en ERROR | Recuento, Estado Solicitud = ERROR | 3,04 % (10) |
| % solicitudes pendientes de mecanizar | Recuento, Estado Solicitud = PDTE_MECANIZAR | 11,55 % (38) |

Nota: `Contador Posponer` va de 1 a 3, así que parece empezar en 1 y no en 0. Sin confirmar; si es así, el KPI de aplazamientos debe leerse como «1 = ninguno».

## 7. Lo que ya enseña el mapa (nivel Básico, datos de TEST)
- Recorrido principal: Alta → Decidir (326, 20 s) → CrearAccion (325, 34 s) → CompletarAccion (207, 29 min).
- Reprocesos: CompletarAccion vuelve a Decidir 159 veces y CrearAccion vuelve a Decidir 94 veces. Decidir se ejecuta 602 veces para 329 solicitudes.
- CrearAccion repetido sobre sí mismo 67 veces, con 2 h de media: es el tramo más lento.
- Mecanizar se repite sobre sí mismo 68 veces (42 min): reintentos de mecanización.
- Mecanizar → Finalizar: solo 4 casos y 2 días de media.
- 161 solicitudes terminan su historia en CrearAccion: siguen abiertas con una acción pendiente.
- En niveles Moderado a Completo aparecen 55 actividades «SCA2 CMD Posponer - fecha». Son transiciones antiguas grabadas antes del cambio; las nuevas salen como «SCA2 CMD Posponer». El catálogo tiene 63 actividades por ese motivo. Los datos antiguos no se han tocado.

## 8. Lo que no ofrece Process HQ aquí
- Los KPIs de recuento por atributo sólo usan atributos del caso (estado, canal, grupo, usuario…), no los de la transición (resultado, comando). Errores por comando o por código no se pueden sacar como KPI con el proceso actual; se ven en el record `SCA2 Error`.
- La pestaña «Toda la información» está vacía: el proceso no tiene informes adicionales.
