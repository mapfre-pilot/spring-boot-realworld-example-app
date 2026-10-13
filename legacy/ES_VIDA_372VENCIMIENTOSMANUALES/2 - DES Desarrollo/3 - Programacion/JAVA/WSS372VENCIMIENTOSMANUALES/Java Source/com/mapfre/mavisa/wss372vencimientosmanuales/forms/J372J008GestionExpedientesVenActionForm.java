/* MODIFICACION : MU-2016-006673
FECHA : MARZO 2016
DESCRIPCION: Se permite modificar y guardar en BBDD el kdomiclio del beneficiario
AUTOR : RAROALE */

/*MODIFICACION : MU-2016-006664
FECHA : MARZO 2016
DESCRIPCION: Se permite modificar y guardar en BBDD los importes de Coaseguros
AUTOR : RAROALE */

/*MODIFICACION : MU-2015-041869
FECHA : 14/10/2015
DESCRIPCION: Incluir "A�o Fiscal" para informar a la BDGI.
AUTOR : INDRA */

package com.mapfre.mavisa.wss372vencimientosmanuales.forms;

import java.util.Collections;
import java.util.List;
import java.util.Vector;
import org.apache.struts.action.ActionForm;

/**
 * Form bean for a Struts application.
 * 
 * @version 1.0 Versi�n inicial
 * @author everis
 */
public class J372J008GestionExpedientesVenActionForm extends ActionForm

{
	/**
	 * Inicializacion de la variable VALORCEROCOMACERO, valor 0,00
	 */
	private static final String VALORCEROCOMACERO = "0,00";

	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inicializamos el IMPUESTO, con valor 34
	 */
	private static final String IMPUESTO = "34";

	/**
	 * Inicializamos el anio, con valor ENBLANCO
	 */
	private String anio = ENBLANCO;
	
	/**
	 * Inicializamos el selectedRow
	 */
	private String selectedRow = ENBLANCO;
	
	/**
	 * Inicializamos el polizaSel
	 */
	private String polizaSel = ENBLANCO;
	
	/**
	 * Inicializamos el subpolizaSel
	 */
	private String subpolizaSel = ENBLANCO;
	
	/**
	 * Inicializamos el certificadoSel
	 */
	private String certificadoSel = ENBLANCO;

	/**
	 * Inicializamos el expediente, con valor ENBLANCO
	 */
	private String expediente = ENBLANCO;

	/**
	 * Inicializamos el polizaBloq1, con valor ENBLANCO
	 */
	private String polizaBloq1 = ENBLANCO;

	/**
	 * Inicializamos el polizaBloq2, con valor ENBLANCO
	 */
	private String polizaBloq2 = ENBLANCO;

	/**
	 * Inicializamos el polizaBloq3, con valor ENBLANCO
	 */
	private String polizaBloq3 = ENBLANCO;

	/**
	 * Inicializamos el subpoliza, con valor ENBLANCO
	 */
	private String subpoliza = ENBLANCO;

	/**
	 * Inicializamos el modalidad, con valor ENBLANCO
	 */
	private String modalidad = ENBLANCO;
	
	/**
	 * Inicializamos el tipRescate, con valor 1
	 */
	private String tipRescate = "1";
	
	/**
	 * Inicializamos el tipSituacion, con valor VI
	 */
	private String tipSituacion = "VI";
	

	/**
	 * Inicializamos el certificado, con valor ENBLANCO
	 */
	private String certificado = ENBLANCO;

	/**
	 * Inicializamos el fecEfect, con valor ENBLANCO
	 */
	private String fecEfect = ENBLANCO;

	/**
	 * Inicializamos el fecAnul, con valor ENBLANCO
	 */
	private String fecAnul = ENBLANCO;

	/**
	 * Inicializamos el fecModi, con valor ENBLANCO
	 */
	private String fecModi = ENBLANCO;

	/**
	 * Inicializamos el tomador, con valor ENBLANCO
	 */
	private String tomador = ENBLANCO;

	/**
	 * Inicializamos el regionalPol, con valor ENBLANCO
	 */
	private String regionalPol = ENBLANCO;

	/**
	 * Inicializamos el regionalEnv, con valor ENBLANCO
	 */
	private String regionalEnv = ENBLANCO;

	/**
	 * Inicializamos el oficina, con valor ENBLANCO
	 */
	private String oficina = ENBLANCO;

	/**
	 * Inicializamos el pendiente, con valor ENBLANCO
	 */
	private String pendiente = VALORCEROCOMACERO;

	/**
	 * Inicializamos el observaciones, con valor ENBLANCO
	 */
	private String observaciones = ENBLANCO;

	/**
	 * Inicializamos el importePri, con valor ENBLANCO
	 */
	private String importePri = VALORCEROCOMACERO;

	/**
	 * Inicializamos el beneficiosPri, con valor ENBLANCO
	 */
	private String beneficiosPri = VALORCEROCOMACERO;

	/**
	 * Inicializamos el fecPagoCapital, con valor ENBLANCO
	 */
	private String fecPagoCapital = ENBLANCO;

	/**
	 * Inicializamos el fecPagoPri, con valor ENBLANCO
	 */
	private String fecPagoPri = ENBLANCO;

	/**
	 * Inicializamos el impAnticipo, con valor ENBLANCO
	 */
	private String impAnticipo = VALORCEROCOMACERO;

	/**
	 * Inicializamos el anticipoPri, con valor ENBLANCO
	 */
	private String anticipoPri = VALORCEROCOMACERO;

	/**
	 * Inicializamos el impInteresPend, con valor ENBLANCO
	 */
	private String impInteresPend = VALORCEROCOMACERO;

	/**
	 * Inicializamos el cobroInterPri, con valor ENBLANCO
	 */
	private String cobroInterPri = VALORCEROCOMACERO;

	/**
	 * Inicializamos el devolInterPri, con valor ENBLANCO
	 */
	private String devolInterPri = VALORCEROCOMACERO;

	/**
	 * Inicializamos el reciboPri, con valor ENBLANCO
	 */
	private String reciboPri = VALORCEROCOMACERO;

	/**
	 * Inicializamos el fecReciPri, con valor ENBLANCO
	 */
	private String fecReciPri = ENBLANCO;

	/**
	 * Inicializamos el fecEmisionPri, con valor ENBLANCO
	 */
	private String fecEmisionPri = ENBLANCO;

	/**
	 * Inicializamos el fecVencimiento, con valor ENBLANCO
	 */
	private String fecVencimiento = ENBLANCO;

	/**
	 * Inicializamos el tipoImpuestoPri, con valor ENBLANCO
	 */
	private String tipoImpuestoPri = IMPUESTO;

	/**
	 * Inicializamos el tipImpuestoCap, con valor ENBLANCO
	 */
	private String tipImpuestoCap = IMPUESTO;

	/**
	 * Inicializamos el rtoIntegroCap, con valor ENBLANCO
	 */
	private String rtoIntegroCap = VALORCEROCOMACERO;

	/**
	 * Inicializamos el rtoIntegroPri, con valor ENBLANCO
	 */
	private String rtoIntegroPri = VALORCEROCOMACERO;

	/**
	 * Inicializamos el redPrimasCap, con valor ENBLANCO
	 */
	private String redPrimasCap = VALORCEROCOMACERO;

	/**
	 * Inicializamos el compensaCap, con valor ENBLANCO
	 */
	private String compensaCap = VALORCEROCOMACERO;

	/**
	 * Inicializamos el rtoNetoCap, con valor ENBLANCO
	 */
	private String rtoNetoCap = VALORCEROCOMACERO;

	/**
	 * Inicializamos el porcentajeCap, con valor ENBLANCO
	 */
	private String porcentajeCap = VALORCEROCOMACERO;

	/**
	 * Inicializamos el retencionCap, con valor ENBLANCO
	 */
	private String retencionCap = VALORCEROCOMACERO;

	/**
	 * Inicializamos el liquidoCap, con valor ENBLANCO
	 */
	private String liquidoCap = VALORCEROCOMACERO;

	/**
	 * Inicializamos el fecPagoIRPFCap, con valor ENBLANCO
	 */
	private String fecPagoIRPFCap = ENBLANCO;

	/**
	 * Inicializamos el redTransitCap, con valor ENBLANCO
	 */
	private String redTransitCap = VALORCEROCOMACERO;

	/**
	 * Inicializamos el redPrimasPri, con valor ENBLANCO
	 */
	private String redPrimasPri = VALORCEROCOMACERO;

	/**
	 * Inicializamos el redTransitPri, con valor ENBLANCO
	 */
	private String redTransitPri = VALORCEROCOMACERO;

	/**
	 * Inicializamos el rtoNetoPri, con valor ENBLANCO
	 */
	private String rtoNetoPri = VALORCEROCOMACERO;

	/**
	 * Inicializamos el porcentajePri, con valor ENBLANCO
	 */
	private String porcentajePri = VALORCEROCOMACERO;

	/**
	 * Inicializamos el retencionPri, con valor ENBLANCO
	 */
	private String retencionPri = VALORCEROCOMACERO;

	/**
	 * Inicializamos el fecPagoIRPFPri, con valor ENBLANCO
	 */
	private String fecPagoIRPFPri = ENBLANCO;

	/**
	 * Inicializamos el compensaPri, con valor ENBLANCO
	 */
	private String compensaPri = VALORCEROCOMACERO;

	/**
	 * Inicializamos el liquidoPri, con valor ENBLANCO
	 */
	private String liquidoPri = VALORCEROCOMACERO;

	/**
	 * Inicializamos el fecBDGICap, con valor ENBLANCO
	 */
	private String fecBDGICap = ENBLANCO;
	/**
	 * Inicializamos el fecBDGIComp1, con valor ENBLANCO
	 */
	private String fecBDGIComp1 = ENBLANCO;
	
	/**
	 * Inicializamos el fecBDGIComp2, con valor ENBLANCO
	 */
	private String fecBDGIComp2 = ENBLANCO;
	
	/**
	 * Inicializamos el sBDGICap
	 */
	private String sBDGICap = ENBLANCO;
	/**
	 * Inicializamos el sBDGIComp
	 */
	private String sBDGIComp = ENBLANCO;
	/**
	 * Inicializamos el sBDGIComp2
	 */
	private String sBDGIComp2 = ENBLANCO;
	

	/**
	 * Inicializamos el fecImprePri, con valor ENBLANCO
	 */
	private String fecImprePri = ENBLANCO;

	/**
	 * Inicializamos el importeComp, con valor ENBLANCO
	 */
	private String importeComp = VALORCEROCOMACERO;

	/**
	 * Inicializamos el fecPagoComp, con valor ENBLANCO
	 */
	private String fecPagoComp = ENBLANCO;

	/**
	 * Inicializamos el fecEmisionComp, con valor ENBLANCO
	 */
	private String fecEmisionComp = ENBLANCO;

	/**
	 * Inicializamos el tipoImpuestoComp, con valor ENBLANCO
	 */
	private String tipoImpuestoComp = IMPUESTO;

	/**
	 * Inicializamos el rtoIntegroComp, con valor ENBLANCO
	 */
	private String rtoIntegroComp = VALORCEROCOMACERO;

	/**
	 * Inicializamos el redPrimasComp, con valor ENBLANCO
	 */
	private String redPrimasComp = VALORCEROCOMACERO;

	/**
	 * Inicializamos el redTransitComp, con valor ENBLANCO
	 */
	private String redTransitComp = VALORCEROCOMACERO;

	/**
	 * Inicializamos el rtoNetoComp, con valor ENBLANCO
	 */
	private String rtoNetoComp = VALORCEROCOMACERO;

