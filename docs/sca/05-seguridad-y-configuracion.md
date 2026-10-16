# 5. Seguridad y configuración

## 5.1 Grupos y autorización

| Grupo | Uso |
|---|---|
| `SCA Administradores` (admin por defecto) | Acceso total a objetos; `SCA_isUsuarioProceso` les concede todos los roles funcionales. |
| `SCA Usuarios` (usuarios por defecto) | Viewers de la app; acceso a sites y tareas. |
| `SCA Acceso Decisora`, `SCA Acceso Decisora Vida` | Listas de NUUMAs autorizados a entrar desde la Decisora (redirección PCA). |
| `SCA Alertas` | Destinatarios de errores; tratado como administrador en `SCA_isUsuarioProceso`. |
| `SCA_PROCESO`, `SCA_CE_*`, `SCA_CE_*_TEST`, `SCA_CE_*old` | 40+ constantes `SCA_GRP_CE_*` apuntan a grupos por perfil comercial (Oficina, Agente, DT, SI24 Experto/Técnico/Front/SA, Recibos CCC/CCR, Control, Central AT). Coexisten tres generaciones: `<grupo>old`, `<grupo>_TEST` y el nombre base. |

Modelo de roles: el rol funcional **no** se deriva solo de grupos Appian, sino de `CMP_APIUsuarios_ObtenerRoles`
(roles corporativos por NUUMA: `SOLICITUD`, `PCACORE`, `PCASOA`, `CE_RM`, `CE_RM_OFICINA`, `PROCESO`, ...) combinado
con `grupoasignacion` + `nivelintervencion` en `SCA solicitudAnulacion` (`SCA_comprobarUserTareaActiva`).

Seguridad de procesos: casi todos los PMs ejecutan `Modify Process Security` al arrancar, para que el proceso quede
visible/editable solo a los grupos de la app.

## 5.2 Autenticación hacia sistemas externos

| Mecanismo | Dónde | Observación |
|---|---|---|
| **WS-Security UsernameToken** (`wsse:UsernameToken` + `wsse:Nonce`) | 204 ocurrencias en integraciones SOAP de SCAC (Core7, webservices, SOA7, ESB, WM) | Usuario/contraseña provienen de **constantes Appian** `SCAC_VAL_USUARIO_ACCESO_SERVICIOS` / `SCAC_VAL_PWD_ACCESO_SERVICIOS` (98/99 refs) y `SCAC_VAL_USUARIO_APP_PCAS` / `SCAC_VAL_PWD_APP_PCAS` (1/1), no del connected system. |
| **Bearer token** | 10 integraciones REST (Clients API vía `SCAC Login Token`, Plataforma Retos vía `SCAC Plataforma Retos Token`) | Token obtenido con una integración de login previa. |
| **API key** | `SCAC API Key Obtener Credenciales` → Web API `SCAC Obtener Credenciales Conceptos` | Los record types `WEB_SERVICE` se autentican pidiendo credenciales a una Web API de la propia app. |
| Usuario/contraseña por regla | `SCA_obtenerUserPassSimularPoliza` (llamada desde SCAC) | Devuelve usuario, contraseña y rol para la simulación de anulación a partir de un objeto de configuración. |

Hallazgos relevantes (sin exponer valores):

- Las contraseñas de servicio están almacenadas como **constantes de texto** y el API de inventario las devuelve.
  Algunas parecen cifradas por la plataforma (prefijo ilegible), pero al menos `SCAC_VAL_PWD_APP_PCAS` se devolvió en
  claro. Cualquier usuario con permiso de *viewer* sobre SCA CORE puede leerlas desde el designer.
- Los connected systems `system.http` tienen los campos de credencial vacíos: la autenticación se compone a mano en
  el body/headers de cada integración, por lo que no se aprovecha el almacenamiento seguro de Appian.

## 5.3 Configuración por entorno

| Aspecto | Estado en DEV |
|---|---|
| Hosts | Centralizados en `SCAC_VAL_HOST_{CORE7,WEBSERVICES,WMAPFRE,WMBIG1IS,ESB}` (valores `*.pre.mapfre.net`) **y** duplicados en `CMP_VAL_HOST_{CORE7,ESB,SOA7}`. |
| Endpoints | Literal en cada regla SCA (`endpoint: "PCA_CORECFSA_HTTPRouter/IGestionarAutorizacionesPCA"`); solo `SCAC_TXT_CORE7_ENDPOINT` está en constante. |
| URLs hardcodeadas | ~82 ficheros SAIL/JSON contienen `core7.pre.mapfre.net` o `webservices.pre.mapfre.net`, en su mayoría en comentarios de cabecera de las reglas, pero también en literales; ~170 ficheros contienen alguna URL. |
| Buzones de correo | Constantes `SCA_BUZON_CUE_AUTOS/HOGAR`, `SCA_TXT_EMAIL_DUE_PARA_ALTITUDE[_TEST]`, `SCA_TXT_EMAIL_DUE_PARA_EXPERTOS`, `SCA_TXT_EMAIL_ENVIO_ERRORES` (`pruebasca@…`). `SCA_TXT_EMAIL_DUE_PARA_ALTITUDE_TEST` contiene el correo **personal** de un desarrollador externo. |
| Feature flags | `SCA_BOOL_BATCH_NSE`, `SCA_TIMER_OK`, `SCA_VAL_ID_ACCION_COMERCIAL`. |
| Punteros a objetos | ~25 constantes tipo `PROCESS_MODEL`/`FOLDER`/`DOCUMENT`/`GROUP`; dos (`SCA_PM_BATCH_CADUCIDAD`, `SCA_PM_BATCH_RSV_PRIMA`) son de tipo **TEXT** con el UUID del PM en lugar de tipo Process Model (no se actualizan al importar). |
| Import Customization | No hay evidencia de un fichero de personalización de importes; las constantes de entorno se editan a mano. |

## 5.4 Auditoría y trazabilidad

- `SCA Trazabilidad Cliente` registra sistema, plataforma, IP (`CMP_CS_OBTENER_IP`), perfil, operación y resultado
  por póliza/cliente en cada alta (`SCA Guardar Trazabilidad`).
- `SCA Decisora` tiene `loggingEnabled = true`; las demás Web APIs no.
- Los errores de flujo se notifican por correo (`SCA Notificacion Errores`) al buzón de `SCA_TXT_EMAIL_ENVIO_ERRORES`.
- Reportes de proceso: `SCA Mecanizaciones` y `SCA Tareas Por Poliza` (documentos `SCA_REP_PROCESS_*`).
