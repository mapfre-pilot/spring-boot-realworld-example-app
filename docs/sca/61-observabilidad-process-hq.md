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

Pendiente de decisión (no modificados):
- `SCA2 CMD Caducar` y `SCA2 CMD Mecanizar`: Appian no permite guardarlos por un aviso que ya existía antes. En los nodos «Write Caducada» y «Write Éxito», `modifiedBy` usa `a!localVariables(local!o: rule!SCA2_insertarObservaciones(...), pp!initiator)`: la variable `local!o` no se usa. Como Appian evalúa las variables locales solo cuando se usan, es probable que esas observaciones no se estén grabando en CORE. **Sin verificar.** Opciones: usar `local!o` (cambia el comportamiento), quitarlo (no cambia lo que pasa hoy) o dejar estos dos comandos sin duración.
- `SCA2 Tarea`: no se han unificado los estados COMPLETADA y FINALIZADA, porque pueden significar cosas distintas (cerrada por el gestor o cerrada por el sistema). Requiere decisión funcional.
- Registro de llamadas a servicios externos (NSE, CORE, GD, Verti, argumentos), con servicio, solicitud, duración, resultado y error: no creado. Requiere decidir si se quiere una tabla nueva.

Efecto secundario detectado: después de guardar los modelos con LCP, los comandos que se lanzan solos desde otro proceso (Decidir y CrearAccion tras el alta) graban como usuario `devin`; antes grababan `deployment.user`. Appian los ejecuta con el usuario que publicó por última vez el modelo que los lanza. Para que vuelva a salir `deployment.user`, hay que republicar esos modelos con ese usuario (por ejemplo, con un despliegue por paquete).

## 4. Prueba con solicitudes nuevas (TEST, usuario JJGONZ2)
| Paso | Resultado |
|---|---|
| Alta póliza Hogar `0731800026902` → solicitud `15788563` | Transición `SCA2 CMD Alta` con `duracionMs` 10.936 |
| Decidir y CrearAccion automáticos | `duracionMs` 5.405 y 3.674; estados ALTA → DECIDIDA → EN_ACCION |
| POSPONER desde la contra anulación | Comando grabado como `SCA2 CMD Posponer` (sin fecha), `duracionMs` 4.681, EN_ACCION → PENDIENTE |

No se tocaron solicitudes antiguas. Póliza anotada en `pruebas/polizas/REGISTRO.md`.

## 5. Qué se puede ver en Process HQ
- Mapa del proceso (niveles Básico a Completo): caminos reales, bucles (Decidir y CrearAccion repetidos), tiempos entre pasos.
- Variantes: recorridos más frecuentes y recorridos raros.
- Con `duracionMs` (solo en solicitudes nuevas): cuánto tarda cada comando.
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
