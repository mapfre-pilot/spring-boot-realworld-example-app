package com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans;

import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;

import java.math.BigDecimal;
import java.util.List;

/**
 * @author everis
 * @version 1.0 Versión inicial Clase de negocio. Encapsula los datos del
 *          detalle del programa.
 * 
 */

public class J372J005ImpresionInformesVenPageBean {
	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inicializamos el fecEmision, con valor ENBLANCO
	 */
	private String fecEmision = ENBLANCO;
	
	/**
	 * Inicializamos el fecCalulo, con valor fecEmision
	 */
	private String fecCalculo = ENBLANCO;

	/**
	 * Inicializamos el tipo, con valor ENBLANCO
	 */
	private String tipo = ENBLANCO;

	/**
	 * Inicializamos el fecEmiHasta, con valor ENBLANCO
	 */
	private String fecEmiHasta = ENBLANCO;

	/**
	 * Inicializamos el fecEmiDesde, con valor ENBLANCO
	 */
	private String fecEmiDesde = ENBLANCO;

	/**
	 * Inicializamos el fecPagDesde, con valor ENBLANCO
	 */
	private String fecPagDesde = ENBLANCO;

	/**
	 * Inicializamos el fecPagHasta, con valor ENBLANCO
	 */
	private String fecPagHasta = ENBLANCO;

	/**
	 * Inicializamos el retorno, con valor ENBLANCO
	 */
	private String retorno;

	/**
	 * Inicializamos el desRetorno, con valor ENBLANCO
	 */
	private String desRetorno;

	/**
	 * Inicializamos el listadoInf, con valor ENBLANCO
	 */
	private List <Object> listadoInf;

	/**
	 * Inicializamos el expedDesde, con valor ENBLANCO
	 */
	private BigDecimal expedDesde = new BigDecimal ( 0 );

	/**
	 * Inicializamos el expedHasta, con valor ENBLANCO
	 */
	private BigDecimal expedHasta = new BigDecimal ( 0 );

	/**
	 * Inicializamos el anioDesde, con valor ENBLANCO
	 */
	private BigDecimal anioDesde = new BigDecimal ( 0 );

	/**
	 * Inicializamos el anioHasta, con valor ENBLANCO
	 */
	private BigDecimal anioHasta = new BigDecimal ( 0 );

	/**
	 * Inicializamos el regionalEnvio, con valor ENBLANCO
	 */
	private String regionalEnvio = ENBLANCO;

	/**
	 * Inicializamos el nomPrograma, con valor ENBLANCO
	 */
	private String nomPrograma = ENBLANCO;

	/**
	 * Inicializamos el tipRescate, con valor ENBLANCO
	 */
	private String tipRescate = ENBLANCO;

	/**
	 * Inicializamos el anio, con valor ENBLANCO
	 */
	private String anio = ENBLANCO;

	/**
	 * Inicializamos el expediente, con valor ENBLANCO
	 */
	private String expediente = ENBLANCO;

	/**
	 * Inicializamos el poliza, con valor ENBLANCO
	 */
	private String poliza = ENBLANCO;

	/**
	 * Inicializamos el ramo, con valor ENBLANCO
	 */
	private String ramo = ENBLANCO;

	/**
	 * Inicializamos el anioPol, con valor ENBLANCO
	 */
	private String anioPol = ENBLANCO;

	/**
	 * Inicializamos el modalidad, con valor ENBLANCO
	 */
	private String modalidad = ENBLANCO;

	/**
	 * Inicializamos el regional, con valor ENBLANCO
	 */
	private String regional = ENBLANCO;

	/**
	 * Inicializamos el oficina, con valor ENBLANCO
	 */
	private String oficina = ENBLANCO;

	/**
	 * Inicializamos el fecEfecto, con valor ENBLANCO
	 */
	private String fecEfecto = ENBLANCO;

	/**
	 * Inicializamos el fecHasta, con valor ENBLANCO
	 */
	private String fecHasta = ENBLANCO;

