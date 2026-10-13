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
/**
 * @author encalde
 * 
 */
public class J372J002EmisionFiniquitosVenActionForm extends ActionForm

{
	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inicializamos el emisionFiniqui, con valor ENBLANCO
	 */
	private String emisionFiniqui = ENBLANCO;

	/**
	 * Inicializamos el anio, con valor ENBLANCO
	 */
	private String anio = ENBLANCO;

	/**
	 * Inicializamos el expedDesde, con valor ENBLANCO
	 */
	private String expedDesde = ENBLANCO;

	/**
	 * Inicializamos el expedHasta, con valor ENBLANCO
	 */
	private String expedHasta = ENBLANCO;

	/**
	 * Inicializamos el regionalEnvio, con valor ENBLANCO
	 */
	private String regionalEnvio = ENBLANCO;

	/**
	 * Inicializamos el fecEfectEmision, con valor ENBLANCO
	 */
	private String fecEfectEmision = ENBLANCO;

	/**
	 * Inicializamos el AntAnio, con valor ENBLANCO
	 */
	private String AntAnio = ENBLANCO;

	/**
	 * Inicializamos el AntExpediente, con valor ENBLANCO
	 */
	private String AntExpediente = ENBLANCO;

	/**
	 * Inicializamos el tipOperacion, con valor ENBLANCO
	 */
	private String tipOperacion = ENBLANCO;

	/**
	 * Inicializamos el listadoEmi, con valor ENBLANCO
	 */
	private List <Object> listadoEmi;

	/**
	 * Inicializamos el vectorMensajes, con valor ENBLANCO
	 */
	private List <Object> vectorMensajes = Collections.synchronizedList ( new Vector <Object> () );

	/**
	 * Inicializamos el retorno, con valor ENBLANCO
	 */
	private String retorno = ENBLANCO;

	/**
	 * Inicializamos el NomPrograma, con valor ENBLANCO
	 */
	private String NomPrograma = ENBLANCO;

	/**
	 * Inicializamos el desRetorno, con valor ENBLANCO
	 */
	private String desRetorno = ENBLANCO;

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
	 * @return el emisionFiniqui
	 */
	public String getEmisionFiniqui () {
		return emisionFiniqui;
	}

	/**
	 * @param emisionFiniqui
	 *            el emisionFiniqui a establecer
	 */
	public void setEmisionFiniqui ( String emisionFiniqui ) {
		this.emisionFiniqui = emisionFiniqui;
	}

	/**
	 * @return el expedDesde
	 */
	public String getExpedDesde () {
		return expedDesde;
	}

	/**
	 * @param expedDesde
	 *            el expedDesde a establecer
	 */
	public void setExpedDesde ( String expedDesde ) {
		this.expedDesde = expedDesde;
	}

	/**
	 * @return el expedHasta
	 */
	public String getExpedHasta () {
		return expedHasta;
	}

	/**
	 * @param expedHasta
	 *            el expedHasta a establecer
	 */
	public void setExpedHasta ( String expedHasta ) {
		this.expedHasta = expedHasta;
	}

	/**
	 * @return el fecEfectEmision
	 */
	public String getFecEfectEmision () {
		return fecEfectEmision;
	}

	/**
	 * @param fecEfectEmision
	 *            el fecEfectEmision a establecer
	 */
	public void setFecEfectEmision ( String fecEfectEmision ) {
		this.fecEfectEmision = fecEfectEmision;
	}

	/**
	 * @return el regionalEnvio
	 */
	public String getRegionalEnvio () {
		return regionalEnvio;
	}

	/**
	 * @param regionalEnvio
	 *            el regionalEnvio a establecer
	 */
	public void setRegionalEnvio ( String regionalEnvio ) {
		this.regionalEnvio = regionalEnvio;
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
	 * @return el listadoEmi
	 */
	public List <Object> getListadoEmi () {
		return listadoEmi;
	}

	/**
	 * @param listadoEmi
	 *            el listadoEmi a establecer
	 */
	public void setListadoEmi ( List <Object> listadoEmi ) {
		this.listadoEmi = listadoEmi;
	}

	/**
	 * @return el antAnio
	 */
	public String getAntAnio () {
		return AntAnio;
	}

	/**
	 * @param antAnio
	 *            el antAnio a establecer
	 */
	public void setAntAnio ( String antAnio ) {
		AntAnio = antAnio;
	}

	/**
	 * @return el antExpediente
	 */
	public String getAntExpediente () {
		return AntExpediente;
	}

	/**
	 * @param antExpediente
	 *            el antExpediente a establecer
	 */
	public void setAntExpediente ( String antExpediente ) {
		AntExpediente = antExpediente;
	}

}
