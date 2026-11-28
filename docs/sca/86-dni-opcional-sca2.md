# 86 · DNI configurable en SCA2

En Appian TEST, `SCA2_BOOL_DNI_OBLIGATORIO` es una constante booleana específica del entorno, con valor inicial `false`. Se puede modificar en el catálogo de variables de aplicación, grupo **Documentos**, como `DNI_OBLIGATORIO`. Los valores admitidos son `true` y `false`.

| Pantalla | Con `false` | Con `true` |
|---|---|---|
| Acciones administrativas | Se puede finalizar sin DNI si se adjunta otro de los documentos admitidos. | Se requiere el otro documento y el DNI (tipo 7). |
| Contra anulación | Se conserva el criterio anterior de carta firmada y argumentos. | Se añade el DNI solo en la vía en que se exige la carta: documentación visible, carta no impresa y perfil sin exención. |
| Autorización | Se conserva el criterio anterior de documentación entregada. | Se añade el DNI al criterio anterior de documentación entregada. |

No cambian las vías de no entrega, los argumentos, los límites de tamaño ni la fecha de disponibilidad del vehículo. No se modificaron SCA, SCAC, CORE ni el componente compartido `SCA2_AccionesAdministrativasDocumentacion`.

## Paquete de despliegue de SCA2

Incluir los seis objetos siguientes; las versiones indicadas son las verificadas en TEST:

| Tipo | Objeto | Versión |
|---|---|---|
| Constante | `SCA2_BOOL_DNI_OBLIGATORIO` | 2 |
| Regla de expresión | `SCA2_obtenerVariablesAplicacion` | 3 |
| Modelo de proceso | `SCA2 CMD Guardar Variable de Aplicación` | 5.0 (publicada) |
| Interfaz | `SCA2_AccionesAdministrativasPrincipal` | 29 |
| Interfaz | `SCA2_ContraAnulacionOpciones` | 88 |
| Interfaz | `SCA2_AnulacionFueraNormaPrincipal` | 28 |

Para habilitar el DNI opcional en el entorno de destino, confirmar que la constante queda en `false`; si se establece al importar, declararlo en el archivo de personalización de importación. Para restaurar la exigencia de DNI en las tres pantallas, cambiar el parámetro a `true` en ese entorno.

## Verificación sin envío

Se confirmó en Designer que la marca **Específico del entorno** seguía activa tras recargar. Se leyeron las versiones de TEST y se evaluaron localmente las guardas publicadas con ambos valores, incluidas las exenciones y el DNI ya adjunto o recién cargado. `testRule` verificó que el validador admite ambos booleanos, detecta que `false` coincide con el valor actual y rechaza `N`. No se inició el modelo ni se finalizó ninguna solicitud de prueba.
