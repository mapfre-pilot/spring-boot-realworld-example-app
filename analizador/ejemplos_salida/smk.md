# Gate de despliegue a PRO — smk.zip

**Veredicto: APTO CON CONDICIONES** — Apto con condiciones: hay controles pendientes de revisión manual o justificados a OT.

| Gate | Control | Estado | Hallazgos |
|------|---------|--------|-----------|
| G01 | Recomendaciones de monitorización revisadas | 🔍 Revisión manual | 0 |
| G02 | Sin riesgos ALTOS de Health Check en los objetos del paquete | 🔍 Revisión manual | 0 |
| G03 | Procesos con grupo de alertas propio (no administradores) | ✅ Cumple | 0 |
| G04 | Borrado de instancias de proceso <= 3 días | ✅ Cumple | 0 |
| G05 | Sin objetos sin dependencias | ✅ Cumple | 0 |
| G06 | Pruebas de rendimiento satisfactorias | 🔍 Revisión manual | 0 |
| G07 | Tareas de usuario con excepción de tiempo <= 1 día | ➖ No aplica | 0 |
| G08 | Records sincronizados sin full sync diario | ✅ Cumple | 0 |
| G09 | Sin constantes ni expresiones con contraseñas | ✅ Cumple | 0 |
| G10 | Procesos batch fuera de la ventana 06:30-22:00 | ➖ No aplica | 0 |

**Health Check**: no aportado
**Cobertura**: 143 objetos del manifiesto, 143 ficheros analizados, 0 no parseables (100%)

## Pendientes de justificación a OT

- `G01`
- `G02`
- `G06`

## Buenas prácticas (no bloqueantes)

- [Media] **ENV-002** `SMK Database AWS` — Valor de entorno sin fichero de personalización
- [Media] **MNT-003** `SMK_catalogoBase` — URL hardcodeada
- [Media] **MNT-002** `SMK_ejecutarPrueba` — Identificador hardcodeado (UUID / ID numérico)
- [Baja] **DOC-001** `SMK Ejecutar Prueba` — Objeto sin descripción
- [Baja] **DOC-001** `SMK Ejecutar Pruebas` — Objeto sin descripción
- [Baja] **DOC-001** `SMK Programar Pruebas` — Objeto sin descripción
- [Baja] **DOC-001** `SMK Pruebas de Humo` — Objeto sin descripción
- [Baja] **DOC-001** `SMK Ver Ejecucion` — Objeto sin descripción
- [Baja] **DOC-001** `SMK Ver Resultado` — Objeto sin descripción
- [Baja] **DOC-001** `SMK_ARTIFACTS_FOLDER` — Objeto sin descripción
