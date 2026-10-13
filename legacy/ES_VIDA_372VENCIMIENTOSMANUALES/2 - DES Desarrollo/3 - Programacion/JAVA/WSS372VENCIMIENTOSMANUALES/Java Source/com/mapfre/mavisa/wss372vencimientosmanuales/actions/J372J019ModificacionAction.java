package com.mapfre.mavisa.wss372vencimientosmanuales.actions;


/* MODIFICACION : MU-2016-006673
FECHA : MARZO 2016
DESCRIPCION: Recuperación del identificador del domicilio
AUTOR : RAROALE */

import java.util.GregorianCalendar;

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
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J001BusquedaExpVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J008GestionExpedientesVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans.J372J008ModificarExpedientesVenHelperBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J001BusquedaExpVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J008GestionExpedientesVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.Mensajes;

/**
 * @author everis
 * @version 1.0 Versión inicial
 */

public class J372J019ModificacionAction extends MapfreAction

{
	/**
	 * OBJTRAZAS
	 */
	private static final Logger OBJTRAZAS = J000J000Trazas.getLogger(J372J019ModificacionAction.class);
	
	/**
	 * Inicializacion de la variable ENBLANCO, 
	 * valor BLANCO
	 */
	private static final String ENBLANCO = ""; //$NON-NLS-1$
	
	/**
	 * Inicializacion de la variable OK, 
	 * valor OK
	 */
	private static final String OK = "OK"; //$NON-NLS-1$
	
	/**
	 * Inicializacion de la variable FORM_GESTION_EXPED, valor formGestionExped
	 */
	private static final String FORM_BUSQUEDA_EXPED = "formBusquedaExpedSel";
	
	/**
	 * Inicializacion de la variable MO, 
	 * valor MO
	 */
	private static final String MO = "MO"; //$NON-NLS-1$
	
	/**
	 * Inicializacion de la variable FORM_GESTION_EXPED, 
	 * valor formGestionExped
	 */
	private static final String FORM_GESTION_EXPED = "formGestionExped"; //$NON-NLS-1$


	/** 
	 * Action de Gestion de Expedientes en Rescates
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
	
	public ActionForward execute (ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws J372J001VencimientosException {

		ActionForward forward = new ActionForward();
		Mensajes mensaje = new Mensajes();
		
		
		//final J372J001BusquedaExpVenActionForm formBusquedaExped = (J372J001BusquedaExpVenActionForm) form;
		final J372J001BusquedaExpVenActionForm formBusquedaExped = (J372J001BusquedaExpVenActionForm) request
		.getSession ().getAttribute (FORM_BUSQUEDA_EXPED);
		J372J008GestionExpedientesVenActionForm formGestionExped = new J372J008GestionExpedientesVenActionForm ();
		
		final String OK = "OK";
		try {
			/* Bean de Entrada y Salida en la llamada al servicio Cobol */
			/* Pasamos el formulario generico a uno especifico */
			final J000J000Usuario usuario = J000J000Usuario.getUsuarioArquitectura (request);
			
			/* Bean de Entrada y Salida en la llamada al servicio Cobol */
			final J372J008ModificarExpedientesVenHelperBean helperBean = new J372J008ModificarExpedientesVenHelperBean ();
			
			J372J001BusquedaExpVenPageBean pageBeanEntrada = new J372J001BusquedaExpVenPageBean();
			J372J001BusquedaExpVenPageBean pageBeanSalida = new J372J001BusquedaExpVenPageBean ();
			J372J008GestionExpedientesVenPageBean GestionSalida = new J372J008GestionExpedientesVenPageBean ();
			J372J008GestionExpedientesVenPageBean GestionEntrada = new J372J008GestionExpedientesVenPageBean ();
			
			/*
			 * Invocamos al metodo recogerDatosEntrada pasando los datos del
			 * formulario y el usuario al pagebean de entrada del servicio.
			 */
			pageBeanEntrada = helperBean.recogerDatosEntrada (formBusquedaExped, usuario);
			/* Llamamos al servicio cobol pasandole los datos de entrada */
			pageBeanSalida = helperBean.llamarServicio (pageBeanEntrada);
			
