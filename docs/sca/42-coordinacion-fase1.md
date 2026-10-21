# 42. Coordinación de la fase 1 (5 sesiones en paralelo, SCA2 TEST)

**Fecha:** 20-10-2026 · OK del usuario a las 5 piezas del [doc 41](41-diseno-logica-appian-fase1.md). Entorno: **Appian TEST** (`mapfrespain-test`), aplicación SCA2. **Nunca PRO. Nunca la BD MR01/CORE** (solo lectura vía las integraciones existentes). Sin cambios funcionales salvo los aprobados (caducidad por nivel).

## Sesiones y propiedad exclusiva de objetos

Cada objeto Appian tiene **una única sesión propietaria**; nadie más lo guarda. Lo que no esté en esta tabla no se toca sin pedirlo al coordinador (sesión padre), que lo asigna por escrito aquí.

| Sesión | Pieza | Objetos NUEVOS (prefijo) | Objetos EXISTENTES que puede modificar |
|---|---|---|---|
| **A** | Caducidad por nivel | `SCA2_calcularCaducidadNivel`, `SCA2_calcularCaducidadNivel_test`, constantes `SCA2_DIAS_CADUCIDAD_PROPIETARIO`(14) / `SCA2_DIAS_CADUCIDAD_NO_PROPIETARIO`(7) | PM `SCA2 CMD Alta`, `SCA2 CMD Decidir` (solo el salto de nivel), `SCA2 CMD CambiarNivel` (si existe), `SCA2 CMD CrearAccion`, `SCA2 CMD Posponer`, `SCA2 CMD Caducar`; reglas `SCA2_configurarDatosContextoSolicitud`, `SCA2_cargarSolicitud`, `SCA2_posponerTarea` |
| **B** | Propietario / carterización | `SCA2_esPropietarioPoliza`, `SCA2_propietarioParaCaducidad`, `SCA2_registrarSombraPropietario`, tests, constante `SCA2_USAR_PROPIETARIO_APPIAN`(false) | `SCA2_setDatosGestionSGC`, `SCA2_setDatosGestionSGCEstratégicas`, `SCA2_nuumaEsPropietario`, interfaz `SCA2_ContraAnulacionOpciones` |
| **C** | Catálogos en Aurora | tablas `sca2_cat_*` (esquema Aurora SCA2), records `SCA2 Cat *`, reglas `SCA2_consultarCausaCore`… (copias de las actuales), PM `SCA2 CAT Carga Inicial`, interfaces de mantenimiento `SCA2_CatMantenimiento*`, constante `SCA2_USAR_CATALOGOS_AURORA`(false) | reglas `SCA2_consultarCausa`, `SCA2_consultarMotivo`, `SCA2_consultarDetalle`, `SCA2_consultarTipoArg`, `SCA2_consultarConcepto`, `SCA2_obtenerOficinasFisicasNuuma` (pasan a leer records con *fallback*); página/menú de **Gestiones de mantenimiento** (añadir entrada) |
| **D** | Caché de cabecera (hasta 07:00 del día siguiente) | `SCA2_obtenerDatosCabeceraLive` (copia exacta de la actual), `SCA2_calcularValidaHastaCache`, tests, constantes `SCA2_USAR_CACHE_CABECERA`(false), `SCA2_HORA_CADUCIDAD_CACHE_CABECERA`(7); campos nuevos en record `SCA2 Datos Cabecera` (`fechaCache`, `validaHasta`, `origenCache`) | regla `SCA2_obtenerDatosCabecera` (se convierte en envoltorio con caché; misma firma + input opcional `forzarRefresco`), record `SCA2 Datos Cabecera`, interfaz `SCA2_DetalleSolicitud` (botón Actualizar) |
| **E** | Entrada a reglas | `SCA2_construirEntradaReglas`, `SCA2_construirEntradaReglas_test` | `SCA2_mapearDatosDecidirAccion` (delega), `SCA2_consultarServiciosReglas` (solo si hace falta) |

**Prohibido para todas:** tocar integraciones, connected systems, CDTs compartidos `SCAC_*`, objetos de SCA/SCAC, las interfaces que no estén en su fila (`SCA2_AltaSolicitudPage`, `SCA2_GestionArgumentos`, etc. **no se tocan**: por eso los cambios de C y D van *detrás* de las reglas existentes, manteniendo la firma).

## Reglas comunes
1. Interruptor por constante en `false` hasta que las pruebas comparadas den iguales; se activa en TEST solo con el OK del coordinador. Excepción aprobada por el usuario: la caducidad por nivel (A) sí cambia comportamiento.
2. Nombres: reglas `SCA2_<verbo><Objeto>`, constantes `SCA2_<MAYUSCULAS>`, tests `<regla>_test`; descripción en castellano; sin la palabra «Devin» en objetos ni datos.
3. Pruebas con solicitudes **nuevas** en TEST; anotar póliza, idSolicitud e instancias en [pruebas/coordinacion-fase1.md](pruebas/coordinacion-fase1.md) (`git pull --rebase` antes de `push`) y no reutilizar las de otra sesión.
4. Documentación: cada sesión escribe solo `docs/sca/43-<letra>-<pieza>.md` (diseño final, objetos y versiones, pruebas con formato `ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos | Causa`) en la rama `feature/sca`; **no** editar `README.md` ni otros docs (lo hace el coordinador).
5. Si una sesión necesita un objeto de otra fila, un dato o un permiso: se para y lo pide (el coordinador lo gestiona con el usuario). Dependencias conocidas: A usa provisionalmente `SCA2_nuumaEsPropietario` + `clienteCarterizado` de la cabecera para «propietario»; cuando B entregue `SCA2_esPropietarioPoliza`, el coordinador pedirá a A el cambio de llamada.
6. Antes de guardar un objeto existente: anotar su versión actual en el doc; cambios mínimos; no reformatear SAIL ajeno.
