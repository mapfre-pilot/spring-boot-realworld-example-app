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
import java.util.List;

import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;

/**
 * @author everis
 * @version 1.0 Versi�n inicial Clase de negocio. Encapsula los datos del
 *          detalle del programa.
 * 
 */
public class J372J001BusquedaExpVenPageBean {

    //INICIO MODIFICACION EVERIS
	/**
	 * Inicializamos el selectedRow, con valor ENBLANCO
	 */
	private String selectedRow = ENBLANCO;
	
	//FIN MODIFICACION EVERIS
	
	
	
	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inicializamos el anio, con valor ENBLANCO
	 */
	private BigDecimal anio = new BigDecimal ( 0 );

	/**
	 * Inicializamos el expediente, con valor ENBLANCO
	 */
	private BigDecimal expediente = new BigDecimal ( 0 );

	/**
	 * Inicializamos el desSituacion, con valor ENBLANCO
	 */
	private String desSituacion = ENBLANCO;

	/**
	 * Inicializamos el rdNifCif, con valor ENBLANCO
	 */
	private String rdNifCif = ENBLANCO;

	/**
	 * Inicializamos el rdPoliza, con valor ENBLANCO
	 */
	private String rdPoliza = ENBLANCO;
	
	/**
	 * Inicializamos el rdSubpoliza
	 */
	private String rdSubpoliza = ENBLANCO;
	
	/**
	 * Inicializamos el rdCertificado
	 */
	private String rdCertificado = ENBLANCO;

	/**
	 * Inicializamos el rdAnioExp, con valor ENBLANCO
	 */
	private String rdAnioExp = ENBLANCO;

	/**
	 * Inicializamos el poliza, con valor ENBLANCO
	 */
	private String poliza = ENBLANCO;

	/**
	 * Inicializamos el anioPoliza, con valor ENBLANCO
	 */
	private String anioPoliza = ENBLANCO;

	/**
	 * Inicializamos el nifCif, con valor ENBLANCO
	 */
	private String nifCif = ENBLANCO;

	/**
	 * Inicializamos el tipBusqueda, con valor ENBLANCO
	 */
	private String tipBusqueda = ENBLANCO;

	/**
	 * Inicializamos el listadoExp
	 */
	private List <Object> listadoExp;

	/**
	 * Inicializamos el retorno, con valor ENBLANCO
	 */
	private String retorno;

	/**
	 * Inicializamos el desRetorno, con valor ENBLANCO
	 */
	private String desRetorno;

	/**
	 * Inicializamos el usuario, con valor ENBLANCO
	 */
	private J000J000Usuario usuario;

	/**
	 * Inicializamos el tomador, con valor ENBLANCO
	 */
	private String tomador;

	/**
	 * Inicializamos el nomPrograma, con valor ENBLANCO
	 */
	private String nomPrograma;

	/**
	 * Inicializamos el paginacion, con valor ENBLANCO
	 */
	private String paginacion = ENBLANCO;

	/**
	 * Inicializamos el antAnio, con valor ENBLANCO
	 */
	private BigDecimal antAnio = new BigDecimal ( 0 );

	/**
	 * Inicializamos el antExpediente, con valor ENBLANCO
	 */
	private BigDecimal antExpediente = new BigDecimal ( 0 );

	/**
	 * Inicializamos el proExpediente, con valor ENBLANCO
	 */
	private BigDecimal proExpediente = new BigDecimal ( 0 );

	/**
	 * Inicializamos el proAnio, con valor ENBLANCO
	 */
	private BigDecimal proAnio = new BigDecimal ( 0 );

	/**
	 * Inicializamos el numRegistros, con valor ENBLANCO
	 */
	private String numRegistros = ENBLANCO;

	/**
	 * Inicializamos el operacion, con valor ENBLANCO
	 */
	private String operacion = ENBLANCO;

	/**
	 * Inicializamos el ramo, con valor ENBLANCO
	 */
	private String ramo = ENBLANCO;

	/**
	 * Inicializamos el registros, con valor ENBLANCO
	 */
	private String registros = ENBLANCO;

	/**
	 * Inicializamos el tipOperacion, con valor ENBLANCO
	 */
	private String tipOperacion;

	/**
	 * Inicializamos el numPoliza, con valor ENBLANCO
	 */
	private String numPoliza;

	/**
	 * Inicializamos el subPoliza, con valor ENBLANCO
	 */
	private BigDecimal subPoliza = new BigDecimal ( 0 );

	/**
	 * Inicializamos el certificado, con valor ENBLANCO
	 */
	private BigDecimal certificado = new BigDecimal ( 0 );

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
	 * Inicializamos el tipoRescate, con valor ENBLANCO
	 */
	private String tipoRescate = ENBLANCO;

	/**
	 * Inicializamos el situacion, con valor ENBLANCO
	 */
	private String situacion = ENBLANCO;

	/**
	 * Inicializamos el fecEfecto, con valor ENBLANCO
	 */
	private String fecEfecto = ENBLANCO;

	/**
	 * Inicializamos el fecAnulada, con valor ENBLANCO
	 */
	private String fecAnulada = ENBLANCO;

	/**
	 * Inicializamos el fecModifica, con valor ENBLANCO
	 */
	private String fecModifica = ENBLANCO;

	/**
	 * Inicializamos el cartera, con valor ENBLANCO
	 */
	private String cartera = ENBLANCO;

	/**
	 * Inicializamos el reaseguro, con valor ENBLANCO
	 */
	private String reaseguro = ENBLANCO;

	/**
	 * Inicializamos el regional, con valor ENBLANCO
	 */
	private String regional = ENBLANCO;

	/**
	 * Inicializamos el lugarEnvio, con valor ENBLANCO
	 */
	private String lugarEnvio = ENBLANCO;

	/**
	 * Inicializamos el oficina, con valor ENBLANCO
	 */
	private String oficina = ENBLANCO;

	/**
	 * Inicializamos el pendiente, con valor ENBLANCO
	 */
	private BigDecimal pendiente = new BigDecimal ( 0 );

	/**
	 * Inicializamos el tipoPers1, con valor ENBLANCO
	 */
	private String tipoPers1 = ENBLANCO;

	/**
	 * Inicializamos el residente1, con valor ENBLANCO
	 */
	private String residente1 = ENBLANCO;

	/**
	 * Inicializamos el nif1, con valor ENBLANCO
	 */
	private String nif1 = ENBLANCO;

	/**
	 * Inicializamos el persona1, con valor ENBLANCO
	 */
	private BigDecimal persona1 = new BigDecimal ( 0 );
	
	// MU-2016-006673 - RAROALE - INI
	/**
	 * Inicializamos el domicilio1, con valor ENBLANCO
	 */
	private BigDecimal domicilio1 = new BigDecimal(0);
	
	/**
	 * Inicializamos el fmodificacion, con valor ENBLANCO
	 */
	private String fmodificacion = ENBLANCO;
	// MU-2016-006673 - RAROALE - FIN

	/**
	 * Inicializamos el tipoPers2, con valor ENBLANCO
	 */
	private String tipoPers2 = ENBLANCO;

	/**
	 * Inicializamos el residente2, con valor ENBLANCO
	 */
	private String residente2 = ENBLANCO;

	/**
	 * Inicializamos el nif2, con valor ENBLANCO
	 */
	private String nif2 = ENBLANCO;

	/**
	 * Inicializamos el persona2, con valor ENBLANCO
	 */
	private BigDecimal persona2 = new BigDecimal ( 0 );

	/**
	 * Inicializamos el impCapital, con valor ENBLANCO
	 */
	private BigDecimal impCapital = new BigDecimal ( 0 );

	/**
	 * Inicializamos el impBeneficios, con valor ENBLANCO
	 */
	private BigDecimal impBeneficios = new BigDecimal ( 0 );

	/**
	 * Inicializamos el fecPagoCapital, con valor ENBLANCO
	 */
	private String fecPagoCapital = ENBLANCO;

	/**
	 * Inicializamos el impAnticipo, con valor ENBLANCO
	 */
	private BigDecimal impAnticipo = new BigDecimal ( 0 );

	/**
	 * Inicializamos el impCobroInt, con valor ENBLANCO
	 */
	private BigDecimal impCobroInt = new BigDecimal ( 0 );

	/**
	 * Inicializamos el impPrimaRec, con valor ENBLANCO
	 */
	private BigDecimal impPrimaRec = new BigDecimal ( 0 );

