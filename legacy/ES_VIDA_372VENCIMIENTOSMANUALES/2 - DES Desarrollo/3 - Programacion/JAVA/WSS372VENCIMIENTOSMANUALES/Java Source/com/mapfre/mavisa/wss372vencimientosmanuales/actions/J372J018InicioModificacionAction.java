package com.mapfre.mavisa.wss372vencimientosmanuales.actions;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J001BusquedaExpVenActionForm;



/**
 * @author everis
 * @version 1.0 Versión inicial
 */

public class J372J018InicioModificacionAction extends MapfreAction

{

	/**
	 * Inicializacion de la variable FORM_GESTION_EXPED, valor formGestionExped
	 */
	private static final String FORM_BUSQUEDA_EXPED = "formBusquedaExpedSel"; //$NON-NLS-1$

	/**
	 * Action de Gestion de Expedientes en Rescates
	 * 
	 * @see org.apache.struts.action.Action#execute(org.apache.struts.action.ActionMapping,
	 *      org.apache.struts.action.ActionForm,
	 *      javax.servlet.http.HttpServletRequest,
	 *      javax.servlet.http.HttpServletResponse)
	 * 
	 * @throws J362J001RescatesException
	 * 
	 * @return forward
	 */
	@Override
	public ActionForward execute ( ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response )
			throws J372J001VencimientosException {

		ActionForward forward = new ActionForward ();
		
		final J372J001BusquedaExpVenActionForm formBusquedaExped = ( J372J001BusquedaExpVenActionForm ) form;
		
		request.setAttribute ( FORM_BUSQUEDA_EXPED, formBusquedaExped );
		request.getSession ().setAttribute (FORM_BUSQUEDA_EXPED, formBusquedaExped);
		
		
		forward = mapping.findForward ( "OK" ); //$NON-NLS-1$

		return ( forward );
	}
}
