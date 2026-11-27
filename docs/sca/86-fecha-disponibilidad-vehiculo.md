# 86 · Fecha de disponibilidad del vehículo en Acciones administrativas

## Corrección en Appian TEST

[SCA2_FechaDisponibilidadVehiculo](https://mapfrespain-test.appiancloud.com/suite/design/HkrBGUGaEKTlLWQIzIWtrLSVgFelfomwg-cMD4meQcmTnhwjNusS6uIKCV3ayW_Eq1I9woOeEp5ADJajBQ6ZWvOQsnUHuXUN4cbc0PYRBwm_FFyKZ5Cgk_FC-0oyG0BTRBjr2W0utll) (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20052747`) pasó de **v2 a v3**:

| Entrada | Antes (v2) | Después (v3) |
|---|---|---|
| `datosCabecera` | Record plano `SCA2 Datos Cabecera` | CDT `{urn:com:appian:types:SCAC}SCAC_DS_datosCabecera`, igual que SCA |

Ambos llamadores, `SCA2_AccionesAdministrativasPrincipal` v28 y `SCA2_INBOX38_AccionesAdministrativasPrueba` v3, pasan el resultado de `SCA2_obtenerDatosCabecera`, que devuelve ese CDT. Antes, al convertirlo al record plano, se perdía la ruta `datosPoliza.fechaVencimiento`. La comparación con el vencimiento nulo activaba el mensaje de fecha posterior incluso con una disponibilidad anterior.

Solo cambió el tipo de la entrada. Se releyó la v3 por MCP y se confirmó que la expresión SAIL, el comparador `>`, los mensajes y las demás entradas son idénticos a la v2. No se modificaron los llamadores, Autorización, NUUMA, subperfiles ni el envío a CORE. La copia previa JSON/SAIL queda en `files/sca2-fecha-disponibilidad/` de la memoria de Appian.

## Pruebas sin pólizas

`testInterface` evaluó la v3 en TEST con una cabecera sintética y vencimiento `21/09/2027`. Las tres evaluaciones devolvieron `diagnostics.error: null`.

| Fecha de disponibilidad | Validación devuelta |
|---|---|
| `26/11/2026` (caso que antes daba el falso positivo) | Ninguna |
| `21/09/2027` (igual al vencimiento) | Ninguna, como en SCA |
| `22/09/2027` (posterior) | «La fecha de anulación no puede ser superior a la fecha de vencimiento de la póliza.» |

No se abrió ninguna póliza ni se inició o modificó una solicitud o tarea. No se hizo prueba visual en el site.

## Paquete

Se añadió la interfaz al paquete existente **SCA2 Caducidad TM 27-11-2026** (`230be394-bb39-4d0c-bb48-e7966391839f`). `addPackageObjects` devolvió un objeto añadido y cero fallos; `getPackage` confirmó la interfaz en la lista. No se exportó ni importó el paquete.
