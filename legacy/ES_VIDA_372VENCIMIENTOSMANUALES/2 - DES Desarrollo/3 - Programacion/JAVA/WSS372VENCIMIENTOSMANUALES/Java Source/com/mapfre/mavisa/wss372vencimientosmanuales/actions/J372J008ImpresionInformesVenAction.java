package com.mapfre.mavisa.wss372vencimientosmanuales.actions;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;
import mapfre.wss000arquitect.excepciones.J000J000PrintConfigException;
import mapfre.wss000arquitect.impresion.PrintJob;
import mapfre.wss000arquitect.impresion.PrintJobSettings;
import mapfre.wss000arquitect.utilidades.J000J000Trazas;
import com.mapfre.mavisa.wss372vencimientosmanuales.config.J372J001ConstantesVen;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J005ImpresionInformesVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans.J372J005ImpresionInformesVenHelperBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J005ImpresionInformesVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.Mensajes;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

/**
 * @author everis. Action de impresion Informes
 * @version 1.0 Versión inicial
 */
public class J372J008ImpresionInformesVenAction extends MapfreAction

{
	/**
	 * objTrazas
	 */
	private static final Logger objTrazas = J000J000Trazas.getLogger ( J372J008ImpresionInformesVenAction.class );

	/**
	 * Inicializacion de la variable INCIO, valor INICIO
	 */
	private static final String INICIO = "INICIO";

	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * @see org.apache.struts.action.Action#execute(org.apache.struts.action.ActionMapping,
	 *      org.apache.struts.action.ActionForm,
	 *      javax.servlet.http.HttpServletRequest,
	 *      javax.servlet.http.HttpServletResponse)
	 *      
	 * @param mapping
	 * @param form
	 * @param request
	 * @param response
	 * 
	 * @returrn ActionForward forward
	 * 
	 * @throws J372J001VencimientosException
	 */
	@Override
	public ActionForward execute ( ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response )
			throws J372J001VencimientosException {

		ActionForward forward = new ActionForward ();

		Mensajes mensaje = new Mensajes ();
		J372J005ImpresionInformesVenActionForm formImprimirInformes = new J372J005ImpresionInformesVenActionForm ();

		PrintJobSettings printJobSettings;

		try {
			/* Damos al parameter en el struts-config un valor para que desde
			 * aqui podamos realizar todas las acciones que marquemos cuando se
			 * inicie la pantalla */
			final String parametro = mapping.getParameter ();
			mapping.getParameter ();
			/* inicio lo comparamos con un valor por si viene null dicho valor no falle */
			if ( INICIO.equalsIgnoreCase ( parametro ) ) {
				/* cuando entre se iniciará el formulario, esto solo pasará cuando entramos por primera vez desde inicio */
				formImprimirInformes = new J372J005ImpresionInformesVenActionForm ();
				formImprimirInformes.setTipOperacion ( "INICIO" );

			} else {
				/* pasamos el formulario generico a uno especifico */
				formImprimirInformes = ( J372J005ImpresionInformesVenActionForm ) form;
			}
			final J372J005ImpresionInformesVenHelperBean helperBean = new J372J005ImpresionInformesVenHelperBean ();
			/* Bean de Entrada y Salida en la llamada al servicio Cobol */
			J372J005ImpresionInformesVenPageBean pageBeanEntrada = new J372J005ImpresionInformesVenPageBean ();
			J372J005ImpresionInformesVenPageBean pageBeanSalida = new J372J005ImpresionInformesVenPageBean ();

			/* Variables gestión usuarios */
			final J000J000Usuario usuario = J000J000Usuario.getUsuarioArquitectura ( request );

			final String tipoOperacion = formImprimirInformes.getTipOperacion ();

			// Si estamos en la busqueda 'BU' llamamos al servicio Cobol.
			if ( "BU".equals ( formImprimirInformes.getTipOperacion () ) ) {

				/* Invocamos al metodo recogerDatosEntrada pasando los datos del
				 * formulario y el usuario al pagebean de entrada del servicio.*/
				pageBeanEntrada = helperBean.recogerDatosEntrada (
						formImprimirInformes, usuario );
				/* Llamamos al servicio cobol pasandole los datos de entrada */
				pageBeanSalida = helperBean.llamarServicio ( pageBeanEntrada );

				/* Se ejecuta la impresion de informes Mandaremos a jsp el IM en tipOperacion */
				printJobSettings = crearImpreso ();
				request.getSession ().setAttribute (
						J372J001ConstantesVen.DATOS_INFORME, pageBeanSalida );

				request.getSession ().setAttribute ( "printJob",printJobSettings );
				formImprimirInformes.setTipOperacion ( "IM" );
			}
			/* Si se hace la accion emitir se mostrara por pantalla un mensaje de OK */
			if ("BU".equals(tipoOperacion)) {
				if ( ("06").equals ( pageBeanSalida.getRetorno () )  ) {
					mensaje.setMensaje(1, "II", ENBLANCO, pageBeanSalida.getDesRetorno(), ENBLANCO, ENBLANCO);
				} else {
				mensaje.setMensaje(1, "II", ENBLANCO, getResources(request)
						.getMessage("rescate.mensaje.ok"), ENBLANCO, ENBLANCO);
				}
			}
			if ( !ENBLANCO.equalsIgnoreCase ( formImprimirInformes
					.getTipOperacion () )
					&& !"INICIO".equals ( formImprimirInformes
							.getTipOperacion () ) ) {

				mensaje.setMensaje ( 1, "II", ENBLANCO, formImprimirInformes
						.getDesRetorno (), ENBLANCO, ENBLANCO );
			}

		} catch ( J372J001VencimientosException e ) {
			/* LOGS trazas para poder seguir las diferentes exception de J372J001VencimientosException */
			if ( objTrazas.isEnabledFor ( Level.ERROR ) ) {
				objTrazas.error ( "ServicioImpresionInformesVenAction - Excepcion - Descripcion: " + e.getStDescripcion () );
				objTrazas.error ( "ServicioImpresionInformesVenAction - Excepcion - Localized:" + e.getLocalizedMessage () );
				objTrazas.error ( "ServicioImpresionInformesVenAction - Excepcion - Clase:" + e.getStClase () );
				objTrazas.error ( "ServicioImpresionInformesVenAction - Excepcion - Error:" + e.getStMensajeError () );
				objTrazas.error ( "ServicioImpresionInformesVenAction - Excepcion - Metodo:" + e.getStMetodo () );
			}
			final String desCodError = e.getStGError ();

			mensaje.setMensaje ( 1, "XX", ENBLANCO, desCodError, ENBLANCO,ENBLANCO );
			/* Si salta alguna excepcion Finally simpre va a continuar recogiendo el mensaje y mostrandolo por pantalla */
		} finally {
			/* Finally. Siempre se va a ejecutar, nos mostrara mensaje por pantalla */
			formImprimirInformes.setVectorMensajes ( mensaje.getVectorMensajes () );
			/* Devolvemos el formulario a la request donde lo deja guardado para recuperarlo despues.*/
			request.setAttribute ( "formImpresionInformes",
					formImprimirInformes );
		}
		/* si va todo bien OK le hemos puesto en el strust-confing una vía de acceso (redirigimos) */
		forward = mapping.findForward ( "OK" );
		/* Finish with */
		formImprimirInformes.setVectorMensajes ( mensaje.getVectorMensajes () );
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
			settings.setJobClass ( J372J016ImpresionInformesDirecta.class );
			settings
					.setCustomizedSuccessMessage ( "El documento se ha impreso correctamente" );
			settings
					.setCustomizedErrorMessage ( "El documento no se ha podido imprimir" );

			return settings;

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
	}
}
