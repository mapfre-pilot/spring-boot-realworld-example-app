# 11. Bandeja de errores SCA2 — informe de pruebas UI

## 1. Alcance y veredicto

Procedimiento ejecutado en Appian TEST el 06/10/2026, en la UI real:
<https://mapfrespain-test.appiancloud.com/suite/sites/sca2/page/errores>.
Versión final comunicada por el lead: **SCA2_BandejaErrores v8 / SCA2_DetalleErrores v3**.

**Las comprobaciones funcionales solicitadas pasan en la versión final observada.**
Durante la ejecución inicial se encontró un fallo del filtro Fecha desde; el lead publicó v8 y la repetición pasó. No se declara éxito sin incidencias del procedimiento completo ni paridad global SCA/SCA2.

Únicas acciones confirmadas:
- Relanzar la fila controlada identificada como id 60, `PRUEBA-ERR-01`, código `PRUEBA_UI`, mensaje «Error de prueba controlado (relanzar)».
- Descartar la fila controlada identificada como id 61, `PRUEBA-ERR-02`, código `PRUEBA_UI`, mensaje «Error de prueba controlado (descartar)».

La tabla no muestra id numérico: la identificación UI se hizo por solicitud, comando, código, mensaje y fecha suministrados. No se modificó ninguna otra fila mediante la UI. No se pulsaron acciones en el detalle 15787744. No se hizo commit.

## 2. Acceso y preparación

- La sesión funcional JJGONZ2 no tenía acceso a `/errores`: «La página no existe o no tiene permiso para verla». El lead confirmó que es una página administrativa.
- Se cerró esa sesión y se inició sesión mediante las credenciales administrativas provisionadas `APPIAN_USERNAME` / `APPIAN_PASSWORD`, sin incluir valores en el informe.
- Con la sesión administrativa la página cargó correctamente. No fue necesario instalar dependencias ni arrancar servicios.
- El blueprint existente fue consultado. No se precisan cambios de instalación/configuración.

## 3. Bandeja, filtros y paginación

| Comprobación | Resultado observado | Veredicto |
|---|---|---|
| Carga y título | `Bandeja de errores (25)` al inicio; contador cambia con filtros | PASA |
| Estado inicial | Pendiente | PASA |
| Columnas | Solicitud, Comando, Nodo, Código, Mensaje, Intentos, Fecha, Relanzamiento y Acciones | PASA |
| Paginación | Primera página 1–15 de 25; siguiente 16–25 de 25 con filas distintas | PASA |
| Estado Todos | Columna Estado visible; valores RELANZADO/DESCARTADO comprobados posteriormente | PASA |
| Comando Posponer | Sólo filas `SCA2 CMD Posponer`, sin Relanzar | PASA |
| Fecha desde | Tras recargar v8, `06/10/2026` + Actualizar muestra las dos filas controladas del día, sin modal | PASA en v8 |
| Limpiar filtros | Restaura Pendiente, Comando Todos, Solicitud/Fecha vacías y primera página | PASA |
| Actualizar | Refresca sin error; al final retira el banner previo y muestra 25 pendientes | PASA |

Las comprobaciones iniciales de paginación/Comando se capturaron antes del ajuste exclusivo del filtro Fecha; los flujos mutables y la repetición de Fecha se capturaron en v8.

