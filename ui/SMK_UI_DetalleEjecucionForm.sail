a!formLayout(
  contents: if(
    a!isNullOrEmpty(ri!ejecucionId),
    a!richTextDisplayField(labelPosition: "COLLAPSED", value: a!richTextItem(text: "Ejecución no disponible.", color: "SECONDARY")),
    rule!SMK_UI_DetalleEjecucion(ejecucionId: ri!ejecucionId)
  ),
  buttons: a!buttonLayout(
    secondaryButtons: a!buttonWidget(label: "Cerrar", icon: "times", style: "LINK", submit: true, validate: false)
  )
)