	/**
	 * Inicializamos el literal, con valor ENBLANCO
	 */
	private String literal = ENBLANCO;

	/**
	 * Inicializamos el anocomples, con valor ENBLANCO
	 */
	private String anocomples = ENBLANCO;

	/**
	 * Inicializamos el fecRecomp, con valor ENBLANCO
	 */
	private String fecRecomp = ENBLANCO;

	/**
	 * Inicializamos el imPrest, con valor ENBLANCO
	 */
	private String imPrest = ENBLANCO;

	/**
	 * Inicializamos el beneficios, con valor ENBLANCO
	 */
	private String beneficios = ENBLANCO;

	/**
	 * Inicializamos el anticipo, con valor ENBLANCO
	 */
	private String anticipo = ENBLANCO;

	/**
	 * Inicializamos el cobroInt, con valor ENBLANCO
	 */
	private String cobroInt = ENBLANCO;

	/**
	 * Inicializamos el devolucionInt, con valor ENBLANCO
	 */
	private String devolucionInt = ENBLANCO;

	/**
	 * Inicializamos el primaRec, con valor ENBLANCO
	 */
	private String primaRec = ENBLANCO;

	/**
	 * Inicializamos el retCuenta, con valor ENBLANCO
	 */
	private String retCuenta = ENBLANCO;

	/**
	 * Inicializamos el Retenc, con valor ENBLANCO
	 */
	private String Retenc = ENBLANCO;

	/**
	 * Inicializamos el imPliquid, con valor ENBLANCO
	 */
	private String imPliquid = ENBLANCO;

	/**
	 * Inicializamos el tipImpuesto, con valor ENBLANCO
	 */
	private String tipImpuesto = ENBLANCO;

	/**
	 * Inicializamos el fecEfectEmisionLit, con valor ENBLANCO
	 */
	private String fecEfectEmisionLit = ENBLANCO;

	/**
	 * Inicializamos el nif, con valor ENBLANCO
	 */
	private String nif = ENBLANCO;

	/**
	 * Inicializamos el nombreApell, con valor ENBLANCO
	 */
	private String nombreApell = ENBLANCO;

	/**
	 * Inicializamos el domicilio, con valor ENBLANCO
	 */
	private String domicilio = ENBLANCO;

	/**
	 * Inicializamos el codPostal, con valor ENBLANCO
	 */
	private String codPostal = ENBLANCO;

	/**
	 * Inicializamos el poblacion, con valor ENBLANCO
	 */
	private String poblacion = ENBLANCO;

	/**
	 * Inicializamos el provincia, con valor ENBLANCO
	 */
	private String provincia = ENBLANCO;

	/**
	 * Inicializamos el tipEmision, con valor ENBLANCO
	 */
	private String tipEmision = ENBLANCO;

	/**
	 * Inicializamos el tipOperacion, con valor ENBLANCO
	 */
	private String tipOperacion = ENBLANCO;

	/**
	 * Inicializamos el tipoCompl, con valor ENBLANCO
	 */
	private String tipoCompl = ENBLANCO;

	/**
	 * Inicializamos el NumRegistros, con valor ENBLANCO
	 */
	private String NumRegistros;

	/**
	 * Inicializamos el fecDesdeLit, con valor ENBLANCO
	 */
	private String fecDesdeLit = ENBLANCO;

	/**
	 * Inicializamos el fecLiquidaLit, con valor ENBLANCO
	 */
	private String fecLiquidaLit = ENBLANCO;

	/**
	 * Inicializamos el usuario, con valor ENBLANCO
	 */
	private J000J000Usuario usuario;

	/**
	 * @return el fecEmiDesde
	 */
	public String getFecEmiDesde () {
		return fecEmiDesde;
	}

	/**
	 * @param fecEmiDesde
	 *            el fecEmiDesde a establecer
	 */
	public void setFecEmiDesde ( String fecEmiDesde ) {
		this.fecEmiDesde = fecEmiDesde;
	}

	/**
	 * @return el fecEmiHasta
	 */
	public String getFecEmiHasta () {
		return fecEmiHasta;
	}

