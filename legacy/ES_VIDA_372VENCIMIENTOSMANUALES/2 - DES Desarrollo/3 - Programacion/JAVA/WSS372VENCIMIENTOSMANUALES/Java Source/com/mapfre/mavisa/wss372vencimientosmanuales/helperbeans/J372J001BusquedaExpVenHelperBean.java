package com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans;

import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;

import com.mapfre.mavisa.wss372vencimientosmanuales.actions.MapfreAction;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J001BusquedaExpVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J001BusquedaExpVenPageBean;
import org.apache.log4j.Logger;
import com.mapfre.mavisa.wss372vencimientosmanuales.servicios.J372J001ServicioBusquedaExpVenBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.UtilidadesBeanAction;

/**
 * @author everis
 * @version 1.0 Versión inicial Clase de negocio. Recoge los datos del
 *          formulario de entrada y los almacena en una tabla generica. Realiza
 *          la llamada al servicio cobol, recuperando los datos en una tabla
 *          generica. Rellena el obteto de salida con los datos de la tabla de
 *          salida del servicio cobol.
 * 
 */

public class J372J001BusquedaExpVenHelperBean extends MapfreAction {

	/**
	 * objTrazas nos mostraralas trazas de código
	 */
	private static final Logger OBJTRAZAS = Logger
			.getLogger ( J372J001BusquedaExpVenHelperBean.class );

	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";
	
	/**
	 * Inicializamos el CEROS
	 */
	private static final String CEROS = "0000000000";	


	/**
	 * Mapea datos del form de entrada en el datosEntrada
	 * 
	 * @param form
	 * @param usuario
	 * @return datosEntrada
	 */
	public J372J001BusquedaExpVenPageBean recogerDatosEntrada (
			J372J001BusquedaExpVenActionForm form, J000J000Usuario usuario ) {

		J372J001BusquedaExpVenPageBean datosEntrada = new J372J001BusquedaExpVenPageBean ();
		final UtilidadesBeanAction UTIL = new UtilidadesBeanAction ();

		datosEntrada.setAnio ( UTIL.numeroBig ( form.getAnioSel () ) );

		datosEntrada
				.setExpediente ( UTIL.numeroBig ( form.getExpedienteSel () ) );

		// datosEntrada.setPoliza(form.getPoliza());

		/*
		 * toUpperCase nos permite pasar de minuscas a mayusculas la variabble
		 * que nos venga Tambien rellenamos con ceros a la izquierda hasta que
		 * completamos el string
		 */
		datosEntrada.setRdNifCif ( UTIL.rellenarCerosIzq ( 10, form
				.getNifCif ().toUpperCase () ) );

		/*
		 * llamamos al metodo de la clase UTILidadesBean, para que rellene el
		 * string con ceros a la izquierda hasta completar el tamaño.
		 */
		datosEntrada.setRdPoliza ( UTIL.rellenarCerosIzq ( 10, form
				.getPolizaSel () ) );

		datosEntrada.setRdSubpoliza ( UTIL.rellenarCerosIzq ( 4, form
				.getSubpolizaSel () ) );

		datosEntrada.setRdCertificado ( UTIL.rellenarCerosIzq ( 6, form
				.getCertificadoSel () ) );

		datosEntrada.setAntAnio ( UTIL.numeroBig ( form.getAntAnio () ) );

		datosEntrada.setAntExpediente ( UTIL.numeroBig ( form
				.getAntExpediente () ) );

		datosEntrada.setLugarEnvio ( form.getLugarEnvio () );

		datosEntrada.setFecCalculo ( form.getFecCalculo () );

		datosEntrada.setUsuario ( usuario );
		if ( !ENBLANCO.equals ( form.getAnioSel () )
				&& !ENBLANCO.equals ( form.getExpedienteSel () ) ) {
			datosEntrada.setOperacion ( "CI" );
		} else if ( !ENBLANCO.equals ( form.getAnioSel () ) ) {
			datosEntrada.setOperacion ( "LA" );
		} else if ( !ENBLANCO.equals ( form.getExpedienteSel () ) ) {
			datosEntrada.setOperacion ( "LE" );
		} else if ( !ENBLANCO.equals ( form.getPolizaSel () )
				|| !ENBLANCO.equals ( form.getSubpolizaSel () )
				|| !ENBLANCO.equals ( form.getCertificadoSel () )
				|| !ENBLANCO.equals ( form.getTipSituacion() )) {
			datosEntrada.setOperacion ( "LP" );
		} else if ( !ENBLANCO.equals ( form.getNifCif () ) ) {
			datosEntrada.setOperacion ( "LN" );
		} else {
			datosEntrada.setOperacion ( "LI" );
		}
		
		datosEntrada.setTipSituacion(form.getTipSituacion());

		return datosEntrada;
	}

