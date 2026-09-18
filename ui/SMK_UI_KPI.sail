a!cardLayout(
  contents: a!richTextDisplayField(
    labelPosition: "COLLAPSED",
    align: "CENTER",
    value: {
      a!richTextIcon(
        icon: ri!icono,
        color: ri!color,
        size: "MEDIUM_PLUS"
      ),
      char(10),
      a!richTextItem(
        text: ri!valor,
        color: ri!color,
        size: "LARGE_PLUS",
        style: "STRONG"
      ),
      char(10),
      a!richTextItem(
        text: ri!etiqueta,
        color: "SECONDARY",
        size: "SMALL",
        style: "EMPHASIS"
      )
    }
  ),
  shape: "ROUNDED",
  showBorder: true,
  showShadow: false,
  height: "AUTO",
  padding: "STANDARD",
  marginBelow: "STANDARD"
)
