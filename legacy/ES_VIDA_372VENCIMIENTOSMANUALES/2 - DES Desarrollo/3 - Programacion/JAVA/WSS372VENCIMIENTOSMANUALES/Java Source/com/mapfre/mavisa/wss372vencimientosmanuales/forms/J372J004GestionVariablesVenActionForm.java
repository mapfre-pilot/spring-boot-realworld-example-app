package com.mapfre.mavisa.wss372vencimientosmanuales.forms;

import java.util.Collections;
import java.util.List;
import java.util.Vector;

import org.apache.struts.action.ActionForm;

/**
 * Formulario Action Gestion Variables.Encapsula los datos del formulario
 * 
 * @version 1.0 Versión inicial
 * @author everis
 */
public class J372J004GestionVariablesVenActionForm extends ActionForm {
	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inicializamos el anio, con valor ENBLANCO
	 */
	private String anio = ENBLANCO;

	/**
	 * Inicializamos el expediente, con valor ENBLANCO
	 */
	private String expediente = ENBLANCO;

	/**
	 * Inicializamos el tipOperacion, con valor ENBLANCO
	 */
	private String tipOperacion = ENBLANCO;

	/**
	 * Inicializamos el vectorMensajes
	 */
	private List <Object> vectorMensajes = Collections.synchronizedList ( new Vector <Object> () );

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
	 * @return vectorMensajes
	 */
	public List getVectorMensajes () {
		return vectorMensajes;
	}

}
