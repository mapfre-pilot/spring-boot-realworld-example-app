# 87 · URLs de navegación en Gestiones de mantenimiento

En **Gestiones de mantenimiento → Variables de la aplicación** de SCA2, los administradores pueden editar las 14 URLs de navegación sin desplegar. Se mantienen como constantes específicas del entorno; en TEST conservan su valor anterior. Los [cinco destinos de integración](85-urls-por-entorno.md#qué-configurar) siguen configurándose por entorno y quedan fuera de la pantalla. El ICF y el SQL de producción no cambian.

| Grupo del editor | Constantes (prefijo `SCA2_`) |
|---|---|
| URLs · Póliza y cliente | `FECHAULTIMOSINIESTRO_URL`, `FICHAAMPLIADA_URL`, `FORMAPAGO_URL`, `NUMPOLIZAVIDA_URL`, `NUMPOLIZA_URL`, `PLANPAGO_URL` |
| URLs · Argumentos | `TXT_LINK_GESVIDA`, `TXT_LINK_GESVIDA_CABECERA`, `TXT_RUTAS_ARGUMENTOS_VAL`, `TXT_URL_NSE_GUIADO` |
| URLs · Enlaces del pie | `TXT_URL_GESCOMWEB`, `TXT_URL_GESTIONCOMPETENCIAS`, `TXT_URL_LOCALIZADOROFICINAS`, `TXT_URL_NSE` |

El editor acepta HTTP y HTTPS y conserva literalmente los parámetros, fragmentos y marcadores. Al editar rutas de argumentos, escribir las diez URLs en su orden original, una por línea; wAutemis es la segunda. Los saltos de línea son solo el formato del editor: el proceso guarda una lista de texto. Para editar esta lista mediante el ICF se mantiene, en cambio, el [formato del paquete](85-urls-por-entorno.md#desplegar-el-paquete). La pantalla no comprueba que el destino exista: antes de guardar, confirmar el enlace para el entorno y conservar los separadores o marcadores de los que depende el consumidor.

Para NSE guiado, indicar solo la URL base, sin consulta (`?`) ni fragmento (`#`): SCA2 añade los parámetros al construir el enlace.

## Implementación en Appian TEST

- [Diff SAIL](sail/87-urls-navegacion-mantenimiento.patch): `SCA2_obtenerVariablesAplicacion`, `SCA2_validarCambioVariableAplicacion` y `SCA2_GestionVariablesAplicacion`.
- **SCA2 CMD Guardar Variable de Aplicación**: sobre la versión con DNI opcional, se añade una rama `Update Constant` por código de navegación, con UUID fijo, ejecución como iniciador y nueva versión. Se conservan la comprobación de administrador, la salida sin escritura si el valor se rechaza o no cambia, la limpieza al día y las alertas existentes. El historial se consulta en **Appian Designer → constante → Versiones**.
- Los cuatro objetos están en **SCA2 Caducidad TM 27-11-2026**. No se cambiaron los consumidores, ni se añadieron tablas, filas o scripts al paquete.

## Verificación sin pólizas

En TEST se comprobó el catálogo, la validación de los valores vigentes y el rechazo de entradas no válidas. Se probó el guardado nativo de una URL simple y de la lista de diez URLs: se cambió únicamente la capitalización del host, se restauró el valor original por el mismo proceso y se comprobó el historial en ambos casos. Se conservó la rama de guardado de `DNI_OBLIGATORIO`. No se accedió a los destinos ni se desplegó en otro entorno.