	/**
	 * Inicializamos el porcentajeComp, con valor ENBLANCO
	 */
	private String porcentajeComp = VALORCEROCOMACERO;

	/**
	 * Inicializamos el retencionComp, con valor ENBLANCO
	 */
	private String retencionComp = VALORCEROCOMACERO;

	/**
	 * Inicializamos el fecPagoIRPFComp, con valor ENBLANCO
	 */
	private String fecPagoIRPFComp = ENBLANCO;

	/**
	 * Inicializamos el liquidoComp, con valor ENBLANCO
	 */
	private String liquidoComp = VALORCEROCOMACERO;

	/**
	 * Inicializamos el kpersonaPri, con valor ENBLANCO
	 */
	private String kpersonaPri = ENBLANCO;
	
	// MU-2016-006673 - RAROALE - INI
	/**
	 * Inicializamos el kdomicilioPri, con valor ENBLANCO
	 */
	private String kdomicilioPri = ENBLANCO;
	
	/**
	 * Inicializamos el fmodificacion, con valor ENBLANCO
	 */
	private String fmodificacion = ENBLANCO;
	// MU-2016-006673 - RAROALE - FIN

	/**
	 * Inicializamos el impCapital, con valor ENBLANCO
	 */
	private String impCapital = VALORCEROCOMACERO;

	/**
	 * Inicializamos el nifCifPri, con valor ENBLANCO
	 */
	private String nifCifPri = ENBLANCO;

	/**
	 * Inicializamos el nombrePri, con valor ENBLANCO
	 */
	private String nombrePri = ENBLANCO;

	/**
	 * Inicializamos el apellido1Pri, con valor ENBLANCO
	 */
	private String apellido1Pri = ENBLANCO;

	/**
	 * Inicializamos el apellido2Pri, con valor ENBLANCO
	 */
	private String apellido2Pri = ENBLANCO;
	
	/**
	 * Inicializamos el tipPersonaPri, con valor ENBLANCO
	 */
	private String tipPersonaPri = ENBLANCO;

	/**
	 * Inicializamos el tipPersonaPriValue, con valor ENBLANCO
	 */
	private String tipPersonaPriValue = ENBLANCO;
	

	/**
	 * Inicializamos el residentePri, con valor ENBLANCO
	 */
	private String residentePri = "1";

	/**
	 * Inicializamos el residenteSeg, con valor ENBLANCO
	 */
	private String residenteSeg = "1";

	/**
	 * Inicializamos el domicilioPri, con valor ENBLANCO
	 */
	private String domicilioPri = ENBLANCO;

	/**
	 * Inicializamos el codPostalPri, con valor ENBLANCO
	 */
	private String codPostalPri = ENBLANCO;

	/**
	 * Inicializamos el localidadPri, con valor ENBLANCO
	 */
	private String localidadPri = ENBLANCO;

	/**
	 * Inicializamos el provinciaPri, con valor ENBLANCO
	 */
	private String provinciaPri = ENBLANCO;

	/**
	 * Inicializamos el paisPri, con valor ENBLANCO
	 */
	private String paisPri = ENBLANCO;

	/**
	 * Inicializamos el nifRepLegalPri, con valor ENBLANCO
	 */
	private String nifRepLegalPri = ENBLANCO;

	/**
	 * Inicializamos el fecNacPri, con valor ENBLANCO
	 */
	private String fecNacPri = ENBLANCO;

	/**
	 * Inicializamos el discapacitadoPri, con valor ENBLANCO
	 */
	private String discapacitadoPri = ENBLANCO;

	/**
	 * Inicializamos el sitFamiliarPri, con valor ENBLANCO
	 */
	private String sitFamiliarPri = ENBLANCO;

	/**
	 * Inicializamos el nifConyugePri, con valor ENBLANCO
	 */
	private String nifConyugePri = ENBLANCO;

	/**
	 * Inicializamos el penCompPri, con valor ENBLANCO
	 */
	private String penCompPri = ENBLANCO;

	/**
	 * Inicializamos el anulAlimenHijosPri, con valor ENBLANCO
	 */
	private String anulAlimenHijosPri = ENBLANCO;

	/**
	 * Inicializamos el prestViviendoPri, con valor ENBLANCO
	 */
	private String prestViviendoPri = ENBLANCO;

	/**
	 * Inicializamos el codCoasegur1, con valor ENBLANCO
	 */
	private String codCoasegur1 = ENBLANCO;

	/**
	 * Inicializamos el porCoasegur1, con valor ENBLANCO
	 */
	private String porCoasegur1 = ENBLANCO;

	/**
	 * Inicializamos el codCoasegur2, con valor ENBLANCO
	 */
	private String codCoasegur2 = ENBLANCO;

	/**
	 * Inicializamos el porCoasegur2, con valor ENBLANCO
	 */
	private String porCoasegur2 = ENBLANCO;

	/**
	 * Inicializamos el codCoasegur3, con valor ENBLANCO
	 */
	private String codCoasegur3 = ENBLANCO;

	/**
	 * Inicializamos el porCoasegur3, con valor ENBLANCO
	 */
	private String porCoasegur3 = ENBLANCO;

	/**
	 * Inicializamos el codCoasegur4, con valor ENBLANCO
	 */
	private String codCoasegur4 = ENBLANCO;

	/**
	 * Inicializamos el porCoasegur4, con valor ENBLANCO
	 */
	private String porCoasegur4 = ENBLANCO;

	/**
	 * Inicializamos el codCoasegur5, con valor ENBLANCO
	 */
	private String codCoasegur5 = ENBLANCO;

	/**
	 * Inicializamos el porCoasegur5, con valor ENBLANCO
	 */
	private String porCoasegur5 = ENBLANCO;

	/**
	 * Inicializamos el codCoasegur6, con valor ENBLANCO
	 */
	private String codCoasegur6 = ENBLANCO;

	/**
	 * Inicializamos el porCoasegur6, con valor ENBLANCO
	 */
	private String porCoasegur6 = ENBLANCO;
	//MU-2016-006664 - RAROALE - INI
	/**
	 * Inicializamos el impCoasegur1, con valor ENBLANCO
	 */
	private String impCoasegur1 = ENBLANCO;
	
	/**
	 * Inicializamos el impCoasegur2, con valor ENBLANCO
	 */
	private String impCoasegur2 = ENBLANCO;
	
	/**
	 * Inicializamos el impCoasegur3, con valor ENBLANCO
	 */
	private String impCoasegur3 = ENBLANCO;
	
	/**
	 * Inicializamos el impCoasegur4, con valor ENBLANCO
	 */
	private String impCoasegur4 = ENBLANCO;
	
	/**
	 * Inicializamos el impCoasegur5, con valor ENBLANCO
	 */
	private String impCoasegur5 = ENBLANCO;
	
	/**
	 * Inicializamos el impCoasegur6, con valor ENBLANCO
	 */
	private String impCoasegur6 = ENBLANCO;
	//MU-2016-006664 - RAROALE - FIN

	// R&V CA Fase II CU011-COASEGURO - INI
	private String valoresManuales = "N";
	public String getValoresManuales() { return valoresManuales; }
	public void setValoresManuales(String valoresManuales) { this.valoresManuales = valoresManuales; }
	// R&V CA Fase II CU011-COASEGURO - FIN

	// R&V Junio 2017 - REACONDICIONAMIENTO VT01 VT04 - everis(RGL) - INI
	private String rtoIntegroCoa1 = ENBLANCO;
	private String rtoIntegroCoa2 = ENBLANCO;
	private String rtoIntegroCoa3 = ENBLANCO;
	private String rtoIntegroCoa4 = ENBLANCO;
	private String rtoIntegroCoa5 = ENBLANCO;
	private String rtoIntegroCoa6 = ENBLANCO;
	private String redPrimasCoa1 = ENBLANCO;
	private String redPrimasCoa2 = ENBLANCO;
	private String redPrimasCoa3 = ENBLANCO;
	private String redPrimasCoa4 = ENBLANCO;
	private String redPrimasCoa5 = ENBLANCO;
	private String redPrimasCoa6= ENBLANCO;
	private String redTransitoriaCoa1 = ENBLANCO;
	private String redTransitoriaCoa2 = ENBLANCO;
	private String redTransitoriaCoa3 = ENBLANCO;
	private String redTransitoriaCoa4 = ENBLANCO;
	private String redTransitoriaCoa5 = ENBLANCO;
	private String redTransitoriaCoa6 = ENBLANCO;
	private String rtoNetoCoa1 = ENBLANCO;
	private String rtoNetoCoa2 = ENBLANCO;
	private String rtoNetoCoa3 = ENBLANCO;
	private String rtoNetoCoa4 = ENBLANCO;
	private String rtoNetoCoa5 = ENBLANCO;
	private String rtoNetoCoa6 = ENBLANCO;
	private String retencionCoa1 = ENBLANCO;
	private String retencionCoa2 = ENBLANCO;
	private String retencionCoa3 = ENBLANCO;
	private String retencionCoa4 = ENBLANCO;
	private String retencionCoa5 = ENBLANCO;
	private String retencionCoa6 = ENBLANCO;
	private String compenCoa1 = ENBLANCO;
	private String compenCoa2 = ENBLANCO;
	private String compenCoa3 = ENBLANCO;
	private String compenCoa4 = ENBLANCO;
	private String compenCoa5 = ENBLANCO;
	private String compenCoa6 = ENBLANCO;

	//R&V - CU009 - INI
	/**
	 * Inicializamos eximido con valor N
	 */
	private String eximido = "N";
	//R&V - CU009 - FIN
		
	/**
	 * Inicializamos el vencimientoMigrado, con valor 1
	 */
	private String vencimientoMigrado = "N";
	
	/**
	 * Inicializamos el usuarioPagoPri, con valor ENBLANCO
	 */
	private String usuarioPagoPri = ENBLANCO;
	
	/**
	 * Inicializamos el fecCapturaPri, con valor ENBLANCO
	 */
	private String fecCapturaPri = ENBLANCO;
	
	/**
	 * Inicializamos el usuarioCapturaPri, con valor ENBLANCO
	 */
	private String usuarioCapturaPri = ENBLANCO;
	
	/**
	 * Inicializamos el formaPagoPri, con valor ENBLANCO
	 */
	private String formaPagoPri = ENBLANCO;
	
	/**
	 * Inicializamos el descFormaPagoPri, con valor ENBLANCO
	 */
	private String descFormaPagoPri = ENBLANCO;
	
	/**
	 * Inicializamos el refReinversionPri, con valor ENBLANCO
	 */
	private String refReinversionPri = ENBLANCO;
		
	/**
	 * Inicializamos el numChequePri, con valor ENBLANCO
	 */
	private String numChequePri = ENBLANCO;
	
	/**
	 * Inicializamos el numCuentaPri, con valor ENBLANCO
	 */
	private String numCuentaPri = ENBLANCO;
	
	/**
	 * Inicializamos el usuarioPagoComp1, con valor ENBLANCO
	 */
	private String usuarioPagoComp1 = ENBLANCO;
	
	/**
	 * Inicializamos el fecCapturaComp1, con valor ENBLANCO
	 */
	private String fecCapturaComp1 = ENBLANCO;
	
	/**
	 * Inicializamos el usuarioCapturaComp1, con valor ENBLANCO
	 */
	private String usuarioCapturaComp1 = ENBLANCO; 
	
	/**
	 * Inicializamos el formaPagoComp1, con valor ENBLANCO
	 */
	private String formaPagoComp1 = ENBLANCO; 
	
	/**
	 * Inicializamos el descFormaPagoComp1, con valor ENBLANCO
	 */
	private String descFormaPagoComp1 = ENBLANCO;
	
