# Coordinación ronda 52 (SCA2, Appian TEST)

Origen: R52 — tareas y errores PENDIENTE repetidos (ampliación con el resultado del script 71 de las 21:00) y usuario real en el histórico (opción B).

| Sesión | Alcance |
|---|---|
| R52 (https://mapfre.devinenterprise.com/sessions/789e8063d29c47069335d5bcfc16799b) | T1: cancelar tareas 375/711/712/713/714, dejar una fila por grupo de errores PENDIENTE, cubrir todos los Write Error, scripts 71/72. T2: Start Process «como iniciador» para que se grabe el usuario del site |

## Objetos en edición

| Objeto | UUID | Sesión | Estado | Versión antes→después | Nota |
|---|---|---|---|---|---|
| SCA2 Tarea (datos) | 696285d3-cb21-4f27-adce-66354ebf2b89 | R52 | RESERVADO | — | 375, 711, 712, 713, 714 → CANCELADA (se conservan 220, 617, 622, 632) |
| SCA2 Error (datos) | d7111f93-55f3-4b43-b921-aedadd2af7c3 | R52 | RESERVADO | — | 24 grupos PENDIENTE repetidos: la más antigua queda PENDIENTE con la suma de intentos; el resto, DESCARTADO |
| SCA2 CMD RefrescarCacheCabecera | 0000f095-81a8-8000-d613-7f0000014e7a | R52 | RESERVADO | v7→ | Nodo 12 «Registrar en SCA2 Error» reutiliza el error PENDIENTE (SCA2_obtenerErrorPendiente) |
| SCA2_ContraAnulacionSGO | _a-0000f069-4f37-8000-9cc8-011c48011c48_20060093 | R52 | RESERVADO | v6→ | a!writeRecords TTQ_KO reutiliza el error PENDIENTE |
| SCA2 CMD Alta | 0000f06f-28fc-8000-6693-7f0000014e7a | R52 | RESERVADO | v46→ | Nodo 12 Start Decidir: runAs iniciador |
| SCA2 CMD Decidir | 0000f06f-0eab-8000-6595-7f0000014e7a | R52 | RESERVADO | v18→ | Nodos 11, 12, 15 (Start Process): runAs iniciador |
| SCA2 CMD CrearAccion | 0000f06f-0eaa-8000-6594-7f0000014e7a | R52 | RESERVADO | v31→ | Nodos 14, 15 (Start Process): runAs iniciador |
| SCA2 CMD CompletarAccion | 0000f06f-1307-8000-65b1-7f0000014e7a | R52 | RESERVADO | v51→ | Nodos 8, 10, 12 (Start Process): runAs iniciador |
| SCA2 CMD Mecanizar | 0000f06f-4cfc-8000-66d3-7f0000014e7a | R52 | RESERVADO | v49→ | Nodo 322 Start CrearAccion: runAs iniciador |
| SCA2 CMD MecanizarNSE | 0000f095-7c8e-8000-d60a-7f0000014e7a | R52 | RESERVADO | v8→ | Nodo 36 Start CrearAccion: runAs iniciador |
| SCA2 CMD MarcarErrorRelanzado | 0000f073-49f2-8000-d0e7-7f0000014e7a | R52 | RESERVADO | v27→ | Nodos 10–17 (relanzar desde /errores): runAs iniciador |

Copias previas en `backups-r52/`. Solo lectura: resto de PM SCA2 CMD, `SCA2_obtenerIdTareaPendiente`, `SCA2_obtenerErrorPendiente`, `SCA2_BandejaErrores`.
