package com.mapfre.mavisa.wss372vencimientosmanuales.actions;

import java.util.StringTokenizer;
import javax.servlet.http.HttpServletRequest;
import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;
import mapfre.wss000arquitect.jsp.etiquetas.table.model.DataProvider;
import mapfre.wss000arquitect.jsp.etiquetas.table.model.FetchResults;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J001BusquedaExpVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans.J372J001BusquedaExpVenHelperBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J001BusquedaExpVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.Mensajes;

/**
 * @author everis
 * @version 1.0 Versión inicial Data Provider para el listado busqueda
 *          expediente
 */
public class J372J002BusquedaExpVenDataProvider extends DataProvider {

	/**
	 * objTrazas
	 */
	public static final Logger objTrazas = Logger.getLogger ( J372J002BusquedaExpVenDataProvider.class );

	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inicializacion de la variable SEPARADOR_CAMPO, valor ::
	 */
	private static final String SEPARADOR_CAMPO = "::";

	/**
	 * Inicializamos el EXCEPCION, con valor J372J002BusquedaExpVenDataProvider - Excepcion:
	 */
	private static final String EXCEPCION = "";

	/**
	 * Inicializamos el keyExpediente, con valor ENBLANCO
	 */
	private String keyExpediente = ENBLANCO;

	/**
	 * Inicializamos el keyAnio, con valor ENBLANCO
	 */
	private String keyAnio = ENBLANCO;

	/**
	 * 
	 * @param stKey
	 * @return NULL
	 */
	private boolean esPrimeraLlamada ( String stKey ) {

		return ( stKey == null );
	}

	/**
	 * @param results
	 * @param stKey
	 * @param absRecord
	 * @param nbrRecords
	 * @param request
	 */

	@Override
	public void getBlock ( FetchResults results, String stKey, int absRecord,
			int nbrRecords, HttpServletRequest request ) {

		Mensajes mensaje = new Mensajes ();

		J372J001BusquedaExpVenActionForm objForm = 
			( J372J001BusquedaExpVenActionForm ) request.getSession ().getAttribute ( "formBusquedaExp" );

		// llamada HOST
		try {

			final J000J000Usuario usuario = J000J000Usuario.getUsuarioArquitectura ( request );

			// recoger CLAVE PAGINACIÓN
			recogerKey ( stKey );

			final J372J001BusquedaExpVenHelperBean helperBean = new J372J001BusquedaExpVenHelperBean ();

			J372J001BusquedaExpVenPageBean datosSalida = new J372J001BusquedaExpVenPageBean ();

			recogerKey ( stKey );

			objForm.setAntExpediente ( keyExpediente );
			objForm.setAntAnio ( keyAnio );

			final J372J001BusquedaExpVenPageBean datosEntrada = helperBean
					.recogerDatosEntrada ( objForm, usuario );

			datosSalida = helperBean.llamarServicio ( datosEntrada );
			objForm = helperBean.ponerDatosSalida ( datosSalida, objForm );

			// tratamos el result, pasamos los datos del form al result para la
			// lista
			results.setData ( objForm.getListadoExp () );
			if ("S".equals (objForm.getPaginacion ().toString ())) {
				results.setHasMore (Boolean.TRUE);
			} else {
				results.setHasMore (Boolean.FALSE);
			}
			// valido para cuando tengamos datos de cobol
			results.setNextKey ( generarKey ( datosSalida.getProExpediente ()
					.toString (), datosSalida.getProAnio ().toString () ) );

			// nos devuelven
			objForm.setProAnio ( datosSalida.getProAnio ().toString () );
			objForm.setProExpediente ( datosSalida.getProExpediente ()
					.toString () );

			if ( objForm.getListadoExp ().isEmpty () ) {
				final String textInfo = "NO HAY RESULTADOS";
				mensaje.setMensaje ( 3, "II", "!!", textInfo, this.getClass ()
						.getName (), "NO HAY RESULTADOS" );
			}

			// objForm.setVectorMensajes(mensajes.getVectorMensajes());

		} catch ( J372J001VencimientosException e ) {

			results.setTotalRecs ( Long.valueOf ( "1" ) );
			results.setData ( new java.util.ArrayList () );
			results.setHasMore ( Boolean.FALSE );

			/*
			 * LOGS trazas para poder seguir las diferentes exception de
			 * J372J001VencimientosException
			 */
			if ( objTrazas.isEnabledFor ( Level.ERROR ) ) {
				objTrazas.error ( EXCEPCION + e.getStDescripcion () );
				objTrazas.error ( EXCEPCION + e.getLocalizedMessage () );
				objTrazas.error ( EXCEPCION + e.getStClase () );
				objTrazas.error ( EXCEPCION + e.getStMensajeError () );
				objTrazas.error ( EXCEPCION + e.getStMetodo () );
			}
			final String desCodError = e.getStGError ();

			mensaje.setMensaje ( 1, "XX", ENBLANCO, desCodError, ENBLANCO,
					ENBLANCO );

		} finally {

			objForm.setVectorMensajes ( mensaje.getVectorMensajes () );
			request.getSession ().setAttribute ( "formBusquedaExp", objForm );

		}

	}

	/**
	 * 
	 * @param valueExpediente
	 * @param valueAnio
	 * @return año y expediente
	 */
	private String generarKey ( String valueExpediente, String valueAnio ) {

		return ( new StringBuffer ( valueExpediente ).append ( SEPARADOR_CAMPO )
				.append ( valueAnio ) ).toString ();

	}

	/**
	 * 
	 * @param stkey
	 */
	private void recogerKey ( String stkey ) {

		if ( esPrimeraLlamada ( stkey ) ) {

			keyExpediente = ENBLANCO;
			keyAnio = ENBLANCO;
		} else {

			final StringTokenizer objStringTokenizer = new StringTokenizer (
					stkey, SEPARADOR_CAMPO );

			keyExpediente = objStringTokenizer.nextToken ();

			keyAnio = objStringTokenizer.nextToken ();

		}

	}

}