	/**
	 * Inicializamos el numChequeComp1, con valor ENBLANCO
	 */
	private String numChequeComp1 = ENBLANCO;
	
	/**
	 * Inicializamos el numCuentaComp1, con valor ENBLANCO
	 */
	private String numCuentaComp1 = ENBLANCO;
	
	/**
	 * Inicializamos el usuarioPagoComp2, con valor ENBLANCO
	 */
	private String usuarioPagoComp2 = ENBLANCO;
	
	/**
	 * Inicializamos el fecCapturaComp2, con valor ENBLANCO
	 */
	private String fecCapturaComp2 = ENBLANCO;
	
	/**
	 * Inicializamos el usuarioCapturaComp2, con valor ENBLANCO
	 */
	private String usuarioCapturaComp2 = ENBLANCO; 
	
	/**
	 * Inicializamos el formaPagoComp2, con valor ENBLANCO
	 */
	private String formaPagoComp2 = ENBLANCO; 
	
	/**
	 * Inicializamos el descFormaPagoComp2, con valor ENBLANCO
	 */
	private String descFormaPagoComp2 = ENBLANCO;
	
	/**
	 * Inicializamos el numChequeComp2, con valor ENBLANCO
	 */
	private String numChequeComp2 = ENBLANCO;
	
	/**
	 * Inicializamos el numCuentaComp2, con valor ENBLANCO
	 */
	private String numCuentaComp2 = ENBLANCO;
	
	/**
	 * @return el vencimientoMigrado
	 */
	public String getVencimientoMigrado() {
	    return vencimientoMigrado;
	}
	
	/**
	 * @param vencimientoMigrado
	 */
	public void setVencimientoMigrado(String vencimientoMigrado) {
	    this.vencimientoMigrado = vencimientoMigrado;
	}
	
	/**
	 * @return el usuarioPagoPri
	 */
	public String getUsuarioPagoPri() {
	    return usuarioPagoPri;
	}
	
	/**
	 * @param usuarioPagoPri
	 */
	public void setUsuarioPagoPri(String usuarioPagoPri) {
	    this.usuarioPagoPri = usuarioPagoPri;
	}
	
	/**
	 * @return el fecCapturaPri
	 */
	public String getFecCapturaPri() {
	    return fecCapturaPri;
	}
	
	/**
	 * @param fecCapturaPri
	 */
	public void setFecCapturaPri(String fecCapturaPri) {
	    this.fecCapturaPri = fecCapturaPri;
	}
	
	/**
	 * @return el usuarioCapturaPri
	 */
	public String getUsuarioCapturaPri() {
	    return usuarioCapturaPri;
	}
	
	/**
	 * @param usuarioCapturaPri
	 */
	public void setUsuarioCapturaPri(String usuarioCapturaPri) {
	    this.usuarioCapturaPri = usuarioCapturaPri;
	}
	
	/**
	 * @return el formaPagoPri
	 */
	public String getFormaPagoPri() {
	    return formaPagoPri;
	}
	
	/**
	 * @param formaPagoPri
	 */
	public void setFormaPagoPri(String formaPagoPri) {
	    this.formaPagoPri = formaPagoPri;
	}
	
	/**
	 * @return el descFormaPagoPri
	 */
	public String getDescFormaPagoPri() {
	    return descFormaPagoPri;
	}
	
	/**
	 * @param descFormaPagoPri
	 */
	public void setDescFormaPagoPri(String descFormaPagoPri) {
	    this.descFormaPagoPri = descFormaPagoPri;
	}
	
	/**
	 * @return el polizaDestPri
	 */
	public String getRefReinversionPri() {
	    return refReinversionPri;
	}
	
	/**
	 * @param polizaDestPri
	 */
	public void setRefReinversionPri(String refReinversionPri) {
	    this.refReinversionPri = refReinversionPri;
	}
	
	/**
	 * @return el numChequePri
	 */
	public String getNumChequePri() {
	    return numChequePri;
	}
	
	/**
	 * @param numChequePri
	 */
	public void setNumChequePri(String numChequePri) {
	    this.numChequePri = numChequePri;
	}
	
	/**
	 * @return el numCuentaPri
	 */
	public String getNumCuentaPri() {
	    return numCuentaPri;
	}
	
	/**
	 * @param numCuentaPri
	 */
	public void setNumCuentaPri(String numCuentaPri) {
	    this.numCuentaPri = numCuentaPri;
	}
	
	/**
	 * @return el usuarioPagoComp1
	 */
	public String getUsuarioPagoComp1() {
	    return usuarioPagoComp1;
	}
	
	/**
	 * @param usuarioPagoComp1
	 */
	public void setUsuarioPagoComp1(String usuarioPagoComp1) {
	    this.usuarioPagoComp1 = usuarioPagoComp1;
	}
	
	/**
	 * @return el fecCapturaComp1
	 */
	public String getFecCapturaComp1() {
	    return fecCapturaComp1;
	}
	
	/**
	 * @param fecCapturaComp1
	 */
	public void setFecCapturaComp1(String fecCapturaComp1) {
	    this.fecCapturaComp1 = fecCapturaComp1;
	}
	
	/**
	 * @return el usuarioCapturaComp1
	 */
	public String getUsuarioCapturaComp1() {
	    return usuarioCapturaComp1;
	}
	
	/**
	 * @param usuarioCapturaComp1
	 */
	public void setUsuarioCapturaComp1(String usuarioCapturaComp1) {
	    this.usuarioCapturaComp1 = usuarioCapturaComp1;
	}
	
	/**
	 * @return el formaPagoComp1
	 */
	public String getFormaPagoComp1() {
	    return formaPagoComp1;
	}
	
	/**
	 * @param formaPagoComp1
	 */
	public void setFormaPagoComp1(String formaPagoComp1) {
	    this.formaPagoComp1 = formaPagoComp1;
	}
	
	/**
	 * @return el descFormaPagoComp1
	 */
	public String getDescFormaPagoComp1() {
	    return descFormaPagoComp1;
	}
	
	/**
	 * @param descFormaPagoComp1
	 */
	public void setDescFormaPagoComp1(String descFormaPagoComp1) {
	    this.descFormaPagoComp1 = descFormaPagoComp1;
	}
	
	/**
	 * @return el numChequeComp1
	 */
	public String getNumChequeComp1() {
	    return numChequeComp1;
	}
	
	/**
	 * @param numChequeComp1
	 */
	public void setNumChequeComp1(String numChequeComp1) {
	    this.numChequeComp1 = numChequeComp1;
	}
	
	/**
	 * @return el numCuentaComp1
	 */
	public String getNumCuentaComp1() {
	    return numCuentaComp1;
	}
	
	/**
	 * @param numCuentaComp1
	 */
	public void setNumCuentaComp1(String numCuentaComp1) {
	    this.numCuentaComp1 = numCuentaComp1;
	}
	
	/**
	 * @return el usuarioPagoComp2
	 */
	public String getUsuarioPagoComp2() {
	    return usuarioPagoComp2;
	}
	
	/**
	 * @param usuarioPagoComp2
	 */
	public void setUsuarioPagoComp2(String usuarioPagoComp2) {
	    this.usuarioPagoComp2 = usuarioPagoComp2;
	}
	
	/**
	 * @return el fecCapturaComp2
	 */
	public String getFecCapturaComp2() {
	    return fecCapturaComp2;
	}
	
	/**
	 * @param fecCapturaComp2
	 */
	public void setFecCapturaComp2(String fecCapturaComp2) {
	    this.fecCapturaComp2 = fecCapturaComp2;
	}
	
	/**
	 * @return el usuarioCapturaComp2
	 */
	public String getUsuarioCapturaComp2() {
	    return usuarioCapturaComp2;
	}
	
	/**
	 * @param usuarioCapturaComp2
	 */
	public void setUsuarioCapturaComp2(String usuarioCapturaComp2) {
	    this.usuarioCapturaComp2 = usuarioCapturaComp2;
	}
	
	/**
	 * @return el formaPagoComp2
	 */
	public String getFormaPagoComp2() {
	    return formaPagoComp2;
	}
	
	/**
	 * @param formaPagoComp2
	 */
	public void setFormaPagoComp2(String formaPagoComp2) {
	    this.formaPagoComp2 = formaPagoComp2;
	}
	
	/**
	 * @return el descFormaPagoComp2
	 */
	public String getDescFormaPagoComp2() {
	    return descFormaPagoComp2;
	}
	
	/**
	 * @param descFormaPagoComp2
	 */
	public void setDescFormaPagoComp2(String descFormaPagoComp2) {
	    this.descFormaPagoComp2 = descFormaPagoComp2;
	}
	
	/**
	 * @return el numChequeComp2
	 */
	public String getNumChequeComp2() {
	    return numChequeComp2;
	}
	
	/**
	 * @param numChequeComp2
	 */
	public void setNumChequeComp2(String numChequeComp2) {
	    this.numChequeComp2 = numChequeComp2;
	}
	
	/**
	 * @return el numCuentaComp2
	 */
	public String getNumCuentaComp2() {
	    return numCuentaComp2;
	}
	
	/**
	 * @param numCuentaComp2
	 */
	public void setNumCuentaComp2(String numCuentaComp2) {
	    this.numCuentaComp2 = numCuentaComp2;
	}
	
	public String getRtoIntegroCoa1() {
		return rtoIntegroCoa1;
	}

	public void setRtoIntegroCoa1(String rtoIntegroCoa1) {
		this.rtoIntegroCoa1 = rtoIntegroCoa1;
	}

	public String getRtoIntegroCoa2() {
		return rtoIntegroCoa2;
	}

	public void setRtoIntegroCoa2(String rtoIntegroCoa2) {
		this.rtoIntegroCoa2 = rtoIntegroCoa2;
	}

	public String getRtoIntegroCoa3() {
		return rtoIntegroCoa3;
	}

	public void setRtoIntegroCoa3(String rtoIntegroCoa3) {
		this.rtoIntegroCoa3 = rtoIntegroCoa3;
	}

	public String getRtoIntegroCoa4() {
		return rtoIntegroCoa4;
	}

	public void setRtoIntegroCoa4(String rtoIntegroCoa4) {
		this.rtoIntegroCoa4 = rtoIntegroCoa4;
	}

	public String getRtoIntegroCoa5() {
		return rtoIntegroCoa5;
	}

	public void setRtoIntegroCoa5(String rtoIntegroCoa5) {
		this.rtoIntegroCoa5 = rtoIntegroCoa5;
	}

	public String getRtoIntegroCoa6() {
		return rtoIntegroCoa6;
	}

	public void setRtoIntegroCoa6(String rtoIntegroCoa6) {
		this.rtoIntegroCoa6 = rtoIntegroCoa6;
	}

	public String getRedPrimasCoa1() {
		return redPrimasCoa1;
	}

	public void setRedPrimasCoa1(String redPrimasCoa1) {
		this.redPrimasCoa1 = redPrimasCoa1;
	}

	public String getRedPrimasCoa2() {
		return redPrimasCoa2;
	}

	public void setRedPrimasCoa2(String redPrimasCoa2) {
		this.redPrimasCoa2 = redPrimasCoa2;
	}

	public String getRedPrimasCoa3() {
		return redPrimasCoa3;
	}

	public void setRedPrimasCoa3(String redPrimasCoa3) {
		this.redPrimasCoa3 = redPrimasCoa3;
	}

	public String getRedPrimasCoa4() {
		return redPrimasCoa4;
	}

	public void setRedPrimasCoa4(String redPrimasCoa4) {
		this.redPrimasCoa4 = redPrimasCoa4;
	}

