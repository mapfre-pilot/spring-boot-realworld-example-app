package com.mapfre.mavisa.wss372vencimientosmanuales.servicios;

import java.math.BigDecimal;
import java.util.Calendar;
import java.util.GregorianCalendar;

import mapfre.wss000arquitect.accesodatos.Factoria.J000J000Conectable;
import mapfre.wss000arquitect.excepciones.J000J000Exception;
import mapfre.wss000arquitect.utilidades.J000J000Trazas;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J004GestionVariablesVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.UtilidadesBeanAction;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;

/**
 * @author everis
 * @version 1.0 Versión inicial Clase de negocio. Contiene los metodos
 *          necesarios para ejecutar los servicios cobol de carga inicial y de
 *          calculo
 * 
 */
public class J372J006ServicioGestionVariablesBean {

	/**
	 * Constructor por defecto PRIVATE
	 * 
	 */
	private J372J006ServicioGestionVariablesBean () {
		// TODO Constructor por defecto PRIVATE
	}

	/**
	 * objTrazas nos mostraralas trazas de código
	 */
	private static final Logger OBJTRAZAS = J000J000Trazas.getLogger ( J372J006ServicioGestionVariablesBean.class );

	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inializacion de la variable CRETORNO_S valor CRETORNO-S
	 */
	private static final String CRETORNO_S = "CRETORNO-S";

	/**
	 * Inializacion de la variable GERROR_S valor GERROR-S
	 */
	private static final String GERROR_S = "GERROR-S";

	/**
	 * Inializacion de la variable GNOMPROG_S valor GNOMPROG-S
	 */
	private static final String GNOMPROG_S = "GNOMPROG-S";

	/**
	 * Inializacion de la variable ANIO_S valor ANIO-S
	 */
	private static final String ANIO_S = "ANIO-S";

	/**
	 * Inializacion de la variable EXPEDIENTE-_S valor EXPEDIENTE--S
	 */
	private static final String EXPEDIENTE_S = "EXPEDIENTE-S";
	
	/**
	 * Inicializamos el OPERACION_E, con valor OPERACION-E
	 */
	private static final String OPERACION_E = "OPERACION-E";

