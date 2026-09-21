# 8. Limitaciones del análisis

- **Análisis estático**: se han leído definiciones de diseño (SAIL, configuración de
  procesos, integraciones, seguridad) vía MCP Appian en modo lectura. **No** se ha ejecutado
  la aplicación ni se han validado los flujos en la UI. Las descripciones de flujo son
  inferencias razonadas a partir del código y de los nombres/descripciones de los objetos.
- **Entorno**: solo DEV (`mapfrespain-dev`). Miembros de grupos, valores de constantes y
  sistemas conectados pueden diferir en PRE/PRO.
- **Web APIs**: el MCP no devolvió el cuerpo SAIL de `TVA InicioTarificadorVidaAhorro` ni
  de `TVA InicioSimuladorRentas`; su lógica se ha deducido de las reglas de respuesta y del
  proceso de inicio.
- **Constantes**: `listApplicationObjects` reportó 0 constantes (se obtuvieron 209 con
  `listConstants`); una no pudo recuperarse
  (`TVA_LITERALES_PREFIJO_DISCREPANCIA_VALOR_VIDA`). Los **valores** de las constantes se
  han usado solo para el análisis; no se listan aquí.
- **CDT / tipos de datos**: no se han volcado las definiciones de los CDT (`TVA_Sesion`,
  `TVA_Traza`, etc.); los campos citados provienen de su uso en SAIL.
- **Data store**: no se ha inspeccionado la entidad `TVA_ENT_TRAZA` ni el esquema
  PostgreSQL; se asume una única tabla de trazas a partir de las consultas.
- **Seguridad**: 42 de 43 mapas de roles (falló la carpeta `TVA Modelos de procesos`).
  No se han consultado los dependientes de reglas ni interfaces.
- **Dependientes de MISV**: hay un dependiente no identificado
  (`79f2b309-…-ac8e655122b4`) fuera del inventario TVA.
- **Referencia de la URL original**: el identificador `USkp6Q-sQmywLU9Ua9FTBQ` de la URL
  proporcionada devolvió HTTP 403 vía MCP; la aplicación se localizó por nombre
  (`e922a3b8-7bb8-4c61-b926-e4ee365b75fc`). Conviene confirmar que se trata de la misma
  aplicación.
- **Datos personales**: no se incluyen en esta documentación nombres de usuarios miembros
  de grupos ni contenidos de los mocks; solo recuentos.
- **Volcado completo**: los ~560 artefactos JSON/SAIL recuperados no se han versionado en
  este repositorio (contienen datos de mocks y configuración interna); están disponibles
  bajo petición para ampliar la documentación.
