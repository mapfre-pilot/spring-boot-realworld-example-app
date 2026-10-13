package com.mapfre.mavisa.wss372vencimientosmanuales.servicios;

import java.util.ArrayList;
import java.util.List;

import mapfre.wss000arquitect.accesodatos.Factoria.J000J000Conectable;
import mapfre.wss000arquitect.excepciones.J000J000Exception;
import mapfre.wss000arquitect.utilidades.J000J000Trazas;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J002EmisionFiniquitosVenPageBean;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

/**
 * @author everis Prepara la llamada al servicio Cobol estableciendo la conexi�n
 *         con el mismo.
 * @version 1.0 Versi�n inicial
 */ 
public class J372J004ServicioEmisionFiniquitosVenBean {

	/**
	 * Constructor por defecto PRIVATE
	 * 
	 */
	private J372J004ServicioEmisionFiniquitosVenBean () {
		// TODO Constructor por defecto PRIVATE
	}

	/** 
	 * objTrazas nos mostraralas trazas de c�digo
	 */
	private static final Logger OBJTRAZAS = J000J000Trazas.getLogger ( J372J004ServicioEmisionFiniquitosVenBean.class );

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
	 * Ejecuta el servicio cobol de carga inicial
	 * 
	 * @param eDatos
	 *            contiene los parametros para hacer la llamada al servicio
	 * @return sDatos datos retornados por el servicio cobol
	 * @throws J372J001VencimientosException
	 */
	public static J372J002EmisionFiniquitosVenPageBean ejecutaServicioCobol (
			J372J002EmisionFiniquitosVenPageBean eDatos )
			throws J372J001VencimientosException {

		final J372J003ServicioCobol oGesServicios = new J372J003ServicioCobol ();

		J000J000Conectable oConector;
		J372J002EmisionFiniquitosVenPageBean sDatos = new J372J002EmisionFiniquitosVenPageBean ();
		if ( OBJTRAZAS.isDebugEnabled () ) {
			OBJTRAZAS
					.debug ( "ServicioEmisionFiniquitosVenBean: CARGA DE DATOS COBOL" );
		}
		try {
			oConector = oGesServicios.prepararLlamada (
					"IN372VENCIMIENTOSMANUALES",
					"B372VT09EmisionFiniquitosVen", eDatos.getUsuario () );
			oConector.setCampo ( "KSERVICIO-C", "B372VT09" );

			// cabecera de control
			oConector.setCampo ( "CCANAL-C", "01" );
			oConector.setCampo ( "KEMPRESA-C", "MAV" );
			oConector.setCampo ( "KDEPARTA-C", "ISA" );
			oConector.setCampo ( "KUSUARIO-C", eDatos.getUsuario ()
					.getStUsuario_Racf () );
			oConector.setCampo ( "KCADISTR-C", ENBLANCO );

			// Entrada
			oConector.setCampo ( "ANIO-E", eDatos.getAnio ().toString () );
			oConector.setCampo ( "EXPEDIDESDE-E", eDatos.getExpedDesde ()
					.toString () );
			oConector.setCampo ( "EXPEDIHASTA-E", eDatos.getExpedHasta ()
					.toString () );
			oConector.setCampo ( "FEMISION-E", eDatos.getFecEfectEmision ()
					.toString () );
			oConector.setCampo ( "TIPOEMI-E", eDatos.getEmisionFiniqui ()
					.toString () );
			oConector.setCampo ( "LUGARENVIO-E", eDatos.getRegionalEnvio ()
					.toString () );
			oConector.setCampo ( "ANT-KEXPEDIENTE-E", eDatos
					.getAntExpediente ().toString () );
			oConector
					.setCampo ( "ANT-ANIO-E", eDatos.getAntAnio ().toString () );

			// logs de datos de entrada
			if ( OBJTRAZAS.isDebugEnabled () ) {
				OBJTRAZAS
						.debug ( "ServicioEmisionFiniquitosVenBean_Datos entrada: EXPEDIDESDE-E = "
								+ oConector.getCampo ( "EXPEDIDESDE-E" ) );
				OBJTRAZAS
						.debug ( "ServicioEmisionFiniquitosVenBean_Datos entrada: EXPEDIHASTA-E = "
								+ oConector.getCampo ( "EXPEDIHASTA-E" ) );
				OBJTRAZAS
						.debug ( "ServicioEmisionFiniquitosVenBean_Datos entrada: ANIO-E = "
								+ oConector.getCampo ( "ANIO-E" ) );
				OBJTRAZAS
						.debug ( "ServicioEmisionFiniquitosVenBean_Datos entrada: FEMISION-E = "
								+ oConector.getCampo ( "FEMISION-E" ) );
				OBJTRAZAS
						.debug ( "ServicioEmisionFiniquitosVenBean_Datos entrada: TIPOEMI-E = "
								+ oConector.getCampo ( "TIPOEMI-E" ) );
				OBJTRAZAS
						.debug ( "ServicioEmisionFiniquitosVenBean_Datos entrada: LUGARENVIO-E = "
								+ oConector.getCampo ( "LUGARENVIO-E" ) );
				OBJTRAZAS
						.debug ( "ServicioEmisionFiniquitosVenBean_Datos entrada: ANT-KEXPEDIENTE-E = "
								+ oConector.getCampo ( "ANT-KEXPEDIENTE-E" ) );
				OBJTRAZAS
						.debug ( "ServicioEmisionFiniquitosVenBean_Datos entrada: ANT-ANIO-E = "
								+ oConector.getCampo ( "ANT-ANIO-E" ) );
			}
			oConector.ejecutarServicio ();

			/* Datos de salida */ 
			final String SRESULTADO = oConector.getCampo ( CRETORNO_S );
			if ( ("00").equals ( SRESULTADO )  || ("06").equals ( SRESULTADO )) {

				sDatos.setDesRetorno ( oConector.getCampo ( GERROR_S ) );
				sDatos.setRetorno ( oConector.getCampo ( CRETORNO_S ) );
				sDatos.setNomPrograma ( oConector.getCampo ( GNOMPROG_S ) );
 
				if ( OBJTRAZAS.isDebugEnabled () ) {
					OBJTRAZAS
		 					.debug ( "ServicioEmisionFiniquitosVenBean_Datos salida: GERROR-S   = "
									+ oConector.getCampo ( GERROR_S ) );
					OBJTRAZAS
							.debug ( "ServicioEmisionFiniquitosVenBean_Datos salida: CRETORNO-S = "
									+ oConector.getCampo ( CRETORNO_S ) );
 
					OBJTRAZAS
							.debug ( "ServicioEmisionFiniquitosVenBean_Datos salida: GNOMPROG-S = "
									+ oConector.getCampo ( GNOMPROG_S ) );
				}
				List listaEmisionFiniq = new ArrayList ();

				int numInformes = 0;
				 
				boolean occurs = true;
				while (!ENBLANCO.equals(oConector.getCampo ( "ANIO-S" ))) { 
					numInformes++;

					J372J002EmisionFiniquitosVenPageBean pageBean = new J372J002EmisionFiniquitosVenPageBean ();

					pageBean.setAnio ( oConector.getCampo ( "ANIO-S" ) );
					
					pageBean.setExpediente ( oConector
							.getCampo ( "KEXPEDIENTE-S" ) );
					pageBean.setRamo ( oConector.getCampo ( "KRAMO-S" ) );
					pageBean.setAnioPol ( oConector.getCampo ( "ANIOPOL-S" ) );
					pageBean.setPoliza ( oConector.getCampo ( "KPOLIZA-S" ) );
					pageBean.setRegional ( oConector.getCampo ( "REGIONAL-S" ) );
					pageBean.setOficina ( oConector.getCampo ( "KOFICINA-S" ) );
					pageBean.setModalidad ( oConector
							.getCampo ( "KMODALIDAD-S" ) );
					pageBean.setFecDesdeLit ( oConector
							.getCampo ( "FECDESDELIT-S" ) );
					pageBean.setFecLiquidaLit ( oConector
							.getCampo ( "FECLIQUIDALIT-S" ) );
					pageBean.setAnocomples ( oConector
							.getCampo ( "ANOEJERCICIO-S" ) );
					pageBean
							.setLiteral ( oConector.getCampo ( "IMPLITERAL-S" ) );
					pageBean.setImPrest ( oConector.getCampo ( "IMPPREST-S" ) );
					pageBean.setBeneficios ( oConector
							.getCampo ( "IMPBENEFICIOS-S" ) );
					pageBean.setAnticipo ( oConector
							.getCampo ( "IMPANTICIPO-S" ) );
					pageBean.setCobroInt ( oConector
							.getCampo ( "IMPINTEPENDP-S" ) );
					pageBean
							.setRetCuenta ( oConector.getCampo ( "RETCUENTA-S" ) );
					pageBean.setRetenc ( oConector.getCampo ( "IMPRETENC-S" ) );
					pageBean
							.setImPliquid ( oConector.getCampo ( "IMPLIQUID-S" ) );
					pageBean.setFecEfectEmisionLit ( oConector
							.getCampo ( "FECEMISIONLIT-S" ) );
					pageBean.setNif ( oConector.getCampo ( "NIF-S" ) );
					pageBean.setNombreApell ( oConector
							.getCampo ( "NOMBREAPELL-S" ) );
					pageBean
							.setDomicilio ( oConector.getCampo ( "DOMICILIO-S" ) ); 
					pageBean
							.setPoblacion ( oConector.getCampo ( "POBLACION-S" ) );
					pageBean
							.setCodPostal ( oConector.getCampo ( "CODPOSTAL-S" ) );
					pageBean
							.setProvincia ( oConector.getCampo ( "PROVINCIA-S" ) );
					pageBean.setTipEmision ( oConector
							.getCampo ( "TIPOEMSION-S" ) );
					pageBean.setTipImpuesto ( oConector
							.getCampo ( "TIPIMPUEST-S" ) );
					pageBean
							.setTipoCompl ( oConector.getCampo ( "TIPOCOMPL-S" ) );

					listaEmisionFiniq.add ( pageBean );

					oConector.next ( "REGISTROS-OCC-S" );

				}
				/*
				 * En los datos de salida vamos a tener la lista con todos sus
				 * campos y por otro lado la paginacion que ir� independiente de
				 * los datos de la lista
				 */

				sDatos.setListadoEmi ( listaEmisionFiniq );
				if ( OBJTRAZAS.isDebugEnabled () ) {
					OBJTRAZAS
							.debug ( "ServicioBusquedaExpVenBean_Datos salida: REGISTROS-OCC-S   = "
									+ oConector.getCampo ( "REGISTROS-OCC-S" ) );

					OBJTRAZAS
							.debug ( "ServicioBusquedaExpVenBean_Datos salida: GERROR-S   = "
									+ oConector.getCampo ( GERROR_S ) );
					OBJTRAZAS
							.debug ( "ServicioBusquedaExpVenBean_Datos salida: CRETORNO-S = "
									+ oConector.getCampo ( CRETORNO_S ) );
				}

				return sDatos;
			} else {
				if ( OBJTRAZAS.isEnabledFor ( Level.ERROR ) ) {
					OBJTRAZAS
							.error ( "ServicioEmisionFiniquitosVenBean: GERROR-S   = "
									+ oConector.getCampo ( GERROR_S ) );
					OBJTRAZAS
							.error ( "ServicioEmisionFiniquitosVenBean: CRETORNO-S = "
									+ oConector.getCampo ( CRETORNO_S ) );

					OBJTRAZAS
							.error ( "ServicioEmisionFiniquitosVenBean: GNOMPROG-S= "
									+ oConector.getCampo ( GNOMPROG_S ) );
				}
				J372J001VencimientosException objException = new J372J001VencimientosException (
						J372J001VencimientosException.ERROR_NEGOCIO, ENBLANCO );
				objException.setStMetodo ( "ejecutaServicio()" );
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
			objException.setStGError ( "Error Gen�rico CICS" );
			objException.setStCRetorno ( ENBLANCO );

			throw objException;
		}

	}

}
