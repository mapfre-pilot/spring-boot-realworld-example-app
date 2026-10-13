package com.mapfre.mavisa.wss372vencimientosmanuales.actions;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import mapfre.wss000arquitect.excepciones.J000J000PrintException;
import mapfre.wss000arquitect.impresion.PrintJobSettings;
import mapfre.wss000arquitect.impresion.struts.J000J000ServicioImpresionStruts;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

/**
 * 
 * @author everis
 * @version 1.0 Versión inicial Action de Impresion. Se encarga de realizar la
 *          impresion directa del proyecto.
 * 
 */
public class J372J015ImpresionDirectaAction extends MapfreAction {

	/**
	 * Ejecuta la impresión directa
	 * 
	 * @param pObjFormulario
	 * @param pObjMapping
	 * @param pObjRequest
	 * @param pObjResponse
	 * 
	 * @throws J000J000PrintException
	 * 
	 * @return ActionForward stRetorno
	 */
	@Override
	public ActionForward execute ( ActionMapping pObjMapping,
			ActionForm pObjFormulario, HttpServletRequest pObjRequest,
			HttpServletResponse pObjResponse ) throws J000J000PrintException {

		ActionForward stRetorno = null;

		stRetorno = imprimirPlantilla ( pObjFormulario, pObjMapping,
				pObjRequest, pObjResponse );

		return stRetorno;

	}

	// ********************************************************** IMPRIMIR
	// PLANTILLA
	// *****************************************************************//

	/**
	 * Imprime plantilla
	 * 
	 * @param pObjFormulario
	 * @param pObjMapping
	 * @param pObjRequest
	 * @param pObjResponse
	 * @return ActionForward
	 * @throws J000J000PrintException
	 */
	public ActionForward imprimirPlantilla ( ActionForm pObjFormulario,
			ActionMapping pObjMapping, HttpServletRequest pObjRequest,
			HttpServletResponse pObjResponse

	) throws J000J000PrintException {

		final HttpSession objSesion = pObjRequest.getSession ();

		final PrintJobSettings settings = ( PrintJobSettings ) objSesion.getAttribute ( "printJob" );
		return ( J000J000ServicioImpresionStruts.genDocOnlineStruts ( settings,
				pObjRequest, pObjResponse ) );

	}
}