	public String getRedPrimasCoa5() {
		return redPrimasCoa5;
	}

	public void setRedPrimasCoa5(String redPrimasCoa5) {
		this.redPrimasCoa5 = redPrimasCoa5;
	}

	public String getRedPrimasCoa6() {
		return redPrimasCoa6;
	}

	public void setRedPrimasCoa6(String redPrimasCoa6) {
		this.redPrimasCoa6 = redPrimasCoa6;
	}

	public String getRedTransitoriaCoa1() {
		return redTransitoriaCoa1;
	}

	public void setRedTransitoriaCoa1(String redTransitoriaCoa1) {
		this.redTransitoriaCoa1 = redTransitoriaCoa1;
	}

	public String getRedTransitoriaCoa2() {
		return redTransitoriaCoa2;
	}

	public void setRedTransitoriaCoa2(String redTransitoriaCoa2) {
		this.redTransitoriaCoa2 = redTransitoriaCoa2;
	}

	public String getRedTransitoriaCoa3() {
		return redTransitoriaCoa3;
	}

	public void setRedTransitoriaCoa3(String redTransitoriaCoa3) {
		this.redTransitoriaCoa3 = redTransitoriaCoa3;
	}

	public String getRedTransitoriaCoa4() {
		return redTransitoriaCoa4;
	}

	public void setRedTransitoriaCoa4(String redTransitoriaCoa4) {
		this.redTransitoriaCoa4 = redTransitoriaCoa4;
	}

	public String getRedTransitoriaCoa5() {
		return redTransitoriaCoa5;
	}

	public void setRedTransitoriaCoa5(String redTransitoriaCoa5) {
		this.redTransitoriaCoa5 = redTransitoriaCoa5;
	}

	public String getRedTransitoriaCoa6() {
		return redTransitoriaCoa6;
	}

	public void setRedTransitoriaCoa6(String redTransitoriaCoa6) {
		this.redTransitoriaCoa6 = redTransitoriaCoa6;
	}

	public String getRtoNetoCoa1() {
		return rtoNetoCoa1;
	}

	public void setRtoNetoCoa1(String rtoNetoCoa1) {
		this.rtoNetoCoa1 = rtoNetoCoa1;
	}

	public String getRtoNetoCoa2() {
		return rtoNetoCoa2;
	}

	public void setRtoNetoCoa2(String rtoNetoCoa2) {
		this.rtoNetoCoa2 = rtoNetoCoa2;
	}

	public String getRtoNetoCoa3() {
		return rtoNetoCoa3;
	}

	public void setRtoNetoCoa3(String rtoNetoCoa3) {
		this.rtoNetoCoa3 = rtoNetoCoa3;
	}

	public String getRtoNetoCoa4() {
		return rtoNetoCoa4;
	}

	public void setRtoNetoCoa4(String rtoNetoCoa4) {
		this.rtoNetoCoa4 = rtoNetoCoa4;
	}

	public String getRtoNetoCoa5() {
		return rtoNetoCoa5;
	}

	public void setRtoNetoCoa5(String rtoNetoCoa5) {
		this.rtoNetoCoa5 = rtoNetoCoa5;
	}

	public String getRtoNetoCoa6() {
		return rtoNetoCoa6;
	}

	public void setRtoNetoCoa6(String rtoNetoCoa6) {
		this.rtoNetoCoa6 = rtoNetoCoa6;
	}

	public String getRetencionCoa1() {
		return retencionCoa1;
	}

	public void setRetencionCoa1(String retencionCoa1) {
		this.retencionCoa1 = retencionCoa1;
	}

	public String getRetencionCoa2() {
		return retencionCoa2;
	}

	public void setRetencionCoa2(String retencionCoa2) {
		this.retencionCoa2 = retencionCoa2;
	}

	public String getRetencionCoa3() {
		return retencionCoa3;
	}

	public void setRetencionCoa3(String retencionCoa3) {
		this.retencionCoa3 = retencionCoa3;
	}

	public String getRetencionCoa4() {
		return retencionCoa4;
	}

	public void setRetencionCoa4(String retencionCoa4) {
		this.retencionCoa4 = retencionCoa4;
	}

	public String getRetencionCoa5() {
		return retencionCoa5;
	}

	public void setRetencionCoa5(String retencionCoa5) {
		this.retencionCoa5 = retencionCoa5;
	}

	public String getRetencionCoa6() {
		return retencionCoa6;
	}

	public void setRetencionCoa6(String retencionCoa6) {
		this.retencionCoa6 = retencionCoa6;
	}

	public String getCompenCoa1() {
		return compenCoa1;
	}

	public void setCompenCoa1(String compenCoa1) {
		this.compenCoa1 = compenCoa1;
	}

	public String getCompenCoa2() {
		return compenCoa2;
	}

	public void setCompenCoa2(String compenCoa2) {
		this.compenCoa2 = compenCoa2;
	}

	public String getCompenCoa3() {
		return compenCoa3;
	}

	public void setCompenCoa3(String compenCoa3) {
		this.compenCoa3 = compenCoa3;
	}

	public String getCompenCoa4() {
		return compenCoa4;
	}

	public void setCompenCoa4(String compenCoa4) {
		this.compenCoa4 = compenCoa4;
	}

	public String getCompenCoa5() {
		return compenCoa5;
	}

	public void setCompenCoa5(String compenCoa5) {
		this.compenCoa5 = compenCoa5;
	}

	public String getCompenCoa6() {
		return compenCoa6;
	}

	public void setCompenCoa6(String compenCoa6) {
		this.compenCoa6 = compenCoa6;
	}
	// R&V Junio 2017 - REACONDICIONAMIENTO VT01 VT04 - everis(RGL) - FIN




	/**
	 * Inicializamos el totPagMapfre, con valor 2
	 */
	private String totPagMapfre = "1";

	/**
	 * Inicializamos el nifCifSeg, con valor ENBLANCO
	 */
	private String nifCifSeg = ENBLANCO;

	/**
	 * Inicializamos el nombreSeg, con valor ENBLANCO
	 */
	private String nombreSeg = ENBLANCO;

	/**
	 * Inicializamos el apellido1Seg, con valor ENBLANCO
	 */
	private String apellido1Seg = ENBLANCO;

	/**
	 * Inicializamos el apellido2Seg, con valor ENBLANCO
	 */
	private String apellido2Seg = ENBLANCO;

	/**
	 * Inicializamos el razonSocialSeg, con valor ENBLANCO
	 */
	private String razonSocialSeg = ENBLANCO;

	/**
	 * Inicializamos el razonSocialPri, con valor ENBLANCO
	 */
	private String razonSocialPri = ENBLANCO;

	/**
	 * Inicializamos el tipPersonaSeg, con valor ENBLANCO
	 */
	private String tipPersonaSeg = ENBLANCO;

	/**
	 * Inicializamos el domicilioSeg, con valor ENBLANCO
	 */
	private String domicilioSeg = ENBLANCO;

	/**
	 * Inicializamos el codPostalSeg, con valor ENBLANCO
	 */
	private String codPostalSeg = ENBLANCO;

	/**
	 * Inicializamos el localidadSeg, con valor ENBLANCO
	 */
	private String localidadSeg = ENBLANCO;

	/**
	 * Inicializamos el provinciaSeg, con valor ENBLANCO
	 */
	private String provinciaSeg = ENBLANCO;

	/**
	 * Inicializamos el paisSeg, con valor ENBLANCO
	 */
	private String paisSeg = ENBLANCO;

	/**
	 * Inicializamos el nifRepLegalSeg, con valor ENBLANCO
	 */
	private String nifRepLegalSeg = ENBLANCO;

	/**
	 * Inicializamos el fecNacSeg, con valor ENBLANCO
	 */
	private String fecNacSeg = ENBLANCO;

	/**
	 * Inicializamos el fecEmision, con valor ENBLANCO
	 */
	private String fecEmision = ENBLANCO;

	/**
	 * Inicializamos el reaseguro, con valor ENBLANCO
	 */
	private String reaseguro = ENBLANCO;
		
	/**
	 * Inicializamos el tipOperacion, con valor ENBLANCO
	 */
	private String tipOperacion = ENBLANCO;

	/**
	 * Inicializamos el tipOperacionJSP, con valor ENBLANCO
	 */
	private String tipOperacionJSP = ENBLANCO;

	/**
	 * Inicializamos el pestanaJSP, con valor ENBLANCO
	 */
	private String pestanaJSP = ENBLANCO;

	/**
	 * Inicializamos el retorno, con valor ENBLANCO
	 */
	private String retorno = ENBLANCO;

	/**
	 * Inicializamos el desRetorno, con valor ENBLANCO
	 */
	private String desRetorno = ENBLANCO;

	/**
	 * Inicializamos el canalCamp, con valor ENBLANCO
	 */
	private String canalCamp = ENBLANCO;

	/**
	 * Inicializamos el entidad, con valor ENBLANCO
	 */
	private String entidad = ENBLANCO;

	/**
	 * Inicializamos el fecImpreCap, con valor ENBLANCO
	 */
	private String fecImpreCap = ENBLANCO;

	/**
	 * Inicializamos el fecImpreComp, con valor ENBLANCO
	 */
	private String fecImpreComp = ENBLANCO;

	/**
	 * Inicializamos el tipImpuestoPri, con valor ENBLANCO
	 */
	private String tipImpuestoPri = IMPUESTO;

	/**
	 * Inicializamos el tipImpuestoComp, con valor ENBLANCO
	 */
	private String tipImpuestoComp = IMPUESTO;

	/**
	 * Inicializamos el duracion, con valor ENBLANCO
	 */
	private String duracion = ENBLANCO;

	/**
	 * Inicializamos el impReciboComp, con valor ENBLANCO
	 */
	private String impReciboComp = ENBLANCO;

	/**
	 * Inicializamos el vectorMensajes, con valor ENBLANCO
	 */
	private List <Object> vectorMensajes = Collections.synchronizedList ( new Vector <Object> () );

	/**
	 * Inicializamos el nomPrograma, con valor ENBLANCO
	 */
	private String nomPrograma = ENBLANCO;
	
	/**
	 * Inicializamos el desSituacion, con valor ENBLANCO
	 */
	private String desSituacion = ENBLANCO;
	
	/*INICIO  MU-2015-041869 */
	/**
	 * Inicializamos el aniofiscal, con valor ENBLANCO
	 */
	private String aniofiscal = ENBLANCO;
	/*FIN  MU-2015-041869 */
	
	
	/**
	 * @return el nomPrograma
	 */
	public String getNomPrograma () {
		return nomPrograma;
	}

	/**
	 * @param nomPrograma
	 *            el nomPrograma a establecer
	 */
	public void setNomPrograma ( String nomPrograma ) {
		this.nomPrograma = nomPrograma;
	}

	/**
	 * @return el anulAlimenHijosPri
	 */
	public String getAnulAlimenHijosPri () {
		return anulAlimenHijosPri;
	}

	/**
	 * @param anulAlimenHijosPri
	 */
	public void setAnulAlimenHijosPri ( String anulAlimenHijosPri ) {
		this.anulAlimenHijosPri = anulAlimenHijosPri;
	}

	/**
	 * @return el apellido1Pri
	 */
	public String getApellido1Pri () {
		return apellido1Pri;
	}

	/**
	 * @param apellido1Pri
	 */
	public void setApellido1Pri ( String apellido1Pri ) {
		this.apellido1Pri = apellido1Pri;
	}

	/**
	 * @return el apellido1Seg
	 */
	public String getApellido1Seg () {
		return apellido1Seg;
	}

	/**
	 * @param apellido1Seg
	 */
	public void setApellido1Seg ( String apellido1Seg ) {
		this.apellido1Seg = apellido1Seg;
	}

