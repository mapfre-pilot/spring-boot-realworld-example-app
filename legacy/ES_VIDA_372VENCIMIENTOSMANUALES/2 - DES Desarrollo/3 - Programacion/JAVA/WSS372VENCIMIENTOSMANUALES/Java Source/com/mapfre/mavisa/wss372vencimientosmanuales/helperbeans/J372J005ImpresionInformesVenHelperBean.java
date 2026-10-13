package com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans;

import java.math.BigDecimal;

import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;
import com.mapfre.mavisa.wss372vencimientosmanuales.actions.MapfreAction;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J005ImpresionInformesVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J005ImpresionInformesVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.servicios.J372J009ServicioImpresionInformesVenBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.UtilidadesBeanAction;

import org.apache.log4j.Logger;


/* MODIFICACION : MU-2015-035084
FECHA : 07/09/2015
DESCRIPCION : Añadimos nuevos criterios a los informes Resumento por Modalidad (tipo 07) 
AUTOR : INDRA */

/**
 * @author everis
 * @version 1.0 Versión inicial Clase de negocio. Recoge los datos del
 *          formulario de entrada y los almacena en una tabla generica. Realiza
 *          la llamada al servicio cobol, recuperando los datos en una tabla
 *          generica. Rellena el obteto de salida con los datos de la tabla de
 *          salida del servicio cobol.
 * 
 */

public class J372J005ImpresionInformesVenHelperBean extends MapfreAction {

	/**
	 * objTrazas nos mostraralas trazas de código
	 */
	public static Logger objTrazas = Logger
			.getLogger ( J372J005ImpresionInformesVenHelperBean.class );

	/**
	 * Mapea datos del form de entrada en el datosEntrada
	 * 
	 * @param usuario
	 * @param form
	 * @return datosEntrada 
	 */

	public J372J005ImpresionInformesVenPageBean recogerDatosEntrada (
			J372J005ImpresionInformesVenActionForm form, J000J000Usuario usuario ) {

		J372J005ImpresionInformesVenPageBean datosEntrada = new J372J005ImpresionInformesVenPageBean ();

		final UtilidadesBeanAction UTIL = new UtilidadesBeanAction ();

		datosEntrada.setUsuario ( usuario );

		datosEntrada.setTipo ( form.getTipo () );

		datosEntrada.setExpedHasta ( UTIL.numeroBig ( form.getExpedHasta () ) );
		datosEntrada.setExpedDesde ( UTIL.numeroBig ( form.getExpedDesde () ) );

		datosEntrada.setFecEmision ( form.getFecEmision () );
		datosEntrada.setFecCalculo ( form.getFecCalculo () );
		datosEntrada.setFecEmiHasta ( form.getFecEmiHasta () );
		datosEntrada.setFecEmiDesde ( form.getFecEmiDesde () );
		datosEntrada.setFecPagHasta ( form.getFecPagHasta () );
		datosEntrada.setFecPagDesde ( form.getFecPagDesde () );

		/*
		 * Si el tipo seleccionado es 1, 2 o 3 el valor de anio expediente se lo
		 * pasamos a anioDesde y anioHasta
		 */
		/*OJS  MU-2015-035084*/
		/*Se quita el tipo 08 puesto que se añade el criterio de Año Desde y Año Hasta por lo que no puede ser el de expediente*/
		if ( ( "01".equals ( form.getTipo () ) )
				|| ( "02".equals ( form.getTipo () ) )
				|| ( "03".equals ( form.getTipo () ) ) ){
				//|| ( "03".equals ( form.getTipo () ) )
				//|| ( "08".equals ( form.getTipo () ) ) ) {
		/*FIN  OJS  MU-2015-035084*/

			datosEntrada
					.setAnioDesde ( UTIL.numeroBig ( form.getAnioExped () ) );
			datosEntrada
					.setAnioHasta ( UTIL.numeroBig ( form.getAnioExped () ) );

		} else {

			datosEntrada
					.setAnioDesde ( UTIL.numeroBig ( form.getAnioDesde () ) );
			datosEntrada
					.setAnioHasta ( UTIL.numeroBig ( form.getAnioHasta () ) );
		}

		return datosEntrada;
	}

	/**
	 * 
	 * @param datosEntrada
	 * @return datosSalida
	 * @throws J372J001VencimientosException
	 */
	public J372J005ImpresionInformesVenPageBean llamarServicio (
			J372J005ImpresionInformesVenPageBean datosEntrada )
			throws J372J001VencimientosException {

		J372J005ImpresionInformesVenPageBean datosSalida = new J372J005ImpresionInformesVenPageBean ();

		// PRUEBAS
		// datosSalida.setListadoInf("PRUEBA");
		try {
			// datosSalida=ServicioImprimirInformesVenBean.ejecutaServicioCobol(datosEntrada);

			datosSalida = J372J009ServicioImpresionInformesVenBean
					.ejecutaServicioCobol ( datosEntrada );

		} catch ( J372J001VencimientosException e ) {
			throw e;
		}
		return datosSalida;
	}

	/**
	 * 
	 * @param datosSalida
	 * @param form
	 * @return form
	 * @throws J372J001VencimientosException
	 */
	public J372J005ImpresionInformesVenActionForm ponerDatosSalida (
			J372J005ImpresionInformesVenPageBean datosSalida,
			J372J005ImpresionInformesVenActionForm form )
			throws J372J001VencimientosException {

		// nos devuelven
		form.setListadoInf ( datosSalida.getListadoInf () );
		form.setDesRetorno ( datosSalida.getDesRetorno () );
		form.setRetorno ( datosSalida.getRetorno () );
		form.setnomPrograma ( datosSalida.getDesRetorno () );
		if ( objTrazas.isDebugEnabled () ) {
			objTrazas.debug ( "ImpresionInformesVenHelperBean-S: listado "
					+ datosSalida.getListadoInf ().toString () );

			objTrazas.debug ( "ImpresionInformesVenHelperBean-S: nomPrograma "
					+ datosSalida.getNomPrograma ().toString () );

			objTrazas.debug ( "ImpresionInformesVenHelperBean-S: retorno "
					+ datosSalida.getRetorno ().toString () );
			objTrazas.debug ( "ImpresionInformesVenHelperBean-S: desRetorno "
					+ datosSalida.getDesRetorno ().toString () );
		}
		return form;
	}

}
