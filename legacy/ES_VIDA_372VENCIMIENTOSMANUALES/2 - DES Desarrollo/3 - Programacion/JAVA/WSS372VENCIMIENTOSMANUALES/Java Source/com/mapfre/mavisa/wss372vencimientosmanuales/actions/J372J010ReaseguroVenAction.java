package com.mapfre.mavisa.wss372vencimientosmanuales.actions;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;
import mapfre.wss000arquitect.utilidades.J000J000Trazas;

import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J007ReaseguroVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans.J372J007ReaseguroVenHelperBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J008GestionExpedientesVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.Mensajes;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

/**
 * @author everis Action de reaseguro
 * @version 1.0 Versión inicial
 */
public class J372J010ReaseguroVenAction extends MapfreAction

{
	/**
	 * objTrazas
	 */
	private static final Logger objTrazas = J000J000Trazas.getLogger(J372J010ReaseguroVenAction.class);
	
	/**
	 * Inicializacion de la variable ENBLANCO, 
	 * valor BLANCO
	 */
	private static final String ENBLANCO = "";
	/**
	 * Inicializacion de la variable OK, 
	 * valor OK
	 */
	private static final String OK = "OK";
	/**
	 * Inicializacion de la variable INICIO, 
	 * valor INICIO
	 */
	private static final String INICIO = "INICIO";
	/**
	 * Inicializacion de la variable TEXTOERROR, 
	 * valor Error no controlado
	 */
	private static final String TEXTOERROR = "Error no controlado";

	/**
	 * @see org.apache.struts.action.Action#execute(org.apache.struts.action.ActionMapping,
	 *      org.apache.struts.action.ActionForm,
	 *      javax.servlet.http.HttpServletRequest,
	 *      javax.servlet.http.HttpServletResponse) 
	 *   
	 *  @throws J372J001VencimientosException
	 *  
	 *  @return ActionForward forward
	 * 
	 */
	@Override
	public ActionForward execute (ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws J372J001VencimientosException {

		ActionForward forward = new ActionForward();

		Mensajes mensaje = new Mensajes();

		J372J007ReaseguroVenActionForm formReaseguro = new J372J007ReaseguroVenActionForm();

		try {
			/*
			 * Damos al parameter en el struts-config un valor para que desde
			 * aqui podamos realizar todas las acciones que marquemos cuando se
			 * inicie la pantalla
			 */
			final String parametro = mapping.getParameter();
			mapping.getParameter();
			/*
			 * inicio lo comparamos con un valor por si viene null dicho valor
			 * no falle
			 */
			if (INICIO.equals(parametro)) {
				/*
				 * cuando entre se iniciará el formulario, esto solo pasará
				 * cuando entramos por primera vez desde inicio
				 */
				formReaseguro = new J372J007ReaseguroVenActionForm();
			}

			final J372J007ReaseguroVenHelperBean helperBean = new J372J007ReaseguroVenHelperBean();

			/* Bean de Entrada y Salida en la llamada al servicio Cobol */
			J372J008GestionExpedientesVenPageBean pageBeanEntrada = new J372J008GestionExpedientesVenPageBean();
			J372J008GestionExpedientesVenPageBean pageBeanSalida = new J372J008GestionExpedientesVenPageBean();

			final J000J000Usuario usuario = J000J000Usuario.getUsuarioArquitectura(request);
			/* pasamos el formulario generico a uno especifico */
			formReaseguro = (J372J007ReaseguroVenActionForm) form;

			/*
			 * Invocamos al metodo recogerDatosEntrada pasando los datos del
			 * formulario y el usuario al pagebean de entrada del servicio.
			 */
			pageBeanEntrada = helperBean.recogerDatosEntrada (formReaseguro, usuario);
			/* Llamamos al servicio cobol pasandole los datos de entrada */
			pageBeanSalida = helperBean.llamarServicio(pageBeanEntrada);
			/*
			 * Pasamos los parametros de salida del servicio desde el pagebean
			 * de salida al formulario. llamada al servicio cobol
			 */
			formReaseguro = helperBean.ponerDatosSalida(pageBeanSalida,formReaseguro);

			if (!ENBLANCO.equalsIgnoreCase(formReaseguro.getOperacion())
					&& !"INICIO".equals(formReaseguro.getOperacion())) {

				mensaje.setMensaje(1, "II", ENBLANCO, formReaseguro
						.getDesRetorno(), ENBLANCO, ENBLANCO);
			}

		} catch (J372J001VencimientosException e) {
			/* LOGS trazas para poder seguir las diferentes exception de J372J001VencimientosException */
			if (objTrazas.isEnabledFor(Level.ERROR)) {
			objTrazas.error("ReaseguroVenAction - Excepcion - Descripcion: " + e.getStDescripcion());
			objTrazas.error("ReaseguroVenAction - Excepcion - Localized:" + e.getLocalizedMessage());
			objTrazas.error("ReaseguroVenAction - Excepcion - Clase:" + e.getStClase());
			objTrazas.error("ReaseguroVenAction - Excepcion - Error:" + e.getStMensajeError());
			objTrazas.error("ReaseguroVenAction - Excepcion - Metodo:" + e.getStMetodo());
			}
			final String desCodError = e.getStGError();

			mensaje.setMensaje(1, "XX", ENBLANCO, desCodError, ENBLANCO,
					ENBLANCO);
 
			mensaje.setMensaje(3, "XX", "!!", TEXTOERROR, this.getClass()
					.getName(), TEXTOERROR);
			/*
			 * Si salta alguna excepcion Finally simpre va a continuar recogiendo 
			 * el mensaje y mostrandolo por pantalla
			 */
		} finally {
			/* Finally. Siempre se va a ejecutar, nos mostrara mensaje por pantalla */
			formReaseguro.setVectorMensajes(mensaje.getVectorMensajes());
			/* Devolvemos el formulario a la request donde lo deja guardado para recuperarlo despues. */
			request.setAttribute("formReaseguro", formReaseguro);
		}
		/* Forward control to the appropriate 'success' URI (change name as desired) */
		forward = mapping.findForward(OK);

		/* Finish with */
		formReaseguro.setVectorMensajes(mensaje.getVectorMensajes());
		return (forward);

	}
}