	/**
	 * @return el apellido2Pri
	 */
	public String getApellido2Pri () {
		return apellido2Pri;
	}

	/**
	 * @param apellido2Pri
	 */
	public void setApellido2Pri ( String apellido2Pri ) {
		this.apellido2Pri = apellido2Pri;
	}

	/**
	 * @return el apellido2Seg
	 */
	public String getApellido2Seg () {
		return apellido2Seg;
	}

	/**
	 * @param apellido2Seg
	 */
	public void setApellido2Seg ( String apellido2Seg ) {
		this.apellido2Seg = apellido2Seg;
	}

	/**
	 * @return el codCoasegur1
	 */
	public String getCodCoasegur1 () {
		return codCoasegur1;
	}

	/**
	 * @param codCoasegur1
	 */
	public void setCodCoasegur1 ( String codCoasegur1 ) {
		this.codCoasegur1 = codCoasegur1;
	}

	/**
	 * @return el codCoasegur2
	 */
	public String getCodCoasegur2 () {
		return codCoasegur2;
	}

	/**
	 * @param codCoasegur2
	 */
	public void setCodCoasegur2 ( String codCoasegur2 ) {
		this.codCoasegur2 = codCoasegur2;
	}

	/**
	 * @return el codCoasegur3
	 */
	public String getCodCoasegur3 () {
		return codCoasegur3;
	}

	/**
	 * @param codCoasegur3
	 */
	public void setCodCoasegur3 ( String codCoasegur3 ) {
		this.codCoasegur3 = codCoasegur3;
	}

	/**
	 * @return el codCoasegur4
	 */
	public String getCodCoasegur4 () {
		return codCoasegur4;
	}

	/**
	 * @param codCoasegur4
	 */
	public void setCodCoasegur4 ( String codCoasegur4 ) {
		this.codCoasegur4 = codCoasegur4;
	}

	/**
	 * @return el codCoasegur5
	 */
	public String getCodCoasegur5 () {
		return codCoasegur5;
	}

	/**
	 * @param codCoasegur5
	 */
	public void setCodCoasegur5 ( String codCoasegur5 ) {
		this.codCoasegur5 = codCoasegur5;
	}

	/**
	 * @return el codCoasegur6
	 */
	public String getCodCoasegur6 () {
		return codCoasegur6;
	}

	/**
	 * @param codCoasegur6
	 */
	public void setCodCoasegur6 ( String codCoasegur6 ) {
		this.codCoasegur6 = codCoasegur6;
	}

	/**
	 * @return el codPostalPri
	 */
	public String getCodPostalPri () {
		return codPostalPri;
	}

	/**
	 * @param codPostalPri
	 */
	public void setCodPostalPri ( String codPostalPri ) {
		this.codPostalPri = codPostalPri;
	}

	/**
	 * @return el codPostalSeg
	 */
	public String getCodPostalSeg () {
		return codPostalSeg;
	}

	/**
	 * @param codPostalSeg
	 */
	public void setCodPostalSeg ( String codPostalSeg ) {
		this.codPostalSeg = codPostalSeg;
	}

	/**
	 * @return el discapacitadoPri
	 */
	public String getDiscapacitadoPri () {
		return discapacitadoPri;
	}

	/**
	 * @param discapacitadoPri
	 */
	public void setDiscapacitadoPri ( String discapacitadoPri ) {
		this.discapacitadoPri = discapacitadoPri;
	}

	/**
	 * @return el domicilioPri
	 */
	public String getDomicilioPri () {
		return domicilioPri;
	}

	/**
	 * @param domicilioPri
	 */
	public void setDomicilioPri ( String domicilioPri ) {
		this.domicilioPri = domicilioPri;
	}

	/**
	 * @return el domicilioSeg
	 */
	public String getDomicilioSeg () {
		return domicilioSeg;
	}

	/**
	 * @param domicilioSeg
	 */
	public void setDomicilioSeg ( String domicilioSeg ) {
		this.domicilioSeg = domicilioSeg;
	}

	/**
	 * @return el expediente
	 */
	public String getExpediente () {
		return expediente;
	}

	/**
	 * @param expediente
	 */
	public void setExpediente ( String expediente ) {
		this.expediente = expediente;
	}

	/**
	 * @return el fecAnul
	 */
	public String getFecAnul () {
		return fecAnul;
	}

	/**
	 * @param fecAnul
	 */
	public void setFecAnul ( String fecAnul ) {
		this.fecAnul = fecAnul;
	}

	/**
	 * @return el fecEfect
	 */
	public String getFecEfect () {
		return fecEfect;
	}

	/**
	 * @param fecEfect
	 */
	public void setFecEfect ( String fecEfect ) {
		this.fecEfect = fecEfect;
	}

	/**
	 * @return el fecEmisionComp
	 */
	public String getFecEmisionComp () {
		return fecEmisionComp;
	}

	/**
	 * @param fecEmisionComp
	 */
	public void setFecEmisionComp ( String fecEmisionComp ) {
		this.fecEmisionComp = fecEmisionComp;
	}

	/**
	 * @return el fecEmisionPri
	 */
	public String getFecEmisionPri () {
		return fecEmisionPri;
	}

	/**
	 * @param fecEmisionPri
	 */
	public void setFecEmisionPri ( String fecEmisionPri ) {
		this.fecEmisionPri = fecEmisionPri;
	}

	/**
	 * @return el fecModi
	 */
	public String getFecModi () {
		return fecModi;
	}

	/**
	 * @param fecModi
	 */
	public void setFecModi ( String fecModi ) {
		this.fecModi = fecModi;
	}

	/**
	 * @return el fecNacPri
	 */
	public String getFecNacPri () {
		return fecNacPri;
	}

	/**
	 * @param fecNacPri
	 */
	public void setFecNacPri ( String fecNacPri ) {
		this.fecNacPri = fecNacPri;
	}

	/**
	 * @return el fecNacSeg
	 */
	public String getFecNacSeg () {
		return fecNacSeg;
	}

	/**
	 * @param fecNacSeg
	 */
	public void setFecNacSeg ( String fecNacSeg ) {
		this.fecNacSeg = fecNacSeg;
	}

	/**
	 * @return el fecPagoComp
	 */
	public String getFecPagoComp () {
		return fecPagoComp;
	}

	/**
	 * @param fecPagoComp
	 */
	public void setFecPagoComp ( String fecPagoComp ) {
		this.fecPagoComp = fecPagoComp;
	}

	/**
	 * @return el fecPagoIRPFComp
	 */
	public String getFecPagoIRPFComp () {
		return fecPagoIRPFComp;
	}

	/**
	 * @param fecPagoIRPFComp
	 */
	public void setFecPagoIRPFComp ( String fecPagoIRPFComp ) {
		this.fecPagoIRPFComp = fecPagoIRPFComp;
	}

	/**
	 * @return fecPagoIRPFPri
	 */
	public String getFecPagoIRPFPri () {
		return fecPagoIRPFPri;
	}

	/**
	 * @param fecPagoIRPFPri
	 */
	public void setFecPagoIRPFPri ( String fecPagoIRPFPri ) {
		this.fecPagoIRPFPri = fecPagoIRPFPri;
	}

	/**
	 * @return fecPagoPri
	 */
	public String getFecPagoPri () {
		return fecPagoPri;
	}

	/**
	 * @param fecPagoPri
	 */
	public void setFecPagoPri ( String fecPagoPri ) {
		this.fecPagoPri = fecPagoPri;
	}

	/**
	 * @return fecReciPri
	 */
	public String getFecReciPri () {
		return fecReciPri;
	}

	/**
	 * @param fecReciPri
	 */
	public void setFecReciPri ( String fecReciPri ) {
		this.fecReciPri = fecReciPri;
	}

	/**
	 * @return localidadPri
	 */
	public String getLocalidadPri () {
		return localidadPri;
	}

	/**
	 * @param localidadPri
	 */
	public void setLocalidadPri ( String localidadPri ) {
		this.localidadPri = localidadPri;
	}

	/**
	 * @return localidadSeg
	 */
	public String getLocalidadSeg () {
		return localidadSeg;
	}

	/**
	 * @param localidadSeg
	 */
	public void setLocalidadSeg ( String localidadSeg ) {
		this.localidadSeg = localidadSeg;
	}

	/**
	 * @return nifCifPri
	 */
	public String getNifCifPri () {
		return nifCifPri;
	}

	/**
	 * @param nifCifPri
	 */
	public void setNifCifPri ( String nifCifPri ) {
		this.nifCifPri = nifCifPri;
	}

	/**
	 * @return nifCifSeg
	 */
	public String getNifCifSeg () {
		return nifCifSeg;
	}

	/**
	 * @param nifCifSeg
	 */
	public void setNifCifSeg ( String nifCifSeg ) {
		this.nifCifSeg = nifCifSeg;
	}

	/**
	 * @return nifConyugePri
	 */
	public String getNifConyugePri () {
		return nifConyugePri;
	}

	/**
	 * @param nifConyugePri
	 */
	public void setNifConyugePri ( String nifConyugePri ) {
		this.nifConyugePri = nifConyugePri;
	}

	/**
	 * @return nifRepLegalPri
	 */
	public String getNifRepLegalPri () {
		return nifRepLegalPri;
	}

	/**
	 * @param nifRepLegalPri
	 */
	public void setNifRepLegalPri ( String nifRepLegalPri ) {
		this.nifRepLegalPri = nifRepLegalPri;
	}

	/**
	 * @return nifRepLegalSeg
	 */
	public String getNifRepLegalSeg () {
		return nifRepLegalSeg;
	}

	/**
	 * @param nifRepLegalSeg
	 */
	public void setNifRepLegalSeg ( String nifRepLegalSeg ) {
		this.nifRepLegalSeg = nifRepLegalSeg;
	}

	/**
	 * @return nombrePri
	 */
	public String getNombrePri () {
		return nombrePri;
	}

	/**
	 * @param nombrePri
	 */
	public void setNombrePri ( String nombrePri ) {
		this.nombrePri = nombrePri;
	}

	/**
	 * @return nombreSeg
	 */
	public String getNombreSeg () {
		return nombreSeg;
	}

	/**
	 * @param nombreSeg
	 */
	public void setNombreSeg ( String nombreSeg ) {
		this.nombreSeg = nombreSeg;
	}

	/**
	 * @return observaciones
	 */
	public String getObservaciones () {
		return observaciones;
	}

	/**
	 * @param observaciones
	 */
	public void setObservaciones ( String observaciones ) {
		this.observaciones = observaciones;
	}

	/**
	 * @return oficina
	 */
	public String getOficina () {
		return oficina;
	}

	/**
	 * @param oficina
	 */
	public void setOficina ( String oficina ) {
		this.oficina = oficina;
	}

	/**
	 * @return paisPri
	 */
	public String getPaisPri () {
		return paisPri;
	}

	/**
	 * @param paisPri
	 */
	public void setPaisPri ( String paisPri ) {
		this.paisPri = paisPri;
	}

	/**
	 * @return paisSeg
	 */
	public String getPaisSeg () {
		return paisSeg;
	}

	/**
	 * @param paisSeg
	 */
	public void setPaisSeg ( String paisSeg ) {
		this.paisSeg = paisSeg;
	}

	/**
	 * @return penCompPri
	 */
	public String getPenCompPri () {
		return penCompPri;
	}

	/**
	 * @param penCompPri
	 */
	public void setPenCompPri ( String penCompPri ) {
		this.penCompPri = penCompPri;
	}

	/**
	 * @return polizaBloq1
	 */
	public String getPolizaBloq1 () {
		return polizaBloq1;
	}

