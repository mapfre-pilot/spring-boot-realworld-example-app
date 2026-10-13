package com.mapfre.mavisa.wss372vencimientosmanuales.utils;

/**
 * @author everis
 * @version 1.0 Versión inicial
 * 
 * Para cambiar la plantilla para este comentario de tipo generado vaya a
 * Ventana&gt;Preferencias&gt;Java&gt;Generación de código&gt;Código y
 * comentarios
 */
public class CombosBean {
	/**
	 * Inicializacion de la variable prop1, valor NULL
	 */
	private String prop1 = null;

	/**
	 * Inicializacion de la variable prop2, valor NULL
	 */
	private String prop2 = null;

	/**
	 * ComboBean
	 */
	public CombosBean () {
		super ();
	}

	/**
	 * @param p1
	 * @param p2
	 */
	public CombosBean ( String p1, String p2 ) {
		super ();
		this.prop1 = p1;
		this.prop2 = p2;
	}

	/**
	 * @return prop1
	 */
	public String getProp1 () {
		return prop1;
	}

	/**
	 * @return prop2
	 */
	public String getProp2 () {
		return prop2;
	}

	/**
	 * @param string
	 */
	public void setProp1 ( String string ) {
		prop1 = string;
	}

	/**
	 * @param string
	 */
	public void setProp2 ( String string ) {
		prop2 = string;
	}

}
