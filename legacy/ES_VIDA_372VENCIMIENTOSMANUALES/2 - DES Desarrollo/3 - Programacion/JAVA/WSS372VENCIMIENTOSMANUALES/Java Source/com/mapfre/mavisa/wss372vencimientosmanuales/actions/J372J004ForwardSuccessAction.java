package com.mapfre.mavisa.wss372vencimientosmanuales.actions;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;

/**
 * @author everis Redirecciones genericas
 * @version 1.0 Versión inicial
 */
public class J372J004ForwardSuccessAction extends MapfreAction {

	
	/**
	 * @see org.apache.struts.action.Action#execute(org.apache.struts.action.ActionMapping,
	 *      org.apache.struts.action.ActionForm,
	 *      javax.servlet.http.HttpServletRequest,
	 *      javax.servlet.http.HttpServletResponse) 
	 *      
	 * @throws J372J001VencimientosException
	 *      
	 *  @return mapping    
	 */
	@Override
	public ActionForward execute (ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws J372J001VencimientosException {

		return mapping.findForward("OK");

	}

}
