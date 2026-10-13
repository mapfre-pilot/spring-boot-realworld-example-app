package com.mapfre.mavisa.wss372vencimientosmanuales.servicios;

import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J008GestionExpedientesVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.UtilidadesBeanAction;
import mapfre.wss000arquitect.accesodatos.Factoria.J000J000Conectable;
import mapfre.wss000arquitect.excepciones.J000J000Exception;
import mapfre.wss000arquitect.utilidades.J000J000Trazas;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

import java.math.BigDecimal;

// R&V Junio 2017 - CU011 - everis(RGL)
public class J372J011ServicioExpCoaseguroVenBean {

	private J372J011ServicioExpCoaseguroVenBean() {
		// TODO Constructor por defecto PRIVATE
	}

	private static final Logger OBJTRAZAS = J000J000Trazas.getLogger (J372J011ServicioExpCoaseguroVenBean.class);
	private static final String CRETORNO_S = "CRETORNO-S";
	private static final String GERROR_S = "GERROR-S";
	private static final String GNOMPROG_S = "GNOMPROG-S";
	private static final String NREGISTROS_S = "NREGISTROS-S";
	private static final String CUADRO_COASEGURO_S = "CUADRO-COASEGURO-S";
	private static final String ENBLANCO = "";

	public static J372J008GestionExpedientesVenPageBean ejecutaServicioCobol (
			J372J008GestionExpedientesVenPageBean eDatos)
			throws J372J001VencimientosException {

		final J372J003ServicioCobol OGESSERVICIO = new J372J003ServicioCobol ();
		final UtilidadesBeanAction UTIL = new UtilidadesBeanAction();

		J000J000Conectable oConector;
		J372J008GestionExpedientesVenPageBean sDatos = new J372J008GestionExpedientesVenPageBean();
		if (OBJTRAZAS.isDebugEnabled ()) {
			OBJTRAZAS.debug ("J372J010GestionExpCoaseguroVenPageBean: CARGA DE DATOS COBOL");
		}
		try {
			oConector = OGESSERVICIO.prepararLlamada ("IN372VENCIMIENTOSMANUALES",
					"B372VT12GestionExpCoaseguroVen", eDatos.getUsuario ());

			// Entrada
			oConector.setCampo ("OPERACION-E", "C1" ); // Unica operación posible C1.
			oConector.setCampo ("POLIZA-E", eDatos.getPolizaBloq3().toString ());
			oConector.setCampo ("SUBPOLIZA-E", eDatos.getSubpoliza().toString ());
			// logs de datos de entrada
			if (OBJTRAZAS.isDebugEnabled ()) {
				OBJTRAZAS.debug (" OPERACION = " + oConector.getCampo ("OPERACION-E"));
				OBJTRAZAS.debug (" POLIZA = " + oConector.getCampo ("POLIZA-E"));
				OBJTRAZAS.debug (" SUBPOLIZA = " + oConector.getCampo ("SUBPOLIZA-E"));
			}


			OBJTRAZAS.debug ("R&V [J372J011ServicioExpCoaseguroVenBean.ejecutaServicioCobol] voy a llamar al servicio ...");
			oConector.ejecutarServicio (); // Llamamos al servicio.
			OBJTRAZAS.debug ("R&V [J372J011ServicioExpCoaseguroVenBean.ejecutaServicioCobol] ... regreso de la llamada al servicio ...");

			final String sResultado = oConector.getCampo (CRETORNO_S);
			if (sResultado.compareTo ("00") == 0) {

				OBJTRAZAS.debug ("R&V [J372J011ServicioExpCoaseguroVenBean.ejecutaServicioCobol] el retorno es correcto y procedo a capturar los datos");
				final BigDecimal CERO = new BigDecimal("0.0");
				final BigDecimal CIEN = new BigDecimal("100.0");
				//inicializo
				sDatos.setCodCoasegur1(""); sDatos.setPorCoasegur1(CERO);sDatos.setImpCoasegur1(CERO);
				sDatos.setCodCoasegur2(""); sDatos.setPorCoasegur2(CERO);sDatos.setImpCoasegur2(CERO);
				sDatos.setCodCoasegur3(""); sDatos.setPorCoasegur3(CERO);sDatos.setImpCoasegur3(CERO);
				sDatos.setCodCoasegur4(""); sDatos.setPorCoasegur4(CERO);sDatos.setImpCoasegur4(CERO);
				sDatos.setCodCoasegur5(""); sDatos.setPorCoasegur5(CERO);sDatos.setImpCoasegur5(CERO);
				sDatos.setCodCoasegur6(""); sDatos.setPorCoasegur6(CERO);sDatos.setImpCoasegur6(CERO);

				BigDecimal importe = eDatos.getImpCapital();
				OBJTRAZAS.debug("R&V oConector.getCampo(NREGISTROS_S) = "+"'"+oConector.getCampo(NREGISTROS_S)+"'");
				Integer numeroCoaseguros = Integer.valueOf( oConector.getCampo(NREGISTROS_S) );
				if (numeroCoaseguros>0) {
					sDatos.setCodCoasegur1( oConector.getCampo("CODCOA-S") );
					sDatos.setPorCoasegur1( UTIL.numeroBig(oConector.getCampo("PORCOA-S") ) );
					//sDatos.setImpCoasegur1(sDatos.getPorCoasegur1().multiply(importe).divide(CIEN));// R&V Correccion 03/08/2017-1-3
					if (oConector.next(CUADRO_COASEGURO_S)){
						sDatos.setCodCoasegur2( oConector.getCampo("CODCOA-S") );
						sDatos.setPorCoasegur2( UTIL.numeroBig(oConector.getCampo("PORCOA-S") ) );
						//sDatos.setImpCoasegur2(sDatos.getPorCoasegur2().multiply(importe).divide(CIEN));// R&V Correccion 03/08/2017-1-3
						if (oConector.next(CUADRO_COASEGURO_S)){
							sDatos.setCodCoasegur3( oConector.getCampo("CODCOA-S") );
							sDatos.setPorCoasegur3( UTIL.numeroBig(oConector.getCampo("PORCOA-S") ) );
							//sDatos.setImpCoasegur3(sDatos.getPorCoasegur3().multiply(importe).divide(CIEN));// R&V Correccion 03/08/2017-1-3
							if (oConector.next(CUADRO_COASEGURO_S)){
								sDatos.setCodCoasegur4( oConector.getCampo("CODCOA-S") );
								sDatos.setPorCoasegur4( UTIL.numeroBig(oConector.getCampo("PORCOA-S") ) );
								//sDatos.setImpCoasegur4(sDatos.getPorCoasegur4().multiply(importe).divide(CIEN));// R&V Correccion 03/08/2017-1-3
								if (oConector.next(CUADRO_COASEGURO_S)){
									sDatos.setCodCoasegur5( oConector.getCampo("CODCOA-S") );
									sDatos.setPorCoasegur5( UTIL.numeroBig(oConector.getCampo("PORCOA-S") ) );
									//sDatos.setImpCoasegur5(sDatos.getPorCoasegur5().multiply(importe).divide(CIEN));// R&V Correccion 03/08/2017-1-3
									if (oConector.next(CUADRO_COASEGURO_S)){
										sDatos.setCodCoasegur6( oConector.getCampo("CODCOA-S") );
										sDatos.setPorCoasegur6( UTIL.numeroBig(oConector.getCampo("PORCOA-S") ) );
										//sDatos.setImpCoasegur6(sDatos.getPorCoasegur6().multiply(importe).divide(CIEN));// R&V Correccion 03/08/2017-1-3
									}
								}
							}
						}
					}
				}


				sDatos.setRetorno (oConector.getCampo (CRETORNO_S));
				sDatos.setDesRetorno (oConector.getCampo (GERROR_S));
				sDatos.setNomPrograma (oConector.getCampo (GNOMPROG_S));
				if (OBJTRAZAS.isDebugEnabled ()) {
					OBJTRAZAS.debug ("ServicioConsultaCarteraVenBean: GERROR-S= " + oConector.getCampo (GERROR_S));
					OBJTRAZAS.debug ("ServicioConsultaCarteraVenBean: CRETORNO-S= " + oConector.getCampo (CRETORNO_S));
					OBJTRAZAS.debug ("ServicioConsultaCarteraVenBean: GNOMPROG-S= "	+ oConector.getCampo (GNOMPROG_S));
				}
				OBJTRAZAS.debug ("R&V [J372J011ServicioExpCoaseguroVenBean.ejecutaServicioCobol] todo ha ido bien, retorno 'sDatos'");



/******************************  BLOQUE HARDODEADO ** INI ********************************
			final String sResultado = "00";
			if (true) {
				//inicializo
				final BigDecimal CERO = new BigDecimal("0.0");
				sDatos.setCodCoasegur1(""); sDatos.setPorCoasegur1(CERO);sDatos.setImpCoasegur1(CERO);
				sDatos.setCodCoasegur2(""); sDatos.setPorCoasegur2(CERO);sDatos.setImpCoasegur2(CERO);
				sDatos.setCodCoasegur3(""); sDatos.setPorCoasegur3(CERO);sDatos.setImpCoasegur3(CERO);
				sDatos.setCodCoasegur4(""); sDatos.setPorCoasegur4(CERO);sDatos.setImpCoasegur4(CERO);
				sDatos.setCodCoasegur5(""); sDatos.setPorCoasegur5(CERO);sDatos.setImpCoasegur5(CERO);
				sDatos.setCodCoasegur6(""); sDatos.setPorCoasegur6(CERO);sDatos.setImpCoasegur6(CERO);

				//hardcodeo
				sDatos.setCodCoasegur1("C0511"); sDatos.setPorCoasegur1(new BigDecimal("70.00"));
				sDatos.setCodCoasegur2("C0711"); sDatos.setPorCoasegur2(new BigDecimal("30.00"));
				sDatos.setCodCoasegur3("C9999"); sDatos.setPorCoasegur3(CERO);
				sDatos.setCodCoasegur4(""); sDatos.setPorCoasegur4(CERO);
				sDatos.setCodCoasegur5(""); sDatos.setPorCoasegur5(CERO);
				sDatos.setCodCoasegur6(""); sDatos.setPorCoasegur6(CERO);
				OBJTRAZAS.debug("R&V [J372J011ServicioExpCoaseguroVenBean.ejecutaServicioCobol] sDatos.getPorCoasegur1() = "+sDatos.getPorCoasegur1());

				// Ajuste para escribir los importes, de otra forma el formulario no muestra bien todos los valores
				final BigDecimal CIEN = new BigDecimal("100.0");
				BigDecimal importe = eDatos.getImpCapital() ;
				sDatos.setImpCoasegur1(sDatos.getPorCoasegur1().multiply(importe).divide(CIEN));
				sDatos.setImpCoasegur2(sDatos.getPorCoasegur2().multiply(importe).divide(CIEN));
				sDatos.setImpCoasegur3(sDatos.getPorCoasegur3().multiply(importe).divide(CIEN));
				sDatos.setImpCoasegur4(sDatos.getPorCoasegur4().multiply(importe).divide(CIEN));
				sDatos.setImpCoasegur5(sDatos.getPorCoasegur5().multiply(importe).divide(CIEN));
				sDatos.setImpCoasegur6(sDatos.getPorCoasegur6().multiply(importe).divide(CIEN));
				OBJTRAZAS.debug("R&V [J372J011ServicioExpCoaseguroVenBean.ejecutaServicioCobol] eDatos.getImpCapital() = "+eDatos.getImpCapital().toString());
				OBJTRAZAS.debug("R&V [J372J011ServicioExpCoaseguroVenBean.ejecutaServicioCobol] sDatos.getImpCoasegur1() = "+sDatos.getImpCoasegur1());


				sDatos.setRetorno ("00");
				sDatos.setDesRetorno ("Retorno hardcodeado");
				sDatos.setNomPrograma ("GNOMPROG-S");

*****************************  BLOQUE HARDODEADO ** FIN *********************************/


				return sDatos;
			} else {
				J372J001VencimientosException objException = new J372J001VencimientosException (
						J372J001VencimientosException.ERROR_NEGOCIO, ENBLANCO);
				final StringBuffer descripcion = new StringBuffer ("0");

				if (OBJTRAZAS.isEnabledFor (Level.ERROR)) {
					OBJTRAZAS.error ("ServicioConsultaCarteraVenBean: GERROR-S= " + oConector.getCampo (GERROR_S));
					OBJTRAZAS.error ("ServicioConsultaCarteraVenBean: CRETORNO-S= " + oConector.getCampo (CRETORNO_S));
					OBJTRAZAS.error ("ServicioConsultaCarteraVenBean: GNOMPROG-S= " + oConector.getCampo (GNOMPROG_S));
				}

				objException.setStMetodo ("ejecutaServicio()");
				objException.setStClase ("ServicioGestionVariablesBean");
				descripcion.append (sResultado).append (": ").append (oConector.getCampo (GERROR_S));
				objException.setStDescripcion (descripcion.toString ());
				objException.setStGNomProg (oConector.getCampo (GNOMPROG_S));
				objException.setStGError (oConector.getCampo (GERROR_S));
				objException.setStCRetorno (oConector.getCampo (CRETORNO_S));

				throw objException;
				}

		} catch (J372J001VencimientosException e) {
			throw e;
		} catch (J000J000Exception e) {
			OBJTRAZAS
					.error("J372J020GestionExpCoaseguroVenAction - Excepcion - Descripcion: "
							+ e.getLocalizedMessage());
			OBJTRAZAS
					.error("J372J020GestionExpCoaseguroVenAction - Excepcion - Localized:"
							+ e.getLocalizedMessage());
			OBJTRAZAS
					.error("J372J020GestionExpCoaseguroVenAction - Excepcion - Clase:"
							+ e.getClass ().toString ());
			J372J001VencimientosException objException = new J372J001VencimientosException (
					J372J001VencimientosException.ERROR_GENERICO_CICS, ENBLANCO);
			objException.setStDescripcion (e.getLocalizedMessage ());
			objException.setStClase (e.getClass ().toString ());
			objException.setStGNomProg (ENBLANCO);
			objException.setStGError ("Error Genérico CICS");
			objException.setStCRetorno (ENBLANCO);
			throw objException;
		}

	}

}
