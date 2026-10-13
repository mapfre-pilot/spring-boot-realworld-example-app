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

package com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;
import java.util.Vector;
import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;

/**
 * Form bean for a Struts application.
 * 
 * @version 1.0 Versi�n inicial
 * @author everis
 */

public class J372J008GestionExpedientesVenPageBean

{
	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inicializamos el anio, con 0
	 */
	private BigDecimal anio = new BigDecimal ( 0 );

	/**
	 * Inicializamos el expediente, con valor 0
	 */
	private BigDecimal expediente = new BigDecimal ( 0 );

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
	private BigDecimal subpoliza = new BigDecimal ( 0 );

	/**
	 * Inicializamos el modalidad, con valor ENBLANCO
	 */
	private BigDecimal modalidad = new BigDecimal ( 0 );

	/**
	 * Inicializamos el canalCamp, con valor ENBLANCO
	 */
	private String canalCamp = ENBLANCO;

	/**
	 * Inicializamos el entidad, con valor ENBLANCO
	 */
	private String entidad = ENBLANCO;

	/**
	 * Inicializamos el certificado, con valor ENBLANCO
	 */
	private BigDecimal certificado = new BigDecimal ( 0 );

	/**
	 * Inicializamos el tipRescate, con valor ENBLANCO
	 */
	private String tipRescate = ENBLANCO;

	/**
	 * Inicializamos el tipSituacion, con valor ENBLANCO
	 */
	private String tipSituacion = ENBLANCO;
	
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
	private BigDecimal pendiente = new BigDecimal ( 0 );

	/**
	 * Inicializamos el observaciones, con valor ENBLANCO
	 */
	private String observaciones = ENBLANCO;

	/**
	 * Inicializamos el impCapital, con valor ENBLANCO
	 */
	private BigDecimal impCapital = new BigDecimal ( 0 );

	/**
	 * Inicializamos el beneficiosPri, con valor ENBLANCO
	 */
	private BigDecimal beneficiosPri = new BigDecimal ( 0 );

	/**
	 * Inicializamos el fecPagoCapital, con valor ENBLANCO
	 */
	private String fecPagoCapital = ENBLANCO;

	/**
	 * Inicializamos el fecPagoPri, con valor ENBLANCO
	 */
	private String fecPagoPri = ENBLANCO;

	/**
	 * Inicializamos el tipImpuestoPri, con valor ENBLANCO
	 */
	private String tipImpuestoPri = ENBLANCO;

	/**
	 * Inicializamos el impAnticipo, con valor ENBLANCO
	 */
	private BigDecimal impAnticipo = new BigDecimal ( 0 );

	/**
	 * Inicializamos el anticipoPri, con valor ENBLANCO
	 */
	private BigDecimal anticipoPri = new BigDecimal ( 0 );

	/**
	 * Inicializamos el cobroInterPri, con valor ENBLANCO
	 */
	private BigDecimal cobroInterPri = new BigDecimal ( 0 );

	/**
	 * Inicializamos el impInteresPend, con valor ENBLANCO
	 */
	private BigDecimal impInteresPend = new BigDecimal ( 0 );

	/**
	 * Inicializamos el reciboPri, con valor ENBLANCO
	 */
	private BigDecimal reciboPri = new BigDecimal ( 0 );

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
	 * Inicializamos el rtoIntegroPri, con valor ENBLANCO
	 */
	private BigDecimal rtoIntegroPri = new BigDecimal ( 0 );

	/**
	 * Inicializamos el redPrimasPri, con valor ENBLANCO
	 */
	private BigDecimal redPrimasPri = new BigDecimal ( 0 );

	/**
	 * Inicializamos el redTransitCap, con valor ENBLANCO
	 */
	private BigDecimal redTransitCap = new BigDecimal ( 0 );

	/**
	 * Inicializamos el rtoIntegroCap, con valor ENBLANCO
	 */
	private BigDecimal rtoIntegroCap = new BigDecimal ( 0 );

	/**
	 * Inicializamos el redPrimasCap, con valor ENBLANCO
	 */
	private BigDecimal redPrimasCap = new BigDecimal ( 0 );

	/**
	 * Inicializamos el redTransitPri, con valor ENBLANCO
	 */
	private BigDecimal redTransitPri = new BigDecimal ( 0 );

	/**
	 * Inicializamos el rtoNetoPri, con valor ENBLANCO
	 */
	private BigDecimal rtoNetoPri = new BigDecimal ( 0 );

	/**
	 * Inicializamos el rtoNetoCap, con valor ENBLANCO
	 */
	private BigDecimal rtoNetoCap = new BigDecimal ( 0 );

	/**
	 * Inicializamos el porcentajePri, con valor ENBLANCO
	 */
	private BigDecimal porcentajePri = new BigDecimal ( 0 );

	/**
	 * Inicializamos el porcentajeCap, con valor ENBLANCO
	 */
	private BigDecimal porcentajeCap = new BigDecimal ( 0 );

	/**
	 * Inicializamos el retencionPri, con valor ENBLANCO
	 */
	private BigDecimal retencionPri = new BigDecimal ( 0 );

	/**
	 * Inicializamos el retencionCap, con valor ENBLANCO
	 */
	private BigDecimal retencionCap = new BigDecimal ( 0 );

	/**
	 * Inicializamos el tipImpuestoCap, con valor ENBLANCO
	 */
	private String tipImpuestoCap = ENBLANCO;

	/**
	 * Inicializamos el fecPagoIRPFCap, con valor ENBLANCO
	 */
	private String fecPagoIRPFCap = ENBLANCO;

	/**
	 * Inicializamos el fecPagoIRPFPri, con valor ENBLANCO
	 */
	private String fecPagoIRPFPri = ENBLANCO;

	/**
	 * Inicializamos el importePri, con valor ENBLANCO
	 */
	private BigDecimal importePri = new BigDecimal ( 0 );

	/**
	 * Inicializamos el compensaPri, con valor ENBLANCO
	 */
	private BigDecimal compensaPri = new BigDecimal ( 0 );

	/**
	 * Inicializamos el compensaCap, con valor ENBLANCO
	 */
	private BigDecimal compensaCap = new BigDecimal ( 0 );

	/**
	 * Inicializamos el liquidoPri, con valor ENBLANCO
	 */
	private BigDecimal liquidoPri = new BigDecimal ( 0 );

	/**
	 * Inicializamos el liquidoCap, con valor ENBLANCO
	 */
	private BigDecimal liquidoCap = new BigDecimal ( 0 );

	/**
	 * Inicializamos el razonSocialPri, con valor ENBLANCO
	 */
	private String razonSocialPri = ENBLANCO;

	/**
	 * Inicializamos el fecImpreCap, con valor ENBLANCO
	 */
	private String fecImpreCap = ENBLANCO;

