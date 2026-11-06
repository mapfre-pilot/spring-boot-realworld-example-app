# Mapa de sesiones Devin — paridad SCA → SCA2

Sesión **padre** (esta): https://mapfre.devinenterprise.com/sessions/6f3b571d45154ca8bddc009fb360ba0c — coordina rondas, consolida informes,
aplica las correcciones transversales y habla con el usuario (ggalv10). Fue creada a su vez desde la sesión
https://mapfre.devinenterprise.com/sessions/572bc44fef1348129445033ca0b0dbad (trabajo previo de construcción/documentación de SCA2, docs 01–11).
Sesiones anteriores relacionadas (análisis, documentación y rondas 1–7 del analista): d4c07d753cc74915b6de1bbcd5160185, abb24cc06b2c4c1ca1a6e44b58344860,
8a6c9e5bb08c459682195f838346acfb, 9bf795d752e64647a7de4d321ac8aafb (todas en https://mapfre.devinenterprise.com/sessions/<id>).

Modelo de trabajo: el padre reparte casos/pólizas/objetos de forma **disjunta**, publica un protocolo de coordinación en la rama
(`docs/sca/pruebas/coordinacion-ronda8.md`, `coordinacion-ronda10.md`: reserva de objetos Appian antes de modificarlos, pull previo, GET vivo antes del
PUT, backups, liberación), cada hija deja su informe en `docs/sca/pruebas/` y hace commit/push a `feature/sca`; el padre consolida (docs 23/26/28/29).

## Sesiones hijas (todas en https://mapfre.devinenterprise.com/sessions/<id>)

| Ronda | Sesión | id | Cometido | Informe / resultado |
|---|---|---|---|---|
| 7 | S1 | 88dee0a40d484f0c9903bfaa0563bd53 | Alta + Contra Anular POSITIVO/FINALIZAR SCA vs SCA2 | `21-revision-ronda7.md` |
| 7 | S2 | 2fdc9d72428e4b56ae2073f058b8cbff | Contra Anular NEGATIVO + documentos GD | `21-revision-ronda7.md` |
| 7 | S3 | 68417fa980db42e7869d2308a4ca4fef | Acción Administrativa | `21-revision-ronda7.md` |
| 7 | S4 | 65abe5180a5d43058d4a8d7c2d7cc47f | Autorización fuera de norma | `21-revision-ronda7.md` |
| 7 | S5 | d407e1ebdec0448b93e294c5e1cffa7f | Detalle, tareas, buscador, errores | `21-revision-ronda7.md` |
| 8 | H1 | 8cfa7eea2f3543dfa72f56c794e3168d | Plan Alta: identificación y validaciones (39 casos) | `pruebas/h1-plan-alta-identificacion-validaciones.md` |
| 8 | H2 | d0c4aa545abe4744888f517e8d4ac63d | Plan Alta: formulario y navegación (34) | `pruebas/h2-plan-alta-formulario-navegacion.md` |
| 8 | H3 | 3ab27cffbd6a4d38af747eff92b8b2f1 | Plan Contra Anular + Argumentos (47); 4 correcciones | `pruebas/h3-plan-contra-anular-argumentos.md` |
| 8 | H4 | 51047341c3004edcbc53f62bcb199c53 | Plan Mecanización + Autorización (24) | `pruebas/h4-plan-mecanizacion-autorizacion.md` |
| 8 | H5 | 9d99fe55c834411c941ee93c254e7982 | Plan Acciones Administrativas (15); 2 correcciones | `pruebas/h5-plan-acciones-administrativas.md` |
| 8 | H6 | cb5cc36ba4d842de8d4eb448a764a67c | Plan Buscador, Detalle y Mantenimiento (44); 4 correcciones | `pruebas/h6-plan-buscador-detalle-mantenimiento.md` |
| 8 | padre | — | Consolidado 203 casos; fecha vigente CORE en mecanización; observaciones CA | `pruebas/15-ronda8-consolidado.md`, `23-resumen-para-el-analista-ronda8.md` |
| 9 | R9-A | 7f54ec827b4c4a3f865d42e98b8ca252 | Alta, simulación (403), PRRA, Verti, pólizas nuevas | `pruebas/r9a-alta-simulacion-polizas-nuevas.md` |
| 9 | R9-B | bf873598aa6d4c5ba9150a6329e0a9a0 | Tareas, permisos, Oficina al POSPONER, SI24 | `pruebas/r9b-tareas-permisos-oficina-si24.md` |
| 9 | R9-C | 2d9a0d7047a24cdba22d805018d8cdb0 | Acciones Administrativas y SI24 (causas ocultas, aviso acuerdos) | `pruebas/r9c-acciones-administrativas-si24.md` |
| 9 | R9-D | a95ae40a2c094ece93c1d9294eeb6cbe | Mecanización, Autorización, ANL, batch NSE de SCA | `pruebas/r9d-mecanizacion-autorizacion-anl.md` |
| 9 | R9-E | 57f98fd1932547828c9db2d9880fd10a | Buscador, Detalle, DUE | `pruebas/r9e-buscador-detalle-due.md` |
| 9 | padre | — | Oficina al RETOMAR, Verti (GAIA 1101), consolidado y 23 dudas | `25-plan-ronda9.md`, `26-consolidado-ronda9.md` |
| 10 | R10-A | fff37912b5ec4762930c28d6ac8b12c6 | Telemáticas | `pruebas/r10a-telematicas.md` |
| 10 | R10-B | 6dfee707a9b24eaf94639ebb5192559c | Corredor; FINALIZAR CA → modal Sí/No (Opciones v48, Modal v3) | `pruebas/r10b-corredor.md` |
| 10 | R10-C | ba214d963554478aa079a0064947e3c7 | Campañas TTQ/PREMFIDE/RETOS/SVA; tréboles y SOAPAction | `pruebas/r10c-campanas.md` |
| 10 | R10-D | 7caa077c0e6d4e38b1cae286c38a0b0e | Plan de pagos, documentos AA, NSE | `pruebas/r10d-plan-pagos-documentos-nse.md` |
| 10 | padre | — | HU3980 etiquetas/colores, detalle NSE, alta Hogar NSE (contexto v11), consolidado | `pruebas/r10-padre-hu3980-nse-documentos.md`, `27-plan-ronda10.md`, `28-consolidado-ronda10.md` |
| 11 | padre (sin hijas) | — | Respuestas del analista: cascada SI24, sin «¿insiste?», anulaExperto, Documentum, batch NSE (diseño) | `29-respuestas-analista-ronda11.md`, `pruebas/r11-pruebas.md` |

Las pruebas de pantalla del padre las ejecuta su *testing agent* (grabaciones y capturas adjuntas en la sesión padre, no en el repo).
Todas las sesiones hijas han terminado; ninguna tiene reservas de objetos abiertas.