| Paginación — primera página | Paginación — segunda página |
|---|---|
| ![Primera página](https://mapfre.devinenterprise.com/attachments/6c7afd5d-bad2-4cad-b6ca-119cecdd0f24/ss_ed6b7e69.png) | ![Segunda página](https://mapfre.devinenterprise.com/attachments/c28d099a-eba6-4e62-b6d7-8e9553053d58/ss_d7591d87.png) |

| Filtro Comando Posponer | Fecha desde v8 — resultado correcto |
|---|---|
| ![Posponer](https://mapfre.devinenterprise.com/attachments/52e962fe-5551-4f60-b5f3-86fae431bbb8/ss_b3301033.png) | ![Fecha v8](https://mapfre.devinenterprise.com/attachments/6db093bc-d237-4673-92e9-1398022f07ae/ss_790cb55e.png) |

## 4. Relanzar — fila controlada 60

1. Se filtró por `PRUEBA-ERR-01`: `SCA2 CMD Decidir`, `PRUEBA_UI`, fecha `06/10/2026 18:40`, Relanzamiento **Automático**.
2. Relanzar abrió confirmación contextual con solicitud/comando. Cancelar conservó la fila.
3. Se abrió de nuevo y se confirmó Relanzar una vez.
4. **No apareció el error `local!dummy`** ni un modal de evaluación.
5. Banner verde exacto:

> Relanzado «SCA2 CMD Decidir» para la solicitud PRUEBA-ERR-01. El error queda marcado como RELANZADO; si vuelve a fallar aparecerá un error nuevo.

6. La original desapareció de Pendiente; el filtro Relanzado la recuperó y Todos permitió leer **RELANZADO**.
7. Se observaron posteriormente tres filas `DECISION_ERROR` para esa solicitud ficticia: una BLOQUEADO y dos PENDIENTE. Se dejaron intactas. La existencia de nuevos errores se había anticipado para esta solicitud inexistente; no se investigó en esta prueba la razón de su multiplicidad.

**Veredicto: PASA** el flujo de relanzamiento solicitado, no el éxito de negocio del Decidir ficticio.

| Relanzamiento — banner y salida de Pendiente | Relanzamiento — estado RELANZADO |
|---|---|
| ![Banner relanzado](https://mapfre.devinenterprise.com/attachments/d066aec8-0588-4979-8f0e-10af2ef70df3/ss_f85b1cb2.png) | ![Estado relanzado](https://mapfre.devinenterprise.com/attachments/0ac3d35e-b80b-4b9c-9ba8-1aa94afad976/ss_ebc19e63.png) |

| Errores nuevos — sólo observación | Bandeja final — sin acciones adicionales |
|---|---|
| ![Errores nuevos](https://mapfre.devinenterprise.com/attachments/6df42ce3-270e-4d64-a699-da36bfcc6df8/ss_665d1d3c.png) | ![Bandeja final](https://mapfre.devinenterprise.com/attachments/3d01f999-571a-4520-93f8-88df98846485/ss_3cca752f.png) |

## 5. Descartar — fila controlada 61

1. Filtro `PRUEBA-ERR-02`: `SCA2 CMD Posponer`, `PRUEBA_UI`, fecha `06/10/2026 18:41`.
2. **Sin Relanzar**, con Descartar y Relanzamiento **Repetir la acción desde la tarea**.
3. Descartar mostró:

> El error dejará de aparecer como pendiente y no se relanzará. ¿Desea continuar?

4. Cancelar conservó la fila. Se abrió de nuevo y se confirmó Descartar una vez.
5. Banner verde **«Error descartado.»**, contador 0 y desaparición de Pendiente.
6. Estado Descartado devolvió la original; Estado Todos mostró **DESCARTADO**, sin botones mutables.

**Veredicto: PASA.**

| 🔴 Antes — Posponer sólo permite Descartar | Confirmación de descarte |
|---|---|
| ![Antes del descarte](https://mapfre.devinenterprise.com/attachments/ce11c9f7-f1eb-446f-97c5-75d46079d16b/ss_2df69b84.png) | ![Confirmación descarte](https://mapfre.devinenterprise.com/attachments/b0f19454-1928-4d2a-ab5c-89dcb39c51c1/ss_f0c04ccf.png) |

| 🟢 Después — banner y salida de Pendiente | 🟢 Después — DESCARTADO |
|---|---|
| ![Banner descarte](https://mapfre.devinenterprise.com/attachments/522cc47b-e6c1-4043-99f4-1227bb99b527/ss_c9dae2ef.png) | ![Estado descartado](https://mapfre.devinenterprise.com/attachments/b1db7bc6-7593-4dd2-bbdf-2afb1a1a3ad3/ss_6612acf1.png) |

## 6. Navegación y detalle 15787744 — sólo lectura

- Filtrar Solicitud `15787744` devolvió Posponer / Observación CORE / CORE_OBSERVACIONES.
- **Ver solicitud** abrió Detalle, sin fallo de evaluación.
- Se desplegó **Trazabilidad técnica**; la cabecera identificó 15787744.
- Sección **Errores** visible: Posponer, PENDIENTE, fecha `01/10/2026 10:18`, «Repetir la acción desde la tarea», **Descartar visible y Relanzar ausente**.
- No se pulsó Descartar ni otra acción de la solicitud.
- **Volver a la bandeja** recuperó la lista conservando el filtro 15787744.

**Veredicto: PASA.**

| Detalle abierto desde bandeja | Sección Errores — sin Relanzar |
|---|---|
| ![Detalle 15787744](https://mapfre.devinenterprise.com/attachments/4615b4ff-7b83-42ad-88c0-807c192f6091/ss_8cfaf237.png) | ![Errores detalle](https://mapfre.devinenterprise.com/attachments/debe42f3-c54e-4a7a-a6d0-32c5e15fc332/ss_20e1f123.png) |

## 7. Estado vacío y retorno

- Solicitud **NOEXISTE** dio contador **0** y texto exacto:
  **«No hay errores con los filtros seleccionados.»**
- Limpiar filtros y Actualizar recuperaron la lista de Pendientes sin error.

**Veredicto: PASA.**

| Volver a la bandeja | Filtro NOEXISTE — vacío |
|---|---|
| ![Retorno a bandeja](https://mapfre.devinenterprise.com/attachments/3aaa6b29-1c0b-47d2-b1fc-471236461ce5/ss_1bb3d620.png) | ![Estado vacío](https://mapfre.devinenterprise.com/attachments/644135cd-6827-4a9d-ae02-6e3baa75dee4/ss_1cbdf607.png) |

## 8. Incidencias, observaciones y límites

1. **Fallo encontrado y corregido durante la prueba:** Fecha desde produjo inicialmente `No se puede aplicar el operador [GREATER_EQUALS_THAN] al campo [fechaCreacion] al comparar con el valor [TypedValue[it=7,v=2026-10-06]]`. El lead publicó v8 (conversión Date a DateTime); tras F5 la misma fecha funcionó. No permanece como fallo reproducido en v8.
2. **Entrada de prueba recuperada:** una segunda escritura de fecha concatenó texto y provocó validación de valor inválido. Se limpió y repitió correctamente; no se atribuye ese texto duplicado a un defecto confirmado de la aplicación.
3. **Refresco/render:** después de F5 hubo estados transitorios de filtros; realizando acciones separadas y esperando al grid no se reprodujo un cambio espontáneo estable. No se acredita un defecto persistente.
4. **Banner previo retenido:** el mensaje de la acción anterior permanece al cambiar filtros y al volver del detalle (por ejemplo «Error descartado.» encima de 15787744, sin haber descartado esa fila). Actualizar lo retira. No bloquea el flujo; puede resultar ambiguo si no se recuerda la acción anterior.
5. **Presentación:** algunos textos y enlaces se parten en varias líneas; no se observó solapamiento que impidiera las acciones probadas. Alta con payload muestra «Automático (alta)» y Relanzar, confirmado como esperado por el lead; no se pulsó.
6. Los estados finales se verificaron mediante consultas/filtros de la propia UI, no mediante una lectura LCP independiente de las filas ni de los campos de auditoría.
7. No se forzaron ramas de error del guardado, banner rojo ni respuesta «sigue en curso». No se ejecutó Relanzar/Descartar desde el detalle porque no había autorización sobre esa fila.
8. No se declara cobertura de otros locales, navegadores, permisos funcionales ni comparación con una bandeja SCA equivalente. La petición concreta cubría la administración SCA2.

## 9. Artefactos y entrega

- Grabación final anotada: `sca2-bandeja-errores-v8-edited.mp4`.
- Plan: `plan-ui-errores.md`.
- Capturas principales: `ss_790cb55e.png`, `ss_f85b1cb2.png`, `ss_ebc19e63.png`, `ss_665d1d3c.png`, `ss_2df69b84.png`, `ss_f0c04ccf.png`, `ss_c9dae2ef.png`, `ss_6612acf1.png`, `ss_8cfaf237.png`, `ss_20e1f123.png`, `ss_1bb3d620.png`, `ss_1cbdf607.png`, `ss_3cca752f.png`.
- Todas las imágenes incrustadas usan enlaces alojados; no hay rutas locales absolutas en este informe.
- Sin commit; los ficheros ajenos del working tree no se modificaron.
- Necesario del usuario para cerrar estas comprobaciones: **ninguno**.
