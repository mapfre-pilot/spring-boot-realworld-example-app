package com.mapfre.mavisa.wss372vencimientosmanuales.actions;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;
import mapfre.wss000arquitect.excepciones.J000J000PrintConfigException;
import mapfre.wss000arquitect.impresion.PrintJob;
import mapfre.wss000arquitect.impresion.PrintJobSettings;
import mapfre.wss000arquitect.utilidades.J000J000Trazas;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import com.mapfre.mavisa.wss372vencimientosmanuales.config.J372J001ConstantesVen;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J002EmisionFiniquitosVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans.J372J002EmisionFiniquitosVenHelperBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J002EmisionFiniquitosVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.Mensajes;

/**
 * @author everis. Action de Emision Finiquitos
 * @version 1.0 Versión inicial
 */
public class J372J003EmisionFiniquitosVenAction extends MapfreAction

{
	/**
	 * objTrazas
	 */
	private static final Logger objTrazas = J000J000Trazas.getLogger ( J372J003EmisionFiniquitosVenAction.class );

	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inicializacion de la variable OK, valor OK
	 */
	private static final String OK = "OK";

	/**
	 * Inicializacion de la variable INICIO, valor INICIO
	 */
	private static final String INICIO = "inicio";

	/**
	 * @see org.apache.struts.action.Action#execute(org.apache.struts.action.ActionMapping,
	 *      org.apache.struts.action.ActionForm,
	 *      javax.servlet.http.HttpServletRequest,
	 *      javax.servlet.http.HttpServletResponse)
	 * 
	 * @throws J372J001VencimientosException
	 * 
	 * @return ActionForward forward
	 */
	@Override
	public ActionForward execute ( ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response )
			throws J372J001VencimientosException {

		ActionForward forward = new ActionForward ();

		Mensajes mensaje = new Mensajes ();
		J372J002EmisionFiniquitosVenActionForm formFiniquitos = new J372J002EmisionFiniquitosVenActionForm ();

		PrintJobSettings printJobSettings;

		try {
			/* Damos al parameter en el struts-config un valor para que desde
			 * aqui podamos realizar todas las acciones que marquemos cuando se
			 * inicie la pantalla*/
			final String parametro = mapping.getParameter ();
			mapping.getParameter ();
			/* inicio lo comparamos con un valor por si viene null dicho valor no falle */
			if ( INICIO.equalsIgnoreCase ( parametro ) ) {
				/*
				 * cuando entre se iniciará el formulario, esto solo pasará
				 * cuando entramos por primera vez desde inicio
				 */
				formFiniquitos = new J372J002EmisionFiniquitosVenActionForm ();
				formFiniquitos.setTipOperacion ( "INICIO" );
			} else {

				/* Pasamos el formulario generico a uno especific */
				formFiniquitos = ( J372J002EmisionFiniquitosVenActionForm ) form;
			}

			final J372J002EmisionFiniquitosVenHelperBean helperBean = new J372J002EmisionFiniquitosVenHelperBean ();

			/* Bean de Entrada y Salida en la llamada al servicio Cobol */
			J372J002EmisionFiniquitosVenPageBean pageBeanEntrada = new J372J002EmisionFiniquitosVenPageBean ();
			J372J002EmisionFiniquitosVenPageBean pageBeanSalida = new J372J002EmisionFiniquitosVenPageBean ();

			final J000J000Usuario usuario = J000J000Usuario.getUsuarioArquitectura ( request );

			final String tipoOperacion = formFiniquitos.getTipOperacion ();

			/* Si estamos en la busqueda 'BU' llamamos al servicio Cobol. */
			if ( "BU".equals ( formFiniquitos.getTipOperacion () ) ) {

				/* Invocamos al metodo recogerDatosEntrada pasando los datos del
				 * formulario y el usuario al pagebean de entrada del servicio. */
				pageBeanEntrada = helperBean.recogerDatosEntrada (
						formFiniquitos, usuario );
				/* Llamamos al servicio cobol pasandole los datos de entrada */
				pageBeanSalida = helperBean.llamarServicio ( pageBeanEntrada );
				/* Pasamos los parametros de salida del servicio desde el
				 * pagebean de salida al formulario. Se ejecuta la impresion de
				 * informes Mandaremos a jsp el IM en tipOperacion*/
				printJobSettings = crearImpreso ();

				request.getSession ().setAttribute (J372J001ConstantesVen.DATOS_EMISION, pageBeanSalida );
				request.getSession ().setAttribute ( "printJob",printJobSettings );
				formFiniquitos.setTipOperacion ( "IM" );
			}
			/* Si se hace la accion emitir se mostrara por pantalla un mensaje de OK */
			if ( "BU".equals ( tipoOperacion ) ) {

				if ( ("06").equals ( pageBeanSalida.getRetorno () )  ) {
					mensaje.setMensaje(1, "II", ENBLANCO, pageBeanSalida.getDesRetorno(), ENBLANCO, ENBLANCO);
				} else {
					mensaje.setMensaje(1, "II", ENBLANCO, getResources(request)
						.getMessage("rescate.mensaje.ok"), ENBLANCO, ENBLANCO);
				}
			}

			if ( !ENBLANCO
					.equalsIgnoreCase ( formFiniquitos.getTipOperacion () )
					&& !"INICIO".equals ( formFiniquitos.getTipOperacion () ) ) {

				mensaje.setMensaje ( 1, "II", ENBLANCO, formFiniquitos
						.getDesRetorno (), ENBLANCO, ENBLANCO );
			}

		} catch ( J372J001VencimientosException e ) {
			/* LOGS trazas para poder seguir las diferentes exception de J372J001VencimientosException */
			if ( objTrazas.isEnabledFor ( Level.ERROR ) ) {
				objTrazas.error ( "EmisionFiniquitosVenAction - Excepcion - Descripcion: " + e.getStDescripcion () );
				objTrazas.error ( "EmisionFiniquitosVenAction - Excepcion - Localized:" + e.getLocalizedMessage () );
				objTrazas.error ( "EmisionFiniquitosVenAction - Excepcion - Clase:" + e.getStClase () );
				objTrazas.error ( "EmisionFiniquitosVenAction - Excepcion - Error:" + e.getStMensajeError () );
				objTrazas.error ( "EmisionFiniquitosVenAction - Excepcion - Metodo:" + e.getStMetodo () );
			}
			final String desCodError = e.getStGError ();
			mensaje.setMensaje ( 1, "XX", ENBLANCO, desCodError, ENBLANCO,ENBLANCO );
		} finally {
			/* Finally. Siempre se va a ejecutar, nos mostrara mensaje por pantalla */
			formFiniquitos.setVectorMensajes ( mensaje.getVectorMensajes () );
			/* Devolvemos el formulario a la request donde lo deja guardado para recuperarlo despues. */
			request.setAttribute ( "formEmisionFiniquitos", formFiniquitos );
		}
		/* si va todo bien OK le hemos puesto en el strust-confing una vía de acceso (redirigimos) */
		forward = mapping.findForward ( OK );
		/* Finish with */
		formFiniquitos.setVectorMensajes ( mensaje.getVectorMensajes () );
		return ( forward );
	}

