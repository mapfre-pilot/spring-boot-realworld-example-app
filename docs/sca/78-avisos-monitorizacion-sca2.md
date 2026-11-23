# 78 · SCA2 — Avisos de monitorización

## Resultado en TEST

En **Monitorear → Panel de estado → Orientación de diseño de Appian** se verificó la desaparición del aviso «Variable de proceso no utilizada» de **SCA2 CMD MecanizarNSE**. En la versión 10.0 se retiró `estadoFinal`: era una variable interna sin valor inicial, sin referencias en el modelo y no formaba parte de los parámetros de entrada. Los informes de proceso de la aplicación revisados no tenían este modelo como contexto.

La comparación con la versión publicada anterior únicamente mostró la retirada de esa variable. Se conservaron los 31 nodos, sus conexiones y los parámetros `idSolicitud`, `relanzado` e `idTarea`. La validación estructural no indicó errores ni advertencias. El panel sigue mostrando «Demasiados nodos» para este modelo. No se lanzaron instancias de mecanización para la comprobación.

Los tres modelos revisados ya eliminaban las instancias completadas al cabo de un día y enviaban las alertas de error al grupo **SCA2 Alertas**. Se mantuvo un día tal como se solicitó, aunque el validador recomienda cero días para modelos sin tareas atendidas. No se modificaron rutas ni se aplicaron cambios en la base de datos.

## Pendientes de decisión

| Objeto | Aviso | Motivo y siguiente paso |
| --- | --- | --- |
| SCA2 CMD Mecanizar | Variable de proceso no utilizada | `inducirVerti` no se lee dentro del modelo, pero es un parámetro y la interfaz que inicia la mecanización aún lo envía. No se elimina sin aprobar y verificar la retirada del contrato en los llamadores. |
| SCA2 CMD Mecanizar | Demasiados nodos | 46 nodos; el panel de TEST recomienda un máximo de 30. Evaluar la extracción del tramo de espera y actualización de ANL, con sus reintentos y salidas de éxito/error, sin mover la inducción. La extracción exige comprobar el encadenamiento y quién ejecuta cada paso. |
| SCA2 CMD MecanizarNSE | Demasiados nodos | 31 nodos. Un posible corte es extraer la creación de la autorización y el registro de esa llamada a un único subproceso síncrono, conservando los datos de respuesta y la rama de error. No se aplicó: cambia el límite de instancia y puede afectar a identidad, transacciones o fallos. |
| SCA2 Batch Mecanizacion NSE | Puerta con múltiples flujos entrantes | La entrada inicial y el retorno del bucle confluyen en «¿Quedan solicitudes?». Appian recomienda un nodo de script que fusione ambas entradas antes de la puerta. Eso cambia la ejecución del bucle si se habilita el batch; no se aplicó ni se activó el batch. |
| SCA2 Tarea Hist, Solicitud Hist, Transicion Hist, Llamada Servicio Hist, Error Hist, Niveles Cobertura Autos Hist, Datos Solicitud Hist y Otras Solicitudes Cabecera Hist | Ciertas propiedades no se utilizan | El aviso indica que el acceso directo no utiliza todas las propiedades de la conexión. Ese acceso es intencionado (véase [el diseño de históricos](71-diseno-tablas-vivas-historicas-sca2.md)); no se cambió la sincronización ni la conexión. |

El sitio piloto, su grupo, las copias del piloto y el proceso Decidir quedaron fuera de esta intervención. El panel también mostró recomendaciones adicionales no visibles en la captura; no se modificaron esos objetos.
