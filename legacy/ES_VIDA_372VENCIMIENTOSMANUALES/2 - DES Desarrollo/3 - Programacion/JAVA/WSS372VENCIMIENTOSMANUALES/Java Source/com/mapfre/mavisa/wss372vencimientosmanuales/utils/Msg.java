package com.mapfre.mavisa.wss372vencimientosmanuales.utils;

/**
 * @author everis
 * @version 1.0 Versión inicial
 */
public class Msg {
	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inicializamos el stKeyMensaje, con valor ENBLANCO
	 */
	private String stKeyMensaje = ENBLANCO;

	/**
	 * Inicializamos el stMensaje, con valor ENBLANCO
	 */
	private String stMensaje = ENBLANCO;

	/**
	 * Inicializamos el stPrograma, con valor ENBLANCO
	 */
	private String stPrograma = ENBLANCO;

	/**
	 * Inicializamos el stTipo, con valor ENBLANCO
	 */
	private String stTipo = ENBLANCO;

	/**
	 * @param pstKeyMensaje
	 * @param pstMensaje
	 * @param pPrograma
	 * @param pstTipo
	 */
	public Msg ( final String pstKeyMensaje, final String pstMensaje,
			final String pPrograma, final String pstTipo ) {
		this.stTipo = pstTipo.trim ().toUpperCase ();

		if ( ( !"AA".equals ( stTipo ) ) && ( !"II".equals ( stTipo ) )
				&& ( !"XX".equals ( stTipo ) ) ) {
			this.stTipo = "XX";
		}

		this.stKeyMensaje = pstKeyMensaje;
		this.stMensaje = pstMensaje;
		this.stPrograma = pPrograma;
	}

	/**
	 * @return stTipo
	 */
	public String getTipo () {
		return this.stTipo;
	}

	/**
	 * @return stPrograma
	 */
	public String getPrograma () {
		return this.stPrograma;
	}

	/**
	 * @return stMensaje
	 */
	public String getTexto () {
		return this.stMensaje;
	}

	/**
	 * @return stKeyMensaje
	 */
	public String getKey () {
		return this.stKeyMensaje;
	}

}