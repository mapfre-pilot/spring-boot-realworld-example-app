# Dudas pendientes para el analista tras la ronda 46 (10/11/2026)

Incluye las dudas que siguen abiertas de `63-dudas-analista-pendientes.md` y las nuevas de la ronda 46. Entre paréntesis va el número de la duda original, la sesión o el informe con el detalle. Mientras no haya respuesta, SCA2 sigue funcionando como se describe en cada punto.

## A. Decisiones pendientes sobre funcionalidad

1. **«Cancelada» al decir NO en Anulación/Suscripción (63-7):** el caso está explicado con la solicitud 15788815 (póliza 2002400195593) en `pruebas/r46-b-anl-nse-new.md`, 4.1.
   - `finalizarSolicitud` deja la solicitud en CORE en 5 y la mecanización en 4 («cerrada sin mecanizar»).
   - `finalizarContraAnulPca` con `mcaEstadoFinal=9` no hace nada, porque no hay ninguna contra anulación abierta.
   - ¿Aceptamos 5 + 4 o hay un servicio de CORE que deje la solicitud en 14?
2. **Fecha de anulación de Más Móvil:** el servicio propone «A VENCIMIENTO TRIMESTRAL» con fecha 02/01/2027, y SCA2 la muestra igual que SCA (póliza 0732500054802). ¿Es correcta o tendría que ser el 01/01/2027?
3. **Filtro «Estado» (63-22, R46-A N1):** la respuesta fue «Son los estados los que indican la etiqueta». Hoy el filtro va por estado interno y por eso, al elegir «Cancelada», salen filas con otras etiquetas.
   - Filtrar por la etiqueta obliga a calcularla en todas las solicitudes antes de paginar (unos 60 s con 441 solicitudes) o a guardar en SCA2 el estado de CORE y el de la mecanización.
   - ¿Se deja como está o se cambia?
4. **Combinaciones que «no pueden darse» (63-23, R46-A N3):** hay casos reales. ¿Qué etiqueta lleva cada uno?

   | Combinación | Ejemplo | Etiqueta actual |
   |---|---|---|
   | 2 + 2 | 15788155 | «Pendiente de Autorización» |
   | 2 + 4 | 15788166 | «Solicitud Pendiente» |
   | 3 + 1 | 15787942 | «Finalizado Contra Anulación Positiva» |

5. **2 + mecanización 1 + gestión 5 sin pasar por el nivel 2 (R46-A N4):** las solicitudes 15787772, 15787783 y 15788781 salen como «Póliza Anulada. Solicitud Pendiente Nivel 2». ¿Es correcto o debería salir «Finalizada. Anulación realizada»?
6. **Estado provisional mientras NSE/ANL termina (63-24):** está pendiente de verlo con negocio. Ahora la espera es de 5 minutos como máximo. ¿Se deja el estado provisional, se pone un estado tipo «En proceso» o se refresca la pantalla sola?
7. **COMPROBAR AHORA y la espera de respaldo de 90 s (63-28 y 63-30):** el funcionamiento está explicado en `pruebas/r46-c-alta-si24-detalle.md`, 3.7. Recomendamos mantener los 90 s. ¿Estáis de acuerdo?
8. **Aviso «cerca del vencimiento» (63-33):** está explicado en `pruebas/r46-c-alta-si24-detalle.md`, 3.8. Hoy no se ve ni en SCA ni en SCA2. ¿Se quiere mostrar?
9. **Si falla el SVA, ¿el argumento se queda abierto? (63-33):** está pendiente de verlo con negocio. Hoy queda pendiente.
10. **Retos y SVA (R46-D):** ¿también se aplican al ACEPTAR la enhorabuena, como los tréboles de TTQ? Hoy se aplican al ACEPTAR su propia pantalla.
11. **Reserva de prima (R46-D):** la he interpretado como el argumento económico (la inserción «Arg. Econ.» en `A2139022_MES` al finalizar en positivo). ¿Es eso o es otra operación?
12. **Texto del fallo del SVA (R46-D):** dice «No se han podido asignar **tréboles**…» aunque lo que falla es el SVA. Es el texto heredado de SCA. ¿Lo cambiamos por «el SVA»?
13. **Entrega parcial de tréboles (R46-D):** cuando Club va bien y TTQ falla, la contra anulación se finaliza en positivo y solo queda pendiente la grabación en TTQ, que se relanza desde `/errores`. ¿Os parece bien?
14. **Tipo de documento del enlace NSE (R46-C):** la cabecera solo trae el número, así que el tipo se deduce de su formato: NIE, NIF o CIF, y PAS si no encaja con ninguno. ¿Hay algún campo con el tipo de documento del cliente que debamos usar?
15. **Perfil control (`CE_MF_CONTROL`, R46-C):** sigue viendo el aviso Si24 y necesita la carta para FINALIZAR, igual que en SCA. ¿Es correcto?
16. **Consulta Vida (63-26, R46-C):** SCA2 pasa a la consulta de póliza Vida el número relleno a 13 dígitos, igual que SCA en el código. Según vuestra descripción tendría que pasarse con 10. ¿Cuál es el correcto?
17. **«Opción seleccionada en el componente» (R46-A N2):** CMP no guarda qué se ejecutó (Verti, Vencimiento o las dos) y por eso el campo sale «-». ¿Puede CMP devolverlo o guardarlo?

