package com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans;

import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;
import com.mapfre.mavisa.wss372vencimientosmanuales.actions.MapfreAction;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J008GestionExpedientesVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J009ConsultaCarteraVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.servicios.J372J007ServicioConsultaCarteraVenBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.UtilidadesBeanAction;
import org.apache.log4j.Logger;

/**
 * @author everis
 * @version 1.0 Versión inicial Clase de negocio. Recoge los datos del
 *          formulario de entrada y los almacena en una tabla generica. Realiza
 *          la llamada al servicio cobol, recuperando los datos en una tabla
 *          generica. Rellena el obteto de salida con los datos de la tabla de
 *          salida del servicio cobol.
 * 
 */

public class J372J009ConsultaCarteraVenHelperBean extends MapfreAction {

	/**
	 * objTrazas nos mostraralas trazas de código
	 */
	public static Logger objTrazas = Logger.getLogger ( J372J009ConsultaCarteraVenHelperBean.class );

	/**
	 * Inicializamos el ENBLANCO
	 */
	private static final String ENBLANCO = ""; //$NON-NLS-1$

	/**
	 * Mapea datos del form de entrada en el datosEntrada
	 * 
	 * @param form
	 * @param usuario
	 * @return datosEntrada
	 * @throws J372J001VencimientosException
	 */
	public J372J009ConsultaCarteraVenPageBean recogerDatosEntrada (
			J372J008GestionExpedientesVenActionForm form,
			J000J000Usuario usuario ) throws J372J001VencimientosException {

		J372J009ConsultaCarteraVenPageBean datosEntrada = new J372J009ConsultaCarteraVenPageBean ();
		final UtilidadesBeanAction util = new UtilidadesBeanAction ();

		if ( form != null ) {

			// datosEntrada.setPoliza(form.getPolizaBloq3());
			// datosEntrada.setSubpoliza(form.getSubpoliza());
			// datosEntrada.setCertificado(form.getCertificado());
			datosEntrada.setUsuario ( usuario );

			/*
			 * llamamos al metodo de la clase UtilidadesBean, para que rellene
			 * el string con ceros a la izquierda hasta completar el tamaño.
			 */
			datosEntrada.setPoliza ( util.rellenarCerosIzq ( 10, form
					.getPolizaBloq3 () ) );
			datosEntrada.setSubpoliza ( util.rellenarCerosIzq ( 4, form
					.getSubpoliza () ) );
			datosEntrada.setCertificado ( util.rellenarCerosIzq ( 6, form
					.getCertificado () ) );
			
		}

		return datosEntrada;
	}

