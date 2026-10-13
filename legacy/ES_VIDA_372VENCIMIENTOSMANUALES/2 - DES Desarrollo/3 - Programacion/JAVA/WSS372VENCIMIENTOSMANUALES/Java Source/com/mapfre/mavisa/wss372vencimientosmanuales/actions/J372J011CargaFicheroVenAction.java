package com.mapfre.mavisa.wss372vencimientosmanuales.actions;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;
import mapfre.wss000arquitect.utilidades.J000J000Trazas;

import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J010CargaFicheroVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans.J372J010CargaFicheroVenHelperBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J010CargaFicheroVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.Mensajes;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

/**
 * Action para la cargaa de ficheros
 * 
 * @author everis Action de cargaFicheros
 * @version 1.0 Versión inicial
 */
public class J372J011CargaFicheroVenAction extends MapfreAction

{
	/**
	 * objTrazas
	 */
	private static final Logger objTrazas = J000J000Trazas.getLogger ( J372J011CargaFicheroVenAction.class );

	/**
	 * Inicializamos el ENBLANCO, con valor ENBLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inicializamos el OK, con valor OK
	 */
	private static final String OK = "OK";

	/**
	 * Inicializamos el INICIO, con valor INICIO
	 */
	private static final String INICIO = "INICIO";

	/**
	 * Inicializamos el TEXTOERROR, con valor TEXTOERROR
	 */
	private static final String TEXTOERROR = "Error no controlado";

	/**
	 * @see org.apache.struts.action.Action#execute(org.apache.struts.action.ActionMapping,
	 *      org.apache.struts.action.ActionForm,
	 *      javax.servlet.http.HttpServletRequest,
	 *      javax.servlet.http.HttpServletResponse)
	 * @throws Exception
	 *             ActionErrors, ActionForward
	 * 
	 * @return forward
	 * 
	 * @param mapping
	 * @param form
	 * @param request
	 * @param response
	 * 
	 * @exception J372J001VencimientosException
	 */
	@Override
	public ActionForward execute ( ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response )
			throws J372J001VencimientosException {

		ActionForward forward = new ActionForward ();

		Mensajes mensaje = new Mensajes ();

		J372J010CargaFicheroVenActionForm formCargaFichero = new J372J010CargaFicheroVenActionForm ();

		try {
			/* Damos al parameter en el struts-config un valor para que desde
			 * aqui podamos realizar todas las acciones que marquemos cuando se
			 * inicie la pantalla */
			final String parametro = mapping.getParameter ();
			mapping.getParameter ();
			/*
			 * inicio lo comparamos con un valor por si viene null dicho valor
			 * no falle
			 */
			if ( INICIO.equals ( parametro ) ) {
				/*
				 * cuando entre se iniciará el formulario, esto solo pasará
				 * cuando entramos por primera vez desde inicio
				 */
				formCargaFichero = new J372J010CargaFicheroVenActionForm ();
			}

			final J372J010CargaFicheroVenHelperBean helperBean = new J372J010CargaFicheroVenHelperBean ();

			/* Bean de Entrada y Salida en la llamada al servicio Cobol */
			J372J010CargaFicheroVenPageBean pageBeanEntrada = new J372J010CargaFicheroVenPageBean ();
			J372J010CargaFicheroVenPageBean pageBeanSalida = new J372J010CargaFicheroVenPageBean ();

			final J000J000Usuario usuario = J000J000Usuario.getUsuarioArquitectura ( request );

			/* pasamos el formulario generico a uno especifico */
			formCargaFichero = ( J372J010CargaFicheroVenActionForm ) form;

			/*
			 * Invocamos al metodo recogerDatosEntrada pasando los datos del
			 * formulario y el usuario al pagebean de entrada del servicio.
			 */
			pageBeanEntrada = helperBean.recogerDatosEntrada (formCargaFichero, usuario );
			/* Llamamos al servicio cobol pasandole los datos de entrada */
			pageBeanSalida = helperBean.llamarServicio ( pageBeanEntrada );
			/*
			 * Pasamos los parametros de salida del servicio desde el pagebean
			 * de salida al formulario. llamada al servicio cobol
			 */
			formCargaFichero = helperBean.ponerDatosSalida ( pageBeanSalida,
					formCargaFichero );

			/* If se dectecta que todo a ido bien (00), mostramos un mensaje, en función de si viene informado
			 * en la llamada o en su defecto mostramos uno propio de la aplicación Web */
			if ( "00".equals ( formCargaFichero.getRetorno ().trim () )
					&& ENBLANCO.equals ( formCargaFichero.getDesRetorno ()
							.trim () ) ) {
				mensaje.setMensaje ( 1, "II", ENBLANCO, getResources ( request )
						.getMessage ( "rescate.mensaje.ok" ), ENBLANCO,
						ENBLANCO );
			} else {

				// Mensaje enviado desde la llamada a Cobol
				mensaje.setMensaje ( 1, "II", ENBLANCO, formCargaFichero
						.getDesRetorno (), ENBLANCO, ENBLANCO );
			}

		} catch ( J372J001VencimientosException e ) {
			/* LOGS trazas para poder seguir las diferentes exception de J372J001VencimientosException */
			if ( objTrazas.isEnabledFor ( Level.ERROR ) ) {
				objTrazas.error ( "CargaFicheroVenAction - Excepcion - Descripcion: " + e.getStDescripcion () );
				objTrazas.error ( "CargaFicheroVenAction - Excepcion - Localized:" + e.getLocalizedMessage () );
				objTrazas.error ( "CargaFicheroVenAction - Excepcion - Clase:" + e.getStClase () );
				objTrazas.error ( "CargaFicheroVenAction - Excepcion - Error:" + e.getStMensajeError () );
				objTrazas.error ( "CargaFicheroVenAction - Excepcion - Metodo:" + e.getStMetodo () );
			}
			final String desCodError = e.getStGError ();

			mensaje.setMensaje ( 1, "XX", ENBLANCO, desCodError, ENBLANCO,ENBLANCO );

			mensaje.setMensaje ( 3, "XX", "!!", TEXTOERROR, this.getClass ().getName (), TEXTOERROR );
			/*
			 * Si salta alguna excepcion Finally simpre va a continuar
			 * recogiendo el mensaje y mostrandolo por pantalla
			 */
		} finally {
			/* Finally. Siempre se va a ejecutar, nos mostrara mensaje por pantalla */
			formCargaFichero.setVectorMensajes ( mensaje.getVectorMensajes () );
			/* Devolvemos el formulario a la request donde lo deja guardado para recuperarlo despues. */
			request.setAttribute ( "formCargaFichero", formCargaFichero );
		}
		/* Forward control to the appropriate 'success' URI (change name as desired) */
		forward = mapping.findForward ( OK );

		/* Finish with */
		formCargaFichero.setVectorMensajes ( mensaje.getVectorMensajes () );
		return ( forward );

	}
}
