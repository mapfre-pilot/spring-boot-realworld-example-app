# 7. Hallazgos y propuestas de mejora

Priorización: **Alta** (riesgo de seguridad/operación), **Media** (mantenibilidad,
coste de evolución), **Baja** (higiene). Los hallazgos se basan en la lectura de las
definiciones; no se ha ejecutado la aplicación.

## Alta

| # | Hallazgo | Evidencia | Propuesta |
|---|---|---|---|
| A1 | **Credenciales hardcodeadas** en `TVA_Conectar_ContrasennaUsuarioVida`: devuelve literales distintos por entorno DEV/PRE/PRO. | `expression_rules/TVA_Conectar_ContrasennaUsuarioVida` | Eliminar la regla; usar la autenticación del sistema conectado (`TVA_WSDL_IGestionarPerfilUsuario` no usa sistema conectado) o un secreto gestionado. Rotar las contraseñas expuestas. |
| A2 | **Datos personales en claro** en la tabla de trazas (`TVA_ENT_TRAZA.json`): sesión completa con NIF, direcciones, IBAN, teléfonos… | `TVA_ObtenerTraza`, `Grabar sesion` en `TVA Inicio Ahorro` | Definir política de retención (revisar `TVA Batch Borrar traza`), cifrar/anonimizar campos sensibles o separar la sesión de la traza técnica. |
| A3 | **Sesión recuperable solo por `claveSesion`**: `TVA_ObtenerTraza` filtra por `upper(claveSesion)`; cualquier usuario con una clave válida en la URL puede abrir la sesión de otro. | `TVA_Principal`, `TVA_ObtenerTraza` | Vincular la sesión al `loggedInUser()`/nuuma y validar en `TVA_Principal`; caducar sesiones. |
| A4 | Sistema conectado `TVA API Life APPINVE` sin ningún dependiente. | `dependents/cs_TVA_API_Life_APPINVE` | Eliminar (credenciales innecesarias). |
| A5 | Entorno DEV apunta a backends **PRE** (`webservices.pre.mapfre.net`, `misv.pre.mapfre.net`) y `TVA_WSDL_IGestionarPerfilUsuario` fuerza PRE en DEV (`forzarPreEnDev: true`). | `connected_systems/*`, `integrations/TVA_WSDL_IGestionarPerfilUsuario` | Confirmar si es intencionado; documentar la matriz entorno Appian ↔ entorno backend. |

## Media