## B. Pendiente de otros equipos (AM, CORE o el propio analista)

18. **Alta Vida en CORE, error 4004 (63-2, 63-3 y 63-5):** el analista no tiene acceso al servicio de alta. Hace falta que AM/CORE diga qué dato falta y pase el log de PDTE-13377305 o PDTE-269184469. También hay que averiguar por qué aplicación se dio de alta la 15788717.
19. **`fecValidez` (63-4):** la respuesta quedó incompleta («Hay que ver qué»). ¿Hay que enviarla y con qué fecha?
20. **BAJAPRIM (63-35):** ¿podéis volver a darlo de alta? El mantenimiento de SCA da 403 a todos los usuarios de prueba.
21. **Entrada desde FDC/Decisora (63-39):** estamos esperando la URL que ibais a preparar para simular la entrada.
22. **Switch Verti (63-40):** estamos esperando los flags que abren el componente de inducción Verti.
23. **DDL de la caché de cabecera (63-38, R46-D):** ¿quién ejecuta `sql/63-r46d-ampliar-poliza-fechaultimosiniestro.sql` en TEST, PRE y PRO: un DBA o un despliegue con script de base de datos?

## C. Datos y accesos de prueba en TEST

24. **Una póliza que llegue a «Pendiente de Autorización» (nivel 00000005/06):** sirve para probar 4/5 + 2, 4/5 + 7 y el rechazo con mecanización 4. También hace falta un caso en que ANL no lance NSE ni NEW, para ver el error `ANL_EXCESO_TIEMPO` (63-14).
25. **Una póliza de acuerdo que llegue a la contra anulación de nivel 2 con fecha de anulación válida:** vencimiento futuro y dentro de los 18 meses de NEW. Sirve para Verti → inducción con Oficina.
26. **Pólizas para tréboles y SVA:**
   - Una con TU TE QUEDAS vigente.
   - Un cliente socio Club, para el SVA.
   - La póliza NO CLUB que ibais a buscar.
27. **Usuarios de TEST:**
   - Administrador SCA2, para `/errores` y `/gestiones-mantenimiento`. JJGONZ2 no tiene permiso.
   - Perfiles Central, CCC, GGE y Si24 front.

## D. Para Álvaro

28. **20 objetos SCA2 sin uso (63-37, `pruebas/r33-objetos-sin-uso-verificados.md`):** ¿se borran? Por ahora no se ha borrado nada.

## Nota

La anulación fuera de norma ya no es una duda. Con el motivo, detalle y causa «Decisión de la entidad / Decisión de la entidad / Anulación fuera de norma», se probará en la próxima ronda con una póliza de Autos y otra de Hogar.