	/**
	 * @param polizaBloq1
	 */
	public void setPolizaBloq1 ( String polizaBloq1 ) {
		this.polizaBloq1 = polizaBloq1;
	}

	/**
	 * @return polizaBloq2
	 */
	public String getPolizaBloq2 () {
		return polizaBloq2;
	}

	/**
	 * @param polizaBloq2
	 */
	public void setPolizaBloq2 ( String polizaBloq2 ) {
		this.polizaBloq2 = polizaBloq2;
	}

	/**
	 * @return polizaBloq3
	 */
	public String getPolizaBloq3 () {
		return polizaBloq3;
	}

	/**
	 * @param polizaBloq3
	 */
	public void setPolizaBloq3 ( String polizaBloq3 ) {
		this.polizaBloq3 = polizaBloq3;
	}

	/**
	 * @return prestViviendoPri
	 */
	public String getPrestViviendoPri () {
		return prestViviendoPri;
	}

	/**
	 * @param prestViviendoPri
	 */
	public void setPrestViviendoPri ( String prestViviendoPri ) {
		this.prestViviendoPri = prestViviendoPri;
	}

	/**
	 * @return provinciaPri
	 */
	public String getProvinciaPri () {
		return provinciaPri;
	}

	/**
	 * @param provinciaPri
	 */
	public void setProvinciaPri ( String provinciaPri ) {
		this.provinciaPri = provinciaPri;
	}

	/**
	 * @return provinciaSeg
	 */
	public String getProvinciaSeg () {
		return provinciaSeg;
	}

	/**
	 * @param provinciaSeg
	 */
	public void setProvinciaSeg ( String provinciaSeg ) {
		this.provinciaSeg = provinciaSeg;
	}

	/**
	 * @return razonSocialSeg
	 */
	public String getRazonSocialSeg () {
		return razonSocialSeg;
	}

	/**
	 * @param razonSocialSeg
	 */
	public void setRazonSocialSeg ( String razonSocialSeg ) {
		this.razonSocialSeg = razonSocialSeg;
	}

	/**
	 * @param regionalEnv
	 */
	public void setRegionalEnv ( String regionalEnv ) {
		this.regionalEnv = regionalEnv;
	}

	/**
	 * @return regionalPol
	 */
	public String getRegionalPol () {
		return regionalPol;
	}

	/**
	 * @param regionalPol
	 */
	public void setRegionalPol ( String regionalPol ) {
		this.regionalPol = regionalPol;
	}

	/**
	 * @return sitFamiliarPri
	 */
	public String getSitFamiliarPri () {
		return sitFamiliarPri;
	}

	/**
	 * @param sitFamiliarPri
	 */
	public void setSitFamiliarPri ( String sitFamiliarPri ) {
		this.sitFamiliarPri = sitFamiliarPri;
	}

	/**
	 * @return tipPersonaSeg
	 */
	public String getTipPersonaSeg () {
		return tipPersonaSeg;
	}

	/**
	 * @param tipPersonaSeg
	 */
	public void setTipPersonaSeg ( String tipPersonaSeg ) {
		this.tipPersonaSeg = tipPersonaSeg;
	}

	/**
	 * @return tipRescate
	 */
	public String getTipRescate () {
		return tipRescate;
	}

	/**
	 * @param tipRescate
	 */
	public void setTipRescate ( String tipRescate ) {
		this.tipRescate = tipRescate;
	}

	/**
	 * @return tipSituacion
	 */
	public String getTipSituacion () {
		return tipSituacion;
	}

	/**
	 * @param tipSituacion
	 */
	public void setTipSituacion ( String tipSituacion ) {
		this.tipSituacion = tipSituacion;
	}

	/**
	 * @return tomador
	 */
	public String getTomador () {
		return tomador;
	}

	/**
	 * @param tomador
	 */
	public void setTomador ( String tomador ) {
		this.tomador = tomador;
	}

	/**
	 * @return totPagMapfre
	 */
	public String getTotPagMapfre () {
		return totPagMapfre;
	}

	/**
	 * @param totPagMapfre
	 */
	public void setTotPagMapfre ( String totPagMapfre ) {
		this.totPagMapfre = totPagMapfre;
	}

	/**
	 * @return el anio
	 */
	public String getAnio () {
		return anio;
	}

	/**
	 * @param anio
	 *            el anio a establecer
	 */
	public void setAnio ( String anio ) {
		this.anio = anio;
	}

	/**
	 * @return el anticipoPri
	 */
	public String getAnticipoPri () {
		return anticipoPri;
	}

	/**
	 * @param anticipoPri
	 *            el anticipoPri a establecer
	 */
	public void setAnticipoPri ( String anticipoPri ) {
		this.anticipoPri = anticipoPri;
	}

	/**
	 * @return el beneficiosPri
	 */
	public String getBeneficiosPri () {
		return beneficiosPri;
	}

	/**
	 * @param beneficiosPri
	 *            el beneficiosPri a establecer
	 */
	public void setBeneficiosPri ( String beneficiosPri ) {
		this.beneficiosPri = beneficiosPri;
	}

	/**
	 * @return el certificado
	 */
	public String getCertificado () {
		return certificado;
	}

	/**
	 * @param certificado
	 *            el certificado a establecer
	 */
	public void setCertificado ( String certificado ) {
		this.certificado = certificado;
	}

	/**
	 * @return el cobroInterPri
	 */
	public String getCobroInterPri () {
		return cobroInterPri;
	}

	/**
	 * @param cobroInterPri
	 *            el cobroInterPri a establecer
	 */
	public void setCobroInterPri ( String cobroInterPri ) {
		this.cobroInterPri = cobroInterPri;
	}


	
	/**
	 * @return el compensaPri
	 */
	public String getCompensaPri () {
		return compensaPri;
	}

	/**
	 * @param compensaPri
	 *            el compensaPri a establecer
	 */
	public void setCompensaPri ( String compensaPri ) {
		this.compensaPri = compensaPri;
	}

	/**
	 * @return el devolInterPri
	 */
	public String getDevolInterPri () {
		return devolInterPri;
	}

	/**
	 * @param devolInterPri
	 *            el devolInterPri a establecer
	 */
	public void setDevolInterPri ( String devolInterPri ) {
		this.devolInterPri = devolInterPri;
	}

	/**
	 * @return el importeComp
	 */
	public String getImporteComp () {
		return importeComp;
	}

	/**
	 * @param importeComp
	 *            el importeComp a establecer
	 */
	public void setImporteComp ( String importeComp ) {
		this.importeComp = importeComp;
	}

	/**
	 * @return el importePri
	 */
	public String getImportePri () {
		return importePri;
	}

	/**
	 * @param importePri
	 *            el importePri a establecer
	 */
	public void setImportePri ( String importePri ) {
		this.importePri = importePri;
	}

	/**
	 * @return el liquidoComp
	 */
	public String getLiquidoComp () {
		return liquidoComp;
	}

	/**
	 * @param liquidoComp
	 *            el liquidoComp a establecer
	 */
	public void setLiquidoComp ( String liquidoComp ) {
		this.liquidoComp = liquidoComp;
	}

	/**
	 * @return el liquidoPri
	 */
	public String getLiquidoPri () {
		return liquidoPri;
	}

	/**
	 * @param liquidoPri
	 *            el liquidoPri a establecer
	 */
	public void setLiquidoPri ( String liquidoPri ) {
		this.liquidoPri = liquidoPri;
	}

	/**
	 * @return el modalidad
	 */
	public String getModalidad () {
		return modalidad;
	}

	/**
	 * @param modalidad
	 *            el modalidad a establecer
	 */
	public void setModalidad ( String modalidad ) {
		this.modalidad = modalidad;
	}

	/**
	 * @return el pendiente
	 */
	public String getPendiente () {
		return pendiente;
	}

	/**
	 * @param pendiente
	 *            el pendiente a establecer
	 */
	public void setPendiente ( String pendiente ) {
		this.pendiente = pendiente;
	}

	/**
	 * @return el porcentajeComp
	 */
	public String getPorcentajeComp () {
		return porcentajeComp;
	}

	/**
	 * @param porcentajeComp
	 *            el porcentajeComp a establecer
	 */
	public void setPorcentajeComp ( String porcentajeComp ) {
		this.porcentajeComp = porcentajeComp;
	}

	/**
	 * @return el porcentajePri
	 */
	public String getPorcentajePri () {
		return porcentajePri;
	}

	/**
	 * @param porcentajePri
	 *            el porcentajePri a establecer
	 */
	public void setPorcentajePri ( String porcentajePri ) {
		this.porcentajePri = porcentajePri;
	}

	/**
	 * @return el porCoasegur1
	 */
	public String getPorCoasegur1 () {
		return porCoasegur1;
	}

	/**
	 * @param porCoasegur1
	 *            el porCoasegur1 a establecer
	 */
	public void setPorCoasegur1 ( String porCoasegur1 ) {
		this.porCoasegur1 = porCoasegur1;
	}

	/**
	 * @return el porCoasegur2
	 */
	public String getPorCoasegur2 () {
		return porCoasegur2;
	}

	/**
	 * @param porCoasegur2
	 *            el porCoasegur2 a establecer
	 */
	public void setPorCoasegur2 ( String porCoasegur2 ) {
		this.porCoasegur2 = porCoasegur2;
	}

	/**
	 * @return el porCoasegur3
	 */
	public String getPorCoasegur3 () {
		return porCoasegur3;
	}

	/**
	 * @param porCoasegur3
	 *            el porCoasegur3 a establecer
	 */
	public void setPorCoasegur3 ( String porCoasegur3 ) {
		this.porCoasegur3 = porCoasegur3;
	}

	/**
	 * @return el porCoasegur4
	 */
	public String getPorCoasegur4 () {
		return porCoasegur4;
	}

	/**
	 * @param porCoasegur4
	 *            el porCoasegur4 a establecer
	 */
	public void setPorCoasegur4 ( String porCoasegur4 ) {
		this.porCoasegur4 = porCoasegur4;
	}

	/**
	 * @return el porCoasegur5
	 */
	public String getPorCoasegur5 () {
		return porCoasegur5;
	}

	/**
	 * @param porCoasegur5
	 *            el porCoasegur5 a establecer
	 */
	public void setPorCoasegur5 ( String porCoasegur5 ) {
		this.porCoasegur5 = porCoasegur5;
	}

	/**
	 * @return el porCoasegur6
	 */
	public String getPorCoasegur6 () {
		return porCoasegur6;
	}

	/**
	 * @param porCoasegur6
	 *            el porCoasegur6 a establecer
	 */
	public void setPorCoasegur6 ( String porCoasegur6 ) {
		this.porCoasegur6 = porCoasegur6;
	}

	/**
	 * @return el reciboPri
	 */
	public String getReciboPri () {
		return reciboPri;
	}

	/**
	 * @param reciboPri
	 *            el reciboPri a establecer
	 */
	public void setReciboPri ( String reciboPri ) {
		this.reciboPri = reciboPri;
	}

	/**
	 * @return el redPrimasComp
	 */
	public String getRedPrimasComp () {
		return redPrimasComp;
	}

	/**
	 * @param redPrimasComp
	 *            el redPrimasComp a establecer
	 */
	public void setRedPrimasComp ( String redPrimasComp ) {
		this.redPrimasComp = redPrimasComp;
	}

	/**
	 * @return el redPrimasPri
	 */
	public String getRedPrimasPri () {
		return redPrimasPri;
	}

	/**
	 * @param redPrimasPri
	 *            el redPrimasPri a establecer
	 */
	public void setRedPrimasPri ( String redPrimasPri ) {
		this.redPrimasPri = redPrimasPri;
	}

