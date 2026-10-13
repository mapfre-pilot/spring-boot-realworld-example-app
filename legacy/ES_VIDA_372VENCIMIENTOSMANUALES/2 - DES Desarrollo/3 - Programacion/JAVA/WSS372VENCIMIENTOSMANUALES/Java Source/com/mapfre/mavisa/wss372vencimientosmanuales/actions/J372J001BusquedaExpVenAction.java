package com.mapfre.mavisa.wss372vencimientosmanuales.actions;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J001BusquedaExpVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans.J372J001BusquedaExpVenHelperBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J001BusquedaExpVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.Mensajes;

import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

/**
 * @author everis. Action de Emision Finiquitos
 * @version 1.0 Versión inicial
 */
public class J372J001BusquedaExpVenAction extends MapfreAction

{
	/**
	 * Inicializacion varible ENBLANCO, valor en BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inicializacion varible OK, valor OK
	 */
	private static final String OK = "OK";

	/**
	 * Inicializacion varible INICIO, valor inicio
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

		J372J001BusquedaExpVenActionForm formBusquedaExpediente = new J372J001BusquedaExpVenActionForm ();

		try {
			/*
			 * Damos al parameter en el struts-config un valor para que desde
			 * aqui podamos realizar todas las acciones que marquemos cuando se
			 * inicie la pantalla
			 */
			final String PARAMETRO = mapping.getParameter ();
			mapping.getParameter ();
			/*
			 * inicio lo comparamos con un valor por si viene null dicho valor
			 * no falle
			 */
			if ( INICIO.equalsIgnoreCase ( PARAMETRO ) ) {
				/*
				 * cuando entre se iniciará el formulario, esto solo pasará
				 * cuando entramos por primera vez desde inicio
				 */
				formBusquedaExpediente = new J372J001BusquedaExpVenActionForm ();

				formBusquedaExpediente.setMostrarResultado ( true );
				/* Cuando se inicie la sesion se limpiara */
				request.getSession ().removeAttribute ( "formBusquedaExp" );
			} else {
				/* Bean de Entrada y Salida en la llamada al servicio Cobol */
				final J372J001BusquedaExpVenHelperBean HELPERBEAN = new J372J001BusquedaExpVenHelperBean ();
				J372J001BusquedaExpVenPageBean pageBeanEntrada = new J372J001BusquedaExpVenPageBean ();
				J372J001BusquedaExpVenPageBean pageBeanSalida = new J372J001BusquedaExpVenPageBean ();

				/* Pasamos el formulario generico a uno especifico */
				formBusquedaExpediente = ( J372J001BusquedaExpVenActionForm ) form;

				final J000J000Usuario usuario = J000J000Usuario
						.getUsuarioArquitectura ( request );
				/*
				 * Invocamos al metodo recogerDatosEntrada,los datos del
				 * formulario y usuario, al pagebean de entrada del servicio.
				 */
				pageBeanEntrada = HELPERBEAN.recogerDatosEntrada (
						formBusquedaExpediente, usuario );
				/* Llamamos al servicio cobol pasandole los datos de entrada */
				pageBeanSalida = HELPERBEAN.llamarServicio ( pageBeanEntrada );
				/*
				 * Pasamos los parametros de salida del servicio desde el
				 * pagebean de salida al formulario.
				 */

				formBusquedaExpediente = HELPERBEAN.ponerDatosSalida (
						pageBeanSalida, formBusquedaExpediente );

				if ( !INICIO.equalsIgnoreCase ( PARAMETRO ) ) {

					formBusquedaExpediente.setMostrarResultado ( true );
				}
			}

		} catch ( J372J001VencimientosException e ) {

			final String DESCODERROR = e.getStGError ();

			mensaje.setMensaje ( 1, "XX", ENBLANCO, DESCODERROR, ENBLANCO,
					ENBLANCO );

		} finally {

			formBusquedaExpediente.setVectorMensajes ( mensaje
					.getVectorMensajes () );

			request.setAttribute ( "formBusquedaExp", formBusquedaExpediente );

			request.getSession ().setAttribute ( "formBusquedaExp",
					formBusquedaExpediente );
		}
		/*
		 * si va todo bien OK le hemos puesto en el strust-confing una vía de
		 * acceso (redirigimos)
		 */
		forward = mapping.findForward ( OK );
		/* Finish with */
		return ( forward );
	}
}