	/**
	 * Inicializamos el fecEmisionCap, con valor ENBLANCO
	 */
	private String fecEmisionCap = ENBLANCO;
	
	
	/**
	 * Inicializamos el fecReciboCap, con valor ENBLANCO
	 */
	private String fecReciboCap = ENBLANCO;

	/**
	 * Inicializamos el tipImpuest, con valor ENBLANCO
	 */
	private String tipImpuest = ENBLANCO;

	/**
	 * Inicializamos el impRtorintegrcap, con valor ENBLANCO
	 */
	private BigDecimal impRtorintegrcap = new BigDecimal ( 0 );

	/**
	 * Inicializamos el impRedPriCap, con valor ENBLANCO
	 */
	private BigDecimal impRedPriCap = new BigDecimal ( 0 );

	/**
	 * Inicializamos el impRedTranCap, con valor ENBLANCO
	 */
	private BigDecimal impRedTranCap = new BigDecimal ( 0 );

	/**
	 * Inicializamos el impCompensatoria, con valor ENBLANCO
	 */
	private BigDecimal impCompensatoria = new BigDecimal ( 0 );

	/**
	 * Inicializamos el impRtonetoCap, con valor ENBLANCO
	 */
	private BigDecimal impRtonetoCap = new BigDecimal ( 0 );

	/**
	 * Inicializamos el porretCap, con valor ENBLANCO
	 */
	private BigDecimal porretCap = new BigDecimal ( 0 );

	/**
	 * Inicializamos el impretCap, con valor ENBLANCO
	 */
	private BigDecimal impretCap = new BigDecimal ( 0 );

	/**
	 * Inicializamos el impliqCap, con valor ENBLANCO
	 */
	private BigDecimal impliqCap = new BigDecimal ( 0 );

	/**
	 * Inicializamos el fecImpreCap, con valor ENBLANCO
	 */
	private String fecImpreCap = ENBLANCO;

	/**
	 * Inicializamos el fecPagret, con valor ENBLANCO
	 */
	private String fecPagret = ENBLANCO;

	/**
	 * Inicializamos el impComp, con valor ENBLANCO
	 */
	private BigDecimal impComp = new BigDecimal ( 0 );

	/**
	 * Inicializamos el impriMareComp, con valor ENBLANCO
	 */
	private BigDecimal impriMareComp = new BigDecimal ( 0 );

	/**
	 * Inicializamos el fecPagComp, con valor ENBLANCO
	 */
	private String fecPagComp = ENBLANCO;

	/**
	 * Inicializamos el fecCemiComp, con valor ENBLANCO
	 */
	private String fecCemiComp = ENBLANCO;

	/**
	 * Inicializamos el tipImpuestComp, con valor ENBLANCO
	 */
	private String tipImpuestComp = ENBLANCO;

	/**
	 * Inicializamos el impRtointComp, con valor ENBLANCO
	 */
	private BigDecimal impRtointComp = new BigDecimal ( 0 );

	/**
	 * Inicializamos el impRedpriComp, con valor ENBLANCO
	 */
	private BigDecimal impRedpriComp = new BigDecimal ( 0 );

	/**
	 * Inicializamos el impRedTranComp, con valor ENBLANCO
	 */
	private BigDecimal impRedTranComp = new BigDecimal ( 0 );

	/**
	 * Inicializamos el irTonetComp, con valor ENBLANCO
	 */
	private BigDecimal irTonetComp = new BigDecimal ( 0 );

	/**
	 * Inicializamos el porretComp, con valor ENBLANCO
	 */
	private BigDecimal porretComp = new BigDecimal ( 0 );

	/**
	 * Inicializamos el iretComp, con valor ENBLANCO
	 */
	private BigDecimal iretComp = new BigDecimal ( 0 );

	/**
	 * Inicializamos el iliqComp, con valor ENBLANCO
	 */
	private BigDecimal iliqComp = new BigDecimal ( 0 );

	/**
	 * Inicializamos el fecImpreComp, con valor ENBLANCO
	 */
	private String fecImpreComp = ENBLANCO;

	/**
	 * Inicializamos el fecPagretCom, con valor ENBLANCO
	 */
	private String fecPagretCom = ENBLANCO;

	/**
	 * Inicializamos el impComp2, con valor ENBLANCO
	 */
	private BigDecimal impComp2 = new BigDecimal ( 0 );

	/**
	 * Inicializamos el tipImpuestComp2, con valor ENBLANCO
	 */
	private String tipImpuestComp2 = ENBLANCO;

	/**
	 * Inicializamos el fecCemiComp2, con valor ENBLANCO
	 */
	private String fecCemiComp2 = ENBLANCO;

	/**
	 * Inicializamos el fecPagComp2, con valor ENBLANCO
	 */
	private String fecPagComp2 = ENBLANCO;

	/**
	 * Inicializamos el impRtointComp2, con valor ENBLANCO
	 */
	private BigDecimal impRtointComp2 = new BigDecimal ( 0 );

	/**
	 * Inicializamos el impRedpriComp2, con valor ENBLANCO
	 */
	private BigDecimal impRedpriComp2 = new BigDecimal ( 0 );

	/**
	 * Inicializamos el impRedTranComp2, con valor ENBLANCO
	 */
	private BigDecimal impRedTranComp2 = new BigDecimal ( 0 );

	/**
	 * Inicializamos el irTonetComp2, con valor ENBLANCO
	 */
	private BigDecimal irTonetComp2 = new BigDecimal ( 0 );

	/**
	 * Inicializamos el porretComp2, con valor ENBLANCO
	 */
	private BigDecimal porretComp2 = new BigDecimal ( 0 );

	/**
	 * Inicializamos el iretComp2, con valor ENBLANCO
	 */
	private BigDecimal iretComp2 = new BigDecimal ( 0 );

	/**
	 * Inicializamos el iliqComp2, con valor ENBLANCO
	 */
	private BigDecimal iliqComp2 = new BigDecimal ( 0 );

	/**
	 * Inicializamos el fecImpreComp2, con valor ENBLANCO
	 */
	private String fecImpreComp2 = ENBLANCO;

	/**
	 * Inicializamos el fecPagretCom2, con valor ENBLANCO
	 */
	private String fecPagretCom2 = ENBLANCO;

	/**
	 * Inicializamos el codCoA1, con valor ENBLANCO
	 */
	private String codCoA1 = ENBLANCO;

	/**
	 * Inicializamos el porCoA1, con valor ENBLANCO
	 */
	private BigDecimal porCoA1 = new BigDecimal ( 0 );

	/**
	 * Inicializamos el codCoA2, con valor ENBLANCO
	 */
	private String codCoA2;

	/**
	 * Inicializamos el porCoA2, con valor ENBLANCO
	 */
	private BigDecimal porCoA2 = new BigDecimal ( 0 );

	/**
	 * Inicializamos el codCoA3, con valor ENBLANCO
	 */
	private String codCoA3 = ENBLANCO;

	private BigDecimal porCoA3 = new BigDecimal ( 0 );

	/**
	 * Inicializamos el codCoA4, con valor ENBLANCO
	 */
	private String codCoA4 = ENBLANCO;

	private BigDecimal porCoA4 = new BigDecimal ( 0 );

	/**
	 * Inicializamos el codCoA5, con valor ENBLANCO
	 */
	private String codCoA5 = ENBLANCO;

	private BigDecimal porCoA5 = new BigDecimal ( 0 );

	/**
	 * Inicializamos el codCoA6, con valor ENBLANCO
	 */
	private String codCoA6 = ENBLANCO;

	/**
	 * Inicializamos el porCoA6, con valor ENBLANCO
	 */
	private BigDecimal porCoA6 = new BigDecimal ( 0 );

	// MU-2016-006664 - RAROALE - INI
	/**
	 * Inicializamos el impCoA1, con valor 0
	 */
	private BigDecimal impCoA1 = new BigDecimal(0);
	/**
	 * Inicializamos el impCoA2, con valor 0
	 */
	private BigDecimal impCoA2 = new BigDecimal(0);
	/**
	 * Inicializamos el impCoA3, con valor 0
	 */
	private BigDecimal impCoA3 = new BigDecimal(0);
	/**
	 * Inicializamos el impCoA4, con valor 0
	 */
	private BigDecimal impCoA4 = new BigDecimal(0);
	/**
	 * Inicializamos el impCoA5, con valor 0
	 */
	private BigDecimal impCoA5 = new BigDecimal(0);
	/**
	 * Inicializamos el impCoA6, con valor 0
	 */
	private BigDecimal impCoA6 = new BigDecimal(0);
	// MU-2016-006664 - RAROALE - FIN

