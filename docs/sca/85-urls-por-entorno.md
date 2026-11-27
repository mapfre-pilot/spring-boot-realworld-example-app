# 85 · URLs de SCA2 por entorno

En Appian TEST se marcaron 14 constantes como **Específico del entorno** y se incluyeron otras 5 que ya tenían la marca. Se conservaron los valores y los tipos de las 19; no se modificaron objetos de SCA, SCAC o CORE.

En `SCA2_GetUrlArgumento` y `SCA2_IF_ArgumentoAplicacionUrl` se sustituye la ruta fija del NSE guiado por `SCA2_TXT_URL_NSE_GUIADO`, conservando todos los parámetros. La interfaz toma la ruta wAutemis de la segunda posición de `SCA2_TXT_RUTAS_ARGUMENTOS_VAL`, igual que la regla; en TEST ambas sustituciones producen la misma URL que antes. El [diff SAIL](sail/85-urls-por-entorno.patch) recoge los dos cambios.

## Qué configurar

| Uso | Constantes incluidas |
|---|---|
| Póliza, recibos, cliente y plan de pagos | `SCA2_FECHAULTIMOSINIESTRO_URL`, `SCA2_FICHAAMPLIADA_URL`, `SCA2_FORMAPAGO_URL`, `SCA2_NUMPOLIZA_URL`, `SCA2_NUMPOLIZAVIDA_URL`, `SCA2_PLANPAGO_URL` |
| Gesvida y enlaces de argumentos | `SCA2_TXT_LINK_GESVIDA`, `SCA2_TXT_LINK_GESVIDA_CABECERA`, `SCA2_TXT_RUTAS_ARGUMENTOS_VAL`, `SCA2_TXT_URL_NSE_GUIADO` |
| Enlaces internos del pie | `SCA2_TXT_URL_GESCOMWEB`, `SCA2_TXT_URL_GESTIONCOMPETENCIAS`, `SCA2_TXT_URL_LOCALIZADOROFICINAS`, `SCA2_TXT_URL_NSE` |
| Integraciones | `SCA2_WEBSERVICES_URL`, `SCA2_HOST_APICLIENTS`, `SCA2_HOST_CORE7`, `SCA2_HOST_ESB`, `SCA2_HOST_SOA7` |

Sin cambios: los enlaces al portal de documentación y al sitio público Tecuidamos (sin indicios de variar por entorno), los alias/rutas relativas y los namespaces SOAP. Las URLs de sistemas conectados se configuran en sus propios objetos; no se cambiaron sistemas compartidos como CMP LoopBack y CMP API Clients.

## Desplegar el paquete

1. Exportar únicamente **SCA2 Caducidad TM 27-11-2026** (`230be394-bb39-4d0c-bb48-e7966391839f`) y descargar su plantilla de personalización de importación (ICF). Las [claves de URL sin valores](sca2-urls-por-entorno.properties) son las que generó Appian para ese paquete.
2. En el único ICF del destino, activar las claves que se deban establecer y escribir valores confirmados para ese entorno. En una primera instalación, completar las 19: el ZIP no contiene los valores de constantes específicas del entorno. Si ya existen y tienen el valor adecuado, dejar las propiedades comentadas para conservarlo. No activar claves vacías ni copiar valores de TEST sin validarlos.
3. Conservar esquema, parámetros, delimitadores y barras finales cuando el consumidor los use. Para `SCA2_TXT_RUTAS_ARGUMENTOS_VAL`, mantener las diez posiciones y separarlas con punto y coma; la posición 2 corresponde a wAutemis. Para `SCA2_TXT_URL_NSE_GUIADO`, no añadir los parámetros que agrega SAIL.
4. Comprobar los enlaces de catálogo en el origen que use el destino (Aurora o CORE). En TEST, `SCA2 Cat Tipo Argumento.txtUrlArg` y `SCA2 Cat Valor Concepto.valorConcepto` (concepto `URL`) contienen enlaces de Gesvida y Club MAPFRE con hosts de preproducción. Son datos: el ICF no los sustituye. No se modificaron catálogos ni se añadió SQL al paquete.
5. Inspeccionar el paquete con el ICF y, tras importar, revisar los valores en Designer y comprobar los enlaces desde el destino. Appian no deduce ni valida las URLs correctas de PROD.

## Verificación en TEST

El ZIP final mantiene los 10 objetos anteriores e incluye las 19 constantes y los dos consumidores SAIL. El ICF generado contiene las 19 claves; por separado, se confirmó que los valores de TEST no cambiaron. La regla y la interfaz devolvieron los enlaces esperados para NSE Hogar, NSE Autos y wAutemis con datos sintéticos, sin abrir los enlaces. No se importó en otro entorno ni se verificaron valores de PROD.
