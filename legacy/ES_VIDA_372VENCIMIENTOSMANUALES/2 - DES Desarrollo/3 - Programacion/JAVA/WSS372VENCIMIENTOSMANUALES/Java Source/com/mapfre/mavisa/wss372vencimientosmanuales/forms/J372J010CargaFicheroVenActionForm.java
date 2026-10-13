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
public class J372J010CargaFicheroVenActionForm extends ActionForm

{
	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inicializamos el vectorMensajes, con valor vectorMensajes
	 */
	private List <Object> vectorMensajes = Collections.synchronizedList ( new Vector <Object> () );

	/**
	 * Inicializamos el tipo, con valor tipo
	 */
	private String tipo = ENBLANCO;

	/**
	 * Inicializamos el retorno, con valor retorno
	 */
	private String retorno = ENBLANCO;

	/**
	 * Inicializamos el desRetorno, con valor desRetorno
	 */
	private String desRetorno = ENBLANCO;

	/**
	 * Inicializamos el NomPrograma, con valor NomPrograma
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
	 * @return vectorMensajes
	 */
	public List getVectorMensajes () {
		return vectorMensajes;
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

}
