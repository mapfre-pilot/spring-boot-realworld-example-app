/* MODIFICACION : MU-2016-006673
FECHA : MARZO 2016
DESCRIPCION: Se permite modificar y guardar en BBDD el kdomiclio del beneficiario
AUTOR : RAROALE */

/*MODIFICACION : MU-2016-006664
FECHA : MARZO 2016
DESCRIPCION: Se permite modificar y guardar en BBDD los importes de Coaseguros
AUTOR : RAROALE */


package com.mapfre.mavisa.wss372vencimientosmanuales.forms;

import java.util.Collections;
import java.util.List;
import java.util.Vector;
import org.apache.struts.action.ActionForm;

/**
 * Form bean for a Struts application.
 * 
 * @version 1.0 Versión inicial
 * @author everis
 */
public class J372J001BusquedaExpVenActionForm extends ActionForm

{
	
	/**
	 * Inicializamos el mostrarResultado
	 */
	private boolean mostrarResultado = false;
	
	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inicializamos el anio, con valor ENBLANCO
	 */
	private String anioSel = ENBLANCO;

	/**
	 * Inicializamos el expediente, con valor ENBLANCO
	 */
	private String expedienteSel = ENBLANCO;

	/**
	 * Inicializamos el poliza, con valor ENBLANCO
	 */
	private String polizaSel = ENBLANCO;
	
	/**
	 * Inicializamos el subpolizaSel
	 */
	/**
	 * Inicializamos el subpolizaSel
	 */
	private String subpolizaSel = ENBLANCO;
	
	/**
	 * Inicializamos el certificadoSel
	 */
	private String certificadoSel = ENBLANCO;

	/**
	 * Inicializamos el nifCif, con valor ENBLANCO
	 */
	private String nifCif = ENBLANCO;

	/**
	 * Inicializamos el nif2, con valor ENBLANCO
	 */
	private String nif2 = ENBLANCO;

	/**
	 * Inicializamos el nif1, con valor ENBLANCO
	 */
	private String nif1 = ENBLANCO;

	/**
	 * Inicializamos el anioPoliza, con valor ENBLANCO
	 */
	private String anioPoliza = ENBLANCO;

	/**
	 * Inicializamos el numPoliza, con valor ENBLANCO
	 */
	private String numPoliza = ENBLANCO;

	/**
	 * Inicializamos el paginacion, con valor ENBLANCO
	 */
	private String paginacion = ENBLANCO;

	/**
	 * Inicializamos el antExpediente, con valor ENBLANCO
	 */
	private String antExpediente = ENBLANCO;

	/**
	 * Inicializamos el antAnio, con valor ENBLANCO
	 */
	private String antAnio = ENBLANCO;

	/**
	 * Inicializamos el proExpediente, con valor ENBLANCO
	 */
	private String proExpediente = ENBLANCO;

	/**
	 * Inicializamos el proAnio, con valor ENBLANCO
	 */
	private String proAnio = ENBLANCO;

	/**
	 * Inicializamos el numRegistros, con valor ENBLANCO
	 */
	private String numRegistros = ENBLANCO;

	/**
	 * Inicializamos el fecCalculo, con valor ENBLANCO
	 */
	private String fecCalculo = ENBLANCO;

	/**
	 * Inicializamos el ramo, con valor ENBLANCO
	 */
	private String ramo = ENBLANCO;

	/**
	 * Inicializamos el registros, con valor ENBLANCO
	 */
	private String registros = ENBLANCO;

	/**
	 * Inicializamos el lugarEnvio, con valor ENBLANCO
	 */
	private String lugarEnvio = ENBLANCO;

	/**
	 * Inicializamos el listadoExp
	 */
	private List <Object> listadoExp;

	/**
	 * Inicializamos el operacion, con valor ENBLANCO
	 */
	private String operacion = ENBLANCO;

	/**
	 * Inicializamos el vectorMensajes
	 */
	private List <Object> vectorMensajes = Collections.synchronizedList ( new Vector <Object> () );

	/**
	 * Inicializamos el tipOperacion, con valor ENBLANCO
	 */
	private String tipOperacion = ENBLANCO;

	/**
	 * Inicializamos el retorno, con valor ENBLANCO
	 */
	private String retorno = ENBLANCO;

	/**
	 * Inicializamos el desRetorno, con valor ENBLANCO
	 */
	private String desRetorno = ENBLANCO;

	/**
	 * Inicializamos el NomPrograma, con valor ENBLANCO
	 */
	private String NomPrograma = ENBLANCO;

	/**
	 * Inicializamos el impComp1, con valor ENBLANCO
	 */
	private String impComp1 = ENBLANCO;

	/**
	 * Inicializamos el tipImpuestComp1, con valor ENBLANCO
	 */
	private String tipImpuestComp1 = ENBLANCO;

	/**
	 * Inicializamos el fecCemiComp1, con valor ENBLANCO
	 */
	private String fecCemiComp1 = ENBLANCO;

	/**
	 * Inicializamos el fecPagComp1, con valor ENBLANCO
	 */
	private String fecPagComp1 = ENBLANCO;

	/**
	 * Inicializamos el impRtointComp1, con valor ENBLANCO
	 */
	private String impRtointComp1 = ENBLANCO;

	/**
	 * Inicializamos el impRedpriComp1, con valor ENBLANCO
	 */
	private String impRedpriComp1 = ENBLANCO;

	/**
	 * Inicializamos el impRedTranComp1, con valor ENBLANCO
	 */
	private String impRedTranComp1 = ENBLANCO;

	/**
	 * Inicializamos el irTonetComp1, con valor ENBLANCO
	 */
	private String irTonetComp1 = ENBLANCO;

	/**
	 * Inicializamos el porretComp1, con valor ENBLANCO
	 */
	private String porretComp1 = ENBLANCO;

	/**
	 * Inicializamos el iretComp1, con valor ENBLANCO
	 */
	private String iretComp1 = ENBLANCO;

	/**
	 * Inicializamos el iliqComp1, con valor ENBLANCO
	 */
	private String iliqComp1= ENBLANCO;

	/**
	 * Inicializamos el fecImpreComp1, con valor ENBLANCO
	 */
	private String fecImpreComp1 = ENBLANCO;

