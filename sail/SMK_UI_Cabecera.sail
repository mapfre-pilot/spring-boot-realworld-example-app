a!cardLayout(
  contents: a!richTextDisplayField(
    labelPosition: "COLLAPSED",
    value: {
      a!richTextItem(
        text: {
          a!richTextIcon(
            icon: ri!icono
          )
        },
        color: cons!SMK_COLOR_BLANCO,
        size: "MEDIUM_PLUS",
        style: "STRONG"
      ),
      char(10),
      a!richTextItem(
        text: ri!titulo,
        color: cons!SMK_COLOR_BLANCO,
        size: "MEDIUM_PLUS",
        style: "STRONG"
      ),
      char(10),
      a!richTextItem(
        text: ri!subtitulo,
        color: cons!SMK_COLOR_BLANCO,
        size: "SMALL",
        style: "STRONG"
      )
    }
  ),
  marginBelow: "NONE",
  height: "AUTO",
  style: cons!SMK_COLOR_ROJO,
  showShadow: true,
  showBorder: true,
  padding: "STANDARD",
  shape: "SQUARED"
)
