package com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans;

import java.math.BigDecimal;

import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;
import com.mapfre.mavisa.wss372vencimientosmanuales.actions.MapfreAction;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J004GestionVariablesVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J004GestionVariablesVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.servicios.J372J006ServicioGestionVariablesBean;
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

public class J372J004GestionVariablesVenHelperBean extends MapfreAction {

	/**
	 * objTrazas nos mostraralas trazas de código
	 */
	final private static Logger OBJTRAZAS = Logger
			.getLogger ( J372J004GestionVariablesVenHelperBean.class );

	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	final UtilidadesBeanAction UTIL = new UtilidadesBeanAction ();

	/**
	 * 
	 * @param form
	 * @param usuario
	 * @return datosEntrada
	 * @throws J372J001VencimientosException
	 */
	public J372J004GestionVariablesVenPageBean recogerDatosEntrada (
			J372J004GestionVariablesVenActionForm form, J000J000Usuario usuario ) {

		J372J004GestionVariablesVenPageBean datosEntrada = new J372J004GestionVariablesVenPageBean ();

		if ( form != null ) {

			if ( this.UTIL.isEntero ( form.getAnio () ) ) {
				datosEntrada.setAnio ( new BigDecimal ( form.getAnio () ) );
			} else {
				datosEntrada.setAnio ( new BigDecimal ( 0 ) );
			}

			if ( this.UTIL.isEntero ( form.getExpediente () ) ) {
				datosEntrada.setExpediente ( new BigDecimal ( form.getExpediente () ) );
			} else {
				datosEntrada.setExpediente ( new BigDecimal ( 0 ) );
			}
			datosEntrada.setUsuario ( usuario );

			if ( "SA".equals ( form.getTipOperacion () ) ) {
				datosEntrada.setTipOperacion ( "M1" );
			} else if ( "BA".equals ( form.getTipOperacion () ) ) {
				datosEntrada.setTipOperacion ( "I1" );
			} else {
				datosEntrada.setTipOperacion ( "S1" );
			}
		}
		return datosEntrada;
	}

	/**
	 * @param datosEntradas
	 * @return datosSalida
	 * @throws J372J001VencimientosException
	 */
	public J372J004GestionVariablesVenPageBean llamarServicio (
			J372J004GestionVariablesVenPageBean datosEntrada )
			throws J372J001VencimientosException {

		J372J004GestionVariablesVenPageBean datosSalida = new J372J004GestionVariablesVenPageBean ();

		try {
			datosSalida = J372J006ServicioGestionVariablesBean
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
	public J372J004GestionVariablesVenActionForm ponerDatosSalida (
			J372J004GestionVariablesVenPageBean datosSalida,
			J372J004GestionVariablesVenActionForm form ) {

		form.setAnio ( datosSalida.getAnio ().toString () );
		form.setExpediente ( datosSalida.getExpediente ().toString () );

		form.setDesRetorno ( datosSalida.getDesRetorno () );
		form.setRetorno ( datosSalida.getRetorno () );
		form.setNomPrograma ( datosSalida.getDesRetorno () );
		if ( OBJTRAZAS.isDebugEnabled () ) {
			OBJTRAZAS.debug ( "estionVariablesVenHelperBean-S: anio "
					+ datosSalida.getAnio ().toString () );
			OBJTRAZAS.debug ( "estionVariablesVenHelperBean-S: expediente "
					+ datosSalida.getExpediente ().toString () );
			OBJTRAZAS.debug ( "estionVariablesVenHelperBean-S: retorno "
					+ datosSalida.getRetorno ().toString () );
			OBJTRAZAS.debug ( "estionVariablesVenHelperBean-S: desRetorno "
					+ datosSalida.getDesRetorno ().toString () );
			OBJTRAZAS.debug ( "estionVariablesVenHelperBean-S: nomPrograma "
					+ datosSalida.getNomPrograma ().toString () );
		}

		return form;
	}

}
