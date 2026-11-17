# Coordinación ronda 53 (SCA2, Appian TEST)

Origen: R53 — avisar con un mensaje claro cuando CORE no responde (SOAP CORE7 caído en TEST el 17/11/2026), sin cambiar la lógica cuando CORE sí responde.

| Sesión | Alcance |
|---|---|
| R53 (https://mapfre.devinenterprise.com/sessions/3870fa0c235a4757854488741c21cd7e) | Guardas en el camino de respuesta nula de las reglas SCA2 que llaman a CORE (carga del site, buscador, alta, Detalle, cabecera) y aviso «El servicio de CORE no está disponible en este momento. Inténtelo más tarde.» en el site. |

## Objetos en edición

| Objeto | UUID | Sesión | Estado | Versión antes→después | Nota |
|---|---|---|---|---|---|
| SCA2_TXT_CORE_NO_DISPONIBLE (constante nueva) | — | R53 | RESERVADO | — | Texto del aviso |
| SCA2_valorCoreNoDisponible (regla nueva) | — | R53 | RESERVADO | — | Valor centinela que devuelven las reglas protegidas |
| SCA2_esCoreNoDisponible (regla nueva) | — | R53 | RESERVADO | — | Detecta el centinela en el llamador |
| SCA2_AvisoCoreNoDisponible (interfaz nueva) | — | R53 | RESERVADO | — | Tarjeta con el aviso |
| SCA2_obtenerRolPerfilSubperfil | _a-0000f069-4f37-8000-9cc8-011c48011c48_20050948 | R53 | RESERVADO | v1→ | Guarda body nulo (carga del site) |
| SCA2_BuscadorTabla | _a-0000f069-4f37-8000-9cc8-011c48011c48_20056379 | R53 | RESERVADO | v18→ | Aviso si roles = centinela |
| SCA2_consultarSolicitudes | _a-0000f069-4f37-8000-9cc8-011c48011c48_20050936 | R53 | RESERVADO | v1→ | Guarda body nulo (buscador, alta) |
| SCA2_Buscador | _a-0000f069-4f37-8000-9cc8-011c48011c48_20055660 | R53 | RESERVADO | v39→ | Aviso al buscar si CORE no responde |

Copias previas en `backups-r53/`. Solo lectura: integraciones SCA2 (compartidas), SCA, SCAC, CMP, CORE, PGM y todos los PM.
