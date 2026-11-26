# 84 · Aviso de oficinas en Autorización

En TEST, la solicitud Autemis `15789428` (tarea `1064`) seguía pendiente tras confirmar **Finalizar**. La consulta de oficinas para su NUUMA devolvía vacío: la validación impedía iniciar el CMD, pero el selector ocultaba el mensaje cuando no había ninguna oficina.

Se publicó **SCA2_AnulacionFueraNormaPrincipal v27** en Appian TEST. Único cambio sobre v26, justo antes de la botonera:

```sail
a!messageBanner(
  primaryText: "No se han podido obtener oficinas",
  backgroundColor: "WARN", highlightColor: "WARN", icon: "exclamation-triangle",
  showWhen: a!isNullOrEmpty(local!oficinas)
),
```

Se conservan la validación y el selector para varias oficinas. No se cambia ningún botón, proceso ni objeto de documentación.

**Comprobación en TEST:** la evaluación de la interfaz mostró el aviso para `15789428` / `1064` (sin oficinas), no lo mostró para `15789388` / `1028` (con oficinas) y conservó el selector en el segundo caso. No se pulsó **Finalizar** ni se consumieron pólizas. Esta incidencia es independiente de la tabla de compraventa, aún pendiente de BD.
