package com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans;

import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;

/**
 * @author everis
 * @version 1.0 Versión inicial Clase de negocio. Encapsula los datos del
 *          detalle del programa.
 * 
 */
public class J372J007ReaseguroVenPageBean {

	/**
	 * Campos a rellenar del PageBean
	 */

	/**
	 * Inicializamos el anio, con valor ENBLANCO
	 */
	private String anio;

	/**
	 * Inicializamos el expediente, con valor ENBLANCO
	 */
	private String expediente;

	/**
	 * Inicializamos el usuario, con valor ENBLANCO
	 */
	private J000J000Usuario usuario;

	/**
	 * Inicializamos el operacion, con valor ENBLANCO
	 */
	private String operacion;

	/**
	 * Inicializamos el ramo, con valor ENBLANCO
	 */
	private String ramo;

	/**
	 * Inicializamos el retorno, con valor ENBLANCO
	 */
	private String retorno;

	/**
	 * Inicializamos el desRetorno, con valor ENBLANCO
	 */
	private String desRetorno;

	/**
	 * Inicializamos el nomPrograma, con valor ENBLANCO
	 */
	private String nomPrograma;

	/**
	 * Inicializamos el fecBDGICap, con valor ENBLANCO
	 */
	private String fecBDGICap;
	
	/**
	 * Inicializamos el fecBDGIComp1, con valor ENBLANCO
	 */
	private String fecBDGIComp1;
	
	/**
	 * Inicializamos el fecBDGIComp2, con valor ENBLANCO
	 */
	private String fecBDGIComp2;

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

}
