package com.mapfre.mavisa.wss372vencimientosmanuales.servicios;

import mapfre.wss000arquitect.accesodatos.Factoria.J000J000Conectable;
import mapfre.wss000arquitect.excepciones.J000J000Exception;
import mapfre.wss000arquitect.utilidades.J000J000Trazas;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J009ConsultaCarteraVenPageBean;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;

/**
 * @author everis
 * 
 * Clase de negocio. Contiene los metodos necesarios para ejecutar los servicios
 * cobol de carga inicial y de calculo
 * @version 1.0 Versión inicial
 */

public class J372J007ServicioConsultaCarteraVenBean {

	/**
	 * Constructor por defecto PRIVATE
	 * 
	 */
	private J372J007ServicioConsultaCarteraVenBean () {
		// TODO Constructor por defecto PRIVATE
	}

	/**
	 * objTrazas nos mostraralas trazas de código
	 */
	private static final Logger OBJTRAZAS = J000J000Trazas.getLogger ( J372J007ServicioConsultaCarteraVenBean.class );

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
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Ejecuta el servicio cobol de carga inicial
	 * 
	 * @param eDatos
	 *            contiene los parametros para hacer la llamada al servicio
	 * @return sDatos datos retornados por el servicio cobol
	 * @throws J372J001VencimientosException
	 */
	public static J372J009ConsultaCarteraVenPageBean ejecutaServicioCobol (
			J372J009ConsultaCarteraVenPageBean eDatos )
			throws J372J001VencimientosException {
		final J372J003ServicioCobol oGesServicios = new J372J003ServicioCobol ();
		J000J000Conectable oConector;
		J372J009ConsultaCarteraVenPageBean sDatos = new J372J009ConsultaCarteraVenPageBean ();
		if ( OBJTRAZAS.isDebugEnabled () ) {
			OBJTRAZAS.debug ( "J372J007ServicioConsultaCarteraVenBean: CARGA DE DATOS COBOL" );
		}
		try {
			oConector = oGesServicios.prepararLlamada (
					"IN372VENCIMIENTOSMANUALES", "B372VT19ConsultaCarteraVen",eDatos.getUsuario () );
			oConector.setCampo ( "KSERVICIO-C", "B372VT19" );
			// cabecera de control
			oConector.setCampo ( "CCANAL-C", "01" );
			oConector.setCampo ( "KEMPRESA-C", "MAV" );
			oConector.setCampo ( "KDEPARTA-C", "ISA" );
			oConector.setCampo ( "KUSUARIO-C", eDatos.getUsuario ().getStUsuario_Racf () );
			oConector.setCampo ( "KCADISTR-C", ENBLANCO );
			// Entrada
			oConector.setCampo ( "POLIZA-E", eDatos.getPoliza ().toString () );
			oConector.setCampo ( "SUBPOLIZA-E", eDatos.getSubpoliza ().toString () );
			oConector.setCampo ( "CERTIFICADO-E", eDatos.getCertificado ().toString () );
			if ( OBJTRAZAS.isDebugEnabled () ) {
				OBJTRAZAS.debug ( " POLIZA = " + oConector.getCampo ( "POLIZA-E" ) );
				OBJTRAZAS.debug ( " SUBPOLIZA = " + oConector.getCampo ( "SUBPOLIZA-E" ) );
				OBJTRAZAS.debug ( " CERTIFICADO = " + oConector.getCampo ( "CERTIFICADO-E" ) );
			}
			oConector.ejecutarServicio ();
			final String SRESULTADO = oConector.getCampo ( CRETORNO_S );
			if ( OBJTRAZAS.isEnabledFor ( Level.ERROR ) ) {
				OBJTRAZAS.error ( "ServicioConsultaCarteraVenBean: GERROR-S   = " + oConector.getCampo ( GERROR_S ) );
				OBJTRAZAS.error ( "ServicioConsultaCarteraVenBean: CRETORNO-S = " + oConector.getCampo ( CRETORNO_S ) );
				OBJTRAZAS.error ( "ServicioConsultaCarteraVenBean: GNOMPROG-S= " + oConector.getCampo ( GNOMPROG_S ) );
			}
			if ( SRESULTADO.compareTo ( "00" ) == 0 ) {
//				sDatos.setAniopol ( oConector.getCampo ( "ANIOPOL-S" ) );
				String condicion = oConector.getCampo ( "FEFECTO-S" );
				String fecEfectoDigitos ="";
				if (condicion != null && !condicion.equals("")) {
					fecEfectoDigitos = condicion.substring(2, 4);
				}else{
					sDatos.setAniopol ("00");
				}
				sDatos.setAniopol (fecEfectoDigitos);
				sDatos.setRamo ( oConector.getCampo ( "RAMO-S" ) );
				sDatos.setPolizaSalida ( oConector.getCampo ( "POLIZA-S" ) );
				sDatos.setSubPolizaSalida ( oConector.getCampo ( "SUBPOLIZA-S" ) );
				sDatos.setCertificado ( eDatos.getCertificado () );
				sDatos.setSituacion ( oConector.getCampo ( "SITUACION-S" ) );
				sDatos.setModalidad ( oConector.getCampo ( "MODALIDAD-S" ) );
				sDatos.setDuracion ( oConector.getCampo ( "DURACION-S" ) );
				sDatos.setFecEfecto ( oConector.getCampo ( "FEFECTO-S" ) );
				sDatos.setFecAnul ( oConector.getCampo ( "FANULACION-S" ) );
				sDatos.setRegionalPol ( oConector.getCampo ( "REGIONAL-S" ) );
				sDatos.setCanalCamp ( oConector.getCampo ( "CANAL-S" ) );
				sDatos.setEntidad ( oConector.getCampo ( "CENTIDAD-S" ) );
				sDatos.setOficina ( oConector.getCampo ( "OFICINA-S" ) );
				sDatos.setTomador ( oConector.getCampo ( "TOMADOR-S" ) );
				sDatos.setNifCifPri ( oConector.getCampo ( "NIF1-S" ) );
				sDatos.setRetorno ( oConector.getCampo ( CRETORNO_S ) );
				sDatos.setDesRetorno ( oConector.getCampo ( GERROR_S ) );
				sDatos.setNomPrograma ( oConector.getCampo ( GNOMPROG_S ) );
				if ( OBJTRAZAS.isDebugEnabled () ) {
					OBJTRAZAS.debug ( "ServicioConsultaCarteraVenBean: ANIOPOL-S   = " + oConector.getCampo ( "ANIOPOL-S" ) );
					OBJTRAZAS.debug ( "ServicioConsultaCarteraVenBean: RAMO-S      = " + oConector.getCampo ( "RAMO-S" ) );
					OBJTRAZAS.debug ( "ServicioConsultaCarteraVenBean: POLIZA-S    = " + oConector.getCampo ( "POLIZA-S" ) );
					OBJTRAZAS.debug ( "ServicioConsultaCarteraVenBean: REGIONAL-S    = " + oConector.getCampo ( "REGIONAL-S" ) );
					OBJTRAZAS.debug ( "ServicioConsultaCarteraVenBean: SUBPOLIZA-S = " + oConector.getCampo ( "SUBPOLIZA-S" ) );
					OBJTRAZAS.debug ( "ServicioConsultaCarteraVenBean: SITUACION-S = " + oConector.getCampo ( "SITUACION-S" ) );
					OBJTRAZAS.debug ( "ServicioConsultaCarteraVenBean: MODALIDAD-S = " + oConector.getCampo ( "MODALIDAD-S" ) );
					OBJTRAZAS.debug ( "ServicioConsultaCarteraVenBean: DURACION-S  = " + oConector.getCampo ( "DURACION-S" ) );
					OBJTRAZAS.debug ( "ServicioConsultaCarteraVenBean: FEFECTO-S = " + oConector.getCampo ( "FEFECTO-S" ) );
					OBJTRAZAS.debug ( "ServicioConsultaCarteraVenBean: FANULACION-S= " + oConector.getCampo ( "FANULACION-S" ) );
					OBJTRAZAS.debug ( "ServicioConsultaCarteraVenBean: CANAL-S  = " + oConector.getCampo ( "CANAL-S" ) );
					OBJTRAZAS.debug ( "ServicioConsultaCarteraVenBean: CENTIDAD-S = " + oConector.getCampo ( "CENTIDAD-S" ) );
					OBJTRAZAS.debug ( "ServicioConsultaCarteraVenBean: OFICINA-S = " + oConector.getCampo ( "OFICINA-S" ) );
					OBJTRAZAS.debug ( "ServicioConsultaCarteraVenBean: TOMADOR-S= "	+ oConector.getCampo ( "TOMADOR-S" ) );
					OBJTRAZAS.debug ( "ServicioConsultaCarteraVenBean: NIF1-S= " + oConector.getCampo ( "NIF1-S" ) );
					OBJTRAZAS.debug ( "ServicioConsultaCarteraVenBean: GERROR-S= " + oConector.getCampo ( GERROR_S ) );
					OBJTRAZAS.debug ( "ServicioConsultaCarteraVenBean: CRETORNO-S= " + oConector.getCampo ( CRETORNO_S ) );
					OBJTRAZAS.debug ( "ServicioConsultaCarteraVenBean: GNOMPROG-S= " + oConector.getCampo ( GNOMPROG_S ) );
				}
				return sDatos;
			} else {
				if ( OBJTRAZAS.isEnabledFor ( Level.ERROR ) ) {
					OBJTRAZAS.error ( "ServicioConsultaCarteraVenBean: GERROR-S= " + oConector.getCampo ( GERROR_S ) );
					OBJTRAZAS.error ( "ServicioConsultaCarteraVenBean: CRETORNO-S= " + oConector.getCampo ( CRETORNO_S ) );
					OBJTRAZAS.error ( "ServicioConsultaCarteraVenBean: GNOMPROG-S= " + oConector.getCampo ( GNOMPROG_S ) );
				}
				J372J001VencimientosException objException = 
					 new J372J001VencimientosException ( J372J001VencimientosException.ERROR_NEGOCIO, ENBLANCO );
				objException.setStMetodo ( "ejecutaServicio()" );
				objException.setStGError ( oConector.getCampo ( GERROR_S ) );
				objException.setStCRetorno ( oConector.getCampo ( CRETORNO_S ) );
				sDatos.setPolizaSalida (eDatos.getPoliza ());
				sDatos.setSubPolizaSalida (eDatos.getSubpoliza ());
				sDatos.setCertificado ( eDatos.getCertificado ());
				sDatos.setRetorno (oConector.getCampo (CRETORNO_S));
				sDatos.setDesRetorno (oConector.getCampo (GERROR_S));
				sDatos.setNomPrograma (oConector.getCampo (GNOMPROG_S));
				return sDatos;
				//throw objException;
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
