package com.mapfre.mavisa.wss372vencimientosmanuales.actions;

import java.util.Collections;
import java.util.List;
import java.util.Vector;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;
import mapfre.wss000arquitect.utilidades.J000J000Trazas;

import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J006PeticionBDGIVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans.J372J006PeticionBDGIVenHelperBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J006PeticionBDGIVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.CombosBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.Mensajes;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

/**
 * @author everis. Action de petición BDGI
 * @version 1.0 Versión inicial
 */
public class J372J009PeticionBDGIVenAction extends MapfreAction

{
	/**
	 * objTrazas
	 */
	private static final Logger OBJTRAZAS = J000J000Trazas.getLogger ( J372J009PeticionBDGIVenAction.class );

	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inicializacion de la variable OK, valor OK
	 */
	private static final String OK = "OK";

	/**
	 * Inicializacion de la variable INICIO, valor inicio
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
	 * 
	 */

	@Override
	public ActionForward execute ( ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response )
			throws J372J001VencimientosException {

		ActionForward forward = new ActionForward ();

		Mensajes mensaje = new Mensajes ();
		J372J006PeticionBDGIVenActionForm formPeticionBDGI = new J372J006PeticionBDGIVenActionForm ();
		try {
			/* Damos al parameter en el struts-config un valor para que desde 
			 * aqui podamos realizar todas las acciones que marquemos cuando se inicie la pantalla.*/			 
			final String PARAMETRO = mapping.getParameter ();
			mapping.getParameter ();
			/* inicio lo comparamos con un valor por si viene null dicho valor no falle. */
			if ( INICIO.equals ( PARAMETRO ) ) {
				/* cuando entre se iniciará el formulario, esto solo pasará cuando entramos por primera vez desde inicio */
				formPeticionBDGI = new J372J006PeticionBDGIVenActionForm ();
			}
			/* Bean de Entrada y Salida en la llamada al servicio Cobol */
			final J372J006PeticionBDGIVenHelperBean HELPERBEAN = new J372J006PeticionBDGIVenHelperBean ();
			J372J006PeticionBDGIVenPageBean pageBeanEntrada = new J372J006PeticionBDGIVenPageBean ();
			J372J006PeticionBDGIVenPageBean pageBeanSalida = new J372J006PeticionBDGIVenPageBean ();
			/* pasamos el formulario generico a uno especifico */
			formPeticionBDGI = ( J372J006PeticionBDGIVenActionForm ) form;

			/* Variables gestión usuarios */
			final J000J000Usuario USUARIO = J000J000Usuario.getUsuarioArquitectura ( request );
			/* Si el campo mesCombo que es el que contiene el desplegable viene lleno le decimos que no lo vuelva a rellenar.*/
			if ( formPeticionBDGI.getMesCombo ().size () == 0 ) {
				/* Cargamos el desplegable con los valores que hemos recogido de la tabla petición BDGI */
				List datosDesplegable = Collections.synchronizedList ( new Vector <Object> () );
				Integer valor = 0;
				for ( int i = 1; i <= 12; i++ ) {

					CombosBean bean = new CombosBean ();
					valor = i;
					bean.setProp1 ( valor.toString () );
					bean.setProp2 ( valor.toString () );

					datosDesplegable.add ( bean );
				}
				/* Cargamos los combos del formulario con los datos que hemos recogido. */
				formPeticionBDGI.setMesCombo ( datosDesplegable );
			}
			 /* Si estamos en la acción de aceptar 'AC' llamamos al servicio Cobol. */
			if ( "AC".equals ( formPeticionBDGI.getTipOperacion () ) ) {
				/* Invocamos al metodo recogerDatosEntrada pasando los datos del formulario y el usuario 
				 * al pagebean de entrada del servicio. */
				pageBeanEntrada = HELPERBEAN.recogerDatosEntrada (formPeticionBDGI, USUARIO );
				/* Llamamos al servicio cobol pasandole los datos de entrada */
				pageBeanSalida = HELPERBEAN.llamarServicio ( pageBeanEntrada );
				/*
				 * Pasamos los PARAMETROs de salida del servicio desde el
				 * pagebean de salida al formulario. llamada al servicio cobol
				 */
				formPeticionBDGI = HELPERBEAN.ponerDatosSalida (pageBeanSalida, formPeticionBDGI );
			}
			 /* Mostramos mensajes por pantalla */
			if ( !ENBLANCO.equals ( formPeticionBDGI.getTipOperacion () )
					&& !"INICIO".equals ( formPeticionBDGI.getTipOperacion () ) ) {

				if ( "00".equals ( formPeticionBDGI.getRetorno ().trim () ) ) {
					mensaje.setMensaje ( 1, "II", ENBLANCO, getResources (
							request ).getMessage ( "rescate.mensaje.ok" ),ENBLANCO, ENBLANCO );
				} else {
					mensaje.setMensaje ( 1, "II", ENBLANCO, formPeticionBDGI.getDesRetorno (), ENBLANCO, ENBLANCO );
				}
			}

		} catch ( J372J001VencimientosException e ) {
			/* LOGS trazas para poder seguir las diferentes exception de J372J001VencimientosException */
			if ( OBJTRAZAS.isEnabledFor ( Level.ERROR ) ) {
				OBJTRAZAS.error ( "PeticionBDGI - Excepcion - Descripcion: " + e.getStDescripcion () );
				OBJTRAZAS.error ( "PeticionBDGI - Excepcion - Localized:" + e.getLocalizedMessage () );
				OBJTRAZAS.error ( "PeticionBDGI - Excepcion - Clase:" + e.getStClase () );
				OBJTRAZAS.error ( "PeticionBDGI - Excepcion - Error:" + e.getStMensajeError () );
				OBJTRAZAS.error ( "PeticionBDGI - Excepcion - Metodo:" + e.getStMetodo () );
			}
			final String DESCODERROR = e.getStGError ();

			mensaje.setMensaje ( 1, "XX", ENBLANCO, DESCODERROR, ENBLANCO,ENBLANCO );/*
			/* Si salta alguna excepcion Finally simpre va a continuar recogiendo el mensaje y mostrandolo por pantalla*/
		} finally {
			/* Finally. Siempre se va a ejecutar, nos mostrara mensaje por pantalla */
			formPeticionBDGI.setVectorMensajes ( mensaje.getVectorMensajes () );
			/* Devolvemos el formulario a la request donde lo deja guardado para recuperarlo despues. */
			request.setAttribute ( "formPeticionBDGI", formPeticionBDGI );
		}
		/* Forward control to the appropriate 'success' URI (change name as desired) */
		forward = mapping.findForward ( OK );
		/* Finish with */
		formPeticionBDGI.setVectorMensajes ( mensaje.getVectorMensajes () );
		return ( forward );

	}
}
