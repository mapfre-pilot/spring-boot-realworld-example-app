package com.mapfre.mavisa.wss372vencimientosmanuales.utils;

import java.util.Collections;
import java.util.List;
import java.util.Vector;

/**
 * @author everis
 * @version 1.0 Versión inicial
 */
public class Mensajes {

	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Gestión de ERRORES
	 */
	private static final String GERROR_S = "GERROR-S";

	/**
	 * Gestión de ERRORES ATT_OBMENSAJE
	 */
	private static final String ATT_OBMENSAJE = "ATT_OBMENSAJE";

	/**
	 * Gestión de ERRORES MENSAJE_ERROR
	 */
	private static final String MENSAJE_ERROR = "XX";

	/**
	 * Gestión de ERRORES MENSAJE_ALERTA
	 */
	private static final String MENSAJE_ALERTA = "AA";

	/**
	 * Gestión de ERRORES MENSAJE_INFO
	 */
	private static final String MENSAJE_INFO = "II";

	/**
	 * Gestión de ERRORES IMG_MENSAJE_ERROR
	 */
	private static final String IMG_MENSAJE_ERROR = "error.gif";

	/**
	 * Gestión de ERRORES IMG_MENSAJE_ALERTA
	 */
	private static final String IMG_MENSAJE_ALERTA = "alerta.gif";

	/**
	 * Gestión de ERRORES IMG_MENSAJE_INFO
	 */
	private static final String IMG_MENSAJE_INFO = "informacion.gif";

	/**
	 * Declaración int inAccion
	 */
	private static int inAccion = 0;

	/**
	 * Declaración String stTipo
	 */
	private static String stTipo = ENBLANCO;

	/**
	 * Declaración String stKeyMensaje
	 */
	private static String stKeyMensaje = ENBLANCO;

	/**
	 * Declaración String stMensaje
	 */
	private static String stMensaje = ENBLANCO;

	/**
	 * Declaración String stPrograma
	 */
	private static String stPrograma = ENBLANCO;

	/**
	 * Declaración String stMasDatos
	 */
	private static String stMasDatos = ENBLANCO;

	/**
	 * Declaración String stURL
	 */
	private static String stURL = ENBLANCO;

	/**
	 * Declaración String accionJavascript
	 */
	private static String accionJavascript = ENBLANCO;

	/**
	 * Declaración String hayMensajes
	 */
	private static boolean hayMensajes = false;

	/**
	 * vectorMensajes
	 */
	private List <Object> vectorMensajes = Collections.synchronizedList ( new Vector <Object> () );

	/**
	 * Declaración Mensajes
	 */
	public Mensajes () {
		this.vectorMensajes = Collections.synchronizedList ( new Vector <Object> () );
	}

	/**
	 * @param pinAccion
	 * @param pstTipo
	 * @param pstKeyMensaje
	 * @param pstMensaje
	 * @param pPrograma
	 * @param pMasDatos
	 */
	@SuppressWarnings ( "unchecked" )
	public void setMensaje ( final int pinAccion, final String pstTipo,
			final String pstKeyMensaje, final String pstMensaje,
			final String pPrograma, final String pMasDatos ) {
		inAccion = pinAccion;
		stTipo = pstTipo;
		stKeyMensaje = pstKeyMensaje;
		stMensaje = pstMensaje;
		stPrograma = pPrograma;
		stMasDatos = pMasDatos;

		stTipo = pstTipo.trim ().toUpperCase ();

		if ( ( !"AA".equals ( stTipo ) ) && ( !"II".equals ( stTipo ) )
				&& ( !MENSAJE_ERROR.equals ( stTipo ) ) ) {
			stTipo = MENSAJE_ERROR;
		}

		final Msg ESTEMSG  =  new Msg ( pstKeyMensaje, pstMensaje, pPrograma,
				stTipo );
		this.vectorMensajes.add ( ESTEMSG );
	}

	/**
	 * Declaración resetMensajes
	 */
	public void resetMensaje () {
		stTipo = ENBLANCO;
		stKeyMensaje = ENBLANCO;
		stMensaje = ENBLANCO;
		stPrograma = ENBLANCO;
		stMasDatos = ENBLANCO;
		accionJavascript = ENBLANCO;
		hayMensajes = false;
		resetArrayMensajes ();
	}

	/**
	 * Declaración resetArrayMensajes
	 */
	public void resetArrayMensajes () {
		this.vectorMensajes = Collections
				.synchronizedList ( new Vector <Object> () );
		this.vectorMensajes.clear ();
		accionJavascript = ENBLANCO;
	}

	/**
	 * @param pstTipo
	 * @param pstKeyMensaje
	 * @param pstMensaje
	 * @param pPrograma
	 */
	public void addMsg ( final String pstTipo, final String pstKeyMensaje,
			final String pstMensaje, final String pPrograma ) {

		String tipo = pstTipo.toUpperCase ();
		if ( ( !"AA".equals ( tipo ) ) && ( !"II".equals ( tipo ) ) ) {
			tipo = MENSAJE_ERROR;
		}

		setMensaje ( 0, tipo, pstKeyMensaje, pstMensaje, pPrograma, ENBLANCO );
	}

	/**
	 * @return vectorMensajes
	 */
	@SuppressWarnings ( "unchecked" )
	public Msg [] getArrayMensajes () {
		return ( Msg [] ) vectorMensajes.toArray ( new Msg [vectorMensajes
				.size ()] );
	}

	/**
	 * @param miVtMsgs
	 * @return errorXX
	 */
	public boolean hayErrorGrave ( final Vector miVtMsgs ) {
		boolean errorXX = false;

		if ( ( miVtMsgs != null ) && ( miVtMsgs.size () > 0 ) ) {
			hayMensajes = true;
			for ( int auxBucle = 0; auxBucle < miVtMsgs.size (); auxBucle++ ) {
				Msg esteMensaje;
				esteMensaje = ( Msg ) miVtMsgs.elementAt ( auxBucle );
				if ( MENSAJE_ERROR.equalsIgnoreCase ( esteMensaje.getTipo () ) ) {
					errorXX = true;
				}
			}
			stKeyMensaje = "99";
		}
		return errorXX;
	}

	/**
	 * @return el vectorMensajes
	 */
	public List <Object> getVectorMensajes () {
		return this.vectorMensajes;
	}

	/**
	 * @param vectorMensajes
	 *            el vectorMensajes a establecer
	 */
	public void setVectorMensajes ( List <Object> vectorMensajes ) {
		this.vectorMensajes = vectorMensajes;
	}
}