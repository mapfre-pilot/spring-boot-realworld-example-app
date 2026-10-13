package com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans;

import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;
import java.math.BigDecimal;

/**
 * @author everis
 * @version 1.0 Versión inicial Clase de negocio. Encapsula los datos del
 *          detalle del programa.
 * 
 */

public class J372J006PeticionBDGIVenPageBean {

	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inicializamos el anio, con valor 0
	 */
	private BigDecimal anio = new BigDecimal ( 0 );

	/**
	 * Inicializamos el mes, con valor 0
	 */
	private BigDecimal mes = new BigDecimal ( 0 );

	/**
	 * Inicializamos el mesCombo, con valor ENBLANCO
	 */
	private String mesCombo = ENBLANCO;

	/**
	 * Inicializamos el fecInicio, con valor ENBLANCO
	 */
	private String fecInicio = ENBLANCO;

	/**
	 * Inicializamos el fecFin, con valor ENBLANCO
	 */
	/**
	 * Inicializamos el fecFin, con valor ENBLANCO
	 */
	private String fecFin = ENBLANCO;

	/**
	 * Inicializamos el aceptar, con valor ENBLANCO
	 */
	private String aceptar = ENBLANCO;

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
	 * Inicializamos el usuario,
	 */
	private J000J000Usuario usuario;

	/**
	 * Inicializamos el operacion, con valor ENBLANCO
	 */
	private String operacion = ENBLANCO;

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
	 * @return el aceptar
	 */
	public String getAceptar () {
		return aceptar;
	}

	/**
	 * @param aceptar
	 *            el aceptar a establecer
	 */
	public void setAceptar ( String aceptar ) {
		this.aceptar = aceptar;
	}

	/**
	 * @return el fecFin
	 */
	public String getFecFin () {
		return fecFin;
	}

	/**
	 * @param fecFin
	 *            el fecFin a establecer
	 */
	public void setFecFin ( String fecFin ) {
		this.fecFin = fecFin;
	}

	/**
	 * @return el fecInicio
	 */
	public String getFecInicio () {
		return fecInicio;
	}

	/**
	 * @param fecInicio
	 *            el fecInicio a establecer
	 */
	public void setFecInicio ( String fecInicio ) {
		this.fecInicio = fecInicio;
	}

	/**
	 * @return el mesCombo
	 */
	public String getMesCombo () {
		return mesCombo;
	}

	/**
	 * @param mesCombo
	 *            el mesCombo a establecer
	 */
	public void setMesCombo ( String mesCombo ) {
		this.mesCombo = mesCombo;
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
	 * @return el mes
	 */
	public BigDecimal getMes () {
		return mes;
	}

	/**
	 * @param mes
	 *            el mes a establecer
	 */
	public void setMes ( BigDecimal mes ) {
		this.mes = mes;
	}

}
