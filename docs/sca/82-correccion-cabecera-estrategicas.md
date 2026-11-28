# SCA2 — Retorno al buscador desde la cabecera de Estratégicas

Appian TEST, 25/11/2026. La flecha roja de la cabecera vuelve al **buscador**, no al detalle. El enlace separado **VOLVER AL DETALLE** no se modifica.

## Causa y corrección

En Acciones Administrativas, la flecha ejecutaba un `a!submitLink` que intentaba guardar en `ri!numSolicitud`. El llamador pasaba `tointeger(ri!idSolicitud)`, un valor calculado en el que Appian no admite guardar. Los demás llamadores de la cabecera en acciones usaban la misma expresión.

La cabecera mantiene el identificador para mostrar los datos; en acciones ya no lo usa como destino de guardado. `SCA2_DetalleTareas` pasa a las cuatro pantallas de gestión un enlace al buscador con la misma navegación que usa el retorno existente: en el site nativo abre la página del buscador sin parámetros de detalle; si la entrada es el piloto de Decidir Acción, borra en la página la selección del expediente, la acción y la tarea usando las variables guardables de la cadena. La entrada desde el buscador legacy conserva su ruta de retorno. Los llamadores sin un enlace explícito, como la pantalla de prueba INBOX38, usan el buscador nativo de SCA2. No cambia la rama de cabecera fuera de acciones.

| Interfaz SCA2 | Versión antes → publicada |
|---|---|
| `SCA2_DatosCabecera_Estrategicas` | 3 → 4 |
| `SCA2_AccionesAdministrativasPrincipal` | 26 → 27 |
| `SCA2_AnulacionFueraNormaPrincipal` | 25 → 26 |
| `SCA2_ContraAnulacionPrincipal` | 4 → 5 |
| `SCA2_VertiVencimientoPrincipal` | 17 → 18 |
| `SCA2_DetalleTareas` | 48 → 49 |

Se guardaron copias previas JSON/SAIL en la memoria privada `files/sca2-fix-cabecera-estrategicas/`. Para la validación de publicación, la cabecera usa un mapa de prueba sintético que evita la consulta con la póliza ficticia de su escenario anterior; Verti/Vencimiento, que no tenía escenario predeterminado, usa entradas sintéticas.

## Validación

| Prueba en TEST | Resultado |
|---|---|
| Relectura de los objetos publicados por MCP | Las expresiones y entradas coinciden con el cambio. INBOX38 sigue en v3. |
| `testInterface`, Acciones Administrativas desde el buscador nativo y desde el contexto del piloto | Sin errores de evaluación. La flecha del site nativo enlaza al buscador; en el piloto genera un enlace dinámico con guardados de estado de página. En la cabecera aislada sin enlace explícito se obtuvo el buscador nativo. |
| Playwright/CDP, site nativo de TEST | Se abrió Acciones Administrativas con un enlace directo cifrado a la acción existente, sin pulsar RETOMAR. Al pulsar la flecha roja de la cabecera apareció **BUSCAR SOLICITUD**, sin diálogo de error ni vista de acción. |

No se ejecutaron acciones de negocio ni se modificaron solicitudes o tareas. No se usaron pólizas para altas ni se realizó DDL/DML. La prueba de clic se hizo en el site nativo; la rama del piloto se evaluó por MCP, sin clic en el site piloto.