			/* Pasamos los parametros de salida del servicio desde el pagebean de salida al formulario.*/
			GestionEntrada = helperBean.ponerDatosSalida (pageBeanSalida,GestionEntrada);
			GestionEntrada.setUsuario ( usuario );
			/* Recuperamos personas */
			GestionSalida = helperBean.llamarServicio ( GestionEntrada );
			
			formGestionExped = helperBean.ponerDatosFormulario (GestionSalida);
			// MU-2016-006673 - RAROALE - INI
			final J372J008ModificarExpedientesVenHelperBean helperPersonaBean = new J372J008ModificarExpedientesVenHelperBean();
			J372J008GestionExpedientesVenPageBean pagePersonaBeanEntrada = new J372J008GestionExpedientesVenPageBean();
			J372J008GestionExpedientesVenPageBean pagePersonaBeanSalida = new J372J008GestionExpedientesVenPageBean();
			
			GestionEntrada.setFmodificacion(today());
			GestionSalida = helperBean.llamarServicio(GestionEntrada);
			
			if ((GestionSalida.getCodPostalPri() != null
					&& !GestionSalida.getCodPostalPri().equals(formGestionExped.getCodPostalPri()))
					|| (GestionSalida.getLocalidadPri() != null
					&& !GestionSalida.getLocalidadPri().equals(formGestionExped.getLocalidadPri()))) {
					formGestionExped.setKdomicilioPri("");
			}
			// MU-2016-006673 - RAROALE - FIN
			
			formGestionExped.setTipOperacionJSP(OK);
			
			formGestionExped.setTipOperacion(MO);
			
			
		} catch (J372J001VencimientosException e) {
			/* LOGS trazas para poder seguir las diferentes exception de J362J001RescatesException*/
			if (OBJTRAZAS.isEnabledFor(Level.ERROR)) {
			OBJTRAZAS.error("GestionExpedienteResAction - Excepcion - Descripcion: " + e.getStDescripcion());
			OBJTRAZAS.error("GestionExpedienteResAction - Excepcion - Localized:" + e.getLocalizedMessage());
			OBJTRAZAS.error("GestionExpedienteResAction - Excepcion - Clase:" + e.getStClase());
			OBJTRAZAS.error("GestionExpedienteResAction - Excepcion - Error:" + e.getStMensajeError());
			OBJTRAZAS.error("GestionExpedienteResAction - Excepcion - Metodo:" + e.getStMetodo());
			}
			final String DESCODERROR = e.getStGError();
			mensaje.setMensaje(1, "XX", ENBLANCO, DESCODERROR, ENBLANCO,ENBLANCO);
			/* Finally. Siempre se va a ejecutar, nos mostrara mensaje por pantalla*/
			formGestionExped.setVectorMensajes(mensaje.getVectorMensajes());
		/* Si salta alguna excepcion Finally simpre va a continuar recogiendo el mensaje y mostrandolo por pantalla */
		} finally {
		
		/* Devolvemos el formulario a la request donde lo deja guardado pararecuperarlo despues.*/
		 request.setAttribute(FORM_GESTION_EXPED, formGestionExped);
	}

		/*
		 * Forward control to the appropriate 'success' URI (change name asdesired)si va todo bien OK le hemos puesto en 
		 * el strust-confing una vía deacceso (redirigimos)
		 */
		forward = mapping.findForward(OK);

		return (forward);
	}
	
	// MU-2016-006673 - RAROALE - INI
	private static String today() {

		GregorianCalendar fm = new GregorianCalendar();
		
		int ano = fm.get(GregorianCalendar.YEAR);
		int mes = fm.get(GregorianCalendar.MONTH)+1;
		int dia = fm.get(GregorianCalendar.DAY_OF_MONTH);
		
		String mesString = "";
		String diaString = "";
		
		
		if (mes < 10)
		{
			mesString = "0" + mes;
		}
		else
		{
			mesString = new Integer(mes).toString();
		}

		if (dia < 10)
		{
			diaString = "0" + new Integer(dia).toString();
		}
		else
		{
		   diaString = new Integer(dia).toString();
		}

		String fa = ano + mesString + diaString;
		return fa;
	}
	// MU-2016-006673 - RAROALE - FIN
}