	/**
	 * Ejecuta el servicio cobol de carga inicial
	 * 
	 * @param eDatos
	 *            contiene los parametros para hacer la llamada al servicio
	 * @return sDatos datos retornados por el servicio cobol
	 * @throws J372J001VencimientosException
	 */
	public static J372J004GestionVariablesVenPageBean ejecutaServicioCobol (
			J372J004GestionVariablesVenPageBean eDatos )
			throws J372J001VencimientosException {

		final J372J003ServicioCobol OGESSERVICIO = new J372J003ServicioCobol ();
		final UtilidadesBeanAction UTIL = new UtilidadesBeanAction ();
		
		J000J000Conectable oConector;
		J372J004GestionVariablesVenPageBean sDatos = new J372J004GestionVariablesVenPageBean ();
		if ( OBJTRAZAS.isDebugEnabled () ) {
			OBJTRAZAS.debug ( "J372J004GestionVariablesVenPageBean: CARGA DE DATOS COBOL" );
		}
		try {
			oConector = OGESSERVICIO.prepararLlamada (
					"IN372VENCIMIENTOSMANUALES", "B372VT02GestionVariablesVen",
					eDatos.getUsuario () );
			oConector.setCampo ( "KSERVICIO-C", "B372VT02" );
			// cabecera de control
			oConector.setCampo ( "CCANAL-C", "01" );
			oConector.setCampo ( "KEMPRESA-C", "MAV" );
			oConector.setCampo ( "KDEPARTA-C", "ISA" );
			oConector.setCampo ( "KUSUARIO-C", eDatos.getUsuario ().getStUsuario_Racf () );
			oConector.setCampo ( "KCADISTR-C", ENBLANCO );
			// Entrada
			oConector.setCampo ( OPERACION_E, eDatos.getTipOperacion () );
			oConector.setCampo ( "TABLA-E", "VE" );
			oConector.setCampo ( "ANIO-E", eDatos.getAnio ().toString () );
			oConector.setCampo ( "EXPEDIENTE-E", eDatos.getExpediente ().toString () );
			if ( OBJTRAZAS.isDebugEnabled () ) {
				OBJTRAZAS.debug ( " OPERACION-E = " + oConector.getCampo ( OPERACION_E ) );
				OBJTRAZAS.debug ( " TABLA-E = " + oConector.getCampo ( "TABLA-E" ) );
				OBJTRAZAS.debug ( " ANIO-E = " + oConector.getCampo ( "ANIO-E" ) );
				OBJTRAZAS.debug ( " EXPEDIENTE-E = " + oConector.getCampo ( "EXPEDIENTE-E" ) );
			}
			oConector.ejecutarServicio ();
			String sResultado = oConector.getCampo ( CRETORNO_S );
			
			/*
			 * Si en la base de datoa no existiera ningun dato, hariamos una
			 * inserccion con el año actual y con numero de expediente 1.
			 */
			if (sResultado.compareTo ("03") == 0 ) {
				oConector.setCampo (OPERACION_E, "I1");
				final Calendar c1 = new GregorianCalendar ();
				oConector.setCampo ("ANIO-E", Integer.toString (c1.get (Calendar.YEAR)));
				oConector.setCampo ("EXPEDIENTE-E", "1");
				oConector.ejecutarServicio ();
				sResultado = oConector.getCampo (CRETORNO_S);

			}
			if ( sResultado.compareTo ( "00" ) == 0 ) {
				sDatos.setDesRetorno ( oConector.getCampo ( GERROR_S ) );
				sDatos.setRetorno ( oConector.getCampo ( CRETORNO_S ) );
				sDatos.setNomPrograma ( oConector.getCampo ( GNOMPROG_S ) );
				sDatos.setAnio(UTIL.numeroBig ( oConector.getCampo ( ANIO_S ) ));
				sDatos.setExpediente(UTIL.numeroBig ( oConector.getCampo ( EXPEDIENTE_S ) ));
				sDatos.setTipOperacion ( oConector.getCampo ( OPERACION_E ) );
				if ( OBJTRAZAS.isDebugEnabled () ) {
					OBJTRAZAS.debug ( "ServicioGestionVariablesBean: GNOMPROG-S = " + oConector.getCampo ( GNOMPROG_S ) );
					OBJTRAZAS.debug ( "ServicioGestionVariablesBean: GERROR-S   = " + oConector.getCampo ( GERROR_S ) );
					OBJTRAZAS.debug ( "ServicioGestionVariablesBean: CRETORNO-S = " + oConector.getCampo ( CRETORNO_S ) );
				}
				return sDatos;
			} else {
				if ( OBJTRAZAS.isEnabledFor ( Level.ERROR ) ) {
					OBJTRAZAS.error ( "ServicioGestionVariablesBean: GNOMPROG-S = " + oConector.getCampo ( GNOMPROG_S ) );
					OBJTRAZAS.error ( "ServicioGestionVariablesBean: GERROR-S   = " + oConector.getCampo ( GERROR_S ) );
					OBJTRAZAS.error ( "ServicioGestionVariablesBean: CRETORNO-S = " + oConector.getCampo ( CRETORNO_S ) );
				}
				final StringBuffer descripcion = new StringBuffer ( "0" );
				J372J001VencimientosException objException = new J372J001VencimientosException (
						J372J001VencimientosException.ERROR_NEGOCIO, ENBLANCO );
				objException.setStMetodo ( "ejecutaServicio()" );
				objException.setStClase ( "ServicioGestionVariablesBean" );
				descripcion.append ( sResultado ).append ( ": " ).append ( oConector.getCampo ( GERROR_S ) );
				objException.setStDescripcion ( descripcion.toString () );
				objException.setStGNomProg ( oConector.getCampo ( GNOMPROG_S ) );
				objException.setStGError ( oConector.getCampo ( GERROR_S ) );
				objException.setStCRetorno ( oConector.getCampo ( CRETORNO_S ) );
				throw objException;
			}
		} catch ( J372J001VencimientosException e ) {
			throw e;
		} catch ( J000J000Exception e ) {
			J372J001VencimientosException objException = new J372J001VencimientosException (
					J372J001VencimientosException.ERROR_GENERICO_CICS, ENBLANCO );
			objException.setStDescripcion ( e.getLocalizedMessage () );
			objException.setStClase ( e.getClass ().toString () );
			objException.setStGNomProg ( ENBLANCO );
			objException.setStGError ( "Error Genérico CICS" );
			objException.setStCRetorno ( ENBLANCO );

			throw objException;
		}

	}

}
