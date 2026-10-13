package com.mapfre.mavisa.wss372vencimientosmanuales.forms;

import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Vector;
import org.apache.struts.action.ActionForm;

/**
 * @author everis
 * @version 1.0 Versión inicial Declaración de variables que utilizamos en el
 *          jsp
 */
public class J372J006PeticionBDGIVenActionForm extends ActionForm

{
	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inicializamos el anio, con valor ENBLANCO
	 */
	private String anio = ENBLANCO;

	/**
	 * Inicializamos el mes, con valor ENBLANCO
	 */
	private String mes = ENBLANCO;

	/**
	 * Inicializamos el fecInicio, con valor ENBLANCO
	 */
	private String fecInicio = ENBLANCO;

	/**
	 * Inicializamos el fecFin, con valor ENBLANCO
	 */
	private String fecFin = ENBLANCO;

	/**
	 * Inicializamos el aceptar, con valor ENBLANCO
	 */
	private String aceptar = ENBLANCO;

	/**
	 * Inicializamos el tipOperacion, con valor ENBLANCO
	 */
	private String tipOperacion = ENBLANCO;

	/**
	 * Inicializamos el mesCombo, con valor NUEVO
	 */
	private Collection <Object> mesCombo = Collections.synchronizedList ( new Vector <Object> () );

	/**
	 * Inicializamos el vectorMensajes, con valor NUEVO
	 */
	private List <Object> vectorMensajes = Collections.synchronizedList ( new Vector <Object> () );

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
	 * Inicializamos el NomPrograma, con valor ENBLANCO
	 */
	private String NomPrograma = ENBLANCO;

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
	 * @return el mes
	 */
	public String getMes () {
		return mes;
	}

	/**
	 * @param mes
	 *            el mes a establecer
	 */
	public void setMes ( String mes ) {
		this.mes = mes;
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
	 * @return el mesCombo
	 */
	public Collection getMesCombo () {
		return mesCombo;
	}

	/**
	 * @return vectorMensajes
	 */
	public List getVectorMensajes () {
		return vectorMensajes;
	}

	/**
	 * @param mesCombo
	 *            el mesCombo a establecer
	 */
	public void setMesCombo ( Collection <Object> mesCombo ) {
		this.mesCombo = mesCombo;
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
	 * @param vectorMensajes
	 *            el vectorMensajes a establecer
	 */
	public void setVectorMensajes ( List <Object> vectorMensajes ) {
		this.vectorMensajes = vectorMensajes;
	}

}
