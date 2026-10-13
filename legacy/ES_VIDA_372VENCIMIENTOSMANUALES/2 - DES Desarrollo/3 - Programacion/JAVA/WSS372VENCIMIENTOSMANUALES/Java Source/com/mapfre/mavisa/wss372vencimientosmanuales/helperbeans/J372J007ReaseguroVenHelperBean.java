package com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans;

import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;
import com.mapfre.mavisa.wss372vencimientosmanuales.actions.MapfreAction;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J007ReaseguroVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J008GestionExpedientesVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.servicios.J372J005ServicioGestionExpVenBean;
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

public class J372J007ReaseguroVenHelperBean extends MapfreAction {

	/**
	 * objTrazas nos mostraralas trazas de código
	 */
	private static final Logger OBJTRAZAS = Logger.getLogger ( J372J007ReaseguroVenHelperBean.class );

	/**
	 * Mapea datos del form de entrada en el datosEntrada La llamada Cobol se
	 * hace a traves del xml vt01.
	 * 
	 * @param form
	 * @param usuario
	 * @return datosEntrada
	 */
	public J372J008GestionExpedientesVenPageBean recogerDatosEntrada (
			J372J007ReaseguroVenActionForm form, J000J000Usuario usuario ) {

		J372J008GestionExpedientesVenPageBean datosEntrada = new J372J008GestionExpedientesVenPageBean ();

		datosEntrada.setUsuario ( usuario );

		if ( "M3".equals ( form.getOperacion () ) ) { //$NON-NLS-1$
			datosEntrada.setOperacion ( "M3" );//$NON-NLS-1$
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
	public J372J008GestionExpedientesVenPageBean llamarServicio (
			J372J008GestionExpedientesVenPageBean datosEntrada )
			throws J372J001VencimientosException {

		J372J008GestionExpedientesVenPageBean datosSalida = new J372J008GestionExpedientesVenPageBean ();

		try {
			datosSalida = J372J005ServicioGestionExpVenBean.ejecutaServicioCobol ( datosEntrada );

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
	 */
	public J372J007ReaseguroVenActionForm ponerDatosSalida (
			J372J008GestionExpedientesVenPageBean datosSalida,
			J372J007ReaseguroVenActionForm form ) {

		form.setDesRetorno ( datosSalida.getDesRetorno () );
		form.setRetorno ( datosSalida.getRetorno () );
		form.setNomPrograma ( datosSalida.getDesRetorno () );
		if ( OBJTRAZAS.isDebugEnabled () ) {
			OBJTRAZAS.debug ( "ReaseguroVenHelperBean-S: retorno " //$NON-NLS-1$
					+ datosSalida.getRetorno ().toString () );
			OBJTRAZAS.debug ( "ReaseguroVenHelperBean-S: desRetorno " //$NON-NLS-1$
					+ datosSalida.getDesRetorno ().toString () );
			OBJTRAZAS.debug ( "ReaseguroVenHelperBean-S: nomPrograma " //$NON-NLS-1$
					+ datosSalida.getNomPrograma ().toString () );
		}
		return form;
	}

}
