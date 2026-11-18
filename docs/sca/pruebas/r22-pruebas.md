# R22 — Pruebas UI (testing agent, 20/10/2026, datos nuevos)

| Caso | Dato | Resultado |
|---|---|---|
| A RETOMAR en AA (Detalle v57) | 15788109 / 0002729296240, JJGONZ2 | PASA: RETOMAR y REASIGNAR visibles con la tarea asignada a otro usuario; RETOMAR abre Acciones Administrativas (no se completó). Con v56 seguía oculto (`SCA2_puedeGestionarTarea`). |
| B Nivel 2 (altaGestionCore v6) | 15788118 / 0002729373066, relanzamiento del error 98 desde la bandeja (devin) | PARCIAL: el relanzamiento no da error (bandeja 0 pendientes, buscador «Solicitud Pendiente»), pero `CMD CrearAccion` (lógica VERTI previa, §5 del doc 40) creó la tarea VERTI 303 (`VERTI-PRE`) en lugar de la CA de nivel 2 → la alta CORE de nivel 2 sigue sin verificar; continuar desde la pantalla Verti de 15788118. |
| C SI24 + acuerdos (Opciones v54 + ModalSiNo v6) | 15788137 / 0002729291207, SISANS, CA negativa (INCREMENTO PRIMA), FINALIZAR → Sí | PASA en pantalla (CA Finalizada Negativa, SI24 EXPERTOS, SISANS); tras ACEPTAR vuelve al buscador y en el Detalle aparece «Gestión Verti/vencimiento Incompleta» (pantalla VERTI previa del punto 5, no abierta automáticamente). Flags Datos Solicitud: ver nota al pie. |

Vídeos: `sca2-r22-abc-v57-edited.mp4` (A/B), `sca2-r22-c-autorizada-edited.mp4` (C). Capturas: ss_5435b709, ss_effb5483, ss_e4d77cd6, ss_0849bcce, ss_a5a6467c, ss_43511252.
Sin tocar: ANULAR PÓLIZA, AA de 15788109, solicitudes protegidas.

Nota al pie (LCP, 14:55): `SCA2 Datos Solicitud` de 15788137 → `mcaanulaexperto = true`, `mcaanulatecnico = true` (SISANS, CE_MF_SI24_EXPERTO) → el punto 4 queda verificado de extremo a extremo hasta la grabación previa a Decidir.
