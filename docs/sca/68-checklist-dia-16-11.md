# Checklist del 16/11/2026 (SCA2, Appian TEST)

## Hecho hoy

- [x] **R49-A · Bloqueo tras ACEPTAR en el alta:** cuando falla el servicio de decisión, SCA2 muestra el error y vuelve al buscador, como SCA (`SCA2_AltaSolicitudPage` v55).
- [x] **R49-B · Buscador:** completa el número de póliza con ceros y quita espacios, como SCA (`SCA2_Buscador` v37).
- [x] **R49-E · Error `repeat` −1 y «Tipo Póliza» vacío:** corregido (`SCA2_obtenerTipoPoliza` v3, `SCA2_Buscador` v39).
- [x] **R49-C · Póliza renovada:** se puede grabar si solo avisa de «fecha fuera de la situación actual», como SCA (`SCA2_AltaSolicitudPage` v56). El resto de puntos ya se comportaba igual que en SCA.
- [x] **R49-D · Producto vacío en Verti/Hogar:** se guarda AU01/AU02/HG01 (`SCA2_construirContextoAlta` v19).
- [x] **R49-D · CANCELAR tras POSITIVO:** la contra anulación ya no se cierra como Positiva (`SCA2_ContraAnulacionOpciones` v80).
- [x] **Listado de dudas:** 78 dudas en `67-dudas-pendientes-consolidado.md`.
- [x] **R50-A · Caché de cabecera:** no crea filas repetidas; se han borrado 5 duplicadas y la fecha del último siniestro admite 1000 caracteres.
- [x] **R50-B · Tareas y errores:** no se crea una segunda tarea pendiente del mismo tipo ni un error repetido; las observaciones se recortan a 255 en el alta y en POSPONER.
- [x] **R50-C · Limpieza:** 9 objetos sin uso borrados (con copia); 6 reglas metidas en la aplicación SCA2; error 215 relanzado y resuelto.
- [x] **R51-A · MEJ-01/02:** los tréboles se dan antes de la enhorabuena, con mensaje nuevo para cliente no Club y enlace a Club Mapfre (`SCA2_ContraAnulacionSGO` v6). Probado con cliente Club.
- [x] **R51-B · MEJ-03/04/05/06:** textos nuevos en TEST; la pantalla de Verti queda solo con «Los datos se han guardado correctamente.».
- [x] **Pruebas:** todo probado en TEST con solicitudes nuevas; sin errores nuevos.

## Pendiente de ti

- [ ] Ejecutar `sql/70-r50a-c1-unique-cache-cabecera.sql` y `sql/71-r50b-tareas-pendientes-fecimpresion.sql` en TEST y pasar los JSON.
- [ ] Republicar en Designer, sin cambios, los procesos `SCA2 CMD` (empezando por Alta y Decidir).
- [ ] ¿Cancelo las tareas repetidas 375 y 711–714 (solicitudes del analista) para poder crear la UNIQUE de tareas?

## Dudas para el analista / negocio

### Mensajes (R51)
- [ ] Erratas: mensaje 02 («club mapfre .», falta la «y») y 04 («la documento»). ¿Las corregimos? ¿Punto final en 03, 05 y 06?
- [ ] Enhorabuena tras dar tréboles: ¿quitamos el CANCELAR o avisamos de que ya están dados?
- [ ] Club OK + Te Cuidamos (TTQ) KO: ¿se deja el aviso actual y luego la enhorabuena, o se trata como «otro error»?
- [ ] Enlace Club Mapfre: ¿es correcta la URL webclub20 + NIF (en TEST, `wportalinterno.pre.mapfre.net`)?
- [ ] Aviso de SVA a un cliente no Club: ¿le ponemos también el enlace?
- [ ] «Salta al SI24 en Nivel 2»: ¿hay algún nivel 2 que no lleve Si24?
- [ ] 04 con una causa que no exige contrato: ahora sale «documentación requerida». ¿Correcto?
- [ ] ¿Quitar de verdad la pantalla de Verti? Supone reorganizar el Detalle.

### Alta y buscador (R49)
- [ ] Error del servicio de decisión: ¿texto más claro que el de SCA? ¿Aviso al abrir el detalle? ¿Tratar igual el estado `ERROR`?
- [ ] La póliza queda bloqueada hasta relanzar desde `/errores`: ¿es lo esperado?
- [ ] Renovada «a fecha»: ¿se puede grabar, como en SCA?
- [ ] Espacio al final del número de póliza (avisa de más de 13 caracteres): ¿se deja?
- [ ] ¿«Tipo Póliza» con NO VIDA ya elegido, como SCA?
- [ ] Error de SCA en `sca_datoscabecera` al volver: ¿se avisa a su equipo?

### Gestión y datos (R49)
- [ ] 0002729391736: ¿la marca `MCA_PENDIENTE` está colgada en CORE?
- [ ] 15788901: ¿qué pasos se hicieron al dar el TTQ? ¿Recargamos su argumentario o la retoma él?
- [ ] ¿Hay que pulsar FINALIZAR después de dar tréboles? (en SCA, sí)
- [ ] Solicitudes 15789153/15789154 (positivas por el fallo antiguo): ¿se cancelan?
- [ ] Autemis: ¿guardamos el producto AU01/AU02 como SCA en vez del código de TRON?
- [ ] 2002300300497: CORE la tiene cerrada y SCA2 en curso (15788003/15788040). ¿Se cierran en SCA2?

### Técnicas que cambian el funcionamiento
- [ ] «Actualizar datos» de la cabecera: ¿que vuelva a consultar los servicios en cada pulsación?
- [ ] `SCA2 CMD BarridoCaducidad`: ¿se borra o se programa un barrido nocturno?
- [ ] `SCA2 Batch Mecanizacion NSE`: ¿se borra o se deja como batch, como en SCA?

### Datos de prueba que necesitamos
- [ ] Pólizas con «TU TE QUEDAS…»: una de socio Club y otra que no lo sea, sin solicitud en curso.
- [ ] Cliente sin Te Cuidamos con argumento de tréboles.
- [ ] Póliza de flota (acuerdo 20, 33 o 35) sin solicitud en curso.
- [ ] Póliza Vida que se pueda dar de alta en TEST (o el dato que falta en CORE).
- [ ] Clientes de 2002600074290/272/293/304 en la API de Clientes de TEST.