	// R&V Correccion 03/08/2017-1-3 INI
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
	private BigDecimal redPrimasCoa6 = new BigDecimal(0);

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
	 * @return el numCuentaComp2
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
	
	/**
	 * @return el discapacitadoPri
	 */
	public String getDiscapacitadoPri() {
	    return discapacitadoPri;
	}

	/**
	 * @param discapacitadoPri el discapacitadoPri a establecer
	 */
	public void setDiscapacitadoPri(String discapacitadoPri) {
	    this.discapacitadoPri = discapacitadoPri;
	}
	
	/**
	 * @return el sitFamiliarPri
	 */
	public String getSitFamiliarPri() {
	    return sitFamiliarPri;
	}

	/**
	 * @param sitFamiliarPri el sitFamiliarPri a establecer
	 */
	public void setSitFamiliarPri(String sitFamiliarPri) {
	    this.sitFamiliarPri = sitFamiliarPri;
	}

	/**
	 * @return el nifConyugePri
	 */
	public String getNifConyugePri() {
	    return nifConyugePri;
	}

	/**
	 * @param nifConyugePri el nifConyugePri a establecer
	 */
	public void setNifConyugePri(String nifConyugePri) {
	    this.nifConyugePri = nifConyugePri;
	}

	/**
	 * @return el penCompPri
	 */
	public String getPenCompPri() {
	    return penCompPri;
	}

	/**
	 * @param penCompPri el penCompPri a establecer
	 */
	public void setPenCompPri(String penCompPri) {
	    this.penCompPri = penCompPri;
	}

	/**
	 * @return el anulAlimenHijosPri
	 */
	public String getAnulAlimenHijosPri() {
	    return anulAlimenHijosPri;
	}

	/**
	 * @param anulAlimenHijosPri el anulAlimenHijosPri a establecer
	 */
	public void setAnulAlimenHijosPri(String anulAlimenHijosPri) {
	    this.anulAlimenHijosPri = anulAlimenHijosPri;
	}

	/**
	 * @return el prestViviendoPri
	 */
	public String getPrestViviendoPri() {
	    return prestViviendoPri;
	}

	/**
	 * @param prestViviendoPri el prestViviendoPri a establecer
	 */
	public void setPrestViviendoPri(String prestViviendoPri) {
	    this.prestViviendoPri = prestViviendoPri;
	}

	public BigDecimal getRtoIntegroCoa1() {
		return rtoIntegroCoa1;
	}

	public void setRtoIntegroCoa1(BigDecimal rtoIntegroCoa1) {
		this.rtoIntegroCoa1 = rtoIntegroCoa1;
	}

	public BigDecimal getRtoIntegroCoa2() {	return rtoIntegroCoa2;	}

	public void setRtoIntegroCoa2(BigDecimal rtoIntegroCoa2) {	this.rtoIntegroCoa2 = rtoIntegroCoa2;	}

	public BigDecimal getRtoIntegroCoa3() {	return rtoIntegroCoa3;	}

	public void setRtoIntegroCoa3(BigDecimal rtoIntegroCoa3) {	this.rtoIntegroCoa3 = rtoIntegroCoa3;	}

	public BigDecimal getRtoIntegroCoa4() {	return rtoIntegroCoa4;	}

	public void setRtoIntegroCoa4(BigDecimal rtoIntegroCoa4) {	this.rtoIntegroCoa4 = rtoIntegroCoa4;	}

	public BigDecimal getRtoIntegroCoa5() {	return rtoIntegroCoa5;	}

	public void setRtoIntegroCoa5(BigDecimal rtoIntegroCoa5) {	this.rtoIntegroCoa5 = rtoIntegroCoa5;	}

	public BigDecimal getRtoIntegroCoa6() {	return rtoIntegroCoa6;	}

	public void setRtoIntegroCoa6(BigDecimal rtoIntegroCoa6) {	this.rtoIntegroCoa6 = rtoIntegroCoa6;	}

	public BigDecimal getRedPrimasCoa1() {	return redPrimasCoa1;	}

	public void setRedPrimasCoa1(BigDecimal redPrimasCoa1) {	this.redPrimasCoa1 = redPrimasCoa1;	}

	public BigDecimal getRedPrimasCoa2() {	return redPrimasCoa2;	}

	public void setRedPrimasCoa2(BigDecimal redPrimasCoa2) {	this.redPrimasCoa2 = redPrimasCoa2;	}

	public BigDecimal getRedPrimasCoa3() {	return redPrimasCoa3;	}

	public void setRedPrimasCoa3(BigDecimal redPrimasCoa3) {	this.redPrimasCoa3 = redPrimasCoa3;	}

	public BigDecimal getRedPrimasCoa4() {	return redPrimasCoa4;	}

	public void setRedPrimasCoa4(BigDecimal redPrimasCoa4) {	this.redPrimasCoa4 = redPrimasCoa4;	}

	public BigDecimal getRedPrimasCoa5() {	return redPrimasCoa5;	}

	public void setRedPrimasCoa5(BigDecimal redPrimasCoa5) {	this.redPrimasCoa5 = redPrimasCoa5;	}

	public BigDecimal getRedPrimasCoa6() {	return redPrimasCoa6;	}

	public void setRedPrimasCoa6(BigDecimal redPrimasCoa6) {	this.redPrimasCoa6 = redPrimasCoa6;	}

	public BigDecimal getRedTransitoriaCoa1() {	return redTransitoriaCoa1;	}

	public void setRedTransitoriaCoa1(BigDecimal redTransitoriaCoa1) {	this.redTransitoriaCoa1 = redTransitoriaCoa1;	}

	public BigDecimal getRedTransitoriaCoa2() {	return redTransitoriaCoa2;	}

	public void setRedTransitoriaCoa2(BigDecimal redTransitoriaCoa2) {	this.redTransitoriaCoa2 = redTransitoriaCoa2;	}

	public BigDecimal getRedTransitoriaCoa3() {	return redTransitoriaCoa3;	}

	public void setRedTransitoriaCoa3(BigDecimal redTransitoriaCoa3) {	this.redTransitoriaCoa3 = redTransitoriaCoa3;	}

	public BigDecimal getRedTransitoriaCoa4() {	return redTransitoriaCoa4;	}

	public void setRedTransitoriaCoa4(BigDecimal redTransitoriaCoa4) {	this.redTransitoriaCoa4 = redTransitoriaCoa4;	}

	public BigDecimal getRedTransitoriaCoa5() {	return redTransitoriaCoa5;	}

	public void setRedTransitoriaCoa5(BigDecimal redTransitoriaCoa5) {	this.redTransitoriaCoa5 = redTransitoriaCoa5;	}

	public BigDecimal getRedTransitoriaCoa6() {	return redTransitoriaCoa6;	}

	public void setRedTransitoriaCoa6(BigDecimal redTransitoriaCoa6) {	this.redTransitoriaCoa6 = redTransitoriaCoa6;	}

	public BigDecimal getRtoNetoCoa1() {	return rtoNetoCoa1;	}

	public void setRtoNetoCoa1(BigDecimal rtoNetoCoa1) {	this.rtoNetoCoa1 = rtoNetoCoa1;	}

	public BigDecimal getRtoNetoCoa2() {	return rtoNetoCoa2;	}

	public void setRtoNetoCoa2(BigDecimal rtoNetoCoa2) {	this.rtoNetoCoa2 = rtoNetoCoa2;	}

	public BigDecimal getRtoNetoCoa3() {	return rtoNetoCoa3;	}

	public void setRtoNetoCoa3(BigDecimal rtoNetoCoa3) {	this.rtoNetoCoa3 = rtoNetoCoa3;	}

	public BigDecimal getRtoNetoCoa4() {	return rtoNetoCoa4;	}

	public void setRtoNetoCoa4(BigDecimal rtoNetoCoa4) {	this.rtoNetoCoa4 = rtoNetoCoa4;	}

	public BigDecimal getRtoNetoCoa5() {	return rtoNetoCoa5;	}

	public void setRtoNetoCoa5(BigDecimal rtoNetoCoa5) {	this.rtoNetoCoa5 = rtoNetoCoa5;	}

