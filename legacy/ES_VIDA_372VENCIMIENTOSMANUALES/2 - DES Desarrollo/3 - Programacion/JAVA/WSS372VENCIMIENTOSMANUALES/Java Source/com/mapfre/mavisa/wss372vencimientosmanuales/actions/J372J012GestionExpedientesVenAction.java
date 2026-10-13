package com.mapfre.mavisa.wss372vencimientosmanuales.actions;

/* MODIFICACION : MU-2016-006673
FECHA : MARZO 2016
DESCRIPCION: Recuperación del identificador del domicilio
AUTOR : RAROALE */

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
import com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans.J372J008GestionExpedientesVenHelperBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J008GestionExpedientesVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.Mensajes;

/**
 * @author everis
 * @version 1.0 Versión inicial
 */

public class J372J012GestionExpedientesVenAction extends MapfreAction

{
	/**
	 * objTrazas
	 */
	private static final Logger objTrazas = J000J000Trazas
			.getLogger ( J372J012GestionExpedientesVenAction.class );

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
	 * Inicializamos el AL
	 */
	private static final String AL = "AL";

	/**
	 * Inicializamos el MO
	 */
	private static final String MO = "MO";

	/**
	 * Inicializacion de la variable FORM_GESTION_EXPED, valor formGestionExped
	 */
	private static final String FORM_GESTION_EXPED = "formGestionExped";

	/**
	 * Action de Gestion de Expedientes en Vencimientos
	 * 
	 * @see org.apache.struts.action.Action#execute(org.apache.struts.action.ActionMapping,
	 *      org.apache.struts.action.ActionForm,
	 *      javax.servlet.http.HttpServletRequest,
	 *      javax.servlet.http.HttpServletResponse)
	 * 
	 * @throws J372J001VencimientosException
	 * 
	 * @return forward
	 */

