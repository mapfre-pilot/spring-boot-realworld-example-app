package com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans;

import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;
import java.math.BigDecimal;

/**
 * @author everis
 * @version 1.0 Versión inicial Clase de negocio. Encapsula los datos del
 *          detalle del programa.
 * 
 */
public class J372J004GestionVariablesVenPageBean {

	/**
	 * Declaracion de las variables del PageBean
	 */

	private BigDecimal anio = new BigDecimal ( 0 );

	/**
	 * Inicializamos el expediente, con valor ENBLANCO
	 */
	private BigDecimal expediente = new BigDecimal ( 0 );

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
	 * Inicializamos el tipOperacion, con valor ENBLANCO
	 */
	private String tipOperacion;

	/**
	 * Inicializamos el nomPrograma, con valor ENBLANCO
	 */
	private String nomPrograma;

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

}