	public BigDecimal getRtoNetoCoa6() {	return rtoNetoCoa6;	}

	public void setRtoNetoCoa6(BigDecimal rtoNetoCoa6) {	this.rtoNetoCoa6 = rtoNetoCoa6;	}

	public BigDecimal getRetencionCoa1() {	return retencionCoa1;	}

	public void setRetencionCoa1(BigDecimal retencionCoa1) {	this.retencionCoa1 = retencionCoa1;	}

	public BigDecimal getRetencionCoa2() {	return retencionCoa2;	}

	public void setRetencionCoa2(BigDecimal retencionCoa2) {	this.retencionCoa2 = retencionCoa2;	}

	public BigDecimal getRetencionCoa3() {	return retencionCoa3;	}

	public void setRetencionCoa3(BigDecimal retencionCoa3) {	this.retencionCoa3 = retencionCoa3;	}

	public BigDecimal getRetencionCoa4() {	return retencionCoa4;	}

	public void setRetencionCoa4(BigDecimal retencionCoa4) {	this.retencionCoa4 = retencionCoa4;	}

	public BigDecimal getRetencionCoa5() {	return retencionCoa5;	}

	public void setRetencionCoa5(BigDecimal retencionCoa5) {	this.retencionCoa5 = retencionCoa5;	}

	public BigDecimal getRetencionCoa6() {	return retencionCoa6;	}

	public void setRetencionCoa6(BigDecimal retencionCoa6) {	this.retencionCoa6 = retencionCoa6;	}

	public BigDecimal getCompenCoa1() {	return compenCoa1;	}

	public void setCompenCoa1(BigDecimal compenCoa1) {	this.compenCoa1 = compenCoa1;	}

	public BigDecimal getCompenCoa2() {	return compenCoa2;	}

	public void setCompenCoa2(BigDecimal compenCoa2) {	this.compenCoa2 = compenCoa2;	}

	public BigDecimal getCompenCoa3() {	return compenCoa3;	}

	public void setCompenCoa3(BigDecimal compenCoa3) {	this.compenCoa3 = compenCoa3;	}

	public BigDecimal getCompenCoa4() {	return compenCoa4;	}

	public void setCompenCoa4(BigDecimal compenCoa4) {	this.compenCoa4 = compenCoa4;	}

	public BigDecimal getCompenCoa5() {	return compenCoa5;	}

	public void setCompenCoa5(BigDecimal compenCoa5) {	this.compenCoa5 = compenCoa5;	}

	public BigDecimal getCompenCoa6() {	return compenCoa6;	}

	public void setCompenCoa6(BigDecimal compenCoa6) {	this.compenCoa6 = compenCoa6;	}
	// R&V Correccion 03/08/2017-1-3 FIN

	/**
	 * Inicializamos el pagotot, con valor ENBLANCO
	 */
	private String pagotot = ENBLANCO;

	/**
	 * Inicializamos el fecBDGICap, con valor ENBLANCO
	 */
	private String fecBDGICap = ENBLANCO;
	
	/**
	 * Inicializamos el fecBDGIComp1, con valor ENBLANCO
	 */
	private String fecBDGIComp1 = ENBLANCO;
	
	/**
	 * Inicializamos el fecBDGICap, con valor ENBLANCO
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
	 * Inicializamos el usuarioC, con valor ENBLANCO
	 */
	private String usuarioC = ENBLANCO;

	/**
	 * Inicializamos el observacionesG, con valor ENBLANCO
	 */
	private String observacionesG = ENBLANCO;

	/**
	 * Inicializamos el impInteresPendiente, con valor ENBLANCO
	 */
	private BigDecimal impInteresPendiente = new BigDecimal ( 0 );

	/**
	 * Inicializamos el fecVencimientoCap, con valor ENBLANCO
	 */
	private String fecVencimientoCap = ENBLANCO;

	/**
	 * Inicializamos el tipImpuestoCap, con valor ENBLANCO
	 */
	private String tipImpuestoCap = ENBLANCO;

	/**
	 * Inicializamos el fecCalculo, con valor ENBLANCO
	 */
	private String fecCalculo = ENBLANCO;

	/**
	 * Inicializamos el lugEnvio, con valor ENBLANCO
	 */
	private String lugEnvio = ENBLANCO;

	/**
	 * Inicializamos el duracion, con valor ENBLANCO
	 */
	private String duracion = ENBLANCO;

	/**
	 * Inicializamos el fecEmision, con valor ENBLANCO
	 */
	private String fecEmision = ENBLANCO;
	
	/**
	 * Inicializamos el eximido
	 */
	private String eximido = ENBLANCO; //R&V - CU009

	/**
	 * Inicializamos el tipSituacion, con valor ENBLANCO
	 */
	private String tipSituacion = ENBLANCO;
	
	public String getTipSituacion() {
		return tipSituacion;
	}

	public void setTipSituacion(String tipSituacion) {
		this.tipSituacion = tipSituacion;
	}

	public String getFecAnul() {
		return fecAnul;
	}

	public void setFecAnul(String fecAnul) {
		this.fecAnul = fecAnul;
	}

	/**
	 * Inicializamos el fecAnul, con valor ENBLANCO
	 */
	private String fecAnul = ENBLANCO;
	
	/* INICIO  MU-2015-041869*/
	/**
	 * Inicializamos el anio, con valor ENBLANCO
	 */
	private BigDecimal aniofiscal = new BigDecimal ( 0 );
	/* FIN  
	 * MU-2015-041869*/
		
	/**
	 * @return el fecVencimientoCap
	 */
	public String getFecVencimientoCap () {
		return fecVencimientoCap;
	}