	/**
	 * @param datosEntrada
	 * @return datosSalida
	 * @throws J372J001VencimientosException
	 */
	public J372J001BusquedaExpVenPageBean llamarServicio (
			J372J001BusquedaExpVenPageBean datosEntrada )
			throws J372J001VencimientosException {

		J372J001BusquedaExpVenPageBean datosSalida = new J372J001BusquedaExpVenPageBean ();

		try {

			datosSalida = J372J001ServicioBusquedaExpVenBean
					.ejecutaServicioCobol ( datosEntrada );

		} catch ( J372J001VencimientosException e ) {
			throw e;

		}
		return datosSalida;
	}

	/**
	 * Completa el bean de salida
	 * 
	 * @param datosSalida
	 * @param form
	 * @return form
	 * @throws J372J001VencimientosException
	 */
	public J372J001BusquedaExpVenActionForm ponerDatosSalida (
			J372J001BusquedaExpVenPageBean datosSalida,
			J372J001BusquedaExpVenActionForm form ) {
		UtilidadesBeanAction UTIL = new UtilidadesBeanAction ();
		form.setProAnio ( UTIL.numeroBig (
				datosSalida.getProAnio ().toString () ).toString () );

		form.setProExpediente ( UTIL.numeroBig (
				datosSalida.getProExpediente ().toString () ).toString () );

		form.setNif1 ( datosSalida.getNif1 () );
		
		if (!CEROS.equals ( datosSalida.getPoliza ())) {
		   form.setPolizaSel ( datosSalida.getPoliza () );
		}
		form.setNumRegistros ( datosSalida.getNumRegistros () );
		form.setRegistros ( datosSalida.getRegistros () );
		form.setListadoExp ( datosSalida.getListadoExp () );
		form.setPaginacion ( datosSalida.getPaginacion () );

		form.setDesRetorno ( datosSalida.getDesRetorno () );
		form.setRetorno ( datosSalida.getRetorno () );
		form.setNomPrograma ( datosSalida.getDesRetorno () );
		if ( OBJTRAZAS.isDebugEnabled () ) {
			OBJTRAZAS.debug ( "BusquedaExpVenHelperBean-S: retorno "
					+ datosSalida.getRetorno ().toString () );
			OBJTRAZAS.debug ( "BusquedaExpVenHelperBean-S: desRetorno "
					+ datosSalida.getDesRetorno ().toString () );
			OBJTRAZAS.debug ( "BusquedaExpVenHelperBean-S: nomPrograma "
					+ datosSalida.getNomPrograma ().toString () );

			OBJTRAZAS.debug ( "BusquedaExpVenHelperBean-S: anio "
					+ datosSalida.getAnio ().toString () );
			OBJTRAZAS.debug ( "BusquedaExpVenHelperBean-S: expediente "
					+ datosSalida.getExpediente ().toString () );
			OBJTRAZAS.debug ( "BusquedaExpVenHelperBean-S: nifCif "
					+ datosSalida.getNifCif ().toString () );
			OBJTRAZAS.debug ( "BusquedaExpVenHelperBean-S: ramo "
					+ datosSalida.getRamo ().toString () );
		}

		return form;
	}

}
