# 65 — Valoración de SCA2 para producción y rendimiento (ronda 47)

> Fecha: 10/11/2026. Entorno: Appian TEST (`mapfrespain-test`). Nada se ha medido ni tocado en PRO.
> Leyenda: **[Observado]** medido o comprobado · **[Inferido]** deducido · **[Pendiente]** sin evidencia.

## 1. Dictamen

**No está lista para una subida con tráfico real.** Sí puede desplegarse en PRO **«apagada»** (fase 1 del doc 58: interruptor OFF, Decisora sigue enviando todo a SCA) para hacer el smoke test, si se cierran antes los puntos de despliegue de la sección 4.

- Funcionalmente, Autos y Hogar reproducen SCA en los flujos probados con solicitudes nuevas (rondas 23–47). [Observado]
- Vida no se puede dar de alta (CORE 4004). [Observado]
- Hay cambios subidos sin prueba E2E (tréboles positivos, TTQ fallido y relanzamiento, SVA, reserva de prima, rechazo NSE, `ANL_EXCESO_TIEMPO`). [Observado]
- Quedan 28 dudas del analista (doc 64) y faltan perfiles de prueba. [Observado]
- No hay campaña de rendimiento con concurrencia ni percentiles fiables. [Pendiente]

## 2. Tiempos de los procesos (TEST, instancias del 10/11/2026) [Observado]

Fuente: `listProcessInstances` de los 17 modelos de SCA2. Solo hay historial del día (las instancias anteriores ya están archivadas), así que la muestra es pequeña y casi toda de pruebas.

| Proceso | Instancias | Mediana | p90 | Máx. |
|---|---:|---:|---:|---:|
| SCA2 CMD Alta | 16 | 11,3 s | 14,1 s | 15 s |
| SCA2 CMD Decidir | 26 | 5,6 s | 10,4 s | 565 s |
| SCA2 CMD CrearAccion | 30 | 0,9 s | 297,6 s | 569 s |
| SCA2 CMD CompletarAccion | 12 | 9,7 s | 12,8 s | 15 s |
| SCA2 CMD Finalizar | 7 | 6,6 s | 557 s | 557 s |
| SCA2 CMD Mecanizar | 3 | 7,6 s | 48,6 s | 49 s |
| SCA2 CMD Posponer | 3 | 0,7 s | 1,6 s | 2 s |
| SCA2 CMD GenerarPdf | 2 | 8,5 s | — | 8,5 s |

- Los máximos de ~9,5 min son **una sola cadena** Finalizar → Decidir → CrearAccion (14:21–14:30), con la espera a NSE/ANL (hasta 10 × 30 s) dentro. No es un cuelgue, pero el proceso queda ocupado ese tiempo. [Observado + Inferido]
- **Dos `SCA2 CMD Mecanizar` siguen ACTIVE desde el 03/11** (9157659 y 11252029). R47-B ha visto que no están colgadas: esperan en el subproceso síncrono «Inducción Verti (CMP)» a que alguien complete la tarea de inducción. Hay además una `CompletarAccion` (11252095) parada en «Start decidir» y 3 tareas de inducción huérfanas (doc R47-B §4). [Observado]
- Alta (11 s de mediana) y CompletarAccion (10 s) superan el objetivo inicial de CMD < 10 s del doc 10. [Observado]

## 3. Tiempos de pantalla e integraciones (documentados)

| Punto | Tiempo | Fuente |
|---|---|---|
| Cabecera del alta (`SCA2_obtenerDatosCabecera`) | 3,9 s media, máx. 5 s (doc 11); R47-B: 1,4–4,8 s de mediana según póliza. Las llamadas independientes **ya van en paralelo** | doc 11, R47-B |
| Formulario de alta | ~10 s (SCA ~40 s), 1 ejecución | doc 10 |
| Pantalla de Contra Anulación | 7,5–9,0 s (antes 11,6 s) | doc 43-B |
| `consultarListadoArgumentosREST` | 8,7 s media, **29 % de fallos**, 2 timeouts de 300 s | doc 59 |
| Otras de la misma pantalla | consultarAnulacionPoliza 6,3 s · simularAnulacion 5,1 s · reglas 4,0 s | doc 59 |
| Decisión con salto a Si24 | 55–70 s (38 s backend + sondeo) | doc 48 |

En todos los casos el tiempo es del backend (PRE/CORE/CMP); la lógica de Appian es de milisegundos. SCA2 ya es más rápida que SCA en alta y argumentario. [Observado]

## 4. Bloqueos y riesgos antes de producción