	/**
	 * @param fecVencimientoCap
	 *            el fecVencimientoCap a establecer
	 */
	public void setFecVencimientoCap ( String fecVencimientoCap ) {
		this.fecVencimientoCap = fecVencimientoCap;
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
	 * @return antAnio
	 */
	public BigDecimal getAntAnio () {
		return antAnio;
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
	 * @return el nifCif
	 */
	public String getNifCif () {
		return nifCif;
	}

	/**
	 * @param nifCif
	 *            el nifCif a establecer
	 */
	public void setNifCif ( String nifCif ) {
		this.nifCif = nifCif;
	}

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
	 * @return el numRegistros
	 */
	public String getNumRegistros () {
		return numRegistros;
	}

	/**
	 * @param numRegistros
	 *            el numRegistros a establecer
	 */
	public void setNumRegistros ( String numRegistros ) {
		this.numRegistros = numRegistros;
	}

	/**
	 * @return el operacion
	 */
	public String getOperacion () {
		return operacion;
	}

	/**
	 * @param operacion
	 *            el operacion a establecer
	 */
	public void setOperacion ( String operacion ) {
		this.operacion = operacion;
	}

	/**
	 * @return el paginacion
	 */
	public String getPaginacion () {
		return paginacion;
	}

	/**
	 * @param paginacion
	 *            el paginacion a establecer
	 */
	public void setPaginacion ( String paginacion ) {
		this.paginacion = paginacion;
	}

	/**
	 * @return el poliza
	 */
	public String getPoliza () {
		return poliza;
	}

	/**
	 * @param poliza
	 *            el poliza a establecer
	 */
	public void setPoliza ( String poliza ) {
		this.poliza = poliza;
	}

	/**
	 * @return el ramo
	 */
	public String getRamo () {
		return ramo;
	}

	/**
	 * @param ramo
	 *            el ramo a establecer
	 */
	public void setRamo ( String ramo ) {
		this.ramo = ramo;
	}

	/**
	 * @return el rdAnioExp
	 */
	public String getRdAnioExp () {
		return rdAnioExp;
	}

	/**
	 * @param rdAnioExp
	 *            el rdAnioExp a establecer
	 */
	public void setRdAnioExp ( String rdAnioExp ) {
		this.rdAnioExp = rdAnioExp;
	}

	/**
	 * @return el rdNifCif
	 */
	public String getRdNifCif () {
		return rdNifCif;
	}

	/**
	 * @param rdNifCif
	 *            el rdNifCif a establecer
	 */
	public void setRdNifCif ( String rdNifCif ) {
		this.rdNifCif = rdNifCif;
	}

	/**
	 * @return el rdPoliza
	 */
	public String getRdPoliza () {
		return rdPoliza;
	}

	/**
	 * @param rdPoliza
	 *            el rdPoliza a establecer
	 */
	public void setRdPoliza ( String rdPoliza ) {
		this.rdPoliza = rdPoliza;
	}

	/**
	 * @return el registros
	 */
	public String getRegistros () {
		return registros;
	}

	/**
	 * @param registros
	 *            el registros a establecer
	 */
	public void setRegistros ( String registros ) {
		this.registros = registros;
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
	 * @return el tipBusqueda
	 */
	public String getTipBusqueda () {
		return tipBusqueda;
	}

	/**
	 * @param tipBusqueda
	 *            el tipBusqueda a establecer
	 */
	public void setTipBusqueda ( String tipBusqueda ) {
		this.tipBusqueda = tipBusqueda;
	}

	/**
	 * @return el usuario
	 */
	public J000J000Usuario getUsuario () {
		return usuario;
	}

	/**
	 * @param usuario
	 *            el usuario a establecer
	 */
	public void setUsuario ( J000J000Usuario usuario ) {
		this.usuario = usuario;
	}

	/**
	 * @return el anioPoliza
	 */
	public String getAnioPoliza () {
		return anioPoliza;
	}

	/**
	 * @param anioPoliza
	 *            el anioPoliza a establecer
	 */
	public void setAnioPoliza ( String anioPoliza ) {
		this.anioPoliza = anioPoliza;
	}

	/**
	 * @return el numPoliza
	 */
	public String getNumPoliza () {
		return numPoliza;
	}

	/**
	 * @param numPoliza
	 *            el numPoliza a establecer
	 */
	public void setNumPoliza ( String numPoliza ) {
		this.numPoliza = numPoliza;
	}

	/**
	 * @return el anio
	 */
	public BigDecimal getAnio () {
		return anio;
	}

	/**
	 * @param anio
	 *            el anio a establecer
	 */
	public void setAnio ( BigDecimal anio ) {
		this.anio = anio;
	}

	/**
	 * @return el antExpediente
	 */
	public BigDecimal getAntExpediente () {
		return antExpediente;
	}

	/**
	 * @return el proAnio
	 */
	public BigDecimal getProAnio () {
		return proAnio;
	}

	/**
	 * @param proAnio
	 *            el proAnio a establecer
	 */
	public void setProAnio ( BigDecimal proAnio ) {
		this.proAnio = proAnio;
	}

	/**
	 * @param antAnio
	 *            el antAnio a establecer
	 */
	public void setAntAnio ( BigDecimal antAnio ) {
		this.antAnio = antAnio;
	}

	/**
	 * @return el codCoA1
	 */
	public String getCodCoA1 () {
		return codCoA1;
	}

	/**
	 * @param codCoA1
	 *            el codCoA1 a establecer
	 */
	public void setCodCoA1 ( String codCoA1 ) {
		this.codCoA1 = codCoA1;
	}

	/**
	 * @return el codCoA2
	 */
	public String getCodCoA2 () {
		return codCoA2;
	}

	/**
	 * @param codCoA2
	 *            el codCoA2 a establecer
	 */
	public void setCodCoA2 ( String codCoA2 ) {
		this.codCoA2 = codCoA2;
	}

	/**
	 * @return el codCoA3
	 */
	public String getCodCoA3 () {
		return codCoA3;
	}

	/**
	 * @param codCoA3
	 *            el codCoA3 a establecer
	 */
	public void setCodCoA3 ( String codCoA3 ) {
		this.codCoA3 = codCoA3;
	}

	/**
	 * @return el codCoA4
	 */
	public String getCodCoA4 () {
		return codCoA4;
	}

	/**
	 * @param codCoA4
	 *            el codCoA4 a establecer
	 */
	public void setCodCoA4 ( String codCoA4 ) {
		this.codCoA4 = codCoA4;
	}

	/**
	 * @return el codCoA5
	 */
	public String getCodCoA5 () {
		return codCoA5;
	}

	/**
	 * @param codCoA5
	 *            el codCoA5 a establecer
	 */
	public void setCodCoA5 ( String codCoA5 ) {
		this.codCoA5 = codCoA5;
	}

	/**
	 * @return el codCoA6
	 */
	public String getCodCoA6 () {
		return codCoA6;
	}

	/**
	 * @param codCoA6
	 *            el codCoA6 a establecer
	 */
	public void setCodCoA6 ( String codCoA6 ) {
		this.codCoA6 = codCoA6;
	}

	/**
	 * @return el fecAnulada
	 */
	public String getFecAnulada () {
		return fecAnulada;
	}

	/**
	 * @param fecAnulada
	 *            el fecAnulada a establecer
	 */
	public void setFecAnulada ( String fecAnulada ) {
		this.fecAnulada = fecAnulada;
	}

	/**
	 * @return el fecCemiComp
	 */
	public String getFecCemiComp () {
		return fecCemiComp;
	}

	/**
	 * @param fecCemiComp
	 *            el fecCemiComp a establecer
	 */
	public void setFecCemiComp ( String fecCemiComp ) {
		this.fecCemiComp = fecCemiComp;
	}

	/**
	 * @return el fecEfecto
	 */
	public String getFecEfecto () {
		return fecEfecto;
	}

	/**
	 * @param fecEfecto
	 *            el fecEfecto a establecer
	 */
	public void setFecEfecto ( String fecEfecto ) {
		this.fecEfecto = fecEfecto;
	}

	/**
	 * @return el fecEmisionCap
	 */
	public String getFecEmisionCap () {
		return fecEmisionCap;
	}

	/**
	 * @param fecEmisionCap
	 *            el fecEmisionCap a establecer
	 */
	public void setFecEmisionCap ( String fecEmisionCap ) {
		this.fecEmisionCap = fecEmisionCap;
	}

	/**
	 * @return el fecModifica
	 */
	public String getFecModifica () {
		return fecModifica;
	}

	/**
	 * @param fecModifica
	 *            el fecModifica a establecer
	 */
	public void setFecModifica ( String fecModifica ) {
		this.fecModifica = fecModifica;
	}

	/**
	 * @return el fecPagComp
	 */
	public String getFecPagComp () {
		return fecPagComp;
	}

	/**
	 * @param fecPagComp
	 *            el fecPagComp a establecer
	 */
	public void setFecPagComp ( String fecPagComp ) {
		this.fecPagComp = fecPagComp;
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
	 * @return el fecPagret
	 */
	public String getFecPagret () {
		return fecPagret;
	}

	/**
	 * @param fecPagret
	 *            el fecPagret a establecer
	 */
	public void setFecPagret ( String fecPagret ) {
		this.fecPagret = fecPagret;
	}

	/**
	 * @return el fecPagretCom
	 */
	public String getFecPagretCom () {
		return fecPagretCom;
	}

	/**
	 * @param fecPagretCom
	 *            el fecPagretCom a establecer
	 */
	public void setFecPagretCom ( String fecPagretCom ) {
		this.fecPagretCom = fecPagretCom;
	}

	/**
	 * @return el fecReciboCap
	 */
	public String getFecReciboCap () {
		return fecReciboCap;
	}

	/**
	 * @param fecReciboCap
	 *            el fecReciboCap a establecer
	 */
	public void setFecReciboCap ( String fecReciboCap ) {
		this.fecReciboCap = fecReciboCap;
	}

	/**
	 * @return el iliqComp
	 */
	public BigDecimal getIliqComp () {
		return iliqComp;
	}

	/**
	 * @param iliqComp
	 *            el iliqComp a establecer
	 */
	public void setIliqComp ( BigDecimal iliqComp ) {
		this.iliqComp = iliqComp;
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
	 * @return el impBeneficios
	 */
	public BigDecimal getImpBeneficios () {
		return impBeneficios;
	}

	/**
	 * @param impBeneficios
	 *            el impBeneficios a establecer
	 */
	public void setImpBeneficios ( BigDecimal impBeneficios ) {
		this.impBeneficios = impBeneficios;
	}

	/**
	 * @return el impCobroInt
	 */
	public BigDecimal getImpCobroInt () {
		return impCobroInt;
	}

	/**
	 * @param impCobroInt
	 *            el impCobroInt a establecer
	 */
	public void setImpCobroInt ( BigDecimal impCobroInt ) {
		this.impCobroInt = impCobroInt;
	}

	/**
	 * @return el impCompensatoria
	 */
	public BigDecimal getImpCompensatoria () {
		return impCompensatoria;
	}

	/**
	 * @param impCompensatoria
	 *            el impCompensatoria a establecer
	 */
	public void setImpCompensatoria ( BigDecimal impCompensatoria ) {
		this.impCompensatoria = impCompensatoria;
	}

	/**
	 * @return el impliqCap
	 */
	public BigDecimal getImpliqCap () {
		return impliqCap;
	}

	/**
	 * @param impliqCap
	 *            el impliqCap a establecer
	 */
	public void setImpliqCap ( BigDecimal impliqCap ) {
		this.impliqCap = impliqCap;
	}

	/**
	 * @return el impPrimaRec
	 */
	public BigDecimal getImpPrimaRec () {
		return impPrimaRec;
	}

	/**
	 * @param impPrimaRec
	 *            el impPrimaRec a establecer
	 */
	public void setImpPrimaRec ( BigDecimal impPrimaRec ) {
		this.impPrimaRec = impPrimaRec;
	}

	/**
	 * @return el impRedPriCap
	 */
	public BigDecimal getImpRedPriCap () {
		return impRedPriCap;
	}

	/**
	 * @param impRedPriCap
	 *            el impRedPriCap a establecer
	 */
	public void setImpRedPriCap ( BigDecimal impRedPriCap ) {
		this.impRedPriCap = impRedPriCap;
	}

	/**
	 * @param impretCap
	 *            el impretCap a establecer
	 */
	public void setImpretCap ( BigDecimal impretCap ) {
		this.impretCap = impretCap;
	}

	/**
	 * @return el impriMareComp
	 */
	public BigDecimal getImpriMareComp () {
		return impriMareComp;
	}

	/**
	 * @param impriMareComp
	 *            el impriMareComp a establecer
	 */
	public void setImpriMareComp ( BigDecimal impriMareComp ) {
		this.impriMareComp = impriMareComp;
	}

	/**
	 * @return el impRtonetoCap
	 */
	public BigDecimal getImpRtonetoCap () {
		return impRtonetoCap;
	}

	/**
	 * @param impRtonetoCap
	 *            el impRtonetoCap a establecer
	 */
	public void setImpRtonetoCap ( BigDecimal impRtonetoCap ) {
		this.impRtonetoCap = impRtonetoCap;
	}

	/**
	 * @return el impRtorintegrcap
	 */
	public BigDecimal getImpRtorintegrcap () {
		return impRtorintegrcap;
	}

	/**
	 * @param impRtorintegrcap
	 *            el impRtorintegrcap a establecer
	 */
	public void setImpRtorintegrcap ( BigDecimal impRtorintegrcap ) {
		this.impRtorintegrcap = impRtorintegrcap;
	}

	/**
	 * @return el iretComp
	 */
	public BigDecimal getIretComp () {
		return iretComp;
	}

	/**
	 * @param iretComp
	 *            el iretComp a establecer
	 */
	public void setIretComp ( BigDecimal iretComp ) {
		this.iretComp = iretComp;
	}

	/**
	 * @return el irTonetComp
	 */
	public BigDecimal getIrTonetComp () {
		return irTonetComp;
	}

	/**
	 * @param irTonetComp
	 *            el irTonetComp a establecer
	 */
	public void setIrTonetComp ( BigDecimal irTonetComp ) {
		this.irTonetComp = irTonetComp;
	}

	/**
	 * @return el lugarEnvio
	 */
	public String getLugarEnvio () {
		return lugarEnvio;
	}

	/**
	 * @param lugarEnvio
	 *            el lugarEnvio a establecer
	 */
	public void setLugarEnvio ( String lugarEnvio ) {
		this.lugarEnvio = lugarEnvio;
	}

	/**
	 * @return el nif1
	 */
	public String getNif1 () {
		return nif1;
	}

	/**
	 * @param nif1
	 *            el nif1 a establecer
	 */
	public void setNif1 ( String nif1 ) {
		this.nif1 = nif1;
	}

	/**
	 * @return el nif2
	 */
	public String getNif2 () {
		return nif2;
	}

	/**
	 * @param nif2
	 *            el nif2 a establecer
	 */
	public void setNif2 ( String nif2 ) {
		this.nif2 = nif2;
	}

	/**
	 * @return el regional
	 */
	public String getRegional () {
		return regional;
	}

	/**
	 * @param regional
	 *            el regional a establecer
	 */
	public void setRegional ( String regional ) {
		this.regional = regional;
	}

	/**
	 * @return el situacion
	 */
	public String getSituacion () {
		return situacion;
	}

	/**
	 * @param situacion
	 *            el situacion a establecer
	 */
	public void setSituacion ( String situacion ) {
		this.situacion = situacion;
	}

	/**
	 * @return el cartera
	 */
	public String getCartera () {
		return cartera;
	}

	/**
	 * @param cartera
	 *            el cartera a establecer
	 */
	public void setCartera ( String cartera ) {
		this.cartera = cartera;
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
	 * @return el observacionesG
	 */
	public String getObservacionesG () {
		return observacionesG;
	}

	/**
	 * @param observacionesG
	 *            el observacionesG a establecer
	 */
	public void setObservacionesG ( String observacionesG ) {
		this.observacionesG = observacionesG;
	}

	/**
	 * @return el oficina
	 */
	public String getOficina () {
		return oficina;
	}

	/**
	 * @param oficina
	 *            el oficina a establecer
	 */
	public void setOficina ( String oficina ) {
		this.oficina = oficina;
	}

	/**
	 * @return el pendiente
	 */
	public BigDecimal getPendiente () {
		return pendiente;
	}

	/**
	 * @param pendiente
	 *            el pendiente a establecer
	 */
	public void setPendiente ( BigDecimal pendiente ) {
		this.pendiente = pendiente;
	}

	/**
	 * @return el persona1
	 */
	public BigDecimal getPersona1 () {
		return persona1;
	}

	/**
	 * @param persona1
	 *            el persona1 a establecer
	 */
	public void setPersona1 ( BigDecimal persona1 ) {
		this.persona1 = persona1;
	}

	/**
	 * @return el persona2
	 */
	public BigDecimal getPersona2 () {
		return persona2;
	}

	/**
	 * @param persona2
	 *            el persona2 a establecer
	 */
	public void setPersona2 ( BigDecimal persona2 ) {
		this.persona2 = persona2;
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
	 * @return el residente1
	 */
	public String getResidente1 () {
		return residente1;
	}

	/**
	 * @param residente1
	 *            el residente1 a establecer
	 */
	public void setResidente1 ( String residente1 ) {
		this.residente1 = residente1;
	}

	/**
	 * @return el residente2
	 */
	public String getResidente2 () {
		return residente2;
	}

	/**
	 * @param residente2
	 *            el residente2 a establecer
	 */
	public void setResidente2 ( String residente2 ) {
		this.residente2 = residente2;
	}

	/**
	 * @return el tipoPers2
	 */
	public String getTipoPers2 () {
		return tipoPers2;
	}

	/**
	 * @param tipoPers2
	 *            el tipoPers2 a establecer
	 */
	public void setTipoPers2 ( String tipoPers2 ) {
		this.tipoPers2 = tipoPers2;
	}

	/**
	 * @return el usuarioC
	 */
	public String getUsuarioC () {
		return usuarioC;
	}

	/**
	 * @param usuarioC
	 *            el usuarioC a establecer
	 */
	public void setUsuarioC ( String usuarioC ) {
		this.usuarioC = usuarioC;
	}

	/**
	 * @return el subPoliza
	 */
	public BigDecimal getSubPoliza () {
		return subPoliza;
	}

	/**
	 * @param subPoliza
	 *            el subPoliza a establecer
	 */
	public void setSubPoliza ( BigDecimal subPoliza ) {
		this.subPoliza = subPoliza;
	}

	/**
	 * @return el tipImpuest
	 */
	public String getTipImpuest () {
		return tipImpuest;
	}

	/**
	 * @param tipImpuest
	 *            el tipImpuest a establecer
	 */
	public void setTipImpuest ( String tipImpuest ) {
		this.tipImpuest = tipImpuest;
	}

	/**
	 * @return el tipImpuestComp
	 */
	public String getTipImpuestComp () {
		return tipImpuestComp;
	}

	/**
	 * @param tipImpuestComp
	 *            el tipImpuestComp a establecer
	 */
	public void setTipImpuestComp ( String tipImpuestComp ) {
		this.tipImpuestComp = tipImpuestComp;
	}

	/**
	 * @return el tipoRescate
	 */
	public String getTipoRescate () {
		return tipoRescate;
	}

	/**
	 * @param tipoRescate
	 *            el tipoRescate a establecer
	 */
	public void setTipoRescate ( String tipoRescate ) {
		this.tipoRescate = tipoRescate;
	}

	/**
	 * @return el certificado
	 */
	public BigDecimal getCertificado () {
		return certificado;
	}

	/**
	 * @param certificado
	 *            el certificado a establecer
	 */
	public void setCertificado ( BigDecimal certificado ) {
		this.certificado = certificado;
	}

	/**
	 * @return el modalidad
	 */
	public BigDecimal getModalidad () {
		return modalidad;
	}

	/**
	 * @param modalidad
	 *            el modalidad a establecer
	 */
	public void setModalidad ( BigDecimal modalidad ) {
		this.modalidad = modalidad;
	}

	/**
	 * @return el impRedpriComp
	 */
	public BigDecimal getImpRedpriComp () {
		return impRedpriComp;
	}

	/**
	 * @param impRedpriComp
	 *            el impRedpriComp a establecer
	 */
	public void setImpRedpriComp ( BigDecimal impRedpriComp ) {
		this.impRedpriComp = impRedpriComp;
	}

	/**
	 * @return el porretComp
	 */
	public BigDecimal getPorretComp () {
		return porretComp;
	}

	/**
	 * @return el impretCap
	 */
	public BigDecimal getImpretCap () {
		return impretCap;
	}

	/**
	 * @return el pagotot
	 */
	public String getPagotot () {
		return pagotot;
	}

	/**
	 * @param pagotot
	 *            el pagotot a establecer
	 */
	public void setPagotot ( String pagotot ) {
		this.pagotot = pagotot;
	}

	/**
	 * @param porretComp
	 *            el porretComp a establecer
	 */
	public void setPorretComp ( BigDecimal porretComp ) {
		this.porretComp = porretComp;
	}

	/**
	 * @return el porretCap
	 */
	public BigDecimal getPorretCap () {
		return porretCap;
	}

	/**
	 * @param porretCap
	 *            el porretCap a establecer
	 */
	public void setPorretCap ( BigDecimal porretCap ) {
		this.porretCap = porretCap;
	}

	/**
	 * @return el impRedTranCap
	 */
	public BigDecimal getImpRedTranCap () {
		return impRedTranCap;
	}

	/**
	 * @param impRedTranCap
	 *            el impRedTranCap a establecer
	 */
	public void setImpRedTranCap ( BigDecimal impRedTranCap ) {
		this.impRedTranCap = impRedTranCap;
	}

	/**
	 * @return el impRedTranComp
	 */
	public BigDecimal getImpRedTranComp () {
		return impRedTranComp;
	}

	/**
	 * @param impRedTranComp
	 *            el impRedTranComp a establecer
	 */
	public void setImpRedTranComp ( BigDecimal impRedTranComp ) {
		this.impRedTranComp = impRedTranComp;
	}

	/**
	 * @return el tipoPers1
	 */
	public String getTipoPers1 () {
		return tipoPers1;
	}

	/**
	 * @param tipoPers1
	 *            el tipoPers1 a establecer
	 */
	public void setTipoPers1 ( String tipoPers1 ) {
		this.tipoPers1 = tipoPers1;
	}

	/**
	 * @return el porCoA1
	 */
	public BigDecimal getPorCoA1 () {
		return porCoA1;
	}

	/**
	 * @param porCoA1
	 *            el porCoA1 a establecer
	 */
	public void setPorCoA1 ( BigDecimal porCoA1 ) {
		this.porCoA1 = porCoA1;
	}

	/**
	 * @return el porCoA2
	 */
	public BigDecimal getPorCoA2 () {
		return porCoA2;
	}

	/**
	 * @param porCoA2
	 *            el porCoA2 a establecer
	 */
	public void setPorCoA2 ( BigDecimal porCoA2 ) {
		this.porCoA2 = porCoA2;
	}

	/**
	 * @return el porCoA3
	 */
	public BigDecimal getPorCoA3 () {
		return porCoA3;
	}

	/**
	 * @param porCoA3
	 *            el porCoA3 a establecer
	 */
	public void setPorCoA3 ( BigDecimal porCoA3 ) {
		this.porCoA3 = porCoA3;
	}

	/**
	 * @return el porCoA4
	 */
	public BigDecimal getPorCoA4 () {
		return porCoA4;
	}

	/**
	 * @param porCoA4
	 *            el porCoA4 a establecer
	 */
	public void setPorCoA4 ( BigDecimal porCoA4 ) {
		this.porCoA4 = porCoA4;
	}

	/**
	 * @return el porCoA5
	 */
	public BigDecimal getPorCoA5 () {
		return porCoA5;
	}

	/**
	 * @param porCoA5
	 *            el porCoA5 a establecer
	 */
	public void setPorCoA5 ( BigDecimal porCoA5 ) {
		this.porCoA5 = porCoA5;
	}

	/**
	 * @return el porCoA6
	 */
	public BigDecimal getPorCoA6 () {
		return porCoA6;
	}

	/**
	 * @param porCoA6
	 *            el porCoA6 a establecer
	 */
	public void setPorCoA6 ( BigDecimal porCoA6 ) {
		this.porCoA6 = porCoA6;
	}

	/**
	 * @return el impRtointComp
	 */
	public BigDecimal getImpRtointComp () {
		return impRtointComp;
	}

	/**
	 * @param impRtointComp
	 *            el impRtointComp a establecer
	 */
	public void setImpRtointComp ( BigDecimal impRtointComp ) {
		this.impRtointComp = impRtointComp;
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
	 * @return el impComp
	 */
	public BigDecimal getImpComp () {
		return impComp;
	}

	/**
	 * @param impComp
	 *            el impComp a establecer
	 */
	public void setImpComp ( BigDecimal impComp ) {
		this.impComp = impComp;
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
	 * @return el listadoExp
	 */
	public List <Object> getListadoExp () {
		return listadoExp;
	}

	/**
	 * @param listadoExp
	 *            el listadoExp a establecer
	 */
	public void setListadoExp ( List <Object> listadoExp ) {
		this.listadoExp = listadoExp;
	}

	/**
	 * @param proExpediente
	 *            el proExpediente a establecer
	 */
	public void setProExpediente ( BigDecimal proExpediente ) {
		this.proExpediente = proExpediente;
	}

	/**
	 * @return el proExpediente
	 */
	public BigDecimal getProExpediente () {
		return proExpediente;
	}

	/**
	 * @param antExpediente
	 *            el antExpediente a establecer
	 */
	public void setAntExpediente ( BigDecimal antExpediente ) {
		this.antExpediente = antExpediente;
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
	 * @return el desSituacion
	 */
	public String getDesSituacion () {
		return desSituacion;
	}

	/**
	 * @param desSituacion
	 *            el desSituacion a establecer
	 */
	public void setDesSituacion ( String desSituacion ) {
		this.desSituacion = desSituacion;
	}

	/**
	 * @return el impInteresPendiente
	 */
	public BigDecimal getImpInteresPendiente () {
		return impInteresPendiente;
	}

	/**
	 * @param impInteresPendiente
	 *            el impInteresPendiente a establecer
	 */
	public void setImpInteresPendiente ( BigDecimal impInteresPendiente ) {
		this.impInteresPendiente = impInteresPendiente;
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
	 * @return el fecCalculo
	 */
	public String getFecCalculo () {
		return fecCalculo;
	}

	/**
	 * @param fecCalculo
	 *            el fecCalculo a establecer
	 */
	public void setFecCalculo ( String fecCalculo ) {
		this.fecCalculo = fecCalculo;
	}

	/**
	 * @return el lugEnvio
	 */
	public String getLugEnvio () {
		return lugEnvio;
	}

	/**
	 * @param lugEnvio
	 *            el lugEnvio a establecer
	 */
	public void setLugEnvio ( String lugEnvio ) {
		this.lugEnvio = lugEnvio;
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
	 * @return el fecPagComp2
	 */
	public String getFecPagComp2 () {
		return fecPagComp2;
	}

	/**
	 * @param fecPagComp2
	 *            el fecPagComp2 a establecer
	 */
	public void setFecPagComp2 ( String fecPagComp2 ) {
		this.fecPagComp2 = fecPagComp2;
	}

	/**
	 * @return el impComp2
	 */
	public BigDecimal getImpComp2 () {
		return impComp2;
	}

	/**
	 * @param impComp2
	 *            el impComp2 a establecer
	 */
	public void setImpComp2 ( BigDecimal impComp2 ) {
		this.impComp2 = impComp2;
	}

	/**
	 * @return el fecCemiComp2
	 */
	public String getFecCemiComp2 () {
		return fecCemiComp2;
	}

	/**
	 * @param fecCemiComp2
	 *            el fecCemiComp2 a establecer
	 */
	public void setFecCemiComp2 ( String fecCemiComp2 ) {
		this.fecCemiComp2 = fecCemiComp2;
	}

	/**
	 * @return el tipImpuestComp2
	 */
	public String getTipImpuestComp2 () {
		return tipImpuestComp2;
	}

	/**
	 * @param tipImpuestComp2
	 *            el tipImpuestComp2 a establecer
	 */
	public void setTipImpuestComp2 ( String tipImpuestComp2 ) {
		this.tipImpuestComp2 = tipImpuestComp2;
	}

	/**
	 * @return el fecImpreComp2
	 */
	public String getFecImpreComp2 () {
		return fecImpreComp2;
	}

	/**
	 * @param fecImpreComp2
	 *            el fecImpreComp2 a establecer
	 */
	public void setFecImpreComp2 ( String fecImpreComp2 ) {
		this.fecImpreComp2 = fecImpreComp2;
	}

	/**
	 * @return el fecPagretCom2
	 */
	public String getFecPagretCom2 () {
		return fecPagretCom2;
	}

	/**
	 * @param fecPagretCom2
	 *            el fecPagretCom2 a establecer
	 */
	public void setFecPagretCom2 ( String fecPagretCom2 ) {
		this.fecPagretCom2 = fecPagretCom2;
	}

	/**
	 * @return el iliqComp2
	 */
	public BigDecimal getIliqComp2 () {
		return iliqComp2;
	}

	/**
	 * @param iliqComp2
	 *            el iliqComp2 a establecer
	 */
	public void setIliqComp2 ( BigDecimal iliqComp2 ) {
		this.iliqComp2 = iliqComp2;
	}

	/**
	 * @return el impRedpriComp2
	 */
	public BigDecimal getImpRedpriComp2 () {
		return impRedpriComp2;
	}

	/**
	 * @param impRedpriComp2
	 *            el impRedpriComp2 a establecer
	 */
	public void setImpRedpriComp2 ( BigDecimal impRedpriComp2 ) {
		this.impRedpriComp2 = impRedpriComp2;
	}

	/**
	 * @return el impRedTranComp2
	 */
	public BigDecimal getImpRedTranComp2 () {
		return impRedTranComp2;
	}

	/**
	 * @param impRedTranComp2
	 *            el impRedTranComp2 a establecer
	 */
	public void setImpRedTranComp2 ( BigDecimal impRedTranComp2 ) {
		this.impRedTranComp2 = impRedTranComp2;
	}

	/**
	 * @return el impRtointComp2
	 */
	public BigDecimal getImpRtointComp2 () {
		return impRtointComp2;
	}

	/**
	 * @param impRtointComp2
	 *            el impRtointComp2 a establecer
	 */
	public void setImpRtointComp2 ( BigDecimal impRtointComp2 ) {
		this.impRtointComp2 = impRtointComp2;
	}

	/**
	 * @return el iretComp2
	 */
	public BigDecimal getIretComp2 () {
		return iretComp2;
	}

	/**
	 * @param iretComp2
	 *            el iretComp2 a establecer
	 */
	public void setIretComp2 ( BigDecimal iretComp2 ) {
		this.iretComp2 = iretComp2;
	}

	/**
	 * @return el irTonetComp2
	 */
	public BigDecimal getIrTonetComp2 () {
		return irTonetComp2;
	}

	/**
	 * @param irTonetComp2
	 *            el irTonetComp2 a establecer
	 */
	public void setIrTonetComp2 ( BigDecimal irTonetComp2 ) {
		this.irTonetComp2 = irTonetComp2;
	}

	/**
	 * @return el porretComp2
	 */
	public BigDecimal getPorretComp2 () {
		return porretComp2;
	}

	/**
	 * @param porretComp2
	 *            el porretComp2 a establecer
	 */
	public void setPorretComp2 ( BigDecimal porretComp2 ) {
		this.porretComp2 = porretComp2;
	}

	
	//INICIO MODIFICACION EVERIS
	/**
	 * @return el selectedRow
	 */
	public String getSelectedRow() {
		return selectedRow;
	}

	/**
	 * @param selectedRow el selectedRow a establecer
	 */
	public void setSelectedRow(String selectedRow) {
		this.selectedRow = selectedRow;
	}

	/**
	 * @return el rdCertificado
	 */
	public String getRdCertificado () {
		return rdCertificado;
	}

	/**
	 * @param rdCertificado el rdCertificado a establecer
	 */
	public void setRdCertificado ( String rdCertificado ) {
		this.rdCertificado = rdCertificado;
	}

	/**
	 * @return el rdSubpoliza
	 */
	public String getRdSubpoliza () {
		return rdSubpoliza;
	}

	/**
	 * @param rdSubpoliza el rdSubpoliza a establecer
	 */
	public void setRdSubpoliza ( String rdSubpoliza ) {
		this.rdSubpoliza = rdSubpoliza;
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
	
	public String getTomador() {
		return tomador;
	}

	public void setTomador(String tomador) {
		this.tomador = tomador;
	}

	//FIN MODIFICACION EVERIS
	
	/* INICIO  MU-2015-041869*/
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
	/* FIN  MU-2015-041869*/
	
	// MU-2016-006664 - RAROALE - INI

	/**
	 * @return el impCoA1
	 */
	public BigDecimal getImpCoA1() {
		return impCoA1;
	}

	/**
	 * @param impCoA1 el impCoA1 a establecer
	 */
	public void setImpCoA1(BigDecimal impCoA1) {
		this.impCoA1 = impCoA1;
	}

	/**
	 * @return el impCoA2
	 */
	public BigDecimal getImpCoA2() {
		return impCoA2;
	}

	/**
	 * @param impCoA2 el impCoA2 a establecer
	 */
	public void setImpCoA2(BigDecimal impCoA2) {
		this.impCoA2 = impCoA2;
	}

	/**
	 * @return el impCoA3
	 */
	public BigDecimal getImpCoA3() {
		return impCoA3;
	}

	/**
	 * @param impCoA3 el impCoA3 a establecer
	 */
	public void setImpCoA3(BigDecimal impCoA3) {
		this.impCoA3 = impCoA3;
	}

	/**
	 * @return el impCoA4
	 */
	public BigDecimal getImpCoA4() {
		return impCoA4;
	}

	/**
	 * @param impCoA4 el impCoA4 a establecer
	 */
	public void setImpCoA4(BigDecimal impCoA4) {
		this.impCoA4 = impCoA4;
	}

	/**
	 * @return el impCoA5
	 */
	public BigDecimal getImpCoA5() {
		return impCoA5;
	}

	/**
	 * @param impCoA5 el impCoA5 a establecer
	 */
	public void setImpCoA5(BigDecimal impCoA5) {
		this.impCoA5 = impCoA5;
	}

	/**
	 * @return el impCoA6
	 */
	public BigDecimal getImpCoA6() {
		return impCoA6;
	}

	/**
	 * @param impCoA6 el impCoA6 a establecer
	 */
	public void setImpCoA6(BigDecimal impCoA6) {
		this.impCoA6 = impCoA6;
	}
	// MU-2016-006664 - RAROALE - FIN

	// MU-2016-006673 - RAROALE - INI
	/**
	 * @return el domicilio1
	 */
	public BigDecimal getDomicilio1() {
		return domicilio1;
	}

	/**
	 * @param domicilio1 el domicilio1 a establecer
	 */
	public void setDomicilio1(BigDecimal domicilio1) {
		this.domicilio1 = domicilio1;
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
	
	//R&V - CU009 - INICIO

	/**
	 *
	 * @return eximido
	 */
	public String getEximido() {
		return eximido;
	}

	/**
	 *
	 * @param eximido
	 */
	public void setEximido(String eximido) {
		this.eximido = eximido;
	}

	//R&V - CU009 - FIN
}
