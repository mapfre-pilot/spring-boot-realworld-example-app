# R10-A · Telemáticas — Alta y Contra Anulación con pólizas de productor telemático/telefónico (SCA vs SCA2, Appian TEST)

Sesión: R10-A (ronda 10). Fecha: 2026-10-14. Usuarios: JJGONZ2 (Oficina CE_RM) y SISANS (SI24 Experto). Regla: SCA TEST es la referencia.

## 1. Pólizas de la sección R10-A (clasificación por consulta de sólo lectura NSE/productor)

Todas las pólizas asignadas son NSE (Hogar `073…` / Autos `200…`, `0003166101513`) y todas tienen productor de canal **INTERNET-TELEFO** (`estele = S`, `essi24 = S`). Ninguna informa `anulatecnicos`/`anulaexpertos` en el productor.

| Póliza | Producto | Estado póliza | Clase productor | Solicitudes CORE previas (abiertas) | Uso en R10-A |
|---|---|---|---|---|---|
| 0731480190624 | Hogar | Vigente – pendiente de anulación | 35 Negocio directo teléfono | 7 (0) | S3 SCA |
| 2002200588051 | Autos | Vigente – pendiente de anulación | 35 Negocio directo teléfono | 3 (1 abierta: 15787783) | S5 reserva |
| 2002200222543 | Autos | Anulada | 06 Delegados producción Internet | 3 (0) | S5 anulada (SCA y SCA2) |
| 0732000028208 | Hogar | Vigente | 35 Negocio directo teléfono | 0 | S3 SCA2 |
| 2001900000272 | Autos | Vigente – pendiente de anulación | 06 Delegados producción Internet | 1 (0) | reserva |
| 0003166101513 | Autos | Vencida | 39 Gestores remotos | 1 (0) | S5 vencida SCA |
| 0732000180872 | Hogar | Vencida | 05 Delegados producción teléfono | 23 (0) | — |
| 0731600111867 | Hogar | Vencida | 05 | 0 | — |
| 2002400517348 | Autos | Vencida | 06 | 0 | S5 vencida SCA2 |
| 2002500378119 | Autos | Vencida | 05 | 0 | — |
| 2002200142401 | Autos | Vencida | 05 | 4 (0) | — |
| 2002400515036 | Autos | Vencida | 78 eBrokers comparadores (Rastreator) | 1 (0) | — |
| 2002600042666 | Autos | Vigente | 06 Delegados producción Internet (web mapfre.es) | 1 (0) | S1 SCA |
| 2002600018038 | Autos | Vigente | 06 | 1 (0) | S2 SCA |
| 0732500051934 | Hogar | Vencida | 05 | 1 (0) | — |
| 2002500448422 | Autos | Vigente – pendiente de solicitud | 05 | 1 (1 abierta: 15786466) | S5 solicitud abierta (SCA y SCA2) |
| 2002600042650 | Autos | Vigente | 06 | 1 (0) | S1 SCA2 |
| 2002600038741 | Autos | Vigente | 06 | 1 (0) | S2 SCA2 |
| 0732400093704 | Hogar | Anulada | 05 | 38 (1 abierta: 15786379) | — |
| 2002200111333 | Autos | Vencida | 35 | 1 (0) | — |

Limitación de datos: sólo 5 pólizas están vigentes y sin solicitud abierta; el resto están vencidas, anuladas o con solicitud abierta en CORE, por lo que sólo sirven para comparar mensajes de bloqueo.

## 2. Casos del plan cubiertos

PENDIENTE (se rellena con los resultados de la UI).

## 3. Resultados por escenario

PENDIENTE.

## 4. Objetos Appian modificados

Ninguno hasta el momento.

## 5. Hallazgos externos (CORE / NSE / Emisión / Documentum / PRE)

PENDIENTE.

## 6. Preguntas para el analista

PENDIENTE.