	/**
	 * Llamada al servicio
	 * 
	 * @param datosEntrada
	 * @return datosSalida
	 * @throws J372J001VencimientosException
	 */
	public J372J009ConsultaCarteraVenPageBean llamarServicio (
			J372J009ConsultaCarteraVenPageBean datosEntrada )
			throws J372J001VencimientosException {

		J372J009ConsultaCarteraVenPageBean datosSalida = new J372J009ConsultaCarteraVenPageBean ();

		try {
			datosSalida = J372J007ServicioConsultaCarteraVenBean.ejecutaServicioCobol ( datosEntrada );

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
	public J372J008GestionExpedientesVenActionForm ponerDatosSalida (
			J372J009ConsultaCarteraVenPageBean datosSalida,
			J372J008GestionExpedientesVenActionForm form )
			throws J372J001VencimientosException {

		
		form.setAnio ( ENBLANCO );
	    form.setExpediente ( ENBLANCO );
		form.setPolizaBloq1 ( datosSalida.getRamo () );
		form.setPolizaBloq2 ( datosSalida.getAniopol () );
		form.setPolizaBloq3 ( datosSalida.getPolizaSalida () );
		form.setSubpoliza ( datosSalida.getSubPolizaSalida () );
		form.setCertificado ( datosSalida.getCertificado () );

		form.setFecAnul ( datosSalida.getFecAnul () );
		form.setRegionalPol ( datosSalida.getRegionalPol () );
		form.setRegionalEnv(datosSalida.getRegionalPol () );
		form.setFecEfect ( datosSalida.getFecEfecto () );
		form.setCanalCamp ( datosSalida.getCanalCamp () );

		form.setTomador ( datosSalida.getTomador () );
		
		
		UtilidadesBeanAction UTIL = new UtilidadesBeanAction ();
		boolean fecha = UTIL.comprobarFormatoFecha ( datosSalida.getDuracion ());
		if (fecha == true) {
			form.setFecVencimiento ( datosSalida.getDuracion () );
		} else {
			form.setDuracion ( datosSalida.getDuracion () );
		}
		form.setModalidad ( datosSalida.getModalidad () );
		form.setSubpoliza ( datosSalida.getSubPolizaSalida () );

		if ( "V".equals ( datosSalida.getSituacion () ) ) {

			form.setTipSituacion ( "VI" );

		} else if ( "A".equals ( datosSalida.getSituacion () ) ) {

			form.setTipSituacion ( "AN" );
		}

		form.setEntidad ( datosSalida.getEntidad () );
		form.setOficina ( datosSalida.getOficina () );

		form.setNifCifPri ( datosSalida.getNifCifPri () );

		form.setDesRetorno ( datosSalida.getDesRetorno () );
		form.setRetorno ( datosSalida.getRetorno () );
		form.setNomPrograma ( datosSalida.getDesRetorno () );
		if ( objTrazas.isDebugEnabled () ) {
			objTrazas.debug ( "ConsultaCarteraVenHelperBean-S: Aniopol "
					+ datosSalida.getAniopol ().toString () );
			objTrazas.debug ( "ConsultaCarteraVenHelperBean-S: Ramo "
					+ datosSalida.getRamo ().toString () );
			objTrazas.debug ( "ConsultaCarteraVenHelperBean-S: PolizaSalida "
					+ datosSalida.getPolizaSalida ().toString () );
			objTrazas.debug ( "ConsultaCarteraVenHelperBean-S: FecAnul "
					+ datosSalida.getFecAnul ().toString () );
			objTrazas.debug ( "ConsultaCarteraResHelperBean-S: RegionalPol "
					+ datosSalida.getRegionalPol ().toString () );
			objTrazas.debug ( "ConsultaCarteraVenHelperBean-S: CanalCamp "
					+ datosSalida.getCanalCamp ().toString () );
			objTrazas.debug ( "ConsultaCarteraVenHelperBean-S: FecEfecto "
					+ datosSalida.getFecEfecto ().toString () );
			objTrazas.debug ( "ConsultaCarteraVenHelperBean-S: Tomador "
					+ datosSalida.getTomador ().toString () );
			objTrazas.debug ( "ConsultaCarteraVenHelperBean-S: Modalidad "
					+ datosSalida.getModalidad ().toString () );
			objTrazas
					.debug ( "ConsultaCarteraVenHelperBean-S: SubPolizaSalida "
							+ datosSalida.getSubPolizaSalida ().toString () );
			objTrazas.debug ( "ConsultaCarteraVenHelperBean-S: Situacion "
					+ datosSalida.getSituacion ().toString () );
			objTrazas.debug ( "ConsultaCarteraVenHelperBean-S: Oficina "
					+ datosSalida.getOficina ().toString () );
			objTrazas.debug ( "ConsultaCarteraVenHelperBean-S: NifCifPri "
					+ datosSalida.getNifCifPri ().toString () );
			objTrazas.debug ( "ConsultaCarteraVenHelperBean-S: retorno "
					+ datosSalida.getRetorno ().toString () );
			objTrazas.debug ( "ConsultaCarteraVenHelperBean-S: desRetorno "
					+ datosSalida.getDesRetorno ().toString () );
			objTrazas.debug ( "ConsultaCarteraVenHelperBean-S: nomPrograma "
					+ datosSalida.getNomPrograma ().toString () );
		}

		return form;
	}

}
