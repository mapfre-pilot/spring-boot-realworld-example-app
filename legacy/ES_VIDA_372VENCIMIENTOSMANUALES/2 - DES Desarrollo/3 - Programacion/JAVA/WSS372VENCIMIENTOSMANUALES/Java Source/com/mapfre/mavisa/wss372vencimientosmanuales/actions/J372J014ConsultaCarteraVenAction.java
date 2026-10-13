package com.mapfre.mavisa.wss372vencimientosmanuales.actions;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;
import mapfre.wss000arquitect.utilidades.J000J000Trazas;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J008GestionExpedientesVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans.J372J009ConsultaCarteraVenHelperBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J009ConsultaCarteraVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.Mensajes;

/**
 * @author everis. Action de Gestion Variables
 * @version 1.0 Versión inicial
 */
public class J372J014ConsultaCarteraVenAction extends MapfreAction

{
	/**
	 * objTrazas
	 */
	private static final Logger objTrazas = J000J000Trazas.getLogger ( J372J014ConsultaCarteraVenAction.class );

	/**
	 * Inicializacion de la variable FORM_GESTION_EXPED, valor formGestionExped
	 */
	private static final String FORM_GESTION_EXPED = "formGestionExped";
	
	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inicializacion de la variable OK, valor OK
	 */
	private static final String OK = "OK";

	/**
	 * Inicializacion de la variable TEXTOERROR, valor Error no controlado
	 */
	private static final String TEXTOERROR = "Error no controlado";

	/**
	 * @see org.apache.struts.action.Action#execute(org.apache.struts.action.ActionMapping,
	 *      org.apache.struts.action.ActionForm,
	 *      javax.servlet.http.HttpServletRequest,
	 *      javax.servlet.http.HttpServletResponse)
	 * 
	 * @throws J372J001VencimientosException
	 * 
	 * @return ActionForward forward
	 * 
	 */

	@Override
	public ActionForward execute ( ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response )
			throws J372J001VencimientosException {

		ActionForward forward = new ActionForward ();

		Mensajes mensaje = new Mensajes ();

		J372J008GestionExpedientesVenActionForm formConsulta = new J372J008GestionExpedientesVenActionForm ();
		J372J008GestionExpedientesVenActionForm formConsultaSalida = new J372J008GestionExpedientesVenActionForm ();
		try {
			/* Bean de Entrada y Salida en la llamada al servicio Cobol */
			final J372J009ConsultaCarteraVenHelperBean helperBean = new J372J009ConsultaCarteraVenHelperBean ();
			J372J009ConsultaCarteraVenPageBean pageBeanEntrada = new J372J009ConsultaCarteraVenPageBean ();
			J372J009ConsultaCarteraVenPageBean pageBeanSalida = new J372J009ConsultaCarteraVenPageBean ();

			/* Pasamos el formulario generico a uno especifico */
			formConsulta = ( J372J008GestionExpedientesVenActionForm ) form;
			final J000J000Usuario usuario = J000J000Usuario
					.getUsuarioArquitectura ( request );

			/*
			 * Invocamos al metodo recogerDatosEntrada pasando los datos del
			 * formulario y el usuario al pagebean de entrada del servicio.
			 */
			pageBeanEntrada = helperBean.recogerDatosEntrada ( formConsulta,
					usuario );
			/* Llamamos al servicio cobol pasandole los datos de entrada */
			pageBeanSalida = helperBean.llamarServicio ( pageBeanEntrada );
			/*
			 * Pasamos los parametros de salida del servicio desde el pagebean
			 * de salida al formulario.
			 */
			formConsultaSalida = helperBean.ponerDatosSalida ( pageBeanSalida,
					formConsultaSalida );

			/*
			 * Mostramos mensajes por pantalla Si ha idobien mandará mensaje ok
			 * y si no mandará la descripcion de cobol
			 */
			if ( "00".equals ( formConsultaSalida.getRetorno ().trim () )
					&& ENBLANCO.equals ( formConsultaSalida.getDesRetorno ().trim () ) ) {
				formConsulta.setTipOperacionJSP ( "OKCONSULTA" );
				mensaje.setMensaje ( 1, "II", ENBLANCO, getResources ( request )
						.getMessage ( "rescate.mensaje.ok" ), ENBLANCO,
						ENBLANCO );
			} else {

				mensaje.setMensaje ( 1, "II", ENBLANCO, formConsultaSalida
						.getDesRetorno (), ENBLANCO, ENBLANCO );
			}

		} catch ( J372J001VencimientosException e ) {

			if ( objTrazas.isEnabledFor ( Level.ERROR ) ) {
				/*
				 * LOGS trazas para poder seguir las diferentes exception de
				 * J372J001VencimientosException
				 */
				objTrazas.error ( "J372J014ConsultaCarteraVenAction - Excepcion - Descripcion: "
								+ e.getStDescripcion () );
				objTrazas.error ( "J372J014ConsultaCarteraVenAction - Excepcion - Localized:"
								+ e.getLocalizedMessage () );
				objTrazas.error ( "J372J014ConsultaCarteraVenAction - Excepcion - Clase:"
								+ e.getStClase () );
				objTrazas.error ( "J372J014ConsultaCarteraVenAction - Excepcion - Error:"
								+ e.getStMensajeError () );
				objTrazas.error ( "J372J014ConsultaCarteraVenAction - Excepcion - Metodo:"
								+ e.getStMetodo () );
			}
			final String desCodError = e.getStGError ();
			formConsultaSalida.setTipOperacionJSP ( "NOKCONSULTA" );

			mensaje.setMensaje ( 1, "XX", ENBLANCO, desCodError, ENBLANCO,
					ENBLANCO );

			mensaje.setMensaje ( 3, "XX", "!!", TEXTOERROR, this.getClass ()
					.getName (), TEXTOERROR );

		} finally {
			/*
			 * Finally. Siempre se va a ejecutar, nos mostrara mensaje por
			 * pantalla
			 */
			formConsultaSalida.setVectorMensajes ( mensaje.getVectorMensajes () );
			/*
			 * Devolvemos el formulario a la request donde lo deja guardado para
			 * recuperarlo despues.
			 */
			request.setAttribute ( FORM_GESTION_EXPED, formConsultaSalida );
		}

		/* si va todo bien OK le hemos puesto en el strust-confing una vía de acceso (redirigimos) */
		forward = mapping.findForward ( OK );

		/* Finish with */
		formConsulta.setVectorMensajes ( mensaje.getVectorMensajes () );
		return ( forward );
	}
}