	/**
	 * Inicializamos el fecPagretCom1, con valor ENBLANCO
	 */
	private String fecPagretComp1 = ENBLANCO;
	
	
	
	
	
	
	
	
	/**
	 * Inicializamos el impComp2, con valor ENBLANCO
	 */
	private String impComp2 = ENBLANCO;

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
	private String impRtointComp2 = ENBLANCO;

	/**
	 * Inicializamos el impRedpriComp2, con valor ENBLANCO
	 */
	private String impRedpriComp2 = ENBLANCO;

	/**
	 * Inicializamos el impRedTranComp2, con valor ENBLANCO
	 */
	private String impRedTranComp2 = ENBLANCO;

	/**
	 * Inicializamos el irTonetComp2, con valor ENBLANCO
	 */
	private String irTonetComp2 = ENBLANCO;

	/**
	 * Inicializamos el porretComp2, con valor ENBLANCO
	 */
	private String porretComp2 = ENBLANCO;

	/**
	 * Inicializamos el iretComp2, con valor ENBLANCO
	 */
	private String iretComp2 = ENBLANCO;

	/**
	 * Inicializamos el iliqComp2, con valor ENBLANCO
	 */
	private String iliqComp2 = ENBLANCO;

	/**
	 * Inicializamos el fecImpreComp2, con valor ENBLANCO
	 */
	private String fecImpreComp2 = ENBLANCO;

	/**
	 * Inicializamos el fecPagretCom2, con valor ENBLANCO
	 */
	private String fecPagretCom2 = ENBLANCO;


	//INICIO MODIFICACION EVERIS
	/**
	 * Inicializamos el selectedRow, con valor ENBLANCO
	 */
	private String selectedRow = ENBLANCO;
	
	/**
	 * Inicializamos el anio, con valor ENBLANCO
	 */
	private String anio = ENBLANCO;
	
	/**
	 * Inicializamos el expediente, con valor ENBLANCO
	 */
	private String expediente = ENBLANCO;
	
	/**
	 * Inicializamos el subPoliza, con valor ENBLANCO
	 */
	private String subPoliza = ENBLANCO;
	
	/**
	 * Inicializamos el certificado, con valor ENBLANCO
	 */
	private String certificado = ENBLANCO;
	
	/**
	 * Inicializamos el modalidad, con valor ENBLANCO
	 */
	private String modalidad = ENBLANCO;
	
	/**
	 * Inicializamos el canalCamp, con valor ENBLANCO
	 */
	private String canalCamp = ENBLANCO;
	
	/**
	 * Inicializamos el entidad, con valor ENBLANCO
	 */
	private String entidad = ENBLANCO;
	
	/**
	 * Inicializamos el duracion, con valor ENBLANCO
	 */
	private String duracion = ENBLANCO;
	
	/**
	 * Inicializamos el regional, con valor ENBLANCO
	 */
	private String regional = ENBLANCO;
	
	/**
	 * Inicializamos el oficina, con valor ENBLANCO
	 */
	private String oficina = ENBLANCO;
	
	/**
	 * Inicializamos el pendiente, con valor ENBLANCO
	 */
	private String pendiente = ENBLANCO;
	
	/**
	 * Inicializamos el tipoPers1, con valor ENBLANCO
	 */
	private String tipoPers1 = ENBLANCO;
	
	/**
	 * Inicializamos el residente1, con valor ENBLANCO
	 */
	private String residente1 = ENBLANCO;
	
	/**
	 * Inicializamos el persona1, con valor ENBLANCO
	 */
	private String persona1 = ENBLANCO;
	
	// MU-2016-006673 - RAROALE - INI
	/**
	 * Inicializamos el domicilio1, con valor ENBLANCO
	 */
	private String domicilio1 = ENBLANCO;
	
	/**
	 * Inicializamos el fmodificacion, con valor ENBLANCO
	 */
	private String fmodificacion = ENBLANCO;
	// MU-2016-006673 - RAROALE - FIN

	/**
	 * Inicializamos el fecPagComp, con valor ENBLANCO
	 */
	private String fecPagComp = ENBLANCO;
	
	/**
	 * Inicializamos el fecPagoCapital, con valor ENBLANCO
	 */
	private String fecPagoCapital = ENBLANCO;
	
	/**
	 * Inicializamos el fecEmision, con valor ENBLANCO
	 */
	private String fecEmision = ENBLANCO;
	
	/**
	 * Inicializamos el fecEfecto, con valor ENBLANCO
	 */
	private String fecEfecto = ENBLANCO;
	
	/**
	 * Inicializamos el impRtorintegrcap, con valor ENBLANCO
	 */
	private String impRtorintegrcap = ENBLANCO;
	
	/**
	 * Inicializamos el impRedPriCap, con valor ENBLANCO
	 */
	private String impRedPriCap = ENBLANCO;
	
	/**
	 * Inicializamos el impRedTranCap, con valor ENBLANCO
	 */
	private String impRedTranCap = ENBLANCO;
	
	/**
	 * Inicializamos el impCompensatoria, con valor ENBLANCO
	 */
	private String impCompensatoria = ENBLANCO;
	
	/**
	 * Inicializamos el impRtonetoCap, con valor ENBLANCO
	 */
	private String impRtonetoCap = ENBLANCO;
	
	/**
	 * Inicializamos el porretCap, con valor ENBLANCO
	 */
	private String porretCap = ENBLANCO;
	
	/**
	 * Inicializamos el impretCap, con valor ENBLANCO
	 */
	private String impretCap = ENBLANCO;
	
	/**
	 * Inicializamos el impliqCap, con valor ENBLANCO
	 */
	private String impliqCap = ENBLANCO;
	
	/**
	 * Inicializamos el fecImpreCap, con valor ENBLANCO
	 */
	private String fecImpreCap = ENBLANCO;
	
	/**
	 * Inicializamos el fecPagret, con valor ENBLANCO
	 */
	private String fecPagret = ENBLANCO;
	
	/**
	 * Inicializamos el impAnticipo, con valor ENBLANCO
	 */
	private String impAnticipo = ENBLANCO;
	
	/**
	 * Inicializamos el impInteresPendiente, con valor ENBLANCO
	 */
	private String impInteresPendiente = ENBLANCO;
	