	/**
	 * @return el redTransitComp
	 */
	public String getRedTransitComp () {
		return redTransitComp;
	}

	/**
	 * @param redTransitComp
	 *            el redTransitComp a establecer
	 */
	public void setRedTransitComp ( String redTransitComp ) {
		this.redTransitComp = redTransitComp;
	}

	/**
	 * @return el redTransitPri
	 */
	public String getRedTransitPri () {
		return redTransitPri;
	}

	/**
	 * @param redTransitPri
	 *            el redTransitPri a establecer
	 */
	public void setRedTransitPri ( String redTransitPri ) {
		this.redTransitPri = redTransitPri;
	}

	/**
	 * @return el retencionComp
	 */
	public String getRetencionComp () {
		return retencionComp;
	}

	/**
	 * @param retencionComp
	 *            el retencionComp a establecer
	 */
	public void setRetencionComp ( String retencionComp ) {
		this.retencionComp = retencionComp;
	}

	/**
	 * @return el retencionPri
	 */
	public String getRetencionPri () {
		return retencionPri;
	}

	/**
	 * @param retencionPri
	 *            el retencionPri a establecer
	 */
	public void setRetencionPri ( String retencionPri ) {
		this.retencionPri = retencionPri;
	}

	/**
	 * @return el rtoIntegroComp
	 */
	public String getRtoIntegroComp () {
		return rtoIntegroComp;
	}

	/**
	 * @param rtoIntegroComp
	 *            el rtoIntegroComp a establecer
	 */
	public void setRtoIntegroComp ( String rtoIntegroComp ) {
		this.rtoIntegroComp = rtoIntegroComp;
	}

	/**
	 * @return el rtoIntegroPri
	 */
	public String getRtoIntegroPri () {
		return rtoIntegroPri;
	}

	/**
	 * @param rtoIntegroPri
	 *            el rtoIntegroPri a establecer
	 */
	public void setRtoIntegroPri ( String rtoIntegroPri ) {
		this.rtoIntegroPri = rtoIntegroPri;
	}

	/**
	 * @return el rtoNetoComp
	 */
	public String getRtoNetoComp () {
		return rtoNetoComp;
	}

	/**
	 * @param rtoNetoComp
	 *            el rtoNetoComp a establecer
	 */
	public void setRtoNetoComp ( String rtoNetoComp ) {
		this.rtoNetoComp = rtoNetoComp;
	}

	/**
	 * @return el rtoNetoPri
	 */
	public String getRtoNetoPri () {
		return rtoNetoPri;
	}

	/**
	 * @param rtoNetoPri
	 *            el rtoNetoPri a establecer
	 */
	public void setRtoNetoPri ( String rtoNetoPri ) {
		this.rtoNetoPri = rtoNetoPri;
	}

	/**
	 * @return el subpoliza
	 */
	public String getSubpoliza () {
		return subpoliza;
	}

	/**
	 * @param subpoliza
	 *            el subpoliza a establecer
	 */
	public void setSubpoliza ( String subpoliza ) {
		this.subpoliza = subpoliza;
	}

	/**
	 * @return el tipOperacion
	 */
	public String getTipOperacion () {
		return tipOperacion;
	}

	/**
	 * @param tipOperacion
	 *            el tipOperacion a establecer
	 */
	public void setTipOperacion ( String tipOperacion ) {
		this.tipOperacion = tipOperacion;
	}

	/**
	 * @return el regionalEnv
	 */
	public String getRegionalEnv () {
		return regionalEnv;
	}

	/**
	 * @return el kpersonaPri
	 */
	public String getKpersonaPri () {
		return kpersonaPri;
	}

	/**
	 * @param kpersonaPri
	 *            el kpersonaPri a establecer
	 */
	public void setKpersonaPri ( String kpersonaPri ) {
		this.kpersonaPri = kpersonaPri;
	}

	/**
	 * @return el tipPersonaPriValue
	 */
	public String getTipPersonaPriValue () {
		return tipPersonaPriValue;
	}

	/**
	 * @param tipPersonaPriValue
	 *            el tipPersonaPriValue a establecer
	 */
	public void setTipPersonaPriValue ( String tipPersonaPriValue ) {
		this.tipPersonaPriValue = tipPersonaPriValue;
	}

	/**
	 * @return el desRetorno
	 */
	public String getDesRetorno () {
		return desRetorno;
	}

	/**
	 * @param desRetorno
	 *            el desRetorno a establecer
	 */
	public void setDesRetorno ( String desRetorno ) {
		this.desRetorno = desRetorno;
	}

	/**
	 * @return el retorno
	 */
	public String getRetorno () {
		return retorno;
	}

	/**
	 * @param retorno
	 *            el retorno a establecer
	 */
	public void setRetorno ( String retorno ) {
		this.retorno = retorno;
	}

	/**
	 * @return el vectorMensajes
	 */
	public List getVectorMensajes () {
		return vectorMensajes;
	}

	/**
	 * @param vectorMensajes
	 *            el vectorMensajes a establecer
	 */
	public void setVectorMensajes ( List vectorMensajes ) {
		this.vectorMensajes = vectorMensajes;
	}

	/**
	 * @return el tipOperacionJSP
	 */
	public String getTipOperacionJSP () {
		return tipOperacionJSP;
	}

	/**
	 * @param tipOperacionJSP
	 *            el tipOperacionJSP a establecer
	 */
	public void setTipOperacionJSP ( String tipOperacionJSP ) {
		this.tipOperacionJSP = tipOperacionJSP;
	}

	/**
	 * @return el canalCamp
	 */
	public String getCanalCamp () {
		return canalCamp;
	}

	/**
	 * @param canalCamp
	 *            el canalCamp a establecer
	 */
	public void setCanalCamp ( String canalCamp ) {
		this.canalCamp = canalCamp;
	}

	/**
	 * @return el entidad
	 */
	public String getEntidad () {
		return entidad;
	}

	/**
	 * @param entidad
	 *            el entidad a establecer
	 */
	public void setEntidad ( String entidad ) {
		this.entidad = entidad;
	}

	/**
	 * @return el fecImpreCap
	 */
	public String getFecImpreCap () {
		return fecImpreCap;
	}

	/**
	 * @param fecImpreCap
	 *            el fecImpreCap a establecer
	 */
	public void setFecImpreCap ( String fecImpreCap ) {
		this.fecImpreCap = fecImpreCap;
	}

	/**
	 * @return el fecImpreComp
	 */
	public String getFecImpreComp () {
		return fecImpreComp;
	}

	/**
	 * @param fecImpreComp
	 *            el fecImpreComp a establecer
	 */
	public void setFecImpreComp ( String fecImpreComp ) {
		this.fecImpreComp = fecImpreComp;
	}

	/**
	 * @return el tipoImpuestoComp
	 */
	public String getTipoImpuestoComp () {
		return tipoImpuestoComp;
	}

	/**
	 * @param tipoImpuestoComp
	 *            el tipoImpuestoComp a establecer
	 */
	public void setTipoImpuestoComp ( String tipoImpuestoComp ) {
		this.tipoImpuestoComp = tipoImpuestoComp;
	}

	/**
	 * @return el tipoImpuestoPri
	 */
	public String getTipoImpuestoPri () {
		return tipoImpuestoPri;
	}

	/**
	 * @param tipoImpuestoPri
	 *            el tipoImpuestoPri a establecer
	 */
	public void setTipoImpuestoPri ( String tipoImpuestoPri ) {
		this.tipoImpuestoPri = tipoImpuestoPri;
	}

	/**
	 * @return el pestanaJSP
	 */
	public String getPestanaJSP () {
		return pestanaJSP;
	}

	/**
	 * @param pestanaJSP
	 *            el pestanaJSP a establecer
	 */
	public void setPestanaJSP ( String pestanaJSP ) {
		this.pestanaJSP = pestanaJSP;
	}

	/**
	 * @return el residentePri
	 */
	public String getResidentePri () {
		return residentePri;
	}

	/**
	 * @param residentePri
	 *            el residentePri a establecer
	 */
	public void setResidentePri ( String residentePri ) {
		this.residentePri = residentePri;
	}

	/**
	 * @return el residenteSeg
	 */
	public String getResidenteSeg () {
		return residenteSeg;
	}

	/**
	 * @param residenteSeg
	 *            el residenteSeg a establecer
	 */
	public void setResidenteSeg ( String residenteSeg ) {
		this.residenteSeg = residenteSeg;
	}

	/**
	 * @return el tipImpuestoComp
	 */
	public String getTipImpuestoComp () {
		return tipImpuestoComp;
	}

	/**
	 * @param tipImpuestoComp
	 *            el tipImpuestoComp a establecer
	 */
	public void setTipImpuestoComp ( String tipImpuestoComp ) {
		this.tipImpuestoComp = tipImpuestoComp;
	}

	/**
	 * @return el tipImpuestoPri
	 */
	public String getTipImpuestoPri () {
		return tipImpuestoPri;
	}

	/**
	 * @param tipImpuestoPri
	 *            el tipImpuestoPri a establecer
	 */
	public void setTipImpuestoPri ( String tipImpuestoPri ) {
		this.tipImpuestoPri = tipImpuestoPri;
	}

	/**
	 * @return el duracion
	 */
	public String getDuracion () {
		return duracion;
	}

	/**
	 * @param duracion
	 *            el duracion a establecer
	 */
	public void setDuracion ( String duracion ) {
		this.duracion = duracion;
	}

	/**
	 * @return el impReciboComp
	 */
	public String getImpReciboComp () {
		return impReciboComp;
	}

	/**
	 * @param impReciboComp
	 *            el impReciboComp a establecer
	 */
	public void setImpReciboComp ( String impReciboComp ) {
		this.impReciboComp = impReciboComp;
	}

	


	/**
	 * @return el fecBDGICap
	 */
	public String getFecBDGICap () {
		return fecBDGICap;
	}

	/**
	 * @param fecBDGICap el fecBDGICap a establecer
	 */
	public void setFecBDGICap ( String fecBDGICap ) {
		this.fecBDGICap = fecBDGICap;
	}

	/**
	 * @return el fecBDGIComp1
	 */
	public String getFecBDGIComp1 () {
		return fecBDGIComp1;
	}

	/**
	 * @param fecBDGIComp1 el fecBDGIComp1 a establecer
	 */
	public void setFecBDGIComp1 ( String fecBDGIComp1 ) {
		this.fecBDGIComp1 = fecBDGIComp1;
	}

	/**
	 * @return el fecBDGIComp2
	 */
	public String getFecBDGIComp2 () {
		return fecBDGIComp2;
	}

	/**
	 * @param fecBDGIComp2 el fecBDGIComp2 a establecer
	 */
	public void setFecBDGIComp2 ( String fecBDGIComp2 ) {
		this.fecBDGIComp2 = fecBDGIComp2;
	}

	/**
	 * @return el fecEmision
	 */
	public String getFecEmision () {
		return fecEmision;
	}

	/**
	 * @param fecEmision
	 *            el fecEmision a establecer
	 */
	public void setFecEmision ( String fecEmision ) {
		this.fecEmision = fecEmision;
	}

	/**
	 * @return el reaseguro
	 */
	public String getReaseguro () {
		return reaseguro;
	}

	/**
	 * @param reaseguro
	 *            el reaseguro a establecer
	 */
	public void setReaseguro ( String reaseguro ) {
		this.reaseguro = reaseguro;
	}

	/**
	 * @return el impCapital
	 */
	public String getImpCapital () {
		return impCapital;
	}

	/**
	 * @param impCapital
	 *            el impCapital a establecer
	 */
	public void setImpCapital ( String impCapital ) {
		this.impCapital = impCapital;
	}

