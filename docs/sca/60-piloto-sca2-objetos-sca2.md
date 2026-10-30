# Piloto SCA2 — objetos creados en SCA2 (TEST)

Alcance: piloto definido **sólo por usuarios del grupo**. Se ha creado únicamente lo necesario en la aplicación SCA2 de Appian TEST. **SCA no se ha modificado**: los cambios en SCA (`SCA_DecidirAccion`, buscador, pop-ups) se harán más adelante y sólo tendrán que llamar a estas piezas.

## Objetos creados

| Objeto | Tipo | UUID | Valor / uso |
|---|---|---|---|
| `SCA2 Piloto` | Grupo (dentro de `SCA2 Users`) | `_e-0000f09c-d8f4-8000-9c87-01075c01075c_11210` | Gestores que darán de alta en SCA2. Al estar dentro de `SCA2 Users` heredan el acceso a SCA2. |
| `SCA2_GRP_PILOTO` | Constante (Grupo) | `_a-0000f09c-d8f4-8000-9d41-011c48011c48_5632089` | Apunta a `SCA2 Piloto`. |
| `SCA2_BOOL_PILOTO_ACTIVO` | Constante (Booleano) | `_a-0000f09c-d8f4-8000-9d41-011c48011c48_5632095` | Interruptor general. **Queda en `false`.** |
| `SCA2_esUsuarioPiloto(nuuma)` | Regla | `_a-0000f09c-d8f4-8000-9d41-011c48011c48_5632101` | `true` sólo si el interruptor está activo y el gestor está en `SCA2 Piloto`. |
| `SCA2_esSolicitudSCA2(numPoliza, idSolicitud)` | Regla | `_a-0000f09c-d8f4-8000-9d41-011c48011c48_5632107` | `true` si la solicitud ya es de SCA2 y debe abrirse siempre en SCA2. |

Carpeta: `SCA2 Rules and Constants`. Código de las reglas: `docs/sca/sail/piloto/`.

## Comportamiento

**`SCA2_esUsuarioPiloto(nuuma)`**
- Interruptor apagado → `false` para todos.
- Interruptor encendido → `true` si el usuario `NUUMA@mapfrenopro.onmicrosoft.com` existe y pertenece a `SCA2 Piloto` (también por grupos anidados).
- Acepta el nuuma en mayúsculas o minúsculas, con espacios y con o sin dominio. Si el usuario no existe o viene vacío → `false` (sin error).

**`SCA2_esSolicitudSCA2(numPoliza, idSolicitud)`**
- Con `idSolicitud`: `true` si existe en `SCA2 Solicitud`, en cualquier estado.
- Sólo con `numPoliza`: `true` si la póliza tiene en SCA2 alguna solicitud **no cerrada**. Se consideran cerradas: `FINALIZADA`, `FINALIZADA_POSITIVO`, `FINALIZADA_NEG_CONTRA`, `FINALIZADA_NO_REQ`, `FINALIZADA_SIN_ANULAR`, `CADUCADA`, `CADUCADA_NEGATIVA` y `CANCELADA`.
- Sin datos → `false`.

## Cómo lo usará SCA más adelante

```
si rule!SCA2_esSolicitudSCA2(numPoliza, idSolicitud)        -> SCA2 (cualquier usuario)
si hay solicitud o tarea viva en SCA                        -> SCA
si rule!SCA2_esUsuarioPiloto(nuuma)                         -> alta en SCA2
en otro caso                                                -> SCA
```

## Pruebas realizadas (TEST, mediante el test de reglas)

| Caso | Esperado | Resultado |
|---|---|---|
| `esSolicitudSCA2` idSolicitud existente (EN_ACCION) | true | true |
| idSolicitud existente CANCELADA | true | true |
| idSolicitud inexistente | false | false |
| Póliza con solicitud EN_ACCION | true | true |
| Póliza sólo con FINALIZADA | false | false |
| Póliza sólo con CANCELADA | false | false |
| Póliza con FINALIZADA_POSITIVO + EN_ACCION | true | true |
| Póliza sin solicitudes SCA2 / sin datos | false | false |
| `esUsuarioPiloto` JJGONZ2 con interruptor apagado | false | false |
| Interruptor encendido: `JJGONZ2`, `jjgonz2`, `" JJGONZ2@mapfrenopro.onmicrosoft.com "`, dominio en mayúsculas | true | true |
| Interruptor encendido: `SISANS` (no está en el piloto) | false | false |
| Interruptor encendido: usuario inexistente, vacío, nulo, `@` | false | false |
| Interruptor apagado de nuevo: JJGONZ2 | false | false |

Las consultas de `esSolicitudSCA2` sólo leen datos; no se ha creado ni modificado ninguna solicitud. El interruptor se encendió sólo durante la prueba y se dejó en `false` (comprobado).

## Estado que queda en TEST

- `SCA2 Piloto` tiene un miembro: `JJGONZ2` (usuario de pruebas), añadido para probar el caso positivo.
- `SCA2_BOOL_PILOTO_ACTIVO = false`.
- Ningún objeto de SCA o SCA2 usa todavía estas piezas: no cambia nada para los usuarios.

## Pendiente (no hecho)

- Cambios en SCA: `SCA_DecidirAccion`, `SCA_BuscadorTabla`, `SCA_TablaOtrasSolAnulación(_Estrategicas)`, `SCA_GenerarSolicitudPopupEstrategicas`, `SCA_PopUpDecisora(Estrategicas)`.
- Permisos para quien trabaje solicitudes del piloto sin estar en él: meter `SCA Usuarios` dentro de `SCA2 Users` (y equivalentes de administradores/alertas). No se ha hecho porque daría acceso al site SCA2 a todos los usuarios de SCA; se hará junto con los cambios de SCA.
- Enlaces de vuelta al site `sca2` en `SCA2_DatosCabecera` y `SCA2_DetalleTareas`: depende de cómo se haga la entrada desde SCA.
