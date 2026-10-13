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
public class J372J005ImpresionInformesVenActionForm extends ActionForm

{
	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	// tipo recogemos el código del combo(lista informe)

	/**
	 * Inicializamos el tipo, con valor tipo
	 */
	private String tipo = ENBLANCO;

	/**
	 * Inicializamos el anioExped, con valor anioExped
	 */
	private String anioExped = ENBLANCO;

	/**
	 * Inicializamos el fecEmision, con valor fecEmision
	 */
	private String fecEmision = ENBLANCO;
	
	/**
	 * Inicializamos el fecCalulo, con valor fecEmision
	 */
	private String fecCalculo = ENBLANCO;

	/**
	 * Inicializamos el capafecPagHasta, con valor capafecPagHasta
	 */
	/**
	 * Inicializamos el capafecPagHasta, con valor capafecPagHasta
	 */
	private String capafecPagHasta = ENBLANCO;

	/**
	 * Inicializamos el capafecPagDesde, con valor capafecPagDesde
	 */
	private String capafecPagDesde = ENBLANCO;

	/**
	 * Inicializamos el capafecEmiDesde, con valor capafecEmiDesde
	 */
	private String capafecEmiDesde = ENBLANCO;

	/**
	 * Inicializamos el capafecEmiHasta, con valor capafecEmiHasta
	 */
	private String capafecEmiHasta = ENBLANCO;

	/**
	 * Inicializamos el anioDesde, con valor anioDesde
	 */
	private String anioDesde = ENBLANCO;

	/**
	 * Inicializamos el anioHasta, con valor anioHasta
	 */
	private String anioHasta = ENBLANCO;

	/**
	 * Inicializamos el expedDesde, con valor expedDesde
	 */
	private String expedDesde = ENBLANCO;

	/**
	 * Inicializamos el expedHasta, con valor expedHasta
	 */
	private String expedHasta = ENBLANCO;

	/**
	 * Inicializamos el imprimir, con valor imprimir
	 */
	private String imprimir = ENBLANCO;

	/**
	 * Inicializamos el tipOperacion, con valor tipOperacion
	 */
	private String tipOperacion = ENBLANCO;

	/**
	 * Inicializamos el fecEmiHasta, con valor fecEmiHasta
	 */
	private String fecEmiHasta = ENBLANCO;

	/**
	 * Inicializamos el fecEmiDesde, con valor fecEmiDesde
	 */
	private String fecEmiDesde = ENBLANCO;

	/**
	 * Inicializamos el fecPagDesde, con valor fecPagDesde
	 */
	private String fecPagDesde = ENBLANCO;

	/**
	 * Inicializamos el fecPagHasta, con valor fecPagHasta
	 */
	private String fecPagHasta = ENBLANCO;

	/**
	 * Inicializamos el listadoInf, con valor listadoInf
	 */
	private List <Object> listadoInf;

	/**
	 * Inicializamos el vectorMensajes, con valor vectorMensajes
	 */
	private List <Object> vectorMensajes = Collections.synchronizedList ( new Vector <Object> () );

	/**
	 * Inicializamos el retorno, con valor retorno
	 */
	private String retorno = ENBLANCO;

	/**
	 * Inicializamos el NomPrograma, con valor NomPrograma
	 */
	private String nomPrograma = ENBLANCO;

	/**
	 * Inicializamos el desRetorno, con valor desRetorno
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
	 * @return el anioDesde
	 */
	public String getAnioDesde () {
		return anioDesde;
	}

	/**
	 * @param anioDesde
	 *            el anioDesde a establecer
	 */
	public void setAnioDesde ( String anioDesde ) {
		this.anioDesde = anioDesde;
	}

	/**
	 * @return el anioHasta
	 */
	public String getAnioHasta () {
		return anioHasta;
	}

	/**
	 * @param anioHasta
	 *            el anioHasta a establecer
	 */
	public void setAnioHasta ( String anioHasta ) {
		this.anioHasta = anioHasta;
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
	 * @return el imprimir
	 */
	public String getImprimir () {
		return imprimir;
	}

	/**
	 * @param imprimir
	 *            el imprimir a establecer
	 */
	public void setImprimir ( String imprimir ) {
		this.imprimir = imprimir;
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
	public String getnomPrograma () {
		return nomPrograma;
	}

	/**
	 * @param nomPrograma
	 *            el nomPrograma a establecer
	 */
	public void setnomPrograma ( String nomPrograma ) {
		nomPrograma = nomPrograma;
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
	 * @return el anioExped
	 */
	public String getAnioExped () {
		return anioExped;
	}

	/**
	 * @param anioExped
	 *            el anioExped a establecer
	 */
	public void setAnioExped ( String anioExped ) {
		this.anioExped = anioExped;
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
	 * @return el capafecEmiDesde
	 */
	public String getCapafecEmiDesde () {
		return capafecEmiDesde;
	}

	/**
	 * @param capafecEmiDesde
	 *            el capafecEmiDesde a establecer
	 */
	public void setCapafecEmiDesde ( String capafecEmiDesde ) {
		this.capafecEmiDesde = capafecEmiDesde;
	}

	/**
	 * @return el capafecEmiHasta
	 */
	public String getCapafecEmiHasta () {
		return capafecEmiHasta;
	}

	/**
	 * @param capafecEmiHasta
	 *            el capafecEmiHasta a establecer
	 */
	public void setCapafecEmiHasta ( String capafecEmiHasta ) {
		this.capafecEmiHasta = capafecEmiHasta;
	}

	/**
	 * @return el capafecPagDesde
	 */
	public String getCapafecPagDesde () {
		return capafecPagDesde;
	}

	/**
	 * @param capafecPagDesde
	 *            el capafecPagDesde a establecer
	 */
	public void setCapafecPagDesde ( String capafecPagDesde ) {
		this.capafecPagDesde = capafecPagDesde;
	}

	/**
	 * @return el capafecPagHasta
	 */
	public String getCapafecPagHasta () {
		return capafecPagHasta;
	}

	/**
	 * @param capafecPagHasta
	 *            el capafecPagHasta a establecer
	 */
	public void setCapafecPagHasta ( String capafecPagHasta ) {
		this.capafecPagHasta = capafecPagHasta;
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
