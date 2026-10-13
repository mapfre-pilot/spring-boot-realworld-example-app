package com.mapfre.mavisa.wss372vencimientosmanuales.forms;

import java.util.Collections;
import java.util.List;
import java.util.Vector;
import org.apache.struts.action.ActionForm;

/**
 * Form bean for a Struts application.
 * 
 * @author everis
 * @version 1.0 Versión inicial
 */
public class J372J007ReaseguroVenActionForm extends ActionForm

{
	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inicializamos el vectorMensajes
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
	 * @return vectorMensajes
	 */
	public List getVectorMensajes () {
		return vectorMensajes;
	}

}
