package com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans;

import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;

import com.mapfre.mavisa.wss372vencimientosmanuales.actions.MapfreAction;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J002EmisionFiniquitosVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J002EmisionFiniquitosVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.servicios.J372J004ServicioEmisionFiniquitosVenBean;
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

public class J372J002EmisionFiniquitosVenHelperBean extends MapfreAction {

	/**
	 * objTrazas nos mostraralas trazas de código
	 */
	private static final Logger OBJTRAZAS = Logger.getLogger ( J372J002EmisionFiniquitosVenHelperBean.class );

	/**
	 * Mapea datos del form de entrada en el datosEntrada
	 * 
	 * @param form
	 * @param usuario
	 * @return datosEntrada
	 * @throws J372J001VencimientosException
	 */

	public J372J002EmisionFiniquitosVenPageBean recogerDatosEntrada (
			J372J002EmisionFiniquitosVenActionForm form, J000J000Usuario usuario ) {

		J372J002EmisionFiniquitosVenPageBean datosEntrada = new J372J002EmisionFiniquitosVenPageBean ();
		final UtilidadesBeanAction UTIL = new UtilidadesBeanAction ();

		datosEntrada.setUsuario ( usuario );

		datosEntrada.setAnio ( form.getAnio () );

        datosEntrada.setExpedDesde ( UTIL.numeroBig ( form.getExpedDesde () ) );		
		datosEntrada.setExpedHasta ( UTIL.numeroBig ( form.getExpedHasta () ) );
		
		datosEntrada.setFecEfectEmision ( form.getFecEfectEmision () );
		datosEntrada.setEmisionFiniqui ( form.getEmisionFiniqui () );
		datosEntrada.setRegionalEnvio ( form.getRegionalEnvio () );

		datosEntrada.setAntAnio ( UTIL.numeroBig ( form.getAntAnio () ) );
		datosEntrada.setAntExpediente ( UTIL.numeroBig ( form.getAntExpediente () ) );
	
		return datosEntrada;
	}

	/**
	 * Llamada al servicio
	 * 
	 * @param datosEntrada
	 * @return datosSalida
	 * @throws J372J001VencimientosException
	 */
	public J372J002EmisionFiniquitosVenPageBean llamarServicio (
			J372J002EmisionFiniquitosVenPageBean datosEntrada )
			throws J372J001VencimientosException {

		J372J002EmisionFiniquitosVenPageBean datosSalida = new J372J002EmisionFiniquitosVenPageBean ();

		try {
			datosSalida = J372J004ServicioEmisionFiniquitosVenBean.ejecutaServicioCobol ( datosEntrada );

		}

		catch ( J372J001VencimientosException e ) {
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
	public J372J002EmisionFiniquitosVenActionForm ponerDatosSalida (
			J372J002EmisionFiniquitosVenPageBean datosSalida,
			J372J002EmisionFiniquitosVenActionForm form )  {

		// nos devuelven
		form.setListadoEmi ( datosSalida.getListadoEmi () );
		form.setDesRetorno ( datosSalida.getDesRetorno () );
		form.setRetorno ( datosSalida.getRetorno () );
		form.setNomPrograma ( datosSalida.getDesRetorno () );
		if ( OBJTRAZAS.isDebugEnabled () ) {
			OBJTRAZAS.debug ( "EmisionFiniquitosVenHelperBean-S: listado "
					+ datosSalida.getListadoEmi ().toString () );

			OBJTRAZAS.debug ( "EmisionFiniquitosVenHelperBean-S: nomPrograma "
					+ datosSalida.getNomPrograma ().toString () );

			OBJTRAZAS.debug ( "EmisionFiniquitosVenHelperBean-S: retorno "
					+ datosSalida.getRetorno ().toString () );
			OBJTRAZAS.debug ( "EmisionFiniquitosVenHelperBean-S: desRetorno "
					+ datosSalida.getDesRetorno ().toString () );
		}
		return form;
	}

}