	/**
	 * Inicializamos el fecEmision, con valor ENBLANCO
	 */
	private String fecEmision = ENBLANCO;

	/**
	 * Inicializamos el fecBDGICap, con valor ENBLANCO
	 */
	private String fecBDGICap = ENBLANCO;
	/**
	 * Inicializamos el fecBDGIComp1, con valor ENBLANCO
	 */
	private String fecBDGIComp1 = ENBLANCO;

	/**
	 * Inicializamos el fecBDGIComp1, con valor ENBLANCO
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
	 * Inicializamos el importeComp, con valor ENBLANCO
	 */
	private BigDecimal importeComp = new BigDecimal ( 0 );

	/**
	 * Inicializamos el fecPagoComp, con valor ENBLANCO
	 */
	private String fecPagoComp = ENBLANCO;

	/**
	 * Inicializamos el fecEmisionComp, con valor ENBLANCO
	 */
	private String fecEmisionComp = ENBLANCO;

	/**
	 * Inicializamos el rtoIntegroComp, con valor ENBLANCO
	 */
	private BigDecimal rtoIntegroComp = new BigDecimal ( 0 );

	/**
	 * Inicializamos el redPrimasComp, con valor ENBLANCO
	 */
	private BigDecimal redPrimasComp = new BigDecimal ( 0 );

	/**
	 * Inicializamos el redTransitComp, con valor ENBLANCO
	 */
	private BigDecimal redTransitComp = new BigDecimal ( 0 );

	/**
	 * Inicializamos el rtoNetoComp, con valor ENBLANCO
	 */
	private BigDecimal rtoNetoComp = new BigDecimal ( 0 );

	/**
	 * Inicializamos el porcentajeComp, con valor ENBLANCO
	 */
	private BigDecimal porcentajeComp = new BigDecimal ( 0 );

	/**
	 * Inicializamos el retencionComp, con valor ENBLANCO
	 */
	private BigDecimal retencionComp = new BigDecimal ( 0 );

	/**
	 * Inicializamos el tipImpuestoComp, con valor ENBLANCO
	 */
	private String tipImpuestoComp = ENBLANCO;

	/**
	 * Inicializamos el fecPagoIRPFComp, con valor ENBLANCO
	 */
	private String fecPagoIRPFComp = ENBLANCO;

	/**
	 * Inicializamos el liquidoComp, con valor ENBLANCO
	 */
	private BigDecimal liquidoComp = new BigDecimal ( 0 );

	/**
	 * Inicializamos el impReciboComp, con valor ENBLANCO
	 */
	private BigDecimal impReciboComp = new BigDecimal ( 0 );

	/**
	 * Inicializamos el kPersonaPri, con valor ENBLANCO
	 */
	private BigDecimal kPersonaPri = new BigDecimal ( 0 );
	
	// MU-2016-006673 - RAROALE - INI
	/**
	 * Inicializamos el kDomicilioPri, con valor ENBLANCO
	 */
	private BigDecimal kDomicilioPri = new BigDecimal(0);
	
	/**
	 * Inicializamos el fmodificacion, con valor ENBLANCO
	 */
	private String fmodificacion = ENBLANCO;
	// MU-2016-006673 - RAROALE - FIN

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
	 * Inicializamos el residentePri, con valor ENBLANCO
	 */
	private String residentePri = ENBLANCO;

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
	 * Inicializamos el penComPri, con valor ENBLANCO
	 */
	private String penComPri = ENBLANCO;

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
	private BigDecimal porCoasegur1 = new BigDecimal ( 0 );

	/**
	 * Inicializamos el codCoasegur2, con valor ENBLANCO
	 */
	private String codCoasegur2 = ENBLANCO;

	/**
	 * Inicializamos el porCoasegur2, con valor ENBLANCO
	 */
	private BigDecimal porCoasegur2 = new BigDecimal ( 0 );

	/**
	 * Inicializamos el codCoasegur3, con valor ENBLANCO
	 */
	private String codCoasegur3 = ENBLANCO;

	/**
	 * Inicializamos el porCoasegur3, con valor ENBLANCO
	 */
	private BigDecimal porCoasegur3 = new BigDecimal ( 0 );

	/**
	 * Inicializamos el codCoasegur4, con valor ENBLANCO
	 */
	private String codCoasegur4 = ENBLANCO;

	/**
	 * Inicializamos el porCoasegur4, con valor ENBLANCO
	 */
	private BigDecimal porCoasegur4 = new BigDecimal ( 0 );

	/**
	 * Inicializamos el codCoasegur5, con valor ENBLANCO
	 */
	private String codCoasegur5 = ENBLANCO;

	/**
	 * Inicializamos el porCoasegur5, con valor ENBLANCO
	 */
	private BigDecimal porCoasegur5 = new BigDecimal ( 0 );

	/**
	 * Inicializamos el codCoasegur6, con valor ENBLANCO
	 */
	private String codCoasegur6 = ENBLANCO;

	/**
	 * Inicializamos el porCoasegur6, con valor ENBLANCO
	 */
	private BigDecimal porCoasegur6 = new BigDecimal ( 0 );

	/**
	 * Inicializamos el totPagMapfre, con valor ENBLANCO
	 */
	private String totPagMapfre = ENBLANCO;
	
	//MU-2016-006664 - RAROALE - FIN
	/**
	 * Inicializamos el impCoasegur1, con valor 0
	 */
	private BigDecimal impCoasegur1 = new BigDecimal(0);
	
	/**
	 * Inicializamos el impCoasegur2, con valor 0
	 */
	private BigDecimal impCoasegur2 = new BigDecimal(0);
	
	/**
	 * Inicializamos el impCoasegur3, con valor 0
	 */
	private BigDecimal impCoasegur3 = new BigDecimal(0);
	
	/**
	 * Inicializamos el impCoasegur4, con valor 0
	 */
	private BigDecimal impCoasegur4 = new BigDecimal(0);
	
	/**
	 * Inicializamos el impCoasegur5, con valor 0
	 */
	private BigDecimal impCoasegur5 = new BigDecimal(0);
	
	/**
	 * Inicializamos el impCoasegur6, con valor 0
	 */
	private BigDecimal impCoasegur6 = new BigDecimal(0);
	//MU-2016-006664 - RAROALE - FIN

	// R&V CA Fase II CU011-COASEGURO - INI
	private String valoresManuales = "N";
	public String getValoresManuales() { return valoresManuales; }
	public void setValoresManuales(String valoresManuales) { this.valoresManuales = valoresManuales; }
	// R&V CA Fase II CU011-COASEGURO - FIN

