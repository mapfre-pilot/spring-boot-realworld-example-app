# 4. Modelo de datos

## 4.1 Fuente de datos

Los 16 record types de base de datos apuntan al connected system **`SCAC AWS DB`** (Aurora PostgreSQL, definido en
SCA CORE). Los otros 3 son de tipo `WEB_SERVICE` (sincronizados desde una integración) y se utilizan para los datos
maestros de conceptos.

Ningún record type define **relaciones**, **record actions** ni **vistas** más allá del *summary* por defecto:
se usan como tablas planas consultadas desde reglas (`a!queryRecordType` en 31 reglas/interfaces) y escritas desde
PMs (`Write Records and Related Records`, `Delete Records and Related Records`). La clave de unión entre tablas es
`idsolicitud` / `numpoliza`, gestionada en código.

## 4.2 Record types

| Record type | Fuente | Campos | Rol |
|---|---|---|---|
| `SCA solicitudAnulacion` | DB | 26 | **Entidad raíz.** Estado del proceso por póliza: `idsolicitud`, `numpoliza`, `procesoactivo`, `interfazactiva`, `nodorelanzar`, `nivelintervencion`, `grupoasignacion`, `usuario`, `estadotarea`, `estadosolicitud`, `caducidadtarea`, `fecinicionivel`, `contadorposponer`, `ispolizaprra`, `transactionid`, `dueenviado`, `canal`, `idioma`, `rol`. |
| `SCA datosSolicitud` | DB | 27 | Datos de negocio de la solicitud: motivo/detalle/causa, canal, origen, catalogación, marcas mecanizada / anula experto / anula técnico, perfil "Te Cuidamos", código PCA. |
| `SCA datosBasicosSolicitud` | DB | 8 | Subconjunto para listados. |
| `SCA datosCabecera` | DB | 43 | Snapshot desnormalizado de cliente + póliza + contacto para la cabecera (prefijos `cliente*`, `poliza*`, `contacto*`). |
| `SCA datosPolizaAutos` / `SCA datosPolizaHogar` / `SCA Datos Poliza Vida` | DB | 83 / 89 / 89 | Snapshot completo de la póliza por ramo. |
| `SCA datosProductor` | DB | 15 | Datos del mediador/productor. |
| `SCA datosPerfilesPca` | DB | 5 | Perfiles PCA del usuario. |
| `SCA nivelesCoberturaAutos` | DB | 5 | Coberturas Autos. |
| `SCA otrasSolicitudesCabecera` | DB | 10 | Otras solicitudes del mismo cliente. |
| `SCA TareasPorPolizaAWS` | DB | 11 | Registro de tareas Appian activas (`idTarea`, `proceso`, `propietario`, `asignadoA`, `estado`) para reasignación/limpieza. |
| `SCA Trazabilidad Cliente` | DB | 11 | Auditoría: `sistema`, `plataforma`, `ip`, `perfilUsuario`, `operacion`, `resultadoOperacion`, `cliente`, `poliza`. |
| `SCA Reserva Prima` | DB | 11 | Cola de reservas de prima a ejecutar contra SGO (`fechaEjecucion`, `ejecutado`). |
| `SCA Traduccion Motivo Detalle Causa` | DB | 15 | Tabla de traducción de códigos PCA ↔ Autemis por compañía/ramo. |
| `SCA Documentos Estaticos` | DB | 2 | Catálogo de documentos estáticos. |
| `SCA Concepto` / `SCA Concepto Funcional` / `SCA Compañia Contraria` | WEB_SERVICE | 2 / 4 / 3 | Datos maestros mantenidos desde `SCA_GestionConceptosYClases` vía PMs `SCA Crear/Modificar/Eliminar Concepto*` (Call Integration + Sync Records). |

Además existe al menos un **Data Store Entity** legacy (`SCA TM Add Transactions to Job Type` usa
`Write to Data Store Entity`), herencia del framework Transaction Manager.

## 4.3 Modelo lógico (simplificado)

```
 solicitudAnulacion (idsolicitud, numpoliza) 1 ─── 1 datosSolicitud
        │ 1 ─── 1 datosCabecera
        │ 1 ─── 0..1 datosPolizaAutos | datosPolizaHogar | datosPolizaVida
        │ 1 ─── 1 datosProductor
        │ 1 ─── * datosPerfilesPca
        │ 1 ─── * nivelesCoberturaAutos
        │ 1 ─── * TareasPorPolizaAWS (por numSolicitud / poliza)
        │ 1 ─── * Trazabilidad Cliente (por poliza)
        │ 1 ─── * Reserva Prima
        └──── referencia a records ANL Anulacion / ANL REF Tipo Integracion (app ANL)
 Traduccion Motivo Detalle Causa, Documentos Estaticos, Concepto*, Compañia Contraria = maestros
```

Las relaciones son implícitas (no declaradas en Appian); `SCA Eliminar Tablas BBDD` (10 nodos *Delete Records*) es
el único lugar donde se ve la "cascada" completa.

## 4.4 Vocabularios (constantes de lista)

| Constante | Valores |
|---|---|
| `SCA_TXT_ACCIONES` | AUTORIZACION [N2/N3], MECANIZAR [N2/N3], CONTRAANULAR [N2/N3], ACCIONES ADMINISTRATIVAS [N2/N3], IR A NIVEL 2, IR A NIVEL 3, FIN PROCESO |
| `SCA_TXT_ESTADO_SOLICITUD_PCA` | Registrada · En tramitación · Autorización / Mecanización / Contra anulación en curso · Contra anulación asignada · Acción administrativa en curso · Finalizada positivamente · Finalizada negativo con contra anulación · Finalizada no requerida contra anulación · Finalizado caducado · Caducada · Caducada negativa · Caduca sin documentación |
| `SCA_TXT_ESTADOS_SOLICITUD_CA` | Pendiente · Pendiente de Autorizar · Finalizada positivamente · Finalizado negativo con contraanulación · Finalizado autorizado (sí anulada) · Finalizada no autorizado (no anulada) · Finalizada no requerida contraanulación · Caducada · Cancelada |
| `SCA_TXT_ESTADOS_AUTORIZACION` | Pendiente · Aceptada · Rechazada · Caducada · Cancelada |
| `SCA_TXT_ESTADOS_MECANIZACION` | ANULACIÓN REALIZADA · ANULACIÓN PENDIENTE DE AUTORIZAR · MECANIZACIÓN INCOMPLETA · CERRADA SIN MECANIZAR · CADUCADA · Finalizada Caducada · Mecanización Enviada · Cerrada sin mecanizar por mecanización Rechazada · Cerrada sin mecanizar por fuera de plazo |
| `SCA_TXT_ESTADO_ARGUMENTO` | Pendiente · Positivo · Negativo |
| `SCA_TXT_ESTADO_SI_NO`, `SCA_TXT_ESTADO_ACTIVO_INACTIVO` | N/S · Activo/Inactivo |

Los estados se referencian por **índice** en el código (`cons!SCA_TXT_ACCIONES[7]`), por lo que el orden de las
listas es parte del contrato (ver riesgos en §6).

## 4.5 Documentos

68 documentos en 17 carpetas: plantillas DOCX de la carta firmada (`SCA DocxPDF` genera PDF), documentos estáticos
para argumentarios, iconos/imágenes de interfaz y ficheros temporales de subida a Documentum.