	/**
	 * Crea el objeto necesario para la impresion
	 * 
	 * @return PrintJobSettings
	 * @throws J372J001VencimientosException
	 */
	private PrintJobSettings crearImpreso ()
			throws J372J001VencimientosException {
		PrintJobSettings settings = new PrintJobSettings ();
		try {
			settings.setOutputType ( PrintJob.OUT_ONLINE );

			settings.setOnlineType ( PrintJob.ONLINE_PREVIEW );

			settings.setDescription ( "VENCIMIENTOS" );
			settings.setJobClass ( J372J017ImpresionEmisionDirecta.class );
			settings
					.setCustomizedSuccessMessage ( "El documento se ha impreso correctamente" );
			settings
					.setCustomizedErrorMessage ( "El documento no se ha podido imprimir" );

		} catch ( J000J000PrintConfigException e ) {
			J372J001VencimientosException objException = 
				new J372J001VencimientosException (J372J001VencimientosException.ERROR_CONFIGURACION, ENBLANCO );
			objException.setStDescripcion ( e.getLocalizedMessage () );
			objException.setStClase ( e.getClass ().toString () );
			objException.setStGNomProg ( ENBLANCO );
			objException.setStGError ( "Error en la Impresión" );
			objException.setStCRetorno ( ENBLANCO );

			throw objException;

		}
		return settings;
	}
}