	/**
	 * @return el fecPagoCapital
	 */
	public String getFecPagoCapital () {
		return fecPagoCapital;
	}

	/**
	 * @param fecPagoCapital
	 *            el fecPagoCapital a establecer
	 */
	public void setFecPagoCapital ( String fecPagoCapital ) {
		this.fecPagoCapital = fecPagoCapital;
	}

	/**
	 * @return el impAnticipo
	 */
	public String getImpAnticipo () {
		return impAnticipo;
	}

	/**
	 * @param impAnticipo
	 *            el impAnticipo a establecer
	 */
	public void setImpAnticipo ( String impAnticipo ) {
		this.impAnticipo = impAnticipo;
	}

	/**
	 * @return el impInteresPend
	 */
	public String getImpInteresPend () {
		return impInteresPend;
	}

	/**
	 * @param impInteresPend
	 *            el impInteresPend a establecer
	 */
	public void setImpInteresPend ( String impInteresPend ) {
		this.impInteresPend = impInteresPend;
	}

	/**
	 * @return el tipImpuestoCap
	 */
	public String getTipImpuestoCap () {
		return tipImpuestoCap;
	}

	/**
	 * @param tipImpuestoCap
	 *            el tipImpuestoCap a establecer
	 */
	public void setTipImpuestoCap ( String tipImpuestoCap ) {
		this.tipImpuestoCap = tipImpuestoCap;
	}

	/**
	 * @return el rtoIntegroCap
	 */
	public String getRtoIntegroCap () {
		return rtoIntegroCap;
	}

	/**
	 * @param rtoIntegroCap
	 *            el rtoIntegroCap a establecer
	 */
	public void setRtoIntegroCap ( String rtoIntegroCap ) {
		this.rtoIntegroCap = rtoIntegroCap;
	}

	/**
	 * @return el redPrimasCap
	 */
	public String getRedPrimasCap () {
		return redPrimasCap;
	}

	/**
	 * @param redPrimasCap
	 *            el redPrimasCap a establecer
	 */
	public void setRedPrimasCap ( String redPrimasCap ) {
		this.redPrimasCap = redPrimasCap;
	}

	/**
	 * @return el redTransitCap
	 */
	public String getRedTransitCap () {
		return redTransitCap;
	}

	/**
	 * @param redTransitCap
	 *            el redTransitCap a establecer
	 */
	public void setRedTransitCap ( String redTransitCap ) {
		this.redTransitCap = redTransitCap;
	}

	/**
	 * @return el compensaCap
	 */
	public String getCompensaCap () {
		return compensaCap;
	}

	/**
	 * @param compensaCap
	 *            el compensaCap a establecer
	 */
	public void setCompensaCap ( String compensaCap ) {
		this.compensaCap = compensaCap;
	}

	/**
	 * @return el fecPagoIRPFCap
	 */
	public String getFecPagoIRPFCap () {
		return fecPagoIRPFCap;
	}

	/**
	 * @param fecPagoIRPFCap
	 *            el fecPagoIRPFCap a establecer
	 */
	public void setFecPagoIRPFCap ( String fecPagoIRPFCap ) {
		this.fecPagoIRPFCap = fecPagoIRPFCap;
	}

	/**
	 * @return el porcentajeCap
	 */
	public String getPorcentajeCap () {
		return porcentajeCap;
	}

	/**
	 * @param porcentajeCap
	 *            el porcentajeCap a establecer
	 */
	public void setPorcentajeCap ( String porcentajeCap ) {
		this.porcentajeCap = porcentajeCap;
	}

	/**
	 * @return el retencionCap
	 */
	public String getRetencionCap () {
		return retencionCap;
	}

	/**
	 * @param retencionCap
	 *            el retencionCap a establecer
	 */
	public void setRetencionCap ( String retencionCap ) {
		this.retencionCap = retencionCap;
	}

	/**
	 * @return el rtoNetoCap
	 */
	public String getRtoNetoCap () {
		return rtoNetoCap;
	}

	/**
	 * @param rtoNetoCap
	 *            el rtoNetoCap a establecer
	 */
	public void setRtoNetoCap ( String rtoNetoCap ) {
		this.rtoNetoCap = rtoNetoCap;
	}

	/**
	 * @return el liquidoCap
	 */
	public String getLiquidoCap () {
		return liquidoCap;
	}

	/**
	 * @param liquidoCap
	 *            el liquidoCap a establecer
	 */
	public void setLiquidoCap ( String liquidoCap ) {
		this.liquidoCap = liquidoCap;
	}

	/**
	 * @return el fecImprePri
	 */
	public String getFecImprePri () {
		return fecImprePri;
	}

	/**
	 * @param fecImprePri
	 *            el fecImprePri a establecer
	 */
	public void setFecImprePri ( String fecImprePri ) {
		this.fecImprePri = fecImprePri;
	}

	/**
	 * @return el fecVencimiento
	 */
	public String getFecVencimiento () {
		return fecVencimiento;
	}

	/**
	 * @param fecVencimiento
	 *            el fecVencimiento a establecer
	 */
	public void setFecVencimiento ( String fecVencimiento ) {
		this.fecVencimiento = fecVencimiento;
	}

	/**
	 * @return el razonSocialPri
	 */
	public String getRazonSocialPri () {
		return razonSocialPri;
	}

	/**
	 * @param razonSocialPri
	 *            el razonSocialPri a establecer
	 */
	public void setRazonSocialPri ( String razonSocialPri ) {
		this.razonSocialPri = razonSocialPri;
	}

	/**
	 * @return el polizaSel
	 */
	public String getPolizaSel () {
		return polizaSel;
	}

	/**
	 * @param polizaSel el polizaSel a establecer
	 */
	public void setPolizaSel ( String polizaSel ) {
		this.polizaSel = polizaSel;
	}

	/**
	 * @return el selectedRow
	 */
	public String getSelectedRow () {
		return selectedRow;
	}

	/**
	 * @param selectedRow el selectedRow a establecer
	 */
	public void setSelectedRow ( String selectedRow ) {
		this.selectedRow = selectedRow;
	}

	/**
	 * @return el subpolizaSel
	 */
	public String getSubpolizaSel () {
		return subpolizaSel;
	}

	/**
	 * @param subpolizaSel el subpolizaSel a establecer
	 */
	public void setSubpolizaSel ( String subpolizaSel ) {
		this.subpolizaSel = subpolizaSel;
	}

	/**
	 * @return el certificadoSel
	 */
	public String getCertificadoSel () {
		return certificadoSel;
	}

	/**
	 * @param certificadoSel el certificadoSel a establecer
	 */
	public void setCertificadoSel ( String certificadoSel ) {
		this.certificadoSel = certificadoSel;
	}

	/**
	 * @return el sBDGICap
	 */
	public String getSBDGICap () {
		return sBDGICap;
	}

	/**
	 * @param cap el sBDGICap a establecer
	 */
	public void setSBDGICap ( String cap ) {
		sBDGICap = cap;
	}

	/**
	 * @return el sBDGIComp
	 */
	public String getSBDGIComp () {
		return sBDGIComp;
	}

	/**
	 * @param comp el sBDGIComp a establecer
	 */
	public void setSBDGIComp ( String comp ) {
		sBDGIComp = comp;
	}

	/**
	 * @return el sBDGIComp2
	 */
	public String getSBDGIComp2 () {
		return sBDGIComp2;
	}

	/**
	 * @param comp2 el sBDGIComp2 a establecer
	 */
	public void setSBDGIComp2 ( String comp2 ) {
		sBDGIComp2 = comp2;
	}

	/**
	 * @return el tipPersonaPri
	 */
	public String getTipPersonaPri () {
		return tipPersonaPri;
	}

	/**
	 * @param tipPersonaPri el tipPersonaPri a establecer
	 */
	public void setTipPersonaPri ( String tipPersonaPri ) {
		this.tipPersonaPri = tipPersonaPri;
	}

	public String getDesSituacion() {
		return desSituacion;
	}

	public void setDesSituacion(String desSituacion) {
		this.desSituacion = desSituacion;
	}

	/*INICIO  MU-2015-041869 */
	/**
	 * @return el aniofiscal
	 */
	public String getAniofiscal() {
		return aniofiscal;
	}

	/**
	 * @param aniofiscal el aniofiscal a establecer
	 */
	public void setAniofiscal(String aniofiscal) {
		this.aniofiscal = aniofiscal;
	}
	/*FIN  MU-2015-041869 */
	
	//MU-2016-006664 - RAROALE - INI
	/**
	 * @return el impCoasegur1
	 */
	public String getImpCoasegur1() {
		return impCoasegur1;
	}

	/**
	 * @param impCoasegur1 el impCoasegur1 a establecer
	 */
	public void setImpCoasegur1(String impCoasegur1) {
		this.impCoasegur1 = impCoasegur1;
	}

	/**
	 * @return el impCoasegur2
	 */
	public String getImpCoasegur2() {
		return impCoasegur2;
	}

	/**
	 * @param impCoasegur2 el impCoasegur2 a establecer
	 */
	public void setImpCoasegur2(String impCoasegur2) {
		this.impCoasegur2 = impCoasegur2;
	}

	/**
	 * @return el impCoasegur3
	 */
	public String getImpCoasegur3() {
		return impCoasegur3;
	}

	/**
	 * @param impCoasegur3 el impCoasegur3 a establecer
	 */
	public void setImpCoasegur3(String impCoasegur3) {
		this.impCoasegur3 = impCoasegur3;
	}

	/**
	 * @return el impCoasegur4
	 */
	public String getImpCoasegur4() {
		return impCoasegur4;
	}

	/**
	 * @param impCoasegur4 el impCoasegur4 a establecer
	 */
	public void setImpCoasegur4(String impCoasegur4) {
		this.impCoasegur4 = impCoasegur4;
	}

	/**
	 * @return el impCoasegur5
	 */
	public String getImpCoasegur5() {
		return impCoasegur5;
	}

	/**
	 * @param impCoasegur5 el impCoasegur5 a establecer
	 */
	public void setImpCoasegur5(String impCoasegur5) {
		this.impCoasegur5 = impCoasegur5;
	}

	/**
	 * @return el impCoasegur6
	 */
	public String getImpCoasegur6() {
		return impCoasegur6;
	}

	/**
	 * @param impCoasegur6 el impCoasegur6 a establecer
	 */
	public void setImpCoasegur6(String impCoasegur6) {
		this.impCoasegur6 = impCoasegur6;
	}
	//MU-2016-006664 - RAROALE - FIN
	
	// MU-2016-006673 - RAROALE - INI
	/**
	 * @return el kdomicilioPri
	 */
	public String getKdomicilioPri() {
		return kdomicilioPri;
	}

	/**
	 * @param kdomicilioPri el kdomicilioPri a establecer
	 */
	public void setKdomicilioPri(String kdomicilioPri) {
		this.kdomicilioPri = kdomicilioPri;
	}
	
	/**
	 * @return el fmodificacion
	 */
	public String getFmodificacion() {
		return fmodificacion;
	}

	/**
	 * @param fmodificacion el fmodificacion a establecer
	 */
	public void setFmodificacion(String fmodificacion) {
		this.fmodificacion = fmodificacion;
	}
	// MU-2016-006673 - RAROALE - FIN

	//R&V - CU009 - INI

	/**
	 *
	 * @return eximido
	 */
	public String getEximido () {
		return eximido;
	}

	/**
	 *
	 * @param eximido
	 */
	public void setEximido (String eximido) {
		this.eximido = eximido;
	}

	//R&V - CU009 - FIN
}
