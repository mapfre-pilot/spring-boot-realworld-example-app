# 62 — Cuadro de mando de SCA2 (Gestiones mantenimiento)

Entorno: Appian TEST (`mapfrespain-test`). Solo objetos SCA2; SCA, SCAC, CORE, CMP, NSE, ANL y SGD no se tocan. Solo lectura: no escribe datos.

## 1. Qué es
Nueva opción **«Cuadro de mando»** (primera del menú) en la página
[Gestiones mantenimiento](https://mapfrespain-test.appiancloud.com/suite/sites/sca2/page/gestiones-mantenimiento) del site SCA2.
Muestra, con gráficas, lo que ya guarda SCA2: solicitudes, gestiones (comandos), resultados, tareas, llamadas a servicios, errores y trazabilidad de cliente.
Público: negocio y administradores de la aplicación (la página sigue limitada al grupo `SCA2 Administradores`; no se han cambiado permisos).

## 2. Filtros (afectan a todas las pestañas)
| Filtro | Valor por defecto |
|---|---|
| Desde / Hasta | últimos 90 días |
| Línea de negocio | Todas (Automóviles, Hogar, Vida) |
| Origen de la póliza | Todos (NSE-Autos, NSE-Hogar, wAutemis) |

## 3. Pestañas
| Pestaña | Indicadores | Gráficas |
|---|---|---|
| Resumen | Solicitudes, en curso, cerradas, contra anulación positiva (% sobre resueltas), mecanizadas, gestiones registradas, llamadas a servicios (% correctas), solicitudes en error | Altas por día y origen; solicitudes por estado; por línea de negocio; por origen; por grupo de asignación; por nivel de intervención |
| Gestiones y resultados | — | Resultado de las cerradas; motivos; detalle del motivo; causa indicada por el cliente; canal de entrada; tipo de catalogación; gestiones por comando y resultado (OK/ERROR); estado al que lleva cada gestión |
| Tareas | Tareas creadas y por estado | Tareas por tipo y estado; tareas creadas por día; tareas por grupo |
| Servicios | Llamadas, correctas, con error, % de éxito, tiempo medio | Llamadas por servicio y resultado; tiempo medio y máximo por servicio (ms); llamadas por día; duración media de cada gestión (ms); tabla de últimas llamadas con error |
| Errores | Errores registrados y por estado (pendiente, relanzado, bloqueado, descartado) | Errores por código y estado; por gestión; por día; tabla de errores pendientes más recientes |
| Trazabilidad | — | Operaciones por tipo y sistema (SCA / SCA2); resultado de las operaciones; perfil de usuario; operaciones por día y sistema |

Capturas: `img/62-cuadro-mando-*.png`.

**Aviso de operación (R47-B, v28).** Encima de las pestañas, y solo cuando hay casos, se muestra «Aviso de operación: procesos en espera más de 1 hora (N)»: tareas `SCA2 Tarea` de tipo `INDUCCION` en estado `PENDIENTE` creadas hace más de 1 hora (no depende de los filtros). Columnas: Solicitud, Póliza, Pendiente desde y Días en espera. Mientras esa tarea del componente de inducción (CMP) no se completa, la instancia de `SCA2 CMD Mecanizar` sigue ACTIVE esperando el subproceso «Inducción Verti (CMP) [SUB encadenado]». Es de solo lectura y no cancela nada. Detalle: `pruebas/r47-b-optimizaciones-sin-cambio-funcional.md`.

## 4. Datos que usa
Records existentes: `SCA2 Solicitud`, `SCA2 Datos Solicitud`, `SCA2 Transicion`, `SCA2 Tarea`, `SCA2 Llamada Servicio`, `SCA2 Error`, `SCA2 Trazabilidad Cliente` y catálogos `SCA2 Cat Motivo` / `SCA2 Cat Detalle`. Las etiquetas de canal, línea de negocio y catalogación salen de las constantes SCA2 existentes. No se ha creado ninguna tabla ni record nuevo.

## 5. Objetos Appian
| Objeto | Cambio |
|---|---|
| `SCA2_CuadroMando` (interfaz nueva, carpeta de reglas SCA2; v28 tras R47-B) | Cuadro de mando completo y aviso de operación (R47-B). Copia: `sail/62-cuadro-mando/SCA2_CuadroMando.sail` |
| `SCA2_GestionMantenimientoMenu` (v5 → v6) | Opción «Cuadro de mando» como primera del menú y seleccionada al entrar; las siete opciones anteriores no cambian. Copia: `sail/62-cuadro-mando/SCA2_GestionMantenimientoMenu.sail` |

Vuelta atrás: restaurar la versión 5 de `SCA2_GestionMantenimientoMenu` (deja el cuadro de mando sin enlazar).

## 6. Decisiones y avisos
- El comando `SCA2 CMD Posponer` se guarda con la fecha en el nombre («SCA2 CMD Posponer - 25/09/2026 12:49 CEST»); en «Gestiones por comando y resultado» se agrupa por el nombre base.
- La tabla de errores no muestra el `payload` (texto extra largo y con datos de la petición); solo fecha, solicitud, gestión, código, intentos y mensaje.
- Los valores vacíos (causa, grupo de tarea, perfil) no se pintan para evitar categorías sin nombre.
- Tiempos en milisegundos en las gráficas; el KPI de tiempo medio en segundos.
- Las cifras son de TEST (datos de pruebas), no representativas de producción.

## 7. Pruebas realizadas (TEST)
- `testInterface` de las seis pestañas sin errores.
- UI (usuario administrador): cada pestaña cambia y pinta sin errores; filtro Línea = Hogar → 31 solicitudes; Origen = wAutemis → 136; cuadros cuadran con los datos (p. ej. cerradas 122 = 55 + 47 + 18 + 2).
- Las siete opciones anteriores del menú siguen abriendo sin errores.
- Fallo encontrado y corregido en la prueba UI: la tabla de errores pendientes cargaba el campo `payload` (no permitido en rejillas); ahora consulta solo los campos mostrados.