	// R&V Junio 2017 - REACONDICIONAMIENTO VT01 VT04 - everis(RGL) - INI
	private BigDecimal rtoIntegroCoa1 = new BigDecimal(0);
	private BigDecimal rtoIntegroCoa2 = new BigDecimal(0);
	private BigDecimal rtoIntegroCoa3 = new BigDecimal(0);
	private BigDecimal rtoIntegroCoa4 = new BigDecimal(0);
	private BigDecimal rtoIntegroCoa5 = new BigDecimal(0);
	private BigDecimal rtoIntegroCoa6 = new BigDecimal(0);
	private BigDecimal redPrimasCoa1 = new BigDecimal(0);
	private BigDecimal redPrimasCoa2 = new BigDecimal(0);
	private BigDecimal redPrimasCoa3 = new BigDecimal(0);
	private BigDecimal redPrimasCoa4 = new BigDecimal(0);
	private BigDecimal redPrimasCoa5 = new BigDecimal(0);
	private BigDecimal redPrimasCoa6= new BigDecimal(0);
	private BigDecimal redTransitoriaCoa1 = new BigDecimal(0);
	private BigDecimal redTransitoriaCoa2 = new BigDecimal(0);
	private BigDecimal redTransitoriaCoa3 = new BigDecimal(0);
	private BigDecimal redTransitoriaCoa4 = new BigDecimal(0);
	private BigDecimal redTransitoriaCoa5 = new BigDecimal(0);
	private BigDecimal redTransitoriaCoa6 = new BigDecimal(0);
	private BigDecimal rtoNetoCoa1 = new BigDecimal(0);
	private BigDecimal rtoNetoCoa2 = new BigDecimal(0);
	private BigDecimal rtoNetoCoa3 = new BigDecimal(0);
	private BigDecimal rtoNetoCoa4 = new BigDecimal(0);
	private BigDecimal rtoNetoCoa5 = new BigDecimal(0);
	private BigDecimal rtoNetoCoa6 = new BigDecimal(0);
	private BigDecimal retencionCoa1 = new BigDecimal(0);
	private BigDecimal retencionCoa2 = new BigDecimal(0);
	private BigDecimal retencionCoa3 = new BigDecimal(0);
	private BigDecimal retencionCoa4 = new BigDecimal(0);
	private BigDecimal retencionCoa5 = new BigDecimal(0);
	private BigDecimal retencionCoa6 = new BigDecimal(0);
	private BigDecimal compenCoa1 = new BigDecimal(0);
	private BigDecimal compenCoa2 = new BigDecimal(0);
	private BigDecimal compenCoa3 = new BigDecimal(0);
	private BigDecimal compenCoa4 = new BigDecimal(0);
	private BigDecimal compenCoa5 = new BigDecimal(0);
	private BigDecimal compenCoa6 = new BigDecimal(0);

	// R&V Junio 2017 - CU011 - everis(RGL) - INI

	//R&V - CU009 - INI
	//private String eximido = "" ;
	/**
	 * Inicializamos el eximido, con valor ENBLANCO
	 */
	private String eximido = "N";
	//R&V - CU009 - FIN

	private BigDecimal kdomcom = new BigDecimal(0);

	/**
	 * Inicializamos el vencimientoMigrado, con valor ENBLANCO
	 */
	private String vencimientoMigrado = ENBLANCO;
	
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
	 * Inicializamos el refReinversionPri, con valor ENBLANCO
	 */
	private String refReinversionPri = ENBLANCO;
		
	/**
	 * Inicializamos el numChequePri, con valor ENBLANCO
	 */
	private BigDecimal numChequePri = new BigDecimal (0);
	
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
	 * Inicializamos el numChequeComp1, con valor ENBLANCO
	 */
	private BigDecimal numChequeComp1 = new BigDecimal (0);
	
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
	 * Inicializamos el numChequeComp2, con valor ENBLANCO
	 */
	private BigDecimal numChequeComp2 = new BigDecimal (0);
	
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
	 * @param vencimientoMigrado el vencimientoMigrado a establecer
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
	 * @param usuarioPagoPri el usuarioPagoPri a establecer
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
	 * @param fecCapturaPri el fecCapturaPri a establecer
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
	 * @param usuarioCapturaPri el usuarioCapturaPri a establecer
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
	 * @param formaPagoPri el formaPagoPri a establecer
	 */
	public void setFormaPagoPri(String formaPagoPri) {
	    this.formaPagoPri = formaPagoPri;
	}
	
	/**
	 * @return el refReinversionPri
	 */
	public String getRefReinversionPri() {
	    return refReinversionPri;
	}
	
	/**
	 * @param refReinversionPri el refReinversionPri a establecer
	 */
	public void setRefReinversionPri(String refReinversionPri) {
	    this.refReinversionPri = refReinversionPri;
	}
	
	/**
	 * @return el numChequePri
	 */
	public BigDecimal getNumChequePri() {
	    return numChequePri;
	}
	
	/**
	 * @param numChequePri el numChequePri a establecer
	 */
	public void setNumChequePri(BigDecimal numChequePri) {
	    this.numChequePri = numChequePri;
	}
	
	/**
	 * @return el numCuentaPri
	 */
	public String getNumCuentaPri() {
	    return numCuentaPri;
	}
	
	/**
	 * @param numCuentaPri el numCuentaPri a establecer
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
	 * @param usuarioPagoComp1 el usuarioPagoComp1 a establecer
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
	 * @param fecCapturaComp1 el fecCapturaComp1 a establecer
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
	 * @param usuarioCapturaComp1 el usuarioCapturaComp1 a establecer
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
	 * @param formaPagoComp1 el formaPagoComp1 a establecer
	 */
	public void setFormaPagoComp1(String formaPagoComp1) {
	    this.formaPagoComp1 = formaPagoComp1;
	}
	
	/**
	 * @return el numChequeComp1
	 */
	public BigDecimal getNumChequeComp1() {
	    return numChequeComp1;
	}
	
	/**
	 * @param numChequeComp1 el numChequeComp1 a establecer
	 */
	public void setNumChequeComp1(BigDecimal numChequeComp1) {
	    this.numChequeComp1 = numChequeComp1;
	}
	
	/**
	 * @return el numCuentaComp1
	 */
	public String getNumCuentaComp1() {
	    return numCuentaComp1;
	}
	
	/**
	 * @param numCuentaComp1 el numCuentaComp1 a establecer
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
	 * @param usuarioPagoComp2 el usuarioPagoComp2 a establecer
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
	 * @param fecCapturaComp2 el fecCapturaComp2 a establecer
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
	 * @param usuarioCapturaComp2 el usuarioCapturaComp2 a establecer
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
	 * @param formaPagoComp2 el formaPagoComp2 a establecer
	 */
	public void setFormaPagoComp2(String formaPagoComp2) {
	    this.formaPagoComp2 = formaPagoComp2;
	}
	
	/**
	 * @return el numChequeComp2
	 */
	public BigDecimal getNumChequeComp2() {
	    return numChequeComp2;
	}
	