	/**
	 * Inicializamos el fecVencimientoCap, con valor ENBLANCO
	 */
	private String fecVencimientoCap = ENBLANCO;
	
	/**
	 * Inicializamos el tipImpuestoCap, con valor ENBLANCO
	 */
	private String tipImpuestoCap = ENBLANCO;
	
	/**
	 * Inicializamos el impCapital, con valor ENBLANCO
	 */
	private String impCapital = ENBLANCO;
	
	/**
	 * Inicializamos el impBeneficios, con valor ENBLANCO
	 */
	private String impBeneficios = ENBLANCO;
	
	/**
	 * Inicializamos el impRtointComp, con valor ENBLANCO
	 */
	private String impRtointComp = ENBLANCO;
	
	/**
	 * Inicializamos el impRedpriComp, con valor ENBLANCO
	 */
	private String impRedpriComp = ENBLANCO;
	
	/**
	 * Inicializamos el impRedTranComp, con valor ENBLANCO
	 */
	private String impRedTranComp = ENBLANCO;
	
	/**
	 * Inicializamos el irTonetComp, con valor ENBLANCO
	 */
	private String irTonetComp = ENBLANCO;
	
	/**
	 * Inicializamos el porretComp, con valor ENBLANCO
	 */
	private String porretComp = ENBLANCO;
	
	/**
	 * Inicializamos el iretComp, con valor ENBLANCO
	 */
	private String iretComp = ENBLANCO;
	
	/**
	 * Inicializamos el iliqComp, con valor ENBLANCO
	 */
	private String iliqComp = ENBLANCO;
	
	/**
	 * Inicializamos el fecImpreComp, con valor ENBLANCO
	 */
	private String fecImpreComp = ENBLANCO;
	
	/**
	 * Inicializamos el fecPagretCom, con valor ENBLANCO
	 */
	private String fecPagretCom = ENBLANCO;
	
	/**
	 * Inicializamos el tipImpuestComp, con valor ENBLANCO
	 */
	private String tipImpuestComp = ENBLANCO;
	
	/**
	 * Inicializamos el impComp, con valor ENBLANCO
	 */
	private String impComp = ENBLANCO;
	
	/**
	 * Inicializamos el fecCemiComp, con valor ENBLANCO
	 */
	private String fecCemiComp = ENBLANCO;
	
	/**
	 * Inicializamos el mpRedTranComp2, con valor ENBLANCO
	 */
	private String mpRedTranComp2 = ENBLANCO;
	
	/**
	 * Inicializamos el codCoA1, con valor ENBLANCO
	 */
	private String codCoA1 = ENBLANCO;
	
	/**
	 * Inicializamos el porCoA1, con valor ENBLANCO
	 */
	private String porCoA1 = ENBLANCO;
	
	/**
	 * Inicializamos el codCoA2, con valor ENBLANCO
	 */
	private String codCoA2 = ENBLANCO;
	
	/**
	 * Inicializamos elporCoA2, con valor ENBLANCO
	 */
	private String porCoA2 = ENBLANCO;
	
	/**
	 * Inicializamos el codCoA3, con valor ENBLANCO
	 */
	private String codCoA3 = ENBLANCO;
	
	/**
	 * Inicializamos el porCoA3, con valor ENBLANCO
	 */
	private String porCoA3 = ENBLANCO;
	
	/**
	 * Inicializamos el codCoA4, con valor ENBLANCO
	 */
	private String codCoA4 = ENBLANCO;
	
	/**
	 * Inicializamos el porCoA4, con valor ENBLANCO
	 */
	private String porCoA4 = ENBLANCO;
	
	/**
	 * Inicializamos el codCoA5, con valor ENBLANCO
	 */
	private String codCoA5 = ENBLANCO;
	
	/**
	 * Inicializamos el porCoA5, con valor ENBLANCO
	 */
	private String porCoA5 = ENBLANCO;
	
	/**
	 * Inicializamos el codCoA6, con valor ENBLANCO
	 */
	private String codCoA6 = ENBLANCO;
	
	/**
	 * Inicializamos el porCoA6, con valor ENBLANCO
	 */
	private String porCoA6 = ENBLANCO;
	
	//MU-2016-006664 - RAROALE - INI
	/**
	 * Inicializamos el impCoA1, con valor ENBLANCO
	 */
	private String impCoA1 = ENBLANCO;
	
	/**
	 * Inicializamos el impCoA2, con valor ENBLANCO
	 */
	private String impCoA2 = ENBLANCO;
	
	/**
	 * Inicializamos el impCoA3, con valor ENBLANCO
	 */
	private String impCoA3 = ENBLANCO;
	
	/**
	 * Inicializamos el impCoA4, con valor ENBLANCO
	 */
	private String impCoA4 = ENBLANCO;

	/**
	 * Inicializamos el impCoA5, con valor ENBLANCO
	 */
	private String impCoA5 = ENBLANCO;
	
	/**
	 * Inicializamos el impCoA6, con valor ENBLANCO
	 */
	private String impCoA6 = ENBLANCO;
	//MU-2016-006664 - RAROALE - FIN


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
	 * Inicializamos el pagotot, con valor ENBLANCO
	 */
	private String pagotot = ENBLANCO;
	
	/**
	 * Inicializamos el cartera, con valor ENBLANCO
	 */
	private String cartera = ENBLANCO;
	
	/**
	 * Inicializamos el reaseguro, con valor ENBLANCO
	 */
	private String reaseguro = ENBLANCO;
	
	/**
	 * Inicializamos el usuarioC, con valor ENBLANCO
	 */
	private String usuarioC = ENBLANCO;
	
	/**
	 * Inicializamos el observacionesG, con valor ENBLANCO
	 */
	private String observacionesG = ENBLANCO;
	
	/**
	 * Inicializamos el fecBDGICap
	 */
	private String fecBDGICap = ENBLANCO;
	/**
	 * Inicializamos el fecBDGIComp1
	 */
	private String fecBDGIComp1 = ENBLANCO;
	/**
	 * Inicializamos el fecBDGIComp2
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
	 * Inicializamos el tipSituacion, con valor ENBLANCO
	 */
	private String tipSituacion = ENBLANCO;
	
