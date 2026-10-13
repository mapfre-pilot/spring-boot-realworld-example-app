package com.mapfre.mavisa.wss372vencimientosmanuales.actions;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;

/**
 * 
 * @author everis Redirecciones genericas
 * @version 1.0 Versión inicial
 */
public class J372J013ForwardSuccessListadoAction extends MapfreAction {
	/**
	 * Inicializacion de la variable PARTIDA, 
	 * valor partida
	 */
	private static final String PARTIDA = "partida";
	/**
	 * Inicializacion de la variable CODIGO, 
	 * valor codigo
	 */
	private static final String CODIGO = "codigo";

	/**
	 * @param mapping
	 * @param form
	 * @param request
	 * @param response
	 * 
	 * @throws J372J001VencimientosException
	 * 
	 * @return mapping
	 */
	@Override
	public ActionForward execute (ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws J372J001VencimientosException {

		if (request.getParameter(CODIGO) != null) {

			request.setAttribute(CODIGO, request.getParameter(CODIGO));

		}

		if (request.getParameter(PARTIDA) != null) {

			request.setAttribute(PARTIDA, request.getParameter(PARTIDA));

		}

		return mapping.findForward("continuar");

	}

}