| # | Hallazgo | Evidencia | Propuesta |
|---|---|---|---|
| M1 | **49 reglas `TVA_MOCK_*` / `TVA_R2C_MOCK_*` y 6 `TVA_prueba*`** desplegadas en la aplicación (28 % de las reglas). `TVA_MOCK_ObtenerClienteRic` se invoca desde código productivo (`TVA_DatosParticipanteV1/V2`, `TVA_R2C_SeccionTomadores`) bajo `cons!TVA_FLAG_SIMULAR_BUSQUEDA_CLIENTE_RIC` en entornos no PRO. Los mocks contienen datos con apariencia real. | `expression_rules/TVA_MOCK_*`, `TVA_prueba*` | Mover mocks a una aplicación/paquete de test separado o a *test cases* de Appian; sustituir datos reales por sintéticos; eliminar `TVA_prueba1..5`, `TVA_prueba_tax`. |
| M2 | **Duplicidad de interfaces y reglas**: `TVA_DatosParticipanteV1` vs `V2` (1.544 / 1.555 líneas, ~2.300 líneas de diff), `TVA_DomicilioV1`/`V2`, cinco `*_DUP` (`TVA_SeccionFirma_popup_DUP`, `TVA_Utilidades_Inicio_DUP`, `TVA_SeccionSeleccionTipoFirma_DUP`, `TVA_CajaDatosFirma_DUP`, `TVA_SeccionCargaPoliza_DUP`), `TVA_ObtenerFuncionalidades2`, `TVA_ObtenerPerfilUsuario2`. | `interfaces/`, `expression_rules/` | Consolidar en una única versión parametrizada; borrar las copias tras confirmar que no tienen dependientes. |
| M3 | **Duplicidad de modelo de datos**: para cada `VIDA_API_Life_X` existe un `TVA_X` (Address, ContactMethod, IdentificationMethod, NaturalPerson, PersonName, LabourInformation, TaxObligationCountry, ClientComplete, PolicyHolder) con reglas de validación paralelas (`TVA_ValidacionX` y `TVA_X_Validacion`). | [03-inventario.md](03-inventario.md#tipos-de-datos-cdt-más-usados) | Decidir un único modelo (el de VIDA, compartido) y mantener en TVA solo los campos propios de UI. |
| M4 | **Interfaces monolíticas**: `TVA_DatosParticipanteV2` (83 KB), `TVA_SeccionDatosDeLaOperacionAhorro` e `…Informada` (52 KB cada una, prácticamente gemelas), `TVA_CapturaTomador_PanelDerecho` (44 KB). | tamaños en `interfaces/` | Extraer sub-componentes (medios de contacto, domicilio, documento identificativo) y parametrizar VA/VIA en una sola sección. |
| M5 | **Código comentado**: 217 bloques de comentario que contienen código SAIL en 70 archivos (p. ej. lanzamiento comentado de `TVA_PM_IMPORTE_MAXIMO` en `TVA_Botonera`, `TVA_SistemaCerrado` sustituido por `MU_Aviso` en `TVA_Principal`). | `interfaces/TVA_Botonera`, `interfaces/TVA_Principal` | Limpiar; la historia queda en las versiones de Appian. |
| M6 | **Constante referenciada inexistente**: `cons!TVA_PM_IMPORTE_MAXIMO` aparece (solo en código comentado) y no existe entre las 209 constantes; `TVA ImporteMaximo` se lanza por otra vía. | `interfaces/TVA_Botonera` | Eliminar el bloque comentado o crear la constante si se reactiva. |
| M7 | **Literales de UI hardcodeados**: ~500 `label: "…"` en interfaces y mensajes de negocio embebidos en reglas (`"Hay discrepancias en los datos…"`, `"La aplicación ha terminado su ejecución…"`). | `interfaces/*.sail`, `TVA_InicializarSesion`, `TVA_Principal` | Centralizar en constantes/bundle de traducción (existe `TVA_LITERALES_*`, solo 9). |
| M8 | **Lógica por entorno dispersa**: `cons!CMP_VAL_ENTORNO_ACTUAL` se evalúa en 13 archivos (mocks, credenciales, perfil de usuario, pantalla principal). | `cross_app_refs` | Concentrar en constantes por entorno (Appian *environment-specific constants*) en lugar de `a!match` sobre el entorno. |
| M9 | **Acoplamiento a MU/VIDA/CMP**: 151 objetos externos; los componentes de formulario son 100 % `MU_*Field`. | [05-dependencias.md](05-dependencias.md) | Aceptable como estándar corporativo, pero documentar versiones mínimas y un contrato de compatibilidad; incluir MU/VIDA/CMP/TI en el orden de despliegue. |
| M10 | **Estado en JSON sin versionado**: `TVA_Sesion` se serializa con `a!toJson`; cualquier cambio en el CDT invalida sesiones en curso y trazas históricas. | `TVA_ObtenerTraza` | Añadir campo de versión de esquema a la sesión y una regla de migración. |
| M11 | **Web APIs sin logging** (`loggingEnabled: false`) y sin cuerpo declarado; el diagnóstico depende de la tabla de trazas. | `web_apis/*` | Activar logging en NO PRO; definir contrato de entrada (parámetros esperados por `TVA_MOCK_ParametrosEntrada`). |
| M12 | **Timeouts heterogéneos**: 10 s (perfil, propuesta, printingTypes, SBC máximo), 20 s (mayoría), 100 s (`generalTable`), 120 s (`policy_documents`). | [04-integraciones.md](04-integraciones.md) | Revisar SLA reales; 100 s para un catálogo parece excesivo; cachear `generalTable`/`ProductList` (ya existe `TVA_Admin_GestionCaches`). |

## Baja

| # | Hallazgo | Propuesta |
|---|---|---|
| B1 | Descripciones poco informativas en algunos procesos (`'CapturaDatosRentas-Contratar'`, `'Inicio'`, `'Record action'` en `TVA Firma-EnvioFirmaManuscrita`). | Completar descripciones. |
| B2 | Cabecera con typo `X-Request-distributionChannnel` en `TVA_API_Life_individualNotes` (triple *n*); cabecera `numma` (vs `nuuma`) en `TVA_API_Life_perfilUsuario`. | Verificar con el equipo de API Life si el backend las lee; corregir. |
| B3 | Inconsistencia de nombres de inputs: `companyId` vs `companyID` entre integraciones; `TVA_PerfiladoClientes` usa `NIF`. | Homogeneizar. |
| B4 | Descripciones en inglés y castellano mezcladas (`Get KID or NI document asscociated…`). | Unificar idioma y corregir ortografía. |
| B5 | Site `TVA Principal Campania` oculto (`visibility: false`) pero desplegado. | Eliminar si la campaña ha terminado. |
| B6 | Grupos vacíos en DEV (`TVA Utilidades`, `TVA Adm Portal SSO *`). | Confirmar uso o eliminar. |
| B7 | Record type `TVA Dummy` únicamente para poder abrir diálogos. | Desde Appian 22.x se pueden usar `a!startProcessLink`/diálogos de interfaz sin record; evaluar retirarlo. |
| B8 | Una constante (`TVA_LITERALES_PREFIJO_DISCREPANCIA_VALOR_VIDA`) no es serializable por el MCP (`'value'`). | Revisar su definición (probablemente valor nulo o tipo poco habitual). |

## Oportunidades funcionales / arquitectura

1. **Observabilidad**: hoy la trazabilidad se basa en `TVA_ENT_TRAZA` + `TVA_LogAplicacion`.
   Un record type sobre esa tabla con vistas por `claveSesion`/usuario/fecha y KPIs
   (sesiones iniciadas, contratadas, abandonadas por pantalla) daría visibilidad de negocio
   sin cambiar el modelo.
2. **Reanudación de sesión**: la arquitectura ya permite reabrir por `claveSesion`; con A3
   resuelto se podría ofrecer "continuar donde lo dejé" al gestor.
3. **Tests automatizados**: convertir los `TVA_MOCK_Sesion_*` en *test cases* de las reglas
   `TVA_*_Validacion` y `TVA_FactoriaRequest*` (que son puras) para proteger las
   refactorizaciones M2–M4.
4. **Contrato API Life**: los CDT `VIDA_API_Life_*` son la fuente de verdad; documentar la
   versión de la API (`/api/life/1.0/`) y un plan para futuras versiones.
5. **Apertura/cierre**: el batch depende de constantes de fecha (`TVA_FECHA_*`) modificadas
   en caliente por `MU_PM_ACTUALIZAR_CONSTANTES`; una tabla de calendario sería más
   auditable.
