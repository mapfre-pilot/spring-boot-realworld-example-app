# Coordinación ronda 43 — póliza Vida: cabecera y motivo/detalle/causa (7.º Análisis SCA2)

Origen: documento «Análisis SCA2» de los analistas (31/10), prueba con la póliza Vida **0005912432** (CreciVida, ramo 101, línea de negocio Vida). Una sola sesión hija (R43-A).

## Puntos del analista (literal)
1. «En la póliza Vida 0005912432 observo que a pesar de haberla buscado correctamente en la consulta de vida […] No ha rellenado correctamente la cabecera. Esta sería la cabecera correcta, hay temas funcionales y técnicos que no está haciendo».
   - SCA2 (`img/r43-analista-cabecera-vida-sca2.png`): Plan de pago «-», **Tipo productor «-»**, **Clave producción «/»**.
   - Correcta (`img/r43-analista-cabecera-vida-correcta.png`): **Tipo productor «AG»**, **Clave producción «105333 / 5324209»**. El resto de campos coincide en la captura, pero «hay temas funcionales y técnicos que no está haciendo»: revisar toda la carga de la cabecera Vida (pestañas Datos cliente, Datos póliza, Otras sol. Anulación, Datos contacto; enlace GESVIDA de R38) frente a SCA.
2. «Al tiempo está cogiendo el motivo detalle y causa de Autos, pero no el de vida (que es línea de negocio 3). Que tiene solo decisión del cliente y además tiene otras causas distintas» (`img/r43-analista-motivo-vida.png`: SCA2 ofrece DECISION DE CLIENTE / DECISION DE LA ENTIDAD / DESAPARICION DEL RIESGO).

## R43-A — objetos propios
Cabecera: `SCA2_obtenerDatosCabecera`, `SCA2_obtenerDatosCabeceraLive` y sus reglas/integraciones SCA2 de Vida, la caché de cabecera (`SCA2_construirFilaCacheCabecera`, `SCA2_renovarCacheCabecera`) y las interfaces SCA2 de la cabecera. Alta: `SCA2_AltaSolicitudPage`, `SCA2_AltaSolicitudAnulacionPopUp`, `SCA2_construirContextoAlta` y las reglas/consultas SCA2 de motivo, detalle y causa. Constantes nuevas `SCA2_*`.
No tocar los objetos de la ronda 42 salvo lo imprescindible (espera síncrona del alta: `SCA2_AltaSolicitudPage` v47); si se edita, conservar ese comportamiento.

## Pólizas
- `0005912432` (del analista): sólo consulta y cabecera (sin GUARDAR), para comparar SCA y SCA2.
- Para altas completas: pólizas Vida nuevas localizadas por la propia sesión (el fichero de pólizas no tiene Vida), anotadas en `polizas/REGISTRO.md` con «R43-A». No usar 0732400126663.

## Reglas
- Sólo objetos SCA2. Prohibido modificar SCA/SCAC/CORE/CMP/NSE/ANL/SGD. No tocar solicitudes antiguas.
- Lectura viva → backup JSON → cambio mínimo → relectura y comparación. Literales de negocio en constantes. Paridad con SCA (leer cómo lo resuelve SCA para línea de negocio 3).

## Objetos en edición
| Objeto | Sesión | Estado |
|---|---|---|
| `SCA2_getCodAgenteVida` (regla) | R43-A | en edición |
| `SCA2_AltaSolicitudPage` (interfaz, v47) | R43-A | en edición |
| Constantes nuevas `SCA2_INT_LINEA_NEGOCIO_VIDA` | R43-A | en edición |
