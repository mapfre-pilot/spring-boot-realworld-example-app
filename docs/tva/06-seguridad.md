# 6. Seguridad, grupos y sites

## Grupos (11)

| Grupo | Miembros | Composición | Rol |
|---|---|---|---|
| `TVA Administradores` | 6 | usuarios | Administrador de todos los objetos de diseño |
| `TVA Usuarios` | 33 | 26 usuarios + 7 grupos (incl. `TVA Adm Portal SSO *`) | Viewer de todos los objetos; usuarios finales |
| `TVA WebApi Inicio` | 2 | 2 cuentas de servicio (GV y PFM) | Viewer de las 2 Web APIs (invocación desde portales GV y PFM) |
| `TVA Administradores portal` | 3 | 1 usuario + `TVA Adm Portal SSO NO PRO` + `TVA Adm Portal SSO PRO` | Acceso a `TVA_Pantalla_Administracion` |
| `TVA Debug` | 7 | `TVA Administradores` + 6 usuarios | Utilidades de depuración |
| `TVA Alertas` | 3 | usuarios | Destinatarios de `TVA IPs` |
| `TVA SSO Vida NO PRO` | 14 | usuarios | Mapeo SSO en entornos no productivos |
| `TVA SSO Vida PRO` | 4 | usuarios | Mapeo SSO en producción |
| `TVA Adm Portal SSO NO PRO` | 0 | — | Grupo SSO de administradores (vacío en DEV) |
| `TVA Adm Portal SSO PRO` | 0 | — | Grupo SSO de administradores (vacío en DEV) |
| `TVA Utilidades` | 0 | — | Sin miembros en DEV |

Los grupos `* PRO` y `* NO PRO` conviven en el mismo paquete de aplicación: la selección
del grupo efectivo se hace por entorno (`cons!CMP_VAL_ENTORNO_ACTUAL`) en las reglas
(`TVA_GRP_*`, 5 constantes).

## Mapa de seguridad de los objetos

Se recuperaron 42 de 43 mapas de roles. El patrón es **homogéneo** en toda la aplicación:

| Tipo de objeto | Administrator | Viewer | Otros roles |
|---|---|---|---|
| Modelos de proceso (28) | `TVA Administradores` | `TVA Usuarios` | editor/manager/initiator/deny vacíos |
| Sistemas conectados (4) | `TVA Administradores` | `TVA Usuarios` | — |
| Sites (2) | `TVA Administradores` | `TVA Usuarios` | — |
| Record type (1) | `TVA Administradores` | `TVA Usuarios` | data_steward vacío |
| Carpeta de reglas (1) | `TVA Administradores` | `TVA Usuarios` | — |
| Web APIs (2) | `TVA Administradores` | `TVA WebApi Inicio` | — |

- `getObjectSecurity` sobre la carpeta `TVA Modelos de procesos` devolvió *"Design object
  not found or not accessible"*; probablemente la seguridad de esa carpeta se gestiona a
  nivel de los modelos (hipótesis, no verificada).
- No hay grupos con rol *initiator* en los procesos: los procesos se lanzan con la
  identidad del usuario que ya es *viewer* (`a!startProcess` desde la interfaz) o desde las
  Web APIs con las cuentas de servicio. Todos los procesos terminan con
  *Modify Process Security*, lo que sugiere que se restringe la visibilidad de las
  instancias tras su ejecución.

## Sites (2)

| Site | Identificador web | Página | Interfaz destino | Visibilidad | Layout / estilo |
|---|---|---|---|---|---|
| `TVA Principal` | `tarificadorVidaAhorro` | `Inicio` (`inicio`) | `TVA_Principal` | `fn!true()` | HEADER_BAR / MERCURY |
| `TVA Principal Campania` | — | `Inicio Campaña` (`inicioCampania`) | `TVA_Principal` | `false` (oculta) | HEADER_BAR / MERCURY |

El nombre visible del site se toma de `cons!TVA_NOMBRE_APLICACION`. Ambos sites
renderizan la misma interfaz; el site de campaña está deshabilitado.

## Web APIs

Ambas son privadas (`isPublic: false`), `POST`, sin cuerpo de petición declarado
(`requestBodyType: NONE`) y con **logging desactivado**. Solo pueden invocarlas los
miembros de `TVA WebApi Inicio`.

## Observaciones de seguridad

1. **Valores tipo credencial en una regla de expresión**:
   `TVA_Conectar_ContrasennaUsuarioVida` devuelve, en función del entorno (DEV/PRE/PRO),
   cadenas literales que por su nombre y uso corresponden a contraseñas del usuario técnico
   de Vida. Cualquier *viewer* de la aplicación puede leerlas. Deberían moverse a un
   sistema conectado, a una constante securizada o a un secreto externo (ver
   [07-mejoras.md](07-mejoras.md)).
2. Los tres sistemas conectados HTTP de DEV apuntan a hosts **PRE** de Mapfre y usan
   **Basic Auth**; no hay separación real DEV/PRE a nivel de backend.
3. `TVA API Life APPINVE` (segundo usuario técnico) no es utilizado por ninguna integración:
   credenciales innecesarias desplegadas.
4. La sesión completa (datos personales de tomadores, cuentas bancarias, documentos) se
   persiste en claro como JSON en la tabla de trazas; el borrado depende del batch
   `TVA Batch Borrar traza` (política de retención a confirmar).
5. En entornos no PRO, `TVA_Principal` puede abrirse sin `claveSesion`; los mocks
   (`TVA_MOCK_Sesion_*`) contienen datos con apariencia real (incluso un NIF en el nombre
   de una regla).
6. Los grupos de usuarios incluyen cuentas externas (tenant no productivo)
   junto a cuentas corporativas; conviene revisar su vigencia.
