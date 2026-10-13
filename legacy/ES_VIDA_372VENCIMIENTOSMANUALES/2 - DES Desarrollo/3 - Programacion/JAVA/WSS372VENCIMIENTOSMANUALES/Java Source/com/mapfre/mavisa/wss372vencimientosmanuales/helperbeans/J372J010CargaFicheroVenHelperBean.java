package com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans;

import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;
import com.mapfre.mavisa.wss372vencimientosmanuales.actions.MapfreAction;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J010CargaFicheroVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J010CargaFicheroVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.servicios.J372J010ServicioCargaFicheroBean;

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

public class J372J010CargaFicheroVenHelperBean extends MapfreAction {

	/**
	 * objTrazas nos mostraralas trazas de código
	 */
	public static Logger objTrazas = Logger.getLogger ( J372J010CargaFicheroVenHelperBean.class );

	/**
	 * Mapea datos del form de entrada en el datosEntrada La llamada Cobol se
	 * hace a traves del xml vt07.
	 * 
	 * @param form
	 * @param usuario
	 * @return datosEntrada
	 * @throws J372J001VencimientosException
	 */
	public J372J010CargaFicheroVenPageBean recogerDatosEntrada (
			J372J010CargaFicheroVenActionForm form, J000J000Usuario usuario )
			throws J372J001VencimientosException {

		J372J010CargaFicheroVenPageBean datosEntrada = new J372J010CargaFicheroVenPageBean ();

		datosEntrada.setTipo ( form.getTipo () );
		datosEntrada.setUsuario ( usuario );

		return datosEntrada;
	}

	/**
	 * Llamada al servicio
	 * 
	 * @param datosEntrada
	 * @return datosSalida
	 * @throws J372J001VencimientosException
	 */
	public J372J010CargaFicheroVenPageBean llamarServicio (
			J372J010CargaFicheroVenPageBean datosEntrada )
			throws J372J001VencimientosException {

		J372J010CargaFicheroVenPageBean datosSalida = new J372J010CargaFicheroVenPageBean ();

		try {
			datosSalida = J372J010ServicioCargaFicheroBean.ejecutaServicioCobol ( datosEntrada );

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
	public J372J010CargaFicheroVenActionForm ponerDatosSalida (
			J372J010CargaFicheroVenPageBean datosSalida,
			J372J010CargaFicheroVenActionForm form )
			throws J372J001VencimientosException {

		form.setDesRetorno ( datosSalida.getDesRetorno () );
		form.setRetorno ( datosSalida.getRetorno () );
		form.setNomPrograma ( datosSalida.getDesRetorno () );
		if ( objTrazas.isDebugEnabled () ) {
			objTrazas.debug ( "CargaFicheroVenHelperBean-S: retorno "
					+ datosSalida.getRetorno ().toString () );
			objTrazas.debug ( "CargaFicheroVenHelperBean-S: desRetorno "
					+ datosSalida.getDesRetorno ().toString () );
			objTrazas.debug ( "CargaFicheroVenHelperBean-S: nomPrograma "
					+ datosSalida.getNomPrograma ().toString () );
		}
		return form;
	}

}