	/**
	 * @param numChequeComp2 el numChequeComp2 a establecer
	 */
	public void setNumChequeComp2(BigDecimal numChequeComp2) {
	    this.numChequeComp2 = numChequeComp2;
	}
	
	/**
	 * @return el numChequeComp2
	 */
	public String getNumCuentaComp2() {
	    return numCuentaComp2;
	}
	
	/**
	 * @param numCuentaComp2 el numCuentaComp2 a establecer
	 */
	public void setNumCuentaComp2(String numCuentaComp2) {
	    this.numCuentaComp2 = numCuentaComp2;
	}
	
	public String getEximido() {
		return eximido;
	}

	public void setEximido(String eximido) {
		this.eximido = eximido;
	}

	public BigDecimal getKdomcom() {
		return kdomcom;
	}

	public void setKdomcom(BigDecimal kdomcom) {
		this.kdomcom = kdomcom;
	}
	// R&V Junio 2017 - CU011 - everis(RGL) - FIN

	public BigDecimal getRtoIntegroCoa1() {
		return rtoIntegroCoa1;
	}

	public void setRtoIntegroCoa1(BigDecimal rtoIntegroCoa1) {
		this.rtoIntegroCoa1 = rtoIntegroCoa1;
	}

	public BigDecimal getRtoIntegroCoa2() {
		return rtoIntegroCoa2;
	}

	public void setRtoIntegroCoa2(BigDecimal rtoIntegroCoa2) {
		this.rtoIntegroCoa2 = rtoIntegroCoa2;
	}

	public BigDecimal getRtoIntegroCoa3() {
		return rtoIntegroCoa3;
	}

	public void setRtoIntegroCoa3(BigDecimal rtoIntegroCoa3) {
		this.rtoIntegroCoa3 = rtoIntegroCoa3;
	}

	public BigDecimal getRtoIntegroCoa4() {
		return rtoIntegroCoa4;
	}

	public void setRtoIntegroCoa4(BigDecimal rtoIntegroCoa4) {
		this.rtoIntegroCoa4 = rtoIntegroCoa4;
	}

	public BigDecimal getRtoIntegroCoa5() {
		return rtoIntegroCoa5;
	}

	public void setRtoIntegroCoa5(BigDecimal rtoIntegroCoa5) {
		this.rtoIntegroCoa5 = rtoIntegroCoa5;
	}

	public BigDecimal getRtoIntegroCoa6() {
		return rtoIntegroCoa6;
	}

	public void setRtoIntegroCoa6(BigDecimal rtoIntegroCoa6) {
		this.rtoIntegroCoa6 = rtoIntegroCoa6;
	}

	public BigDecimal getRedPrimasCoa1() {
		return redPrimasCoa1;
	}

	public void setRedPrimasCoa1(BigDecimal redPrimasCoa1) {
		this.redPrimasCoa1 = redPrimasCoa1;
	}

	public BigDecimal getRedPrimasCoa2() {
		return redPrimasCoa2;
	}

	public void setRedPrimasCoa2(BigDecimal redPrimasCoa2) {
		this.redPrimasCoa2 = redPrimasCoa2;
	}

	public BigDecimal getRedPrimasCoa3() {
		return redPrimasCoa3;
	}

	public void setRedPrimasCoa3(BigDecimal redPrimasCoa3) {
		this.redPrimasCoa3 = redPrimasCoa3;
	}

	public BigDecimal getRedPrimasCoa4() {
		return redPrimasCoa4;
	}

	public void setRedPrimasCoa4(BigDecimal redPrimasCoa4) {
		this.redPrimasCoa4 = redPrimasCoa4;
	}

	public BigDecimal getRedPrimasCoa5() {
		return redPrimasCoa5;
	}

	public void setRedPrimasCoa5(BigDecimal redPrimasCoa5) {
		this.redPrimasCoa5 = redPrimasCoa5;
	}

	public BigDecimal getRedPrimasCoa6() {
		return redPrimasCoa6;
	}

	public void setRedPrimasCoa6(BigDecimal redPrimasCoa6) {
		this.redPrimasCoa6 = redPrimasCoa6;
	}

	public BigDecimal getRedTransitoriaCoa1() {
		return redTransitoriaCoa1;
	}

	public void setRedTransitoriaCoa1(BigDecimal redTransitoriaCoa1) {
		this.redTransitoriaCoa1 = redTransitoriaCoa1;
	}

	public BigDecimal getRedTransitoriaCoa2() {
		return redTransitoriaCoa2;
	}

	public void setRedTransitoriaCoa2(BigDecimal redTransitoriaCoa2) {
		this.redTransitoriaCoa2 = redTransitoriaCoa2;
	}

	public BigDecimal getRedTransitoriaCoa3() {
		return redTransitoriaCoa3;
	}

	public void setRedTransitoriaCoa3(BigDecimal redTransitoriaCoa3) {
		this.redTransitoriaCoa3 = redTransitoriaCoa3;
	}

	public BigDecimal getRedTransitoriaCoa4() {
		return redTransitoriaCoa4;
	}

	public void setRedTransitoriaCoa4(BigDecimal redTransitoriaCoa4) {
		this.redTransitoriaCoa4 = redTransitoriaCoa4;
	}

	public BigDecimal getRedTransitoriaCoa5() {
		return redTransitoriaCoa5;
	}

	public void setRedTransitoriaCoa5(BigDecimal redTransitoriaCoa5) {
		this.redTransitoriaCoa5 = redTransitoriaCoa5;
	}

	public BigDecimal getRedTransitoriaCoa6() {
		return redTransitoriaCoa6;
	}

	public void setRedTransitoriaCoa6(BigDecimal redTransitoriaCoa6) {
		this.redTransitoriaCoa6 = redTransitoriaCoa6;
	}

	public BigDecimal getRtoNetoCoa1() {
		return rtoNetoCoa1;
	}

	public void setRtoNetoCoa1(BigDecimal rtoNetoCoa1) {
		this.rtoNetoCoa1 = rtoNetoCoa1;
	}

	public BigDecimal getRtoNetoCoa2() {
		return rtoNetoCoa2;
	}

	public void setRtoNetoCoa2(BigDecimal rtoNetoCoa2) {
		this.rtoNetoCoa2 = rtoNetoCoa2;
	}

	public BigDecimal getRtoNetoCoa3() {
		return rtoNetoCoa3;
	}

	public void setRtoNetoCoa3(BigDecimal rtoNetoCoa3) {
		this.rtoNetoCoa3 = rtoNetoCoa3;
	}

	public BigDecimal getRtoNetoCoa4() {
		return rtoNetoCoa4;
	}

	public void setRtoNetoCoa4(BigDecimal rtoNetoCoa4) {
		this.rtoNetoCoa4 = rtoNetoCoa4;
	}

	public BigDecimal getRtoNetoCoa5() {
		return rtoNetoCoa5;
	}

