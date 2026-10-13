package com.mapfre.mavisa.wss372vencimientosmanuales.servicios;

import java.util.ArrayList;
import java.util.List;

import mapfre.wss000arquitect.accesodatos.Factoria.J000J000Conectable;
import mapfre.wss000arquitect.excepciones.J000J000Exception;
import mapfre.wss000arquitect.utilidades.J000J000Trazas;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J005ImpresionInformesVenPageBean;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;

/**
 * @author everis Prepara la llamada al servicio Cobol estableciendo la conexi�n
 *         con el mismo.
 * @version 1.0 Versi�n inicial
 */
public class J372J009ServicioImpresionInformesVenBean {

	/**
	 * Constructor por defecto PRIVATE
	 * 
	 */
	private J372J009ServicioImpresionInformesVenBean () {
		// TODO Constructor por defecto PRIVATE
	}

	/**
	 * objTrazas nos mostraralas trazas de c�digo
	 */
	private static final Logger OBJTRAZAS = J000J000Trazas
			.getLogger ( J372J009ServicioImpresionInformesVenBean.class );

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
	public static J372J005ImpresionInformesVenPageBean ejecutaServicioCobol (
			J372J005ImpresionInformesVenPageBean eDatos )
			throws J372J001VencimientosException {

		final J372J003ServicioCobol oGesServicios = new J372J003ServicioCobol ();

		J000J000Conectable oConector;
		J372J005ImpresionInformesVenPageBean sDatos = new J372J005ImpresionInformesVenPageBean ();
		if ( OBJTRAZAS.isDebugEnabled () ) {
			OBJTRAZAS
					.debug ( "ServicioImpresionInformesVenBean: CARGA DE DATOS COBOL" );
		}
		try { 
			oConector = oGesServicios.prepararLlamada (
					"IN372VENCIMIENTOSMANUALES",
					"B372VT10ImpresionInformesVen", eDatos.getUsuario () );
			oConector.setCampo ( "KSERVICIO-C", "B372VT10" );

			// cabecera de control
			oConector.setCampo ( "CCANAL-C", "01" );
			oConector.setCampo ( "KEMPRESA-C", "MAV" );
			oConector.setCampo ( "KDEPARTA-C", "ISA" );
			oConector.setCampo ( "KUSUARIO-C", eDatos.getUsuario ()
					.getStUsuario_Racf () );
			oConector.setCampo ( "KCADISTR-C", ENBLANCO );

			// Entrada
			oConector.setCampo ( "TIPOEMI-E", eDatos.getTipo ().toString () );
			oConector.setCampo ( "ANIODESDE-E", eDatos.getAnioDesde ()
					.toString () );
			oConector.setCampo ( "ANIOHASTA-E", eDatos.getAnioHasta ()
					.toString () );
			oConector.setCampo ( "EXPEDIDESDE-E", eDatos.getExpedDesde ()
					.toString () );
			oConector.setCampo ( "EXPEDIHASTA-E", eDatos.getExpedHasta ()
					.toString () );
			oConector.setCampo ( "FECEMISION-E", eDatos.getFecEmision ()
					.toString () );
			oConector.setCampo ( "FECCALCULO-E", eDatos.getFecCalculo ()
					.toString () );
			oConector.setCampo ( "FECEMIDESDE-E", eDatos.getFecEmiDesde ()
					.toString () );
			oConector.setCampo ( "FECEMIHASTA-E", eDatos.getFecEmiHasta ()
					.toString () );
			oConector.setCampo ( "FECPAGDESDE-E", eDatos.getFecPagDesde ()
					.toString () );
			oConector.setCampo ( "FECPAGHASTA-E", eDatos.getFecPagHasta ()
					.toString () );

			// logs de datos de entrada
			if ( OBJTRAZAS.isDebugEnabled () ) {
				OBJTRAZAS
						.debug ( "ServicioImpresionInformesVenBean_Datos entrada: TIPOEMI-E = "
								+ oConector.getCampo ( "TIPOEMI-E" ) );
				OBJTRAZAS
						.debug ( "ServicioImpresionInformesVenBean_Datos entrada: ANIODESDE-E = "
								+ oConector.getCampo ( "ANIODESDE-E" ) );
				OBJTRAZAS
						.debug ( "ServicioImpresionInformesVenBean_Datos entrada: ANIOHASTA-E = "
								+ oConector.getCampo ( "ANIOHASTA-E" ) );
				OBJTRAZAS
						.debug ( "ServicioImpresionInformesVenBean_Datos entrada: EXPEDIDESDE-E = "
								+ oConector.getCampo ( "EXPEDIDESDE-E" ) );
				OBJTRAZAS
						.debug ( "ServicioImpresionInformesVenBean_Datos entrada: EXPEDIHASTA-E = "
								+ oConector.getCampo ( "EXPEDIHASTA-E" ) );
				OBJTRAZAS
						.debug ( "ServicioImpresionInformesVenBean_Datos entrada: FECEMISION-E = "
								+ oConector.getCampo ( "FECEMISION-E" ) );
				OBJTRAZAS
						.debug ( "ServicioImpresionInformesVenBean_Datos entrada: FECEMIDESDE-E = "
								+ oConector.getCampo ( "FECEMIDESDE-E" ) );

				OBJTRAZAS
						.debug ( "ServicioImpresionInformesVenBean_Datos entrada: FECEMIHASTA-E = "
								+ oConector.getCampo ( "FECEMIHASTA-E" ) );

				OBJTRAZAS
						.debug ( "ServicioImpresionInformesVenBean_Datos entrada: FECPAGDESDE-E = "
								+ oConector.getCampo ( "FECPAGDESDE-E" ) );

				OBJTRAZAS
						.debug ( "ServicioImpresionInformesVenBean_Datos entrada: FECPAGHASTA-E = "
								+ oConector.getCampo ( "FECPAGHASTA-E" ) );
			}
			oConector.ejecutarServicio ();

			/* Datos de salida */
			final String SRESULTADO = oConector.getCampo ( CRETORNO_S );

			if ( ("00").equals ( SRESULTADO )  || ("06").equals ( SRESULTADO ) ) {

				sDatos.setDesRetorno ( oConector.getCampo ( GERROR_S ) );
				sDatos.setRetorno ( oConector.getCampo ( CRETORNO_S ) );
				sDatos.setNomPrograma ( oConector.getCampo ( GNOMPROG_S ) );

				if ( OBJTRAZAS.isDebugEnabled () ) {
					OBJTRAZAS 
							.debug ( "ServicioImpresionInformesVenBean_Datos salida: GERROR-S   = "
									+ oConector.getCampo ( GERROR_S ) );
		 			OBJTRAZAS
							.debug ( "ServicioImpresionInformesVenBean_Datos salida: CRETORNO-S = "
									+ oConector.getCampo ( CRETORNO_S ) );

					OBJTRAZAS
							.debug ( "ServicioImpresionInformesVenBean_Datos salida: GNOMPROG-S = "
									+ oConector.getCampo ( GNOMPROG_S ) );
				}

				List listaImpresionInf = new ArrayList ();
				int numInformes = 0;

				boolean occurs = true;
				while (!ENBLANCO.equals(oConector.getCampo ( "ANIO-S" ))) { 
					numInformes++;
 
					J372J005ImpresionInformesVenPageBean pageBean = new J372J005ImpresionInformesVenPageBean ();

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

					listaImpresionInf.add ( pageBean );

					occurs = oConector.next ( "REGISTROS-OCC-S" );

				}
				/*
				 * En los datos de salida vamos a tener la lista con todos sus
				 * campos y por otro lado la paginacion que ir� independiente de
				 * los datos de la lista
				 */

				sDatos.setListadoInf ( listaImpresionInf );
				if ( OBJTRAZAS.isDebugEnabled () ) {
					OBJTRAZAS
							.debug ( "ServicioImpresionInformesVenBean_Datos salida: REGISTROS-OCC-S   = "
									+ numInformes );

					OBJTRAZAS
							.debug ( "ServicioImpresionInformesVenBean_Datos salida: GERROR-S   = "
									+ oConector.getCampo ( GERROR_S ) );
					OBJTRAZAS
							.debug ( "ServicioImpresionInformesVenBean_Datos salida: CRETORNO-S = "
									+ oConector.getCampo ( CRETORNO_S ) );
				}

				return sDatos;
			} else {
				if ( OBJTRAZAS.isEnabledFor ( Level.ERROR ) ) {
					OBJTRAZAS
							.error ( "ServicioImpresionInformesVenBean: GERROR-S   = "
									+ oConector.getCampo ( GERROR_S ) );
					OBJTRAZAS
							.error ( "ServicioImpresionInformesVenBean: CRETORNO-S = "
									+ oConector.getCampo ( CRETORNO_S ) );
				}
				if ( OBJTRAZAS.isDebugEnabled () ) {
					OBJTRAZAS
							.debug ( "ServicioImpresionInformesVenBean: GNOMPROG-S= "
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
