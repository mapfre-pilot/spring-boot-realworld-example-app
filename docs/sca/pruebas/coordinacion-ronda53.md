# Coordinación ronda 53 (SCA2, Appian TEST)

Origen: R53 — avisar con un mensaje claro cuando CORE no responde (SOAP CORE7 caído en TEST el 17/11/2026), sin cambiar la lógica cuando CORE sí responde.

| Sesión | Alcance |
|---|---|
| R53 (https://mapfre.devinenterprise.com/sessions/3870fa0c235a4757854488741c21cd7e) | Guardas en el camino de respuesta nula de las reglas SCA2 que llaman a CORE (carga del site, buscador, alta, Detalle, cabecera) y aviso «El servicio de CORE no está disponible en este momento. Inténtelo más tarde.» en el site. |

## Objetos en edición

| Objeto | UUID | Sesión | Estado | Versión antes→después | Nota |
|---|---|---|---|---|---|
| SCA2_TXT_CORE_NO_DISPONIBLE (constante nueva) | _a-0000f0b4-5b71-8000-9d56-011c48011c48_5751622 | R53 | LIBERADO | — → v1 | Texto del aviso |
| SCA2_valorCoreNoDisponible (regla nueva) | _a-0000f0b4-5b71-8000-9d56-011c48011c48_5751628 | R53 | LIBERADO | — → v1 | Valor centinela que devuelven las reglas protegidas |
| SCA2_esCoreNoDisponible (regla nueva) | _a-0000f0b4-5b71-8000-9d56-011c48011c48_5751634 | R53 | LIBERADO | — → v1 | Detecta el centinela en el llamador |
| SCA2_AvisoCoreNoDisponible (interfaz nueva) | _a-0000f0b4-5b71-8000-9d56-011c48011c48_5751640 | R53 | LIBERADO | — → v1 | Tarjeta con el aviso |
| SCA2_obtenerRolPerfilSubperfil | _a-0000f069-4f37-8000-9cc8-011c48011c48_20050948 | R53 | LIBERADO | v1→v2 | Guarda body nulo (carga del site) |
| SCA2_BuscadorTabla | _a-0000f069-4f37-8000-9cc8-011c48011c48_20056379 | R53 | LIBERADO | v18→v20 | Aviso si roles = centinela |
| SCA2_consultarSolicitudes | _a-0000f069-4f37-8000-9cc8-011c48011c48_20050936 | R53 | LIBERADO | v1→v2 | Guarda body nulo (buscador, alta) |
| SCA2_Buscador | _a-0000f069-4f37-8000-9cc8-011c48011c48_20055660 | R53 | LIBERADO | v39→v39 (sin cambios) | Aviso al buscar si CORE no responde |
| SCA2_AltaSolicitudAnulacionPopUp | _a-0000f069-4f37-8000-9cc8-011c48011c48_20064994 | R53 | LIBERADO | v12→v14 | Aviso en el popup de alta si roles = centinela |
| SCA2_DetalleSolicitud | _a-0000f069-4f37-8000-9cc8-011c48011c48_20055572 | R53 | LIBERADO | v76→v77 | Aviso en el Detalle si roles = centinela |
| SCA2_consultarCabeceraSolicitud | _a-0000f069-4f37-8000-9cc8-011c48011c48_20051080 | R53 | LIBERADO | v1→v2 | Guarda body nulo (Detalle, cabecera) |
| SCA2 CMD Alta (PM), nodo 8 «Write Datos» | 0000f06f-28fc-8000-6693-7f0000014e7a | R53 | LIBERADO | v47→v48 | `fecsolicitudanul`: fallar como antes si `consultarSolicitudes` = centinela (decisión del usuario) |
| SCA2 CMD Mecanizar (PM), nodo 301 «ANL Alta» | 0000f06f-4cfc-8000-66d3-7f0000014e7a | R53 | LIBERADO | v50→v51 | `fechaAnulacion`: fallar como antes si `consultarCabeceraSolicitud` = centinela (decisión del usuario) |
| SCA2 CMD Mecanizar (PM), nodo 301 «ANL Alta» `runAs` | 0000f06f-4cfc-8000-66d3-7f0000014e7a | R53 | LIBERADO | v51→v52 | `runAs` DESIGNER → INITIATOR: que ANL grabe como `creador` al usuario que mecaniza (opción B aprobada) |

Copias previas en `backups-r53/`. Solo lectura: integraciones SCA2 (compartidas), SCA, SCAC, CMP, CORE, PGM y el resto de PM.