	@Override
	public ActionForward execute ( ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response )
			throws J372J001VencimientosException {

		ActionForward forward = new ActionForward ();
		Mensajes mensaje = new Mensajes ();

		J372J008GestionExpedientesVenActionForm formGestionExped = ( J372J008GestionExpedientesVenActionForm ) form;

		try {

			/*
			 * Damos al parameter en el struts-config un valor para que desde
			 * aqui podamos realizar todas las acciones que marquemos cuando se
			 * inicie la pantalla
			 */
			final String PARAMETRO = request.getParameter ( "parametro" );
			/*
			 * inicio lo comparamos con un valor por si viene null dicho valor
			 * no falle
			 */
			if ( INICIO.equalsIgnoreCase ( PARAMETRO ) ) {
				/*
				 * cuando entre se iniciará el formulario, esto solo pasará
				 * cuando entramos por primera vez desde inicio
				 */

				formGestionExped = new J372J008GestionExpedientesVenActionForm ();

				formGestionExped.setTipOperacionJSP ( "INICIO" );
			} else {

				request.setAttribute ( FORM_GESTION_EXPED, formGestionExped );

				/* Bean de Entrada y Salida en la llamada al servicio Cobol */
				final J372J008GestionExpedientesVenHelperBean helperBean = new J372J008GestionExpedientesVenHelperBean ();
				J372J008GestionExpedientesVenPageBean pageBeanEntrada = new J372J008GestionExpedientesVenPageBean ();
				J372J008GestionExpedientesVenPageBean pageBeanSalida = new J372J008GestionExpedientesVenPageBean ();

				/* Pasamos el formulario generico a uno especifico */
				final J000J000Usuario usuario = J000J000Usuario
						.getUsuarioArquitectura ( request );

				if ( ENBLANCO.equals ( formGestionExped.getAnio () )
						&& ENBLANCO.equals ( formGestionExped
								.getTipOperacionJSP () ) ) {
					formGestionExped.setTipOperacion ( AL );
				} else if ( ENBLANCO.equals ( formGestionExped
						.getTipOperacionJSP () ) ) {
					formGestionExped.setTipOperacion ( MO );
				}

				if ( "AL".equals ( formGestionExped.getTipOperacion () )
						|| "MO".equals ( formGestionExped.getTipOperacion () )
						|| "AN".equals ( formGestionExped.getTipOperacion () ) ) {

					formGestionExped.setTipOperacionJSP ( "NOK" );
					// MU-2016-006673 - RAROALE - INI
					
					if (ENBLANCO.equals(formGestionExped.getKdomicilioPri())) {
						mensaje.setMensaje ( 1, "II", ENBLANCO,
								"Debe de actualizar el domicilio del primer beneficiario", ENBLANCO,
								ENBLANCO );
					}	
					
					if 	(mensaje.getVectorMensajes().size() < 1) {
						/*
						 * Invocamos al metodo recogerDatosEntrada pasando los datos
						 * del formulario y el usuario al pagebean de entrada del
						 * servicio.
						 */
						pageBeanEntrada = helperBean.recogerDatosEntrada (
								formGestionExped, usuario );
						/* Llamamos al servicio cobol pasandole los datos de entrada */
						pageBeanSalida = helperBean
								.llamarServicio ( pageBeanEntrada );
						/*
						 * Pasamos los parametros de salida del servicio desde el
						 * pagebean de salida al formulario.
						 */
						formGestionExped = helperBean.ponerDatosSalida (
								pageBeanSalida, formGestionExped );
					}
					// MU-2016-006673 - RAROALE - FIN
				}

				/*
				 * Mostramos mensajes por pantalla Si ha ido bien mandará
				 * mensaje ok y si no mandará la descripcion de cobol
				 */
				if ( !ENBLANCO.equals ( formGestionExped.getTipOperacion () )
						&& !"INICIO".equals ( formGestionExped
								.getTipOperacion () ) ) {

					mensaje.setMensaje ( 1, "II", ENBLANCO, formGestionExped
							.getDesRetorno (), ENBLANCO, ENBLANCO );

					if ( "00".equals ( formGestionExped.getRetorno ().trim () ) ) {
						formGestionExped.setTipOperacionJSP ( "OK" );
					} else {
						formGestionExped.setTipOperacionJSP ( "NOK" );
						mensaje.setMensaje ( 1, "II", ENBLANCO,
								formGestionExped.getDesRetorno (), ENBLANCO,
								ENBLANCO );
					}
				}
			}
			/*
			 * Devolvemos el formulario a la request donde lo deja guardado para
			 * recuperarlo despues.
			 */
			request.setAttribute ( "formGestionExpedVen", formGestionExped );

		} catch ( J372J001VencimientosException e ) {

			/*
			 * LOGS trazas para poder seguir las diferentes exception de
			 * J372J001VencimientosException
			 */
			if ( objTrazas.isEnabledFor ( Level.ERROR ) ) {
				objTrazas
						.error ( "GestionExpedienteVenAction - Excepcion - Descripcion: "
								+ e.getStDescripcion () );
				objTrazas
						.error ( "GestionExpedienteVenAction - Excepcion - Localized:"
								+ e.getLocalizedMessage () );
				objTrazas
						.error ( "GestionExpedienteVenAction - Excepcion - Clase:"
								+ e.getStClase () );
				objTrazas
						.error ( "GestionExpedienteVenAction - Excepcion - Error:"
								+ e.getStMensajeError () );
				objTrazas
						.error ( "GestionExpedienteVenAction - Excepcion - Metodo:"
								+ e.getStMetodo () );
			}
			final String desCodError = e.getStGError ();

			mensaje.setMensaje ( 1, "XX", ENBLANCO, desCodError, ENBLANCO,
					ENBLANCO );
			/*
			 * Si salta alguna excepcion Finally simpre va a continuar
			 * recogiendo el mensaje y mostrandolo por pantalla
			 */
		} finally {
			/*
			 * Finally. Siempre se va a ejecutar, nos mostrara mensaje por
			 * pantalla
			 */
			formGestionExped.setVectorMensajes ( mensaje.getVectorMensajes () );
			/*
			 * Devolvemos el formulario a la request donde lo deja guardado para
			 * recuperarlo despues.
			 */
			request.setAttribute ( "formGestionExped", formGestionExped );
		}

		/*
		 * Forward control to the appropriate 'success' URI (change name as
		 * desired)
		 * 
		 * si va todo bien OK le hemos puesto en el strust-confing una vía de
		 * acceso (redirigimos)
		 */
		forward = mapping.findForward ( OK );

		/* Finish with */
		formGestionExped.setVectorMensajes ( mensaje.getVectorMensajes () );
		return ( forward );

	}
}