### Funcionales
1. Alta Vida: error CORE 4004 en `generarStudAnul`. [Observado]
2. Sin prueba E2E: Club/TTQ positivos, TTQ fallido + relanzar desde `/errores`, SVA, reserva de prima, rechazo NSE, `ANL_EXCESO_TIEMPO`, Pendiente de Autorización, Mecanización Enviada, Oficina → inducción. [Observado]
3. Perfiles sin probar: Central, CCC, GGE, Si24 front y administrador SCA2. [Observado]
4. 28 dudas del analista (doc 64), entre ellas «Cancelada» 5+4, filtro «Estado» y fecha de Más Móvil. [Observado]

### Despliegue y operación
5. DDL de `POLIZA_FECHAULTIMOSINIESTRO` sin ejecutar (sql/63). Sin él se sigue recortando el enlace GESVIDA. [Observado]
6. Temporizadores: `RefrescarCacheCabecera` sin timer **por decisión funcional** (R38-A: la caché la renueva el usuario al abrir la cabecera; no es un fallo). `BarridoCaducidad` sin timer → las solicitudes SCA2 **no caducan**. `Batch Mecanizacion NSE` sin ejecuciones. Hay que decidir y revisar en Designer los dos últimos. [Observado + Pendiente]
7. Reglas `[SCA2]` fuera de la aplicación: tienen que entrar en el paquete (doc 58). [Observado]
8. Índices, secuencias y nulabilidad de BD: el DBA tiene que compararlos con TEST antes de PRO (doc 58). [Pendiente]
9. Callbacks de autorización para solicitudes SCA2 y equivalente de reserva de prima/batch NSE (doc 58). [Pendiente]
10. Instancias colgadas (sección 2) y sin alarma: hace falta revisar `/errores` y Process HQ a diario. [Observado]

### Rendimiento
11. No hay prueba con concurrencia. TEST apunta a servicios PRE, así que los tiempos de PRO pueden ser distintos. [Pendiente]
12. Procesos síncronos que esperan hasta 5 min a NSE/ANL: con muchos usuarios ocupan el motor de procesos. [Inferido]
13. Un alta de más de 30 s volvía al formulario y creaba la solicitud por detrás (doc 56). Está corregido desde R35/R37 (espera con aviso y COMPROBAR AHORA); con varios usuarios a la vez hay que volver a medirlo. [Observado]

## 5. Optimizaciones (por impacto)

| # | Qué | Ganancia esperada | Esfuerzo |
|---|---|---|---|
| 1 | Cabecera: ~~lanzar las llamadas en paralelo~~ (R47-B: ya lo están; las que van en serie necesitan el dato de otra). Queda solo leer siempre de la caché (doc 66 §1) | ~0,1–0,2 s con caché | Bajo, pero con cambio funcional |
| 2 | Argumentario: aplicar doc 59 (catálogo en caché, lectura rápida, BRMS fuera de pantalla) y bajar el timeout de 300 s a ~30 s con reintento | 8,7 s → < 2 s; sin pantallas bloqueadas 5 min | Fase 1 Appian; fase 2 con backend |
| 3 | Espera NSE/ANL **asíncrona**: que Decidir/CrearAccion terminen y la espera quede en un subproceso, con estado «En proceso» y refresco | El usuario no espera 5–9 min y el proceso no queda ocupado | Medio |
| 4 | Decisión con salto a Si24: quitar el sondeo de 30 s y encadenar con activity chaining | 55–70 s → ~40 s, menos si se paraleliza CORE | Bajo–medio |
| 5 | Alta y CompletarAccion: revisar nodos en serie hacia CORE y escrituras repetidas | Bajar de 10–11 s [Inferido] | Medio |
| 6 | Aviso de procesos en espera más de 1 h (hecho en R47-B, cuadro de mando). El borrado de instancias terminadas ya existe (`AUTO_DELETE` a 1 día) | Detección de esperas largas | Hecho |

## 6. Criterio de salida propuesto

1. Cerrar 1–4 de la sección 4 (o dejar Vida fuera del alcance de la primera oleada, de forma explícita).
2. Ejecutar el DDL y configurar/decidir los temporizadores.
3. Prueba de rendimiento en TEST con 10–20 usuarios simultáneos: buscador, detalle, alta, contra anulación y decisión, con p50/p90/p95 y tasa de errores.
4. Desplegar en PRO apagada (fase 1 doc 58), smoke test y abrir por oleadas desde Decisora.

## 7. Qué optimizaciones cambian la funcionalidad (10/11/2026)

- **Sin cambio funcional (R47-B, `pruebas/r47-b-optimizaciones-sin-cambio-funcional.md`):** 5 aplicada (aviso de solo lectura en el cuadro de mando, `SCA2_CuadroMando` v25→v28); limpieza sin cambios porque ya existía. 1a sin cambios: las llamadas independientes de la cabecera ya iban en paralelo.
- **Con cambio funcional:** 1b, 2, 3 y 4. Se plantean a analistas y negocio en el doc 66 y no se tocan sin su visto bueno.
