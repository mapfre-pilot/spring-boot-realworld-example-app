/* R53: aviso que se muestra en el site cuando CORE no responde */
a!cardLayout(
  contents: {
    a!richTextDisplayField(
      labelPosition: "COLLAPSED",
      value: {
        a!richTextIcon(icon: "exclamation-triangle", color: "#B45F06", size: "MEDIUM"),
        "  ",
        a!richTextItem(
          text: a!defaultValue(ri!mensaje, cons!SCA2_TXT_CORE_NO_DISPONIBLE),
          style: "STRONG",
          size: "MEDIUM"
        )
      }
    )
  },
  style: "WARN",
  showBorder: true,
  marginBelow: "STANDARD"
)