	/**
	 * @param fecEmiHasta
	 *            el fecEmiHasta a establecer
	 */
	public void setFecEmiHasta ( String fecEmiHasta ) {
		this.fecEmiHasta = fecEmiHasta;
	}

	/**
	 * @return el fecPagDesde
	 */
	public String getFecPagDesde () {
		return fecPagDesde;
	}

	/**
	 * @param fecPagDesde
	 *            el fecPagDesde a establecer
	 */
	public void setFecPagDesde ( String fecPagDesde ) {
		this.fecPagDesde = fecPagDesde;
	}

	/**
	 * @return el fecPagHasta
	 */
	public String getFecPagHasta () {
		return fecPagHasta;
	}

	/**
	 * @param fecPagHasta
	 *            el fecPagHasta a establecer
	 */
	public void setFecPagHasta ( String fecPagHasta ) {
		this.fecPagHasta = fecPagHasta;
	}

	/**
	 * @return el tipo
	 */
	public String getTipo () {
		return tipo;
	}

	/**
	 * @param tipo
	 *            el tipo a establecer
	 */
	public void setTipo ( String tipo ) {
		this.tipo = tipo;
	}

	/**
	 * @param regionalEnvio
	 *            el regionalEnvio a establecer
	 */
	public void setRegionalEnvio ( String regionalEnvio ) {
		this.regionalEnvio = regionalEnvio;
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
	 * @return el listadoInf
	 */
	public List <Object> getListadoInf () {
		return listadoInf;
	}

	/**
	 * @param listadoInf
	 *            el listadoInf a establecer
	 */
	public void setListadoInf ( List <Object> listadoInf ) {
		this.listadoInf = listadoInf;
	}

	/**
	 * @return el anioPol
	 */
	public String getAnioPol () {
		return anioPol;
	}

	/**
	 * @param anioPol
	 *            el anioPol a establecer
	 */
	public void setAnioPol ( String anioPol ) {
		this.anioPol = anioPol;
	}

	/**
	 * @return el anocomples
	 */
	public String getAnocomples () {
		return anocomples;
	}

	/**
	 * @param anocomples
	 *            el anocomples a establecer
	 */
	public void setAnocomples ( String anocomples ) {
		this.anocomples = anocomples;
	}

	/**
	 * @return el anticipo
	 */
	public String getAnticipo () {
		return anticipo;
	}

	/**
	 * @param anticipo
	 *            el anticipo a establecer
	 */
	public void setAnticipo ( String anticipo ) {
		this.anticipo = anticipo;
	}

	/**
	 * @return el beneficios
	 */
	public String getBeneficios () {
		return beneficios;
	}

	/**
	 * @param beneficios
	 *            el beneficios a establecer
	 */
	public void setBeneficios ( String beneficios ) {
		this.beneficios = beneficios;
	}

	/**
	 * @return el cobroInt
	 */
	public String getCobroInt () {
		return cobroInt;
	}

	/**
	 * @param cobroInt
	 *            el cobroInt a establecer
	 */
	public void setCobroInt ( String cobroInt ) {
		this.cobroInt = cobroInt;
	}

	/**
	 * @return el codPostal
	 */
	public String getCodPostal () {
		return codPostal;
	}

	/**
	 * @param codPostal
	 *            el codPostal a establecer
	 */
	public void setCodPostal ( String codPostal ) {
		this.codPostal = codPostal;
	}

	/**
	 * @return el devolucionInt
	 */
	public String getDevolucionInt () {
		return devolucionInt;
	}

	/**
	 * @param devolucionInt
	 *            el devolucionInt a establecer
	 */
	public void setDevolucionInt ( String devolucionInt ) {
		this.devolucionInt = devolucionInt;
	}

	/**
	 * @return el domicilio
	 */
	public String getDomicilio () {
		return domicilio;
	}

	/**
	 * @param domicilio
	 *            el domicilio a establecer
	 */
	public void setDomicilio ( String domicilio ) {
		this.domicilio = domicilio;
	}

	/**
	 * @return el anioDesde
	 */
	public BigDecimal getAnioDesde () {
		return anioDesde;
	}

	/**
	 * @param anioDesde
	 *            el anioDesde a establecer
	 */
	public void setAnioDesde ( BigDecimal anioDesde ) {
		this.anioDesde = anioDesde;
	}

	/**
	 * @return el anioHasta
	 */
	public BigDecimal getAnioHasta () {
		return anioHasta;
	}

	/**
	 * @param anioHasta
	 *            el anioHasta a establecer
	 */
	public void setAnioHasta ( BigDecimal anioHasta ) {
		this.anioHasta = anioHasta;
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
	 * @return el expedDesde
	 */
	public BigDecimal getExpedDesde () {
		return expedDesde;
	}

	/**
	 * @return el expedHasta
	 */
	public BigDecimal getExpedHasta () {
		return expedHasta;
	}

	/**
	 * @return el regionalEnvio
	 */
	public String getRegionalEnvio () {
		return regionalEnvio;
	}

	/**
	 * @return el fecEfectEmisionLit
	 */
	public String getFecEfectEmisionLit () {
		return fecEfectEmisionLit;
	}

	/**
	 * @param fecEfectEmisionLit
	 *            el fecEfectEmisionLit a establecer
	 */
	public void setFecEfectEmisionLit ( String fecEfectEmisionLit ) {
		this.fecEfectEmisionLit = fecEfectEmisionLit;
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
	 * @return el fecHasta
	 */
	public String getFecHasta () {
		return fecHasta;
	}

	/**
	 * @param fecHasta
	 *            el fecHasta a establecer
	 */
	public void setFecHasta ( String fecHasta ) {
		this.fecHasta = fecHasta;
	}

	/**
	 * @return el fecRecomp
	 */
	public String getFecRecomp () {
		return fecRecomp;
	}

	/**
	 * @param fecRecomp
	 *            el fecRecomp a establecer
	 */
	public void setFecRecomp ( String fecRecomp ) {
		this.fecRecomp = fecRecomp;
	}

	/**
	 * @return el imPliquid
	 */
	public String getImPliquid () {
		return imPliquid;
	}

	/**
	 * @param imPliquid
	 *            el imPliquid a establecer
	 */
	public void setImPliquid ( String imPliquid ) {
		this.imPliquid = imPliquid;
	}

	/**
	 * @return el imPrest
	 */
	public String getImPrest () {
		return imPrest;
	}

	/**
	 * @param imPrest
	 *            el imPrest a establecer
	 */
	public void setImPrest ( String imPrest ) {
		this.imPrest = imPrest;
	}

	/**
	 * @return el literal
	 */
	public String getLiteral () {
		return literal;
	}

	/**
	 * @param literal
	 *            el literal a establecer
	 */
	public void setLiteral ( String literal ) {
		this.literal = literal;
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
	 * @return el nif
	 */
	public String getNif () {
		return nif;
	}

	/**
	 * @param nif
	 *            el nif a establecer
	 */
	public void setNif ( String nif ) {
		this.nif = nif;
	}

	/**
	 * @return el nombreApell
	 */
	public String getNombreApell () {
		return nombreApell;
	}

	/**
	 * @param nombreApell
	 *            el nombreApell a establecer
	 */
	public void setNombreApell ( String nombreApell ) {
		this.nombreApell = nombreApell;
	}

	/**
	 * @return el numRegistros
	 */
	public String getNumRegistros () {
		return NumRegistros;
	}

	/**
	 * @param numRegistros
	 *            el numRegistros a establecer
	 */
	public void setNumRegistros ( String numRegistros ) {
		NumRegistros = numRegistros;
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
	 * @return el poblacion
	 */
	public String getPoblacion () {
		return poblacion;
	}

	/**
	 * @param poblacion
	 *            el poblacion a establecer
	 */
	public void setPoblacion ( String poblacion ) {
		this.poblacion = poblacion;
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
	 * @return el primaRec
	 */
	public String getPrimaRec () {
		return primaRec;
	}

	/**
	 * @param primaRec
	 *            el primaRec a establecer
	 */
	public void setPrimaRec ( String primaRec ) {
		this.primaRec = primaRec;
	}

	/**
	 * @return el provincia
	 */
	public String getProvincia () {
		return provincia;
	}

	/**
	 * @param provincia
	 *            el provincia a establecer
	 */
	public void setProvincia ( String provincia ) {
		this.provincia = provincia;
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
	 * @return el retCuenta
	 */
	public String getRetCuenta () {
		return retCuenta;
	}

	/**
	 * @param retCuenta
	 *            el retCuenta a establecer
	 */
	public void setRetCuenta ( String retCuenta ) {
		this.retCuenta = retCuenta;
	}

	/**
	 * @return el retenc
	 */
	public String getRetenc () {
		return Retenc;
	}

	/**
	 * @param retenc
	 *            el retenc a establecer
	 */
	public void setRetenc ( String retenc ) {
		Retenc = retenc;
	}

	/**
	 * @return el tipEmision
	 */
	public String getTipEmision () {
		return tipEmision;
	}

	/**
	 * @param tipEmision
	 *            el tipEmision a establecer
	 */
	public void setTipEmision ( String tipEmision ) {
		this.tipEmision = tipEmision;
	}

	/**
	 * @return el tipImpuesto
	 */
	public String getTipImpuesto () {
		return tipImpuesto;
	}

	/**
	 * @param tipImpuesto
	 *            el tipImpuesto a establecer
	 */
	public void setTipImpuesto ( String tipImpuesto ) {
		this.tipImpuesto = tipImpuesto;
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
	 * @return el tipRescate
	 */
	public String getTipRescate () {
		return tipRescate;
	}

	/**
	 * @param tipRescate
	 *            el tipRescate a establecer
	 */
	public void setTipRescate ( String tipRescate ) {
		this.tipRescate = tipRescate;
	}

	/**
	 * @param expedDesde
	 *            el expedDesde a establecer
	 */
	public void setExpedDesde ( BigDecimal expedDesde ) {
		this.expedDesde = expedDesde;
	}

	/**
	 * @param expedHasta
	 *            el expedHasta a establecer
	 */
	public void setExpedHasta ( BigDecimal expedHasta ) {
		this.expedHasta = expedHasta;
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
	 * @return el expediente
	 */
	public String getExpediente () {
		return expediente;
	}

	/**
	 * @param expediente
	 *            el expediente a establecer
	 */
	public void setExpediente ( String expediente ) {
		this.expediente = expediente;
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
	 * @return el fecLiquidaLit
	 */
	public String getFecLiquidaLit () {
		return fecLiquidaLit;
	}

	/**
	 * @param fecLiquidaLit
	 *            el fecLiquidaLit a establecer
	 */
	public void setFecLiquidaLit ( String fecLiquidaLit ) {
		this.fecLiquidaLit = fecLiquidaLit;
	}

	/**
	 * @return el fecDesdeLit
	 */
	public String getFecDesdeLit () {
		return fecDesdeLit;
	}

	/**
	 * @param fecDesdeLit
	 *            el fecDesdeLit a establecer
	 */
	public void setFecDesdeLit ( String fecDesdeLit ) {
		this.fecDesdeLit = fecDesdeLit;
	}

	/**
	 * @return el tipoCompl
	 */
	public String getTipoCompl () {
		return tipoCompl;
	}

	/**
	 * @param tipoCompl
	 *            el tipoCompl a establecer
	 */
	public void setTipoCompl ( String tipoCompl ) {
		this.tipoCompl = tipoCompl;
	}

	/**
	 * @return el fecCalculo
	 */
	public String getFecCalculo () {
		return fecCalculo;
	}

	/**
	 * @param fecCalculo el fecCalculo a establecer
	 */
	public void setFecCalculo ( String fecCalculo ) {
		this.fecCalculo = fecCalculo;
	}

}