	public void setRtoNetoCoa5(BigDecimal rtoNetoCoa5) {
		this.rtoNetoCoa5 = rtoNetoCoa5;
	}

	public BigDecimal getRtoNetoCoa6() {
		return rtoNetoCoa6;
	}

	public void setRtoNetoCoa6(BigDecimal rtoNetoCoa6) {
		this.rtoNetoCoa6 = rtoNetoCoa6;
	}

	public BigDecimal getRetencionCoa1() {
		return retencionCoa1;
	}

	public void setRetencionCoa1(BigDecimal retencionCoa1) {
		this.retencionCoa1 = retencionCoa1;
	}

	public BigDecimal getRetencionCoa2() {
		return retencionCoa2;
	}

	public void setRetencionCoa2(BigDecimal retencionCoa2) {
		this.retencionCoa2 = retencionCoa2;
	}

	public BigDecimal getRetencionCoa3() {
		return retencionCoa3;
	}

	public void setRetencionCoa3(BigDecimal retencionCoa3) {
		this.retencionCoa3 = retencionCoa3;
	}

	public BigDecimal getRetencionCoa4() {
		return retencionCoa4;
	}

	public void setRetencionCoa4(BigDecimal retencionCoa4) {
		this.retencionCoa4 = retencionCoa4;
	}

	public BigDecimal getRetencionCoa5() {
		return retencionCoa5;
	}

	public void setRetencionCoa5(BigDecimal retencionCoa5) {
		this.retencionCoa5 = retencionCoa5;
	}

	public BigDecimal getRetencionCoa6() {
		return retencionCoa6;
	}

	public void setRetencionCoa6(BigDecimal retencionCoa6) {
		this.retencionCoa6 = retencionCoa6;
	}

	public BigDecimal getCompenCoa1() {
		return compenCoa1;
	}

	public void setCompenCoa1(BigDecimal compenCoa1) {
		this.compenCoa1 = compenCoa1;
	}

	public BigDecimal getCompenCoa2() {
		return compenCoa2;
	}

	public void setCompenCoa2(BigDecimal compenCoa2) {
		this.compenCoa2 = compenCoa2;
	}

	public BigDecimal getCompenCoa3() {
		return compenCoa3;
	}

	public void setCompenCoa3(BigDecimal compenCoa3) {
		this.compenCoa3 = compenCoa3;
	}

	public BigDecimal getCompenCoa4() {
		return compenCoa4;
	}

	public void setCompenCoa4(BigDecimal compenCoa4) {
		this.compenCoa4 = compenCoa4;
	}

	public BigDecimal getCompenCoa5() {
		return compenCoa5;
	}

	public void setCompenCoa5(BigDecimal compenCoa5) {
		this.compenCoa5 = compenCoa5;
	}

	public BigDecimal getCompenCoa6() {
		return compenCoa6;
	}

	public void setCompenCoa6(BigDecimal compenCoa6) {
		this.compenCoa6 = compenCoa6;
	}
	// R&V Junio 2017 - REACONDICIONAMIENTO VT01 VT04 - everis(RGL) - FIN



	/**
	 * Inicializamos el kPersonaSeg, con valor ENBLANCO
	 */
	private BigDecimal kPersonaSeg = new BigDecimal ( 0 );

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
	 * Inicializamos el tipPersonaSeg, con valor ENBLANCO
	 */
	private String tipPersonaSeg = ENBLANCO;

	/**
	 * Inicializamos el residenteSeg, con valor ENBLANCO
	 */
	private String residenteSeg = ENBLANCO;

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
	 * Inicializamos el vectorMensajes, con valor ENBLANCO
	 */
	private List <Object> vectorMensajes = Collections.synchronizedList ( new Vector <Object> () );

	/**
	 * Inicializamos el fecImprePri, con valor ENBLANCO
	 */
	private String fecImprePri = ENBLANCO;

	/**
	 * Inicializamos el fecImpreComp, con valor ENBLANCO
	 */
	private String fecImpreComp = ENBLANCO;

	/**
	 * Inicializamos el usuario, con valor ENBLANCO
	 */
	private J000J000Usuario usuario;

	/**
	 * Inicializamos el operacion, con valor ENBLANCO
	 */
	private String operacion = ENBLANCO;

	/**
	 * Inicializamos el retorno, con valor ENBLANCO
	 */
	private String retorno = ENBLANCO;

	/**
	 * Inicializamos el desRetorno, con valor ENBLANCO
	 */
	private String desRetorno = ENBLANCO;

	/**
	 * Inicializamos el nomPrograma, con valor ENBLANCO
	 */
	private String nomPrograma = ENBLANCO;

	/**
	 * Inicializamos el reaseguro, con valor ENBLANCO
	 */
	private String reaseguro = ENBLANCO;

	/**
	 * Inicializamos el duracion, con valor ENBLANCO
	 */
	private BigDecimal duracion = new BigDecimal ( 0 );
	
	/*INICIO  MU-2015-041869 */
	/**
	 * Inicializamos el aniofiscal, con valor ENBLANCO
	 */
	private BigDecimal aniofiscal = new BigDecimal ( 0 );
	/*FIN  MU-2015-041869 */

	/**
	 * @return el reaseguro
	 */
	public String getReaseguro () {
		return reaseguro;
	}

	/**
	 * @return el anticipoPri
	 */
	public BigDecimal getAnticipoPri () {
		return anticipoPri;
	}

