package com.mapfre.mavisa.wss372vencimientosmanuales.actions;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;


import com.mapfre.mavisa.wss372vencimientosmanuales.config.J372J001ConstantesVen;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J005ImpresionInformesVenPageBean;

import mapfre.wss000arquitect.excepciones.J000J000PrintException;
import mapfre.wss000arquitect.impresion.PrintJob;
import mapfre.wss000arquitect.impresion.PrintJobTask;
import mapfre.wss000arquitect.utilidades.J000J000Trazas;

/**
 * 
 * @author everis
 * 
 * @version 1.0  Clase para realizar la impresion de FormsPath.
 * 
 */
public class J372J016ImpresionInformesDirecta extends PrintJobTask

{
	/**
	 * objTrazas
	 */
	private static final Logger objTrazas = J000J000Trazas.getLogger(J372J016ImpresionInformesDirecta.class);


	/**
	 * Prepara todos las etiquetas necesarias para la impresion
	 * 
	 * @param request
	 *            objeto request
	 * @param response
	 *            objeto response
	 * @param job
	 *            objeto tarea de impresion
	 * @throws J000J000PrintException
	 */
  

	public void prepareJob (HttpServletRequest request,
			HttpServletResponse response, PrintJob job)
			throws J000J000PrintException {
		try { 
			HttpSession oSesion = null;
			J372J005ImpresionInformesVenPageBean oResultado = null;
			// Se obtiene la sesi�n de la request
			oSesion = request.getSession(true);

			if (oSesion.getAttribute(J372J001ConstantesVen.DATOS_INFORME) != null) {

				oResultado = (J372J005ImpresionInformesVenPageBean) oSesion
				.getAttribute (J372J001ConstantesVen.DATOS_INFORME);

		// A�adimos la plantilla sobre la que se imprimiran los datos.

				
				job.setDocType("EMISIONFINIQUITOVENCIMIENTOS");
				
				int size = oResultado.getListadoInf().size();
				
				for (int i = 0; i < size; i++) {
					
					 final J372J005ImpresionInformesVenPageBean elemListado = 
						  (J372J005ImpresionInformesVenPageBean)oResultado.getListadoInf().get(i);
				
					 
	//				 TODO A�adir trazas en los logs
					if (objTrazas.isDebugEnabled()) { 
						
						objTrazas.debug("ImpresionInformesDirecta");
						objTrazas.debug("ImpresionInformesDirecta - oResultado.getListadoInf()"
								 + oResultado.getListadoInf());
					}
					if (elemListado.getAnio()!= ""){
					//parseo de variables que iran en el pdf
					job.addDataTag("V0001", elemListado.getAnio(), PrintJob.GLBData);
					job.addDataTag("V0002", elemListado.getExpediente(), PrintJob.GLBData);
					job.addDataTag("V0003", elemListado.getRamo(), PrintJob.GLBData);
					job.addDataTag("V0004", elemListado.getAnioPol(), PrintJob.GLBData);
					job.addDataTag("V0005", elemListado.getPoliza(), PrintJob.GLBData);
					job.addDataTag("V0006", elemListado.getRegional(), PrintJob.GLBData);
					job.addDataTag("V0007", elemListado.getOficina(), PrintJob.GLBData);
					job.addDataTag("V0008", elemListado.getModalidad(), PrintJob.GLBData);
					job.addDataTag("V0009", elemListado.getFecDesdeLit(), PrintJob.GLBData);
					job.addDataTag("V0010", elemListado.getFecLiquidaLit(), PrintJob.GLBData);
					
					job.addDataTag("V0011", elemListado.getAnocomples(), PrintJob.GLBData);
					
					job.addDataTag("V0012", elemListado.getImPrest(), PrintJob.GLBData);
					job.addDataTag("V0013", elemListado.getLiteral(), PrintJob.GLBData);
					job.addDataTag("V0014", elemListado.getBeneficios(), PrintJob.GLBData);
					
					job.addDataTag("V0015", elemListado.getCobroInt(), PrintJob.GLBData);
					job.addDataTag("V0016", elemListado.getAnticipo(), PrintJob.GLBData);
					
					job.addDataTag("V0017", elemListado.getRetCuenta(), PrintJob.GLBData);
					job.addDataTag("V0018", elemListado.getRetenc(), PrintJob.GLBData);
					job.addDataTag("V0019", elemListado.getImPliquid(), PrintJob.GLBData);
					job.addDataTag("V0020", elemListado.getFecEfectEmisionLit(), PrintJob.GLBData);
					job.addDataTag("V0021", elemListado.getNombreApell(), PrintJob.GLBData);
					job.addDataTag("V0022", elemListado.getNif(), PrintJob.GLBData);
					job.addDataTag("V0023", elemListado.getDomicilio(), PrintJob.GLBData);
					job.addDataTag("V0024", elemListado.getCodPostal(), PrintJob.GLBData);
					job.addDataTag("V0025", elemListado.getPoblacion(), PrintJob.GLBData);
					job.addDataTag("V0026", elemListado.getProvincia(), PrintJob.GLBData);
					job.addDataTag("V0027", elemListado.getTipEmision(), PrintJob.GLBData);
					job.addDataTag("V0028", elemListado.getTipImpuesto(), PrintJob.GLBData);
					job.addDataTag("V0029", elemListado.getTipoCompl(), PrintJob.GLBData);
					}
				 } 
			}
		} catch (J000J000PrintException printException) {
			if (objTrazas.isEnabledFor(Level.ERROR)) {
				objTrazas.error("ImpresionDirecta - Excepcion servicio impresi�n:"
						+ printException.toString());
			}	
			throw printException;
		}
			
	}
	
}
