# Ronda 11 — pruebas (padre)

Ámbito: cambios de `docs/sca/29-respuestas-analista-ronda11.md`. Entorno Appian TEST. Usuarios: JJGONZ2 (Oficina, CE_RM) y SISANS (SI24 Experto).
Pólizas nuevas usadas: 0000253500305 (sin solicitudes previas; sólo identificación en el alta, sin guardar).

## 1. Pruebas por expresión (LCP, reglas vivas)

| Prueba | Resultado |
|---|---|
| Cascada SI24: `SCA2_consultarDetalle` × `SCA2_consultarCausa(codPerfil: CE_MF_SI24)` para motivos 1–12, líneas 1 y 2 | Autos: motivo 1 → se oculta detalle 5 (0 causas SI24, 2 para RM); motivos 2, 3 y 4 sin ningún detalle con causas SI24 → ocultos. Hogar: motivo 1 → se oculta detalle 10; motivos 3 y 4 ocultos. Tabla completa en el doc 29 §2.1 |
| Cascada RM: mismas llamadas con `CE_RM` | Sin cambios respecto a CORE (sólo filtra SI24) |
| PUT + relectura de los 4 objetos SAIL y del PM | Relectura idéntica al payload: AltaSolicitudPage v30, ModalSiNo v4, Opciones v49, subirDocumentosGD v7, CMD CompletarAccion nueva versión (nodos 11 y 312) |

## 2. Pruebas UI (testing agent)

Grabación y capturas en la sesión (testing agent). Nada guardado ni finalizado; sin solicitudes nuevas.

| # | Caso | Resultado |
|---|---|---|
| 1 | Alta como **SISANS** (SI24), póliza 0000253500305, línea Autos | **OK**. Motivos: sólo «DECISION DE CLIENTE» (motivos 2, 3 y 4 ocultos). Detalles del motivo 1: ASEGURADO NO DESEA SEGURO, MALA GESTION, PRECIO, PRODUCTO, SINIESTRO (sin «VENTA DEL VEHICULO», detalle 5, que no tiene causas para SI24). Causas de PRECIO: ME HA SUBIDO MUCHO LA PRIMA / MEJOR PRECIO DE LA COMPETENCIA / NO PUEDO PAGAR ESA CANTIDAD. Alta cancelada sin guardar |
| 2 | Alta como **JJGONZ2** (Red Mapfre), misma póliza | **OK**, sin cambios: motivos DECISION DE CLIENTE / DECISION DE LA ENTIDAD / DESAPARICION DEL RIESGO (lista de CORE para el perfil); detalles del motivo 1 con «VENTA DEL VEHICULO»; mismas causas de PRECIO. Sin guardar |
| 3 | FINALIZAR de Contra Anulación (JJGONZ2, 15788011, solicitud de prueba de R10) | **OK**. Para habilitar FINALIZAR se ejecutó un argumento (INCREMENTO PRIMA PLATINO → NEGATIVO), oficina MADRID CORREDORES NORTE II, plantilla de carta impresa y adjuntada como firmada. FINALIZAR abre «Se van a finalizar las acciones de contra anulación. ¿Desea continuar?» (NO/SI), sin la pregunta «¿El cliente insiste…?» y sin errores. Se contestó NO: la CA sigue Incompleta. No se probó la rama SI (finalizaría la solicitud) |
| 4 | Bandeja de errores `/sites/sca2/page/errores` con JJGONZ2 | **No accesible**: «La página no existe o no tiene permiso para verla». En rondas anteriores la bandeja se usó con usuario administrador; ver nota |

Nota bandeja: la página de errores está restringida por grupo (no es un fallo de la ronda 11: ningún objeto del sitio se ha tocado). Queda la
pregunta de quién debe ver la bandeja en SCA2 (¿sólo administradores o también SI24/Oficina?).

## 3. Sin probar en esta ronda
- Decisión del motor con `anulaExperto = true` (SI24 + póliza de acuerdos): exige una CA positiva con SISANS sobre una póliza de acuerdos nueva; la marca se graba ahora en `SCA2 Datos Solicitud` en el nodo Write Decidir (PUT verificado por relectura). Pendiente de una póliza de acuerdos sin solicitudes.
- Relanzamiento con referencia SGD reutilizada: exige provocar un fallo de BBDD CORE tras una subida correcta; verificado por código (regla v7) y relectura del PM.
