# Ronda 35 — sexto «Análisis SCA2» (analistas, 29/10/2026): clasificación y reparto

Origen: «Analisis SCA2.docx» (6.º) + `polizasDevin.csv` (970.823 pólizas para pruebas; ver `pruebas/polizas/`).

| # | Punto del analista | Tipo | Qué hay que hacer | Quién |
|---|---|---|---|---|
| 1 | Alta (prueba TTQ con póliza Hogar 0732400126663): tras ACEPTAR, «decidir acción» tarda >30 s, no avanza y **vuelve a la pantalla de Alta**; por detrás la solicitud sí se ha creado y al volver a GUARDAR salta una excepción «ya existe una solicitud en curso» | Error | (a) Si la decisión tarda: mostrar aviso «está tardando un poco más en generar la siguiente gestión, espere» y **ampliar la espera 15 s** (repetible) hasta que exista la siguiente gestión; nunca volver al alta en blanco. (b) Si el usuario vuelve a GUARDAR con una solicitud en vuelo para esa póliza: mensaje «existe una solicitud en curso para la póliza, ¿quiere consultarla?» → navegar al detalle de esa solicitud con RETOMAR (si el rol lo permite) → la CA. Sin excepción. | R35-A |
| 2 | Carga de documentos: permitir imágenes además de PDF (como en la carga de DNI) | Necesidad | Aceptar los mismos formatos de imagen que la carga de DNI en la carga de documentos de la solicitud; comprobar que SGD/visor los acepta. | R35-B |
| 3 | Tréboles: en el detalle, el argumento positivo muestra los 20 ofrecidos pero no los 17 aplicados | Necesidad | Al aplicar tréboles (ACEPTAR de la pantalla TTQ, R34-A), guardar en **observaciones** del argumento «Se han aplicado Y tréboles al cliente» y mostrarlo en la consulta de la solicitud. | R35-B |

| 4 | Los documentos mostrados (PDF de oposición a la renovación, imagen del DNI) salen sobredimensionados | Necesidad | Adaptar el visor al tamaño real del documento (PDF e imágenes) sin sobredimensionar. Añadido el 29/10 por el usuario. | R35-B |

Coordinación y pólizas: `pruebas/coordinacion-ronda35.md`, `pruebas/polizas/` (bloques por sesión y registro de uso). Informes: `pruebas/r35-a-espera-decision-solicitud-en-curso.md`, `pruebas/r35-b-documentos-imagen-observaciones-treboles.md`.