	/**
	 * @param anticipoPri
	 *            el anticipoPri a establecer
	 */
	public void setAnticipoPri ( BigDecimal anticipoPri ) {
		this.anticipoPri = anticipoPri;
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
	 * @return el beneficiosPri
	 */
	public BigDecimal getBeneficiosPri () {
		return beneficiosPri;
	}

	/**
	 * @param beneficiosPri
	 */
	public void setBeneficiosPri ( BigDecimal beneficiosPri ) {
		this.beneficiosPri = beneficiosPri;
	}

	/**
	 * @return el cobroInterPri
	 */
	public BigDecimal getCobroInterPri () {
		return cobroInterPri;
	}

	/**
	 * @param cobroInterPri
	 */
	public void setCobroInterPri ( BigDecimal cobroInterPri ) {
		this.cobroInterPri = cobroInterPri;
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
	 * @return el compensaPri
	 */
	public BigDecimal getCompensaPri () {
		return compensaPri;
	}

	/**
	 * @param compensaPri
	 */
	public void setCompensaPri ( BigDecimal compensaPri ) {
		this.compensaPri = compensaPri;
	}

	/**
	 * @return el desRetorno
	 */
	public String getDesRetorno () {
		return desRetorno;
	}

	/**
	 * @param desRetorno
	 */
	public void setDesRetorno ( String desRetorno ) {
		this.desRetorno = desRetorno;
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
	 * @return importeComp
	 */
	public BigDecimal getImporteComp () {
		return importeComp;
	}

	/**
	 * @param importeComp
	 */
	public void setImporteComp ( BigDecimal importeComp ) {
		this.importeComp = importeComp;
	}

	/**
	 * @return liquidoComp
	 */
	public BigDecimal getLiquidoComp () {
		return liquidoComp;
	}

	/**
	 * @param liquidoComp
	 */
	public void setLiquidoComp ( BigDecimal liquidoComp ) {
		this.liquidoComp = liquidoComp;
	}

	/**
	 * @return liquidoPri
	 */
	public BigDecimal getLiquidoPri () {
		return liquidoPri;
	}

	/**
	 * @param liquidoPri
	 */
	public void setLiquidoPri ( BigDecimal liquidoPri ) {
		this.liquidoPri = liquidoPri;
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
	 * @return nomPrograma
	 */
	public String getNomPrograma () {
		return nomPrograma;
	}

	/**
	 * @param nomPrograma
	 */
	public void setNomPrograma ( String nomPrograma ) {
		this.nomPrograma = nomPrograma;
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
	 * @return operacion
	 */
	public String getOperacion () {
		return operacion;
	}

	/**
	 * @param operacion
	 */
	public void setOperacion ( String operacion ) {
		this.operacion = operacion;
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
	 * @return pendiente
	 */
	public BigDecimal getPendiente () {
		return pendiente;
	}

	/**
	 * @param pendiente
	 */
	public void setPendiente ( BigDecimal pendiente ) {
		this.pendiente = pendiente;
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
	 * @return porcentajeComp
	 */
	public BigDecimal getPorcentajeComp () {
		return porcentajeComp;
	}

	/**
	 * @param porcentajeComp
	 */
	public void setPorcentajeComp ( BigDecimal porcentajeComp ) {
		this.porcentajeComp = porcentajeComp;
	}

	/**
	 * @return porcentajePri
	 */
	public BigDecimal getPorcentajePri () {
		return porcentajePri;
	}

	/**
	 * 
	 * @param porcentajePri
	 */
	public void setPorcentajePri ( BigDecimal porcentajePri ) {
		this.porcentajePri = porcentajePri;
	}

	/**
	 * 
	 * @return porCoasegur1
	 */
	public BigDecimal getPorCoasegur1 () {
		return porCoasegur1;
	}

	/**
	 * @param porCoasegur1
	 */
	public void setPorCoasegur1 ( BigDecimal porCoasegur1 ) {
		this.porCoasegur1 = porCoasegur1;
	}

	/**
	 * @return porCoasegur2
	 */
	public BigDecimal getPorCoasegur2 () {
		return porCoasegur2;
	}

	/**
	 * @param porCoasegur2
	 */
	public void setPorCoasegur2 ( BigDecimal porCoasegur2 ) {
		this.porCoasegur2 = porCoasegur2;
	}

	/**
	 * @return porCoasegur3
	 */
	public BigDecimal getPorCoasegur3 () {
		return porCoasegur3;
	}

	/**
	 * @param porCoasegur3
	 */
	public void setPorCoasegur3 ( BigDecimal porCoasegur3 ) {
		this.porCoasegur3 = porCoasegur3;
	}

	/**
	 * @return porCoasegur4
	 */
	public BigDecimal getPorCoasegur4 () {
		return porCoasegur4;
	}

	/**
	 * @param porCoasegur4
	 */
	public void setPorCoasegur4 ( BigDecimal porCoasegur4 ) {
		this.porCoasegur4 = porCoasegur4;
	}

	/**
	 * @return porCoasegur5
	 */
	public BigDecimal getPorCoasegur5 () {
		return porCoasegur5;
	}

	/**
	 * @param porCoasegur5
	 */
	public void setPorCoasegur5 ( BigDecimal porCoasegur5 ) {
		this.porCoasegur5 = porCoasegur5;
	}

	/**
	 * @return porCoasegur6
	 */
	public BigDecimal getPorCoasegur6 () {
		return porCoasegur6;
	}

	/**
	 * @param porCoasegur6
	 */
	public void setPorCoasegur6 ( BigDecimal porCoasegur6 ) {
		this.porCoasegur6 = porCoasegur6;
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
	 * @return reciboPri
	 */
	public BigDecimal getReciboPri () {
		return reciboPri;
	}

	/**
	 * @param reciboPri
	 */
	public void setReciboPri ( BigDecimal reciboPri ) {
		this.reciboPri = reciboPri;
	}

	/**
	 * @return redPrimasComp
	 */
	public BigDecimal getRedPrimasComp () {
		return redPrimasComp;
	}

	/**
	 * @param redPrimasComp
	 */
	public void setRedPrimasComp ( BigDecimal redPrimasComp ) {
		this.redPrimasComp = redPrimasComp;
	}

	/**
	 * @return redPrimasPri
	 */
	public BigDecimal getRedPrimasPri () {
		return redPrimasPri;
	}

	/**
	 * @param redPrimasPri
	 */
	public void setRedPrimasPri ( BigDecimal redPrimasPri ) {
		this.redPrimasPri = redPrimasPri;
	}

	/**
	 * @return redTransitComp
	 */
	public BigDecimal getRedTransitComp () {
		return redTransitComp;
	}

	/**
	 * @param redTransitComp
	 */
	public void setRedTransitComp ( BigDecimal redTransitComp ) {
		this.redTransitComp = redTransitComp;
	}

	/**
	 * @return redTransitPri
	 */
	public BigDecimal getRedTransitPri () {
		return redTransitPri;
	}

	/**
	 * @param redTransitPri
	 */
	public void setRedTransitPri ( BigDecimal redTransitPri ) {
		this.redTransitPri = redTransitPri;
	}

	/**
	 * @return regionalEnv
	 */
	public String getRegionalEnv () {
		return regionalEnv;
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
	 * @return retencionComp
	 */
	public BigDecimal getRetencionComp () {
		return retencionComp;
	}

	/**
	 * @param retencionComp
	 */
	public void setRetencionComp ( BigDecimal retencionComp ) {
		this.retencionComp = retencionComp;
	}

	/**
	 * @return retencionPri
	 */
	public BigDecimal getRetencionPri () {
		return retencionPri;
	}

	/**
	 * @param retencionPri
	 */
	public void setRetencionPri ( BigDecimal retencionPri ) {
		this.retencionPri = retencionPri;
	}

	/**
	 * @return retorno
	 */
	public String getRetorno () {
		return retorno;
	}

	/**
	 * @param retorno
	 */
	public void setRetorno ( String retorno ) {
		this.retorno = retorno;
	}

	/**
	 * @return rtoIntegroComp
	 */
	public BigDecimal getRtoIntegroComp () {
		return rtoIntegroComp;
	}

	/**
	 * @param rtoIntegroComp
	 */
	public void setRtoIntegroComp ( BigDecimal rtoIntegroComp ) {
		this.rtoIntegroComp = rtoIntegroComp;
	}

	/**
	 * @return rtoIntegroPri
	 */
	public BigDecimal getRtoIntegroPri () {
		return rtoIntegroPri;
	}

	/**
	 * @param rtoIntegroPri
	 */
	public void setRtoIntegroPri ( BigDecimal rtoIntegroPri ) {
		this.rtoIntegroPri = rtoIntegroPri;
	}

	/**
	 * @return rtoNetoComp
	 */
	public BigDecimal getRtoNetoComp () {
		return rtoNetoComp;
	}

	/**
	 * @param rtoNetoComp
	 */
	public void setRtoNetoComp ( BigDecimal rtoNetoComp ) {
		this.rtoNetoComp = rtoNetoComp;
	}

	/**
	 * @return rtoNetoPri
	 */
	public BigDecimal getRtoNetoPri () {
		return rtoNetoPri;
	}

	/**
	 * @param rtoNetoPri
	 */
	public void setRtoNetoPri ( BigDecimal rtoNetoPri ) {
		this.rtoNetoPri = rtoNetoPri;
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
	 * @return tipPersonaPri
	 */
	public String getTipPersonaPri () {
		return tipPersonaPri;
	}

	/**
	 * @param tipPersonaPri
	 */
	public void setTipPersonaPri ( String tipPersonaPri ) {
		this.tipPersonaPri = tipPersonaPri;
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
	 * @return usuario
	 */
	public J000J000Usuario getUsuario () {
		return usuario;
	}

	/**
	 * @param usuario
	 */
	public void setUsuario ( J000J000Usuario usuario ) {
		this.usuario = usuario;
	}

	/**
	 * @param reaseguro
	 */
	public void setReaseguro ( String reaseguro ) {
		this.reaseguro = reaseguro;
	}

	/**
	 * @return subpoliza
	 */
	public BigDecimal getSubpoliza () {
		return subpoliza;
	}

	/**
	 * @param subpoliza
	 */
	public void setSubpoliza ( BigDecimal subpoliza ) {
		this.subpoliza = subpoliza;
	}

	/**
	 * @return residentePri
	 */
	public String getResidentePri () {
		return residentePri;
	}

	/**
	 * @return vectorMensajes
	 */
	public List getVectorMensajes () {
		return vectorMensajes;
	}

	/**
	 * @param vectorMensajes
	 */
	public void setVectorMensajes ( List vectorMensajes ) {
		this.vectorMensajes = vectorMensajes;
	}

	/**
	 * @param residentePri
	 */
	public void setResidentePri ( String residentePri ) {
		this.residentePri = residentePri;
	}

	/**
	 * @return residenteSeg
	 */
	public String getResidenteSeg () {
		return residenteSeg;
	}

	/**
	 * @param residenteSeg
	 */
	public void setResidenteSeg ( String residenteSeg ) {
		this.residenteSeg = residenteSeg;
	}

	/**
	 * @return tipImpuestoComp
	 */
	public String getTipImpuestoComp () {
		return tipImpuestoComp;
	}

	/**
	 * @param tipImpuestoComp
	 */
	public void setTipImpuestoComp ( String tipImpuestoComp ) {
		this.tipImpuestoComp = tipImpuestoComp;
	}

	/**
	 * @return kPersonaPri
	 */
	public BigDecimal getKPersonaPri () {
		return kPersonaPri;
	}

	/**
	 * @param personaPri
	 */
	public void setKPersonaPri ( BigDecimal personaPri ) {
		kPersonaPri = personaPri;
	}

	/**
	 * @return kPersonaSeg
	 */
	public BigDecimal getKPersonaSeg () {
		return kPersonaSeg;
	}

	/**
	 * @param personaSeg
	 */
	public void setKPersonaSeg ( BigDecimal personaSeg ) {
		kPersonaSeg = personaSeg;
	}

	/**
	 * @return anio
	 */
	public BigDecimal getAnio () {
		return anio;
	}

	/**
	 * @param anio
	 */
	public void setAnio ( BigDecimal anio ) {
		this.anio = anio;
	}

	/**
	 * @return certificado
	 */
	public BigDecimal getCertificado () {
		return certificado;
	}

	/**
	 * @param certificado
	 */
	public void setCertificado ( BigDecimal certificado ) {
		this.certificado = certificado;
	}

	/**
	 * @return modalidad
	 */
	public BigDecimal getModalidad () {
		return modalidad;
	}

	/**
	 * @param modalidad
	 */
	public void setModalidad ( BigDecimal modalidad ) {
		this.modalidad = modalidad;
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
	 * @return el expediente
	 */
	public BigDecimal getExpediente () {
		return expediente;
	}

	/**
	 * @param expediente
	 *            el expediente a establecer
	 */
	public void setExpediente ( BigDecimal expediente ) {
		this.expediente = expediente;
	}

	/**
	 * @return el duracion
	 */
	public BigDecimal getDuracion () {
		return duracion;
	}

	/**
	 * @param duracion
	 *            el duracion a establecer
	 */
	public void setDuracion ( BigDecimal duracion ) {
		this.duracion = duracion;
	}

	/**
	 * @return el impReciboComp
	 */
	public BigDecimal getImpReciboComp () {
		return impReciboComp;
	}

	/**
	 * @param impReciboComp
	 *            el impReciboComp a establecer
	 */
	public void setImpReciboComp ( BigDecimal impReciboComp ) {
		this.impReciboComp = impReciboComp;
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
	 * @return el fecEmision
	 */
	public String getFecEmision () {
		return fecEmision;
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
	 * @param fecEmision
	 *            el fecEmision a establecer
	 */
	public void setFecEmision ( String fecEmision ) {
		this.fecEmision = fecEmision;
	}

	/**
	 * @return el impCapital
	 */
	public BigDecimal getImpCapital () {
		return impCapital;
	}

	/**
	 * @param impCapital
	 *            el impCapital a establecer
	 */
	public void setImpCapital ( BigDecimal impCapital ) {
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
	public BigDecimal getImpAnticipo () {
		return impAnticipo;
	}

	/**
	 * @param impAnticipo
	 *            el impAnticipo a establecer
	 */
	public void setImpAnticipo ( BigDecimal impAnticipo ) {
		this.impAnticipo = impAnticipo;
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
	 * @return el redPrimasCap
	 */
	public BigDecimal getRedPrimasCap () {
		return redPrimasCap;
	}

	/**
	 * @param redPrimasCap
	 *            el redPrimasCap a establecer
	 */
	public void setRedPrimasCap ( BigDecimal redPrimasCap ) {
		this.redPrimasCap = redPrimasCap;
	}

	/**
	 * @return el redTransitCap
	 */
	public BigDecimal getRedTransitCap () {
		return redTransitCap;
	}

	/**
	 * @param redTransitCap
	 *            el redTransitCap a establecer
	 */
	public void setRedTransitCap ( BigDecimal redTransitCap ) {
		this.redTransitCap = redTransitCap;
	}

	/**
	 * @return el rtoIntegroCap
	 */
	public BigDecimal getRtoIntegroCap () {
		return rtoIntegroCap;
	}

	/**
	 * @param rtoIntegroCap
	 *            el rtoIntegroCap a establecer
	 */
	public void setRtoIntegroCap ( BigDecimal rtoIntegroCap ) {
		this.rtoIntegroCap = rtoIntegroCap;
	}

	/**
	 * @return el compensaCap
	 */
	public BigDecimal getCompensaCap () {
		return compensaCap;
	}

	/**
	 * @param compensaCap
	 *            el compensaCap a establecer
	 */
	public void setCompensaCap ( BigDecimal compensaCap ) {
		this.compensaCap = compensaCap;
	}

	/**
	 * @return el porcentajeCap
	 */
	public BigDecimal getPorcentajeCap () {
		return porcentajeCap;
	}

	/**
	 * @param porcentajeCap
	 *            el porcentajeCap a establecer
	 */
	public void setPorcentajeCap ( BigDecimal porcentajeCap ) {
		this.porcentajeCap = porcentajeCap;
	}

	/**
	 * @return el rtoNetoCap
	 */
	public BigDecimal getRtoNetoCap () {
		return rtoNetoCap;
	}

	/**
	 * @param rtoNetoCap
	 *            el rtoNetoCap a establecer
	 */
	public void setRtoNetoCap ( BigDecimal rtoNetoCap ) {
		this.rtoNetoCap = rtoNetoCap;
	}

	/**
	 * @return el retencionCap
	 */
	public BigDecimal getRetencionCap () {
		return retencionCap;
	}

	/**
	 * @param retencionCap
	 *            el retencionCap a establecer
	 */
	public void setRetencionCap ( BigDecimal retencionCap ) {
		this.retencionCap = retencionCap;
	}

	/**
	 * @return el liquidoCap
	 */
	public BigDecimal getLiquidoCap () {
		return liquidoCap;
	}

	/**
	 * @param liquidoCap
	 *            el liquidoCap a establecer
	 */
	public void setLiquidoCap ( BigDecimal liquidoCap ) {
		this.liquidoCap = liquidoCap;
	}

	/**
	 * @return el fecPagoIRPF
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
	 * @return el importePri
	 */
	public BigDecimal getImportePri () {
		return importePri;
	}

	/**
	 * @param importePri
	 *            el importePri a establecer
	 */
	public void setImportePri ( BigDecimal importePri ) {
		this.importePri = importePri;
	}

	/**
	 * @param tipImpuestoPri
	 *            el tipImpuestoPri a establecer
	 */
	public void setTipImpuestoPri ( String tipImpuestoPri ) {
		this.tipImpuestoPri = tipImpuestoPri;
	}

	/**
	 * @return el tipImpuestoPri
	 */
	public String getTipImpuestoPri () {
		return tipImpuestoPri;
	}

	/**
	 * @return el penComPri
	 */
	public String getPenComPri () {
		return penComPri;
	}

	/**
	 * @param penComPri
	 *            el penComPri a establecer
	 */
	public void setPenComPri ( String penComPri ) {
		this.penComPri = penComPri;
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
	 * @return el impInteresPend
	 */
	public BigDecimal getImpInteresPend () {
		return impInteresPend;
	}

	/**
	 * @param impInteresPend
	 *            el impInteresPend a establecer
	 */
	public void setImpInteresPend ( BigDecimal impInteresPend ) {
		this.impInteresPend = impInteresPend;
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

	/*INICIO  MU-2015-041869 */
	/**
	 * @return el aniofiscal
	 */
	public BigDecimal getAniofiscal() {
		return aniofiscal;
	}

	/**
	 * @param aniofiscal el aniofiscal a establecer
	 */
	public void setAniofiscal(BigDecimal aniofiscal) {
		this.aniofiscal = aniofiscal;
	}	
	/*FIN  MU-2015-041869 */
	
	//MU-2016-006664 - RAROALE - INI

	/**
	 * @return el impCoasegur1
	 */
	public BigDecimal getImpCoasegur1() {
		return impCoasegur1;
	}

	/**
	 * @param impCoasegur1 el impCoasegur1 a establecer
	 */
	public void setImpCoasegur1(BigDecimal impCoasegur1) {
		this.impCoasegur1 = impCoasegur1;
	}

	/**
	 * @return el impCoasegur2
	 */
	public BigDecimal getImpCoasegur2() {
		return impCoasegur2;
	}

	/**
	 * @param impCoasegur2 el impCoasegur2 a establecer
	 */
	public void setImpCoasegur2(BigDecimal impCoasegur2) {
		this.impCoasegur2 = impCoasegur2;
	}

	/**
	 * @return el impCoasegur3
	 */
	public BigDecimal getImpCoasegur3() {
		return impCoasegur3;
	}

	/**
	 * @param impCoasegur3 el impCoasegur3 a establecer
	 */
	public void setImpCoasegur3(BigDecimal impCoasegur3) {
		this.impCoasegur3 = impCoasegur3;
	}

	/**
	 * @return el impCoasegur4
	 */
	public BigDecimal getImpCoasegur4() {
		return impCoasegur4;
	}

	/**
	 * @param impCoasegur4 el impCoasegur4 a establecer
	 */
	public void setImpCoasegur4(BigDecimal impCoasegur4) {
		this.impCoasegur4 = impCoasegur4;
	}

	/**
	 * @return el impCoasegur5
	 */
	public BigDecimal getImpCoasegur5() {
		return impCoasegur5;
	}

	/**
	 * @param impCoasegur5 el impCoasegur5 a establecer
	 */
	public void setImpCoasegur5(BigDecimal impCoasegur5) {
		this.impCoasegur5 = impCoasegur5;
	}

	/**
	 * @return el impCoasegur6
	 */
	public BigDecimal getImpCoasegur6() {
		return impCoasegur6;
	}

	/**
	 * @param impCoasegur6 el impCoasegur6 a establecer
	 */
	public void setImpCoasegur6(BigDecimal impCoasegur6) {
		this.impCoasegur6 = impCoasegur6;
	}
	//MU-2016-006664 - RAROALE - FIN
	
	// MU-2016-006673 - RAROALE - INI
	/**
	 * @return el kDomicilioPri
	 */
	public BigDecimal getKDomicilioPri() {
		return kDomicilioPri;
	}

	/**
	 * @param domicilioPri el kDomicilioPri a establecer
	 */
	public void setKDomicilioPri(BigDecimal domicilioPri) {
		kDomicilioPri = domicilioPri;
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
}