	/**
	 * Inicializamos el fecAnul, con valor ENBLANCO
	 */
	private String fecAnul = ENBLANCO; //R&V - CU009

	/**
	 * Inicializamos eximido con valor ENBLANCO
	 */
	private String eximido = ENBLANCO;
	
	//FIN MODIFICACION EVERIS
	
	
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
	 * @return el antAnio
	 */
	public String getAntAnio () {
		return antAnio;
	}

	/**
	 * @param antAnio
	 *            el antAnio a establecer
	 */
	public void setAntAnio ( String antAnio ) {
		this.antAnio = antAnio;
	}

	/**
	 * @return el antExpediente
	 */
	public String getAntExpediente () {
		return antExpediente;
	}

	/**
	 * @param antExpediente
	 *            el antExpediente a establecer
	 */
	public void setAntExpediente ( String antExpediente ) {
		this.antExpediente = antExpediente;
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
	 * @return el anioSel
	 */
	public String getAnioSel () {
		return anioSel;
	}

	/**
	 * @param anioSel el anioSel a establecer
	 */
	public void setAnioSel ( String anioSel ) {
		this.anioSel = anioSel;
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
	 * @return el expedienteSel
	 */
	public String getExpedienteSel () {
		return expedienteSel;
	}

	/**
	 * @param expedienteSel el expedienteSel a establecer
	 */
	public void setExpedienteSel ( String expedienteSel ) {
		this.expedienteSel = expedienteSel;
	}

	/**
	 * @return el fecCemiComp1
	 */
	public String getFecCemiComp1 () {
		return fecCemiComp1;
	}

	/**
	 * @param fecCemiComp1 el fecCemiComp1 a establecer
	 */
	public void setFecCemiComp1 ( String fecCemiComp1 ) {
		this.fecCemiComp1 = fecCemiComp1;
	}

	/**
	 * @return el fecImpreComp1
	 */
	public String getFecImpreComp1 () {
		return fecImpreComp1;
	}

	/**
	 * @param fecImpreComp1 el fecImpreComp1 a establecer
	 */
	public void setFecImpreComp1 ( String fecImpreComp1 ) {
		this.fecImpreComp1 = fecImpreComp1;
	}

	/**
	 * @return el fecPagComp1
	 */
	public String getFecPagComp1 () {
		return fecPagComp1;
	}

	/**
	 * @param fecPagComp1 el fecPagComp1 a establecer
	 */
	public void setFecPagComp1 ( String fecPagComp1 ) {
		this.fecPagComp1 = fecPagComp1;
	}

	/**
	 * @return el fecPagretComp1
	 */
	public String getFecPagretComp1 () {
		return fecPagretComp1;
	}

	/**
	 * @param fecPagretComp1 el fecPagretComp1 a establecer
	 */
	public void setFecPagretComp1 ( String fecPagretComp1 ) {
		this.fecPagretComp1 = fecPagretComp1;
	}

	/**
	 * @return el iliqComp1
	 */
	public String getIliqComp1 () {
		return iliqComp1;
	}

	/**
	 * @param iliqComp1 el iliqComp1 a establecer
	 */
	public void setIliqComp1 ( String iliqComp1 ) {
		this.iliqComp1 = iliqComp1;
	}

	/**
	 * @return el impComp1
	 */
	public String getImpComp1 () {
		return impComp1;
	}

	/**
	 * @param impComp1 el impComp1 a establecer
	 */
	public void setImpComp1 ( String impComp1 ) {
		this.impComp1 = impComp1;
	}

	/**
	 * @return el impRedpriComp1
	 */
	public String getImpRedpriComp1 () {
		return impRedpriComp1;
	}

	/**
	 * @param impRedpriComp1 el impRedpriComp1 a establecer
	 */
	public void setImpRedpriComp1 ( String impRedpriComp1 ) {
		this.impRedpriComp1 = impRedpriComp1;
	}

	/**
	 * @return el impRedTranComp1
	 */
	public String getImpRedTranComp1 () {
		return impRedTranComp1;
	}

	/**
	 * @param impRedTranComp1 el impRedTranComp1 a establecer
	 */
	public void setImpRedTranComp1 ( String impRedTranComp1 ) {
		this.impRedTranComp1 = impRedTranComp1;
	}

	/**
	 * @return el impRtointComp1
	 */
	public String getImpRtointComp1 () {
		return impRtointComp1;
	}

	/**
	 * @param impRtointComp1 el impRtointComp1 a establecer
	 */
	public void setImpRtointComp1 ( String impRtointComp1 ) {
		this.impRtointComp1 = impRtointComp1;
	}

	/**
	 * @return el iretComp1
	 */
	public String getIretComp1 () {
		return iretComp1;
	}

	/**
	 * @param iretComp1 el iretComp1 a establecer
	 */
	public void setIretComp1 ( String iretComp1 ) {
		this.iretComp1 = iretComp1;
	}

	/**
	 * @return el irTonetComp1
	 */
	public String getIrTonetComp1 () {
		return irTonetComp1;
	}

	/**
	 * @param irTonetComp1 el irTonetComp1 a establecer
	 */
	public void setIrTonetComp1 ( String irTonetComp1 ) {
		this.irTonetComp1 = irTonetComp1;
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
	 * @return el porretComp1
	 */
	public String getPorretComp1 () {
		return porretComp1;
	}

	/**
	 * @param porretComp1 el porretComp1 a establecer
	 */
	public void setPorretComp1 ( String porretComp1 ) {
		this.porretComp1 = porretComp1;
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
	 * @return el tipImpuestComp1
	 */
	public String getTipImpuestComp1 () {
		return tipImpuestComp1;
	}

	/**
	 * @param tipImpuestComp1 el tipImpuestComp1 a establecer
	 */
	public void setTipImpuestComp1 ( String tipImpuestComp1 ) {
		this.tipImpuestComp1 = tipImpuestComp1;
	}

	/**
	 * @return el proAnio
	 */
	public String getProAnio () {
		return proAnio;
	}

	/**
	 * @param proAnio
	 *            el proAnio a establecer
	 */
	public void setProAnio ( String proAnio ) {
		this.proAnio = proAnio;
	}

	/**
	 * @return el proExpediente
	 */
	public String getProExpediente () {
		return proExpediente;
	}

	/**
	 * @param proExpediente
	 *            el proExpediente a establecer
	 */
	public void setProExpediente ( String proExpediente ) {
		this.proExpediente = proExpediente;
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
	 * @return el vectorMensajes
	 */
	public List <Object> getVectorMensajes () {
		return vectorMensajes;
	}

	/**
	 * @param vectorMensajes
	 *            el vectorMensajes a establecer
	 */
	public void setVectorMensajes ( List <Object> vectorMensajes ) {
		this.vectorMensajes = vectorMensajes;
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
	 * @return el nomPrograma
	 */
	public String getNomPrograma () {
		return NomPrograma;
	}

	/**
	 * @param nomPrograma
	 *            el nomPrograma a establecer
	 */
	public void setNomPrograma ( String nomPrograma ) {
		NomPrograma = nomPrograma;
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
	public String getIliqComp2 () {
		return iliqComp2;
	}

	/**
	 * @param iliqComp2
	 *            el iliqComp2 a establecer
	 */
	public void setIliqComp2 ( String iliqComp2 ) {
		this.iliqComp2 = iliqComp2;
	}

	/**
	 * @return el impComp2
	 */
	public String getImpComp2 () {
		return impComp2;
	}

	/**
	 * @param impComp2
	 *            el impComp2 a establecer
	 */
	public void setImpComp2 ( String impComp2 ) {
		this.impComp2 = impComp2;
	}

	/**
	 * @return el impRedpriComp2
	 */
	public String getImpRedpriComp2 () {
		return impRedpriComp2;
	}

	/**
	 * @param impRedpriComp2
	 *            el impRedpriComp2 a establecer
	 */
	public void setImpRedpriComp2 ( String impRedpriComp2 ) {
		this.impRedpriComp2 = impRedpriComp2;
	}

	/**
	 * @return el impRedTranComp2
	 */
	public String getImpRedTranComp2 () {
		return impRedTranComp2;
	}

	/**
	 * @param impRedTranComp2
	 *            el impRedTranComp2 a establecer
	 */
	public void setImpRedTranComp2 ( String impRedTranComp2 ) {
		this.impRedTranComp2 = impRedTranComp2;
	}

	/**
	 * @return el impRtointComp2
	 */
	public String getImpRtointComp2 () {
		return impRtointComp2;
	}

	/**
	 * @param impRtointComp2
	 *            el impRtointComp2 a establecer
	 */
	public void setImpRtointComp2 ( String impRtointComp2 ) {
		this.impRtointComp2 = impRtointComp2;
	}

	/**
	 * @return el iretComp2
	 */
	public String getIretComp2 () {
		return iretComp2;
	}

	/**
	 * @param iretComp2
	 *            el iretComp2 a establecer
	 */
	public void setIretComp2 ( String iretComp2 ) {
		this.iretComp2 = iretComp2;
	}

	/**
	 * @return el irTonetComp2
	 */
	public String getIrTonetComp2 () {
		return irTonetComp2;
	}

	/**
	 * @param irTonetComp2
	 *            el irTonetComp2 a establecer
	 */
	public void setIrTonetComp2 ( String irTonetComp2 ) {
		this.irTonetComp2 = irTonetComp2;
	}

	/**
	 * @return el porretComp2
	 */
	public String getPorretComp2 () {
		return porretComp2;
	}

	/**
	 * @param porretComp2
	 *            el porretComp2 a establecer
	 */
	public void setPorretComp2 ( String porretComp2 ) {
		this.porretComp2 = porretComp2;
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

	
//	INICIO MODIFICACION EVERIS
	/**
	 * @return el anio
	 */
	public String getAnio() {
		return anio;
	}

	
	
	/**
	 * @param anio el anio a establecer
	 */
	public void setAnio(String anio) {
		this.anio = anio;
	}

	/**
	 * @return el canalCamp
	 */
	public String getCanalCamp() {
		return canalCamp;
	}

	/**
	 * @param canalCamp el canalCamp a establecer
	 */
	public void setCanalCamp(String canalCamp) {
		this.canalCamp = canalCamp;
	}

	/**
	 * @return el cartera
	 */
	public String getCartera() {
		return cartera;
	}

	/**
	 * @param cartera el cartera a establecer
	 */
	public void setCartera(String cartera) {
		this.cartera = cartera;
	}

	/**
	 * @return el certificado
	 */
	public String getCertificado() {
		return certificado;
	}

	/**
	 * @param certificado el certificado a establecer
	 */
	public void setCertificado(String certificado) {
		this.certificado = certificado;
	}

	/**
	 * @return el codCoA1
	 */
	public String getCodCoA1() {
		return codCoA1;
	}

	/**
	 * @param codCoA1 el codCoA1 a establecer
	 */
	public void setCodCoA1(String codCoA1) {
		this.codCoA1 = codCoA1;
	}

	/**
	 * @return el codCoA2
	 */
	public String getCodCoA2() {
		return codCoA2;
	}

	/**
	 * @param codCoA2 el codCoA2 a establecer
	 */
	public void setCodCoA2(String codCoA2) {
		this.codCoA2 = codCoA2;
	}

	/**
	 * @return el codCoA3
	 */
	public String getCodCoA3() {
		return codCoA3;
	}

	/**
	 * @param codCoA3 el codCoA3 a establecer
	 */
	public void setCodCoA3(String codCoA3) {
		this.codCoA3 = codCoA3;
	}

	/**
	 * @return el codCoA4
	 */
	public String getCodCoA4() {
		return codCoA4;
	}

	/**
	 * @param codCoA4 el codCoA4 a establecer
	 */
	public void setCodCoA4(String codCoA4) {
		this.codCoA4 = codCoA4;
	}

	/**
	 * @return el codCoA5
	 */
	public String getCodCoA5() {
		return codCoA5;
	}

	/**
	 * @param codCoA5 el codCoA5 a establecer
	 */
	public void setCodCoA5(String codCoA5) {
		this.codCoA5 = codCoA5;
	}

	/**
	 * @return el codCoA6
	 */
	public String getCodCoA6() {
		return codCoA6;
	}

	/**
	 * @param codCoA6 el codCoA6 a establecer
	 */
	public void setCodCoA6(String codCoA6) {
		this.codCoA6 = codCoA6;
	}

	/**
	 * @return el duracion
	 */
	public String getDuracion() {
		return duracion;
	}

	/**
	 * @param duracion el duracion a establecer
	 */
	public void setDuracion(String duracion) {
		this.duracion = duracion;
	}

	/**
	 * @return el entidad
	 */
	public String getEntidad() {
		return entidad;
	}

	/**
	 * @param entidad el entidad a establecer
	 */
	public void setEntidad(String entidad) {
		this.entidad = entidad;
	}

	/**
	 * @return el expediente
	 */
	public String getExpediente() {
		return expediente;
	}

	/**
	 * @param expediente el expediente a establecer
	 */
	public void setExpediente(String expediente) {
		this.expediente = expediente;
	}

	/**
	 * @return el fecCemiComp
	 */
	public String getFecCemiComp() {
		return fecCemiComp;
	}

	/**
	 * @param fecCemiComp el fecCemiComp a establecer
	 */
	public void setFecCemiComp(String fecCemiComp) {
		this.fecCemiComp = fecCemiComp;
	}

	/**
	 * @return el fecEfecto
	 */
	public String getFecEfecto() {
		return fecEfecto;
	}

	/**
	 * @param fecEfecto el fecEfecto a establecer
	 */
	public void setFecEfecto(String fecEfecto) {
		this.fecEfecto = fecEfecto;
	}

	/**
	 * @return el fecEmision
	 */
	public String getFecEmision() {
		return fecEmision;
	}

	/**
	 * @param fecEmision el fecEmision a establecer
	 */
	public void setFecEmision(String fecEmision) {
		this.fecEmision = fecEmision;
	}

	/**
	 * @return el fecImpreCap
	 */
	public String getFecImpreCap() {
		return fecImpreCap;
	}

	/**
	 * @param fecImpreCap el fecImpreCap a establecer
	 */
	public void setFecImpreCap(String fecImpreCap) {
		this.fecImpreCap = fecImpreCap;
	}

	/**
	 * @return el fecImpreComp
	 */
	public String getFecImpreComp() {
		return fecImpreComp;
	}

	/**
	 * @param fecImpreComp el fecImpreComp a establecer
	 */
	public void setFecImpreComp(String fecImpreComp) {
		this.fecImpreComp = fecImpreComp;
	}

	/**
	 * @return el fecPagComp
	 */
	public String getFecPagComp() {
		return fecPagComp;
	}

	/**
	 * @param fecPagComp el fecPagComp a establecer
	 */
	public void setFecPagComp(String fecPagComp) {
		this.fecPagComp = fecPagComp;
	}

	/**
	 * @return el fecPagoCapital
	 */
	public String getFecPagoCapital() {
		return fecPagoCapital;
	}

	/**
	 * @param fecPagoCapital el fecPagoCapital a establecer
	 */
	public void setFecPagoCapital(String fecPagoCapital) {
		this.fecPagoCapital = fecPagoCapital;
	}

	/**
	 * @return el fecPagret
	 */
	public String getFecPagret() {
		return fecPagret;
	}

	/**
	 * @param fecPagret el fecPagret a establecer
	 */
	public void setFecPagret(String fecPagret) {
		this.fecPagret = fecPagret;
	}

	/**
	 * @return el fecPagretCom
	 */
	public String getFecPagretCom() {
		return fecPagretCom;
	}

	/**
	 * @param fecPagretCom el fecPagretCom a establecer
	 */
	public void setFecPagretCom(String fecPagretCom) {
		this.fecPagretCom = fecPagretCom;
	}

	/**
	 * @return el fecVencimientoCap
	 */
	public String getFecVencimientoCap() {
		return fecVencimientoCap;
	}

	/**
	 * @param fecVencimientoCap el fecVencimientoCap a establecer
	 */
	public void setFecVencimientoCap(String fecVencimientoCap) {
		this.fecVencimientoCap = fecVencimientoCap;
	}

	/**
	 * @return el iliqComp
	 */
	public String getIliqComp() {
		return iliqComp;
	}

	/**
	 * @param iliqComp el iliqComp a establecer
	 */
	public void setIliqComp(String iliqComp) {
		this.iliqComp = iliqComp;
	}

	/**
	 * @return el impAnticipo
	 */
	public String getImpAnticipo() {
		return impAnticipo;
	}

	/**
	 * @param impAnticipo el impAnticipo a establecer
	 */
	public void setImpAnticipo(String impAnticipo) {
		this.impAnticipo = impAnticipo;
	}

	/**
	 * @return el impBeneficios
	 */
	public String getImpBeneficios() {
		return impBeneficios;
	}

	/**
	 * @param impBeneficios el impBeneficios a establecer
	 */
	public void setImpBeneficios(String impBeneficios) {
		this.impBeneficios = impBeneficios;
	}

	/**
	 * @return el impCapital
	 */
	public String getImpCapital() {
		return impCapital;
	}

	/**
	 * @param impCapital el impCapital a establecer
	 */
	public void setImpCapital(String impCapital) {
		this.impCapital = impCapital;
	}

	/**
	 * @return el impComp
	 */
	public String getImpComp() {
		return impComp;
	}

	/**
	 * @param impComp el impComp a establecer
	 */
	public void setImpComp(String impComp) {
		this.impComp = impComp;
	}

	/**
	 * @return el impCompensatoria
	 */
	public String getImpCompensatoria() {
		return impCompensatoria;
	}

	/**
	 * @param impCompensatoria el impCompensatoria a establecer
	 */
	public void setImpCompensatoria(String impCompensatoria) {
		this.impCompensatoria = impCompensatoria;
	}

	/**
	 * @return el impInteresPendiente
	 */
	public String getImpInteresPendiente() {
		return impInteresPendiente;
	}

	/**
	 * @param impInteresPendiente el impInteresPendiente a establecer
	 */
	public void setImpInteresPendiente(String impInteresPendiente) {
		this.impInteresPendiente = impInteresPendiente;
	}

	/**
	 * @return el impliqCap
	 */
	public String getImpliqCap() {
		return impliqCap;
	}

	/**
	 * @param impliqCap el impliqCap a establecer
	 */
	public void setImpliqCap(String impliqCap) {
		this.impliqCap = impliqCap;
	}

	/**
	 * @return el impRedPriCap
	 */
	public String getImpRedPriCap() {
		return impRedPriCap;
	}

	/**
	 * @param impRedPriCap el impRedPriCap a establecer
	 */
	public void setImpRedPriCap(String impRedPriCap) {
		this.impRedPriCap = impRedPriCap;
	}

	/**
	 * @return el impRedpriComp
	 */
	public String getImpRedpriComp() {
		return impRedpriComp;
	}

	/**
	 * @param impRedpriComp el impRedpriComp a establecer
	 */
	public void setImpRedpriComp(String impRedpriComp) {
		this.impRedpriComp = impRedpriComp;
	}

	/**
	 * @return el impRedTranCap
	 */
	public String getImpRedTranCap() {
		return impRedTranCap;
	}

	/**
	 * @param impRedTranCap el impRedTranCap a establecer
	 */
	public void setImpRedTranCap(String impRedTranCap) {
		this.impRedTranCap = impRedTranCap;
	}

	/**
	 * @return el impRedTranComp
	 */
	public String getImpRedTranComp() {
		return impRedTranComp;
	}

	/**
	 * @param impRedTranComp el impRedTranComp a establecer
	 */
	public void setImpRedTranComp(String impRedTranComp) {
		this.impRedTranComp = impRedTranComp;
	}

	/**
	 * @return el impretCap
	 */
	public String getImpretCap() {
		return impretCap;
	}

	/**
	 * @param impretCap el impretCap a establecer
	 */
	public void setImpretCap(String impretCap) {
		this.impretCap = impretCap;
	}

	/**
	 * @return el impRtointComp
	 */
	public String getImpRtointComp() {
		return impRtointComp;
	}

	/**
	 * @param impRtointComp el impRtointComp a establecer
	 */
	public void setImpRtointComp(String impRtointComp) {
		this.impRtointComp = impRtointComp;
	}

	/**
	 * @return el impRtonetoCap
	 */
	public String getImpRtonetoCap() {
		return impRtonetoCap;
	}

	/**
	 * @param impRtonetoCap el impRtonetoCap a establecer
	 */
	public void setImpRtonetoCap(String impRtonetoCap) {
		this.impRtonetoCap = impRtonetoCap;
	}

	/**
	 * @return el impRtorintegrcap
	 */
	public String getImpRtorintegrcap() {
		return impRtorintegrcap;
	}

	/**
	 * @param impRtorintegrcap el impRtorintegrcap a establecer
	 */
	public void setImpRtorintegrcap(String impRtorintegrcap) {
		this.impRtorintegrcap = impRtorintegrcap;
	}

	/**
	 * @return el iretComp
	 */
	public String getIretComp() {
		return iretComp;
	}

	/**
	 * @param iretComp el iretComp a establecer
	 */
	public void setIretComp(String iretComp) {
		this.iretComp = iretComp;
	}

	/**
	 * @return el irTonetComp
	 */
	public String getIrTonetComp() {
		return irTonetComp;
	}

	/**
	 * @param irTonetComp el irTonetComp a establecer
	 */
	public void setIrTonetComp(String irTonetComp) {
		this.irTonetComp = irTonetComp;
	}

	/**
	 * @return el modalidad
	 */
	public String getModalidad() {
		return modalidad;
	}

	/**
	 * @param modalidad el modalidad a establecer
	 */
	public void setModalidad(String modalidad) {
		this.modalidad = modalidad;
	}

	/**
	 * @return el mpRedTranComp2
	 */
	public String getMpRedTranComp2() {
		return mpRedTranComp2;
	}

	/**
	 * @param mpRedTranComp2 el mpRedTranComp2 a establecer
	 */
	public void setMpRedTranComp2(String mpRedTranComp2) {
		this.mpRedTranComp2 = mpRedTranComp2;
	}

	/**
	 * @return el observacionesG
	 */
	public String getObservacionesG() {
		return observacionesG;
	}

	/**
	 * @param observacionesG el observacionesG a establecer
	 */
	public void setObservacionesG(String observacionesG) {
		this.observacionesG = observacionesG;
	}

	/**
	 * @return el oficina
	 */
	public String getOficina() {
		return oficina;
	}

	/**
	 * @param oficina el oficina a establecer
	 */
	public void setOficina(String oficina) {
		this.oficina = oficina;
	}

	/**
	 * @return el pagotot
	 */
	public String getPagotot() {
		return pagotot;
	}

	/**
	 * @param pagotot el pagotot a establecer
	 */
	public void setPagotot(String pagotot) {
		this.pagotot = pagotot;
	}

	/**
	 * @return el pendiente
	 */
	public String getPendiente() {
		return pendiente;
	}

	/**
	 * @param pendiente el pendiente a establecer
	 */
	public void setPendiente(String pendiente) {
		this.pendiente = pendiente;
	}

	/**
	 * @return el persona1
	 */
	public String getPersona1() {
		return persona1;
	}

	/**
	 * @param persona1 el persona1 a establecer
	 */
	public void setPersona1(String persona1) {
		this.persona1 = persona1;
	}

	/**
	 * @return el porCoA1
	 */
	public String getPorCoA1() {
		return porCoA1;
	}

	/**
	 * @param porCoA1 el porCoA1 a establecer
	 */
	public void setPorCoA1(String porCoA1) {
		this.porCoA1 = porCoA1;
	}

	/**
	 * @return el porCoA2
	 */
	public String getPorCoA2() {
		return porCoA2;
	}

	/**
	 * @param porCoA2 el porCoA2 a establecer
	 */
	public void setPorCoA2(String porCoA2) {
		this.porCoA2 = porCoA2;
	}

	/**
	 * @return el porCoA3
	 */
	public String getPorCoA3() {
		return porCoA3;
	}

	/**
	 * @param porCoA3 el porCoA3 a establecer
	 */
	public void setPorCoA3(String porCoA3) {
		this.porCoA3 = porCoA3;
	}

	/**
	 * @return el porCoA4
	 */
	public String getPorCoA4() {
		return porCoA4;
	}

	/**
	 * @param porCoA4 el porCoA4 a establecer
	 */
	public void setPorCoA4(String porCoA4) {
		this.porCoA4 = porCoA4;
	}

	/**
	 * @return el porCoA5
	 */
	public String getPorCoA5() {
		return porCoA5;
	}

	/**
	 * @param porCoA5 el porCoA5 a establecer
	 */
	public void setPorCoA5(String porCoA5) {
		this.porCoA5 = porCoA5;
	}

	/**
	 * @return el porCoA6
	 */
	public String getPorCoA6() {
		return porCoA6;
	}

	/**
	 * @param porCoA6 el porCoA6 a establecer
	 */
	public void setPorCoA6(String porCoA6) {
		this.porCoA6 = porCoA6;
	}

	/**
	 * @return el porretCap
	 */
	public String getPorretCap() {
		return porretCap;
	}

	/**
	 * @param porretCap el porretCap a establecer
	 */
	public void setPorretCap(String porretCap) {
		this.porretCap = porretCap;
	}

	/**
	 * @return el porretComp
	 */
	public String getPorretComp() {
		return porretComp;
	}

	/**
	 * @param porretComp el porretComp a establecer
	 */
	public void setPorretComp(String porretComp) {
		this.porretComp = porretComp;
	}

	/**
	 * @return el reaseguro
	 */
	public String getReaseguro() {
		return reaseguro;
	}

	/**
	 * @param reaseguro el reaseguro a establecer
	 */
	public void setReaseguro(String reaseguro) {
		this.reaseguro = reaseguro;
	}

	/**
	 * @return el regional
	 */
	public String getRegional() {
		return regional;
	}

	/**
	 * @param regional el regional a establecer
	 */
	public void setRegional(String regional) {
		this.regional = regional;
	}

	/**
	 * @return el residente1
	 */
	public String getResidente1() {
		return residente1;
	}

	/**
	 * @param residente1 el residente1 a establecer
	 */
	public void setResidente1(String residente1) {
		this.residente1 = residente1;
	}

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
	 * @return el subPoliza
	 */
	public String getSubPoliza() {
		return subPoliza;
	}

	/**
	 * @param subPoliza el subPoliza a establecer
	 */
	public void setSubPoliza(String subPoliza) {
		this.subPoliza = subPoliza;
	}

	/**
	 * @return el tipImpuestComp
	 */
	public String getTipImpuestComp() {
		return tipImpuestComp;
	}

	/**
	 * @param tipImpuestComp el tipImpuestComp a establecer
	 */
	public void setTipImpuestComp(String tipImpuestComp) {
		this.tipImpuestComp = tipImpuestComp;
	}

	/**
	 * @return el tipImpuestoCap
	 */
	public String getTipImpuestoCap() {
		return tipImpuestoCap;
	}

	/**
	 * @param tipImpuestoCap el tipImpuestoCap a establecer
	 */
	public void setTipImpuestoCap(String tipImpuestoCap) {
		this.tipImpuestoCap = tipImpuestoCap;
	}

	/**
	 * @return el tipoPers1
	 */
	public String getTipoPers1() {
		return tipoPers1;
	}

	/**
	 * @param tipoPers1 el tipoPers1 a establecer
	 */
	public void setTipoPers1(String tipoPers1) {
		this.tipoPers1 = tipoPers1;
	}

	/**
	 * @return el usuarioC
	 */
	public String getUsuarioC() {
		return usuarioC;
	}

	/**
	 * @param usuarioC el usuarioC a establecer
	 */
	public void setUsuarioC(String usuarioC) {
		this.usuarioC = usuarioC;
	}

	/**
	 * @return el mostrarResultado
	 */
	public boolean isMostrarResultado() {
		return mostrarResultado;
	}

	/**
	 * @param mostrarResultado el mostrarResultado a establecer
	 */
	public void setMostrarResultado(boolean mostrarResultado) {
		this.mostrarResultado = mostrarResultado;
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

	//FIN MODIFICACION EVERIS
	
	//MU-2016-006664 - RAROALE - INI
	/**
	 * @return el impCoA1
	 */
	public String getImpCoA1() {
		return impCoA1;
	}

	/**
	 * @param impCoA1 el impCoA1 a establecer
	 */
	public void setImpCoA1(String impCoA1) {
		this.impCoA1 = impCoA1;
	}

	/**
	 * @return el impCoA2
	 */
	public String getImpCoA2() {
		return impCoA2;
	}

	/**
	 * @param impCoA2 el impCoA2 a establecer
	 */
	public void setImpCoA2(String impCoA2) {
		this.impCoA2 = impCoA2;
	}

	/**
	 * @return el impCoA3
	 */
	public String getImpCoA3() {
		return impCoA3;
	}

	/**
	 * @param impCoA3 el impCoA3 a establecer
	 */
	public void setImpCoA3(String impCoA3) {
		this.impCoA3 = impCoA3;
	}

	/**
	 * @return el impCoA4
	 */
	public String getImpCoA4() {
		return impCoA4;
	}

	/**
	 * @param impCoA4 el impCoA4 a establecer
	 */
	public void setImpCoA4(String impCoA4) {
		this.impCoA4 = impCoA4;
	}

	/**
	 * @return el impCoA5
	 */
	public String getImpCoA5() {
		return impCoA5;
	}

	/**
	 * @param impCoA5 el impCoA5 a establecer
	 */
	public void setImpCoA5(String impCoA5) {
		this.impCoA5 = impCoA5;
	}

	/**
	 * @return el impCoA6
	 */
	public String getImpCoA6() {
		return impCoA6;
	}

	/**
	 * @param impCoA6 el impCoA6 a establecer
	 */
	public void setImpCoA6(String impCoA6) {
		this.impCoA6 = impCoA6;
	}
	//MU-2016-006664 - RAROALE - FIN
	
	// MU-2016-006673 - RAROALE - INI
	/**
	 * @return el domicilio1
	 */
	public String getDomicilio1() {
		return domicilio1;
	}

	/**
	 * @param domicilio1 el domicilio1 a establecer
	 */
	public void setDomicilio1(String domicilio1) {
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

	//R&V - CU009 - INI

	/**
	 *
	 * @return String
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
