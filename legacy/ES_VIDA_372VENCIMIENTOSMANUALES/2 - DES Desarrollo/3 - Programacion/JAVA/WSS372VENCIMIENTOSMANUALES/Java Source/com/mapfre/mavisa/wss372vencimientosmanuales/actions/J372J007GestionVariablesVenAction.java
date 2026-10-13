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
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J004GestionVariablesVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans.J372J004GestionVariablesVenHelperBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J004GestionVariablesVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.Mensajes;

/**
 * @author everis. Action de Gestion Variables
 * @version 1.0 Versión inicial
 */
public class J372J007GestionVariablesVenAction extends MapfreAction

{

	/**
	 * objTrazas
	 */
	private static final Logger objTrazas = J000J000Trazas.getLogger ( J372J007GestionVariablesVenAction.class );

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
	 * Inicializacion varible TEXTOERROR, valor Error no controlado
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
	 */

	@Override
	public ActionForward execute ( ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response )
			throws J372J001VencimientosException {

		ActionForward forward = new ActionForward ();

		Mensajes mensaje = new Mensajes ();

		J372J004GestionVariablesVenActionForm formGestion = new J372J004GestionVariablesVenActionForm ();

		try {
			/* Damos al parameter en el struts-config un valor para que desde
			 * aqui podamos realizar todas las acciones que marquemos cuando se
			 * inicie la pantalla */
			final String parametro = mapping.getParameter ();
			mapping.getParameter ();
			/* inicio lo comparamos con un valor por si viene null dicho valor no falle */
			if ( INICIO.equals ( parametro ) ) {
				/* cuando entre se iniciará el formulario, esto solo pasará cuando entramos por primera vez desde inicio */
				formGestion = new J372J004GestionVariablesVenActionForm ();
			}
			/* Bean de Entrada y Salida en la llamada al servicio Cobol */
			final J372J004GestionVariablesVenHelperBean helperBean = new J372J004GestionVariablesVenHelperBean ();
			J372J004GestionVariablesVenPageBean pageBeanEntrada = new J372J004GestionVariablesVenPageBean ();
			J372J004GestionVariablesVenPageBean pageBeanSalida = new J372J004GestionVariablesVenPageBean ();

			/* Pasamos el formulario generico a uno especifico */
			formGestion = ( J372J004GestionVariablesVenActionForm ) form;
			final J000J000Usuario usuario = J000J000Usuario.getUsuarioArquitectura ( request );

			final String tipoOperacion = formGestion.getTipOperacion ();

			/*
			 * Invocamos al metodo recogerDatosEntrada pasando los datos del
			 * formulario y el usuario al pagebean de entrada del servicio.
			 */
			pageBeanEntrada = helperBean.recogerDatosEntrada ( formGestion,
					usuario );
			/* Llamamos al servicio cobol pasandole los datos de entrada */
			pageBeanSalida = helperBean.llamarServicio ( pageBeanEntrada );
			/* Pasamos los parametros de salida del servicio desde el pagebean de salida al formulario. */
			formGestion = helperBean.ponerDatosSalida ( pageBeanSalida,
					formGestion );

			/* Si se hace la accion guardar se mostrara por pantalla un mensaje de OK */
			if ( "SA".equals ( tipoOperacion ) || "BA".equals ( tipoOperacion ) ) {

				mensaje.setMensaje ( 1, "II", ENBLANCO, getResources ( request )
						.getMessage ( "rescate.mensaje.ok" ), ENBLANCO,
						ENBLANCO );
			}

			if ( !ENBLANCO.equalsIgnoreCase ( formGestion.getTipOperacion () )
					&& ( !"INICIO".equals ( formGestion.getTipOperacion () ) )
					&& ( !ENBLANCO.equalsIgnoreCase ( formGestion
							.getDesRetorno ().trim () ) ) ) {

				mensaje.setMensaje ( 1, "II", ENBLANCO, formGestion
						.getDesRetorno (), ENBLANCO, ENBLANCO );
			}

		} catch ( J372J001VencimientosException e ) {
			/* LOGS trazas para poder seguir las diferentes exception de J372J001VencimientosException */			if ( objTrazas.isEnabledFor ( Level.ERROR ) ) {
				objTrazas.error ( "GestionVariablesVenAction - Excepcion - Descripcion: " + e.getStDescripcion () );
				objTrazas.error ( "GestionVariablesVenAction - Excepcion - Localized:" + e.getLocalizedMessage () );
				objTrazas.error ( "GestionVariablesVenAction - Excepcion - Clase:" + e.getStClase () );
				objTrazas.error ( "GestionVariablesVenAction - Excepcion - Error:" + e.getStMensajeError () );
				objTrazas.error ( "GestionVariablesVenAction - Excepcion - Metodo:" + e.getStMetodo () );
			}
			final String desCodError = e.getStGError ();

			mensaje.setMensaje ( 1, "XX", ENBLANCO, desCodError, ENBLANCO,ENBLANCO );
			/* Muestra el mensaje de error por pantalla */
			mensaje.setMensaje ( 3, "XX", "!!", TEXTOERROR, this.getClass ()
					.getName (), TEXTOERROR );
			/* Si salta alguna excepcion Finally simpre va a continuar recogiendo el mensaje y mostrandolo por pantalla */
		} finally {
			/* Finally. Siempre se va a ejecutar, nos mostrara mensaje por pantalla */
			formGestion.setVectorMensajes ( mensaje.getVectorMensajes () );
			/*
			 * Devolvemos el formulario a la request donde lo deja guardado para
			 * recuperarlo despues.
			 */
			request.setAttribute ( "formGestionVariables", formGestion );
		}

		/*
		 * Forward control to the appropriate 'success' URI (change name as
		 * desired)
		 */
		forward = mapping.findForward ( OK );

		/* Finish with */
		formGestion.setVectorMensajes ( mensaje.getVectorMensajes () );
		return ( forward );

	}
}
