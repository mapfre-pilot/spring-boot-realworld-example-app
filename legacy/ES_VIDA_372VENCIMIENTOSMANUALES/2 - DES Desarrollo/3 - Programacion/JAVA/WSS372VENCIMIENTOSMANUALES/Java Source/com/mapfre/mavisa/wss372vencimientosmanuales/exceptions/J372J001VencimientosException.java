package com.mapfre.mavisa.wss372vencimientosmanuales.exceptions;

import mapfre.wss000arquitect.utilidades.J000J000Trazas;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;

/**
 * Clase de excepciones.
 * 
 * @version 1.0 Versión inicial
 * @author everis
 */

public class J372J001VencimientosException extends Exception {

	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * objTrazas
	 */
	static Logger objTrazas = J000J000Trazas.getLogger ( J372J001VencimientosException.class );

	/**
	 * Extraccion de variables de errores
	 */
	protected String stCodigoError = null;

	/**
	 * Inicializamos el stMensajeError, con valor ENBLANCO
	 */
	protected String stMensajeError = null;

	/**
	 * Inicializamos el stDescripcion, con valor ENBLANCO
	 */
	/**
	 * Inicializamos el stDescripcion, con valor ENBLANCO
	 */
	protected String stDescripcion = null;

	/**
	 * Inicializamos el oExcepcionFuente, con valor ENBLANCO
	 */
	protected Exception oExcepcionFuente = null;

	/**
	 * Inicializamos el stClase, con valor ENBLANCO
	 */
	protected String stClase = null;

	/**
	 * Inicializamos el stMetodo, con valor ENBLANCO
	 */
	protected String stMetodo = null;

	/**
	 * Inicializamos el stTipoError, con valor ENBLANCO
	 */
	protected String stTipoError = null;

	/**
	 * Inicializamos el stModal, con valor ENBLANCO
	 */
	protected String stModal = null;

	/**
	 * Inicializamos el stGNomProg, con valor ENBLANCO
	 */
	protected String stGNomProg = ENBLANCO;

	/**
	 * Inicializamos el stGError, con valor ENBLANCO
	 */
	protected String stGError = ENBLANCO;

	/**
	 * Inicializamos el stCRetorno, con valor ENBLANCO
	 */
	protected String stCRetorno = ENBLANCO;

	/**
	 * Declaración de Error ERROR_GENERICO_JAVA, para hacer un catálogo de
	 * errores
	 */
	public static final String ERROR_GENERICO_JAVA = "00000001";

	/**
	 * Declaración de Error ERROR_GENERICO_CICS, para hacer un catálogo de
	 * errores
	 */
	public static final String ERROR_GENERICO_CICS = "00000002";

	/**
	 * Declaración de Error ERROR_ENTRADA_DATOS, para hacer un catálogo de
	 * errores
	 */
	public static final String ERROR_ENTRADA_DATOS = "00000003";

	/**
	 * Declaración de Error ERROR_CONFIGURACION, para hacer un catálogo de
	 * errores
	 */
	public static final String ERROR_CONFIGURACION = "00000004";

	/**
	 * Declaración de Error ERROR_NEGOCIO, para hacer un catálogo de errores
	 */
	public static final String ERROR_NEGOCIO = "00000005";

	/**
	 * Declaración de Error ERROR_SALIDA_DATOS, para hacer un catálogo de
	 * errores
	 */
	public static final String ERROR_SALIDA_DATOS = "00000006";

	/**
	 * Declaración de Error ERROR_USUARIO, para hacer un catálogo de errores
	 */
	public static final String ERROR_USUARIO = "00000007";

	// ...

	/**
	 * Inicializamos el oArrMsjError
	 */
	private static final String [] oArrMsjError = { ENBLANCO,
			"ERROR GENERICO JAVA", "ERROR GENERICO CICS",
			"ERROR EN RECOGIDA DATOS DE ENTRADA",
			"ERROR EN DATOS DE CONFIGURACION", "ERROR EN ACCESO A NEGOCIO",
			"ERROR EN CONSTRUCCIÓN DATOS SALIDA",
			"ERROR DE PERMISOS DE USUARIO"
	// ...
	};

	/**
	 * Constructor
	 * 
	 * @param pstCodigoError
	 *            codigo de error
	 */
	public J372J001VencimientosException ( String pstCodigoError ) {

		if ( pstCodigoError != null ) {
			this.stCodigoError = pstCodigoError;

			// mensaje de error
			if ( !ENBLANCO.equals ( pstCodigoError.trim () ) ) {
				final int intCod = Integer.parseInt ( pstCodigoError );
				if ( intCod < oArrMsjError.length ) {
					this.stMensajeError = oArrMsjError [intCod];
				}
			}
		}
		if ( objTrazas.isEnabledFor ( Level.ERROR ) ) {
			objTrazas.error ( pstCodigoError );
		}
	}

	/**
	 * Constructor
	 * 
	 * @param pstCodigoError
	 *            codigo de error
	 * @param pstDescripcion
	 *            descripcion del error
	 */
	public J372J001VencimientosException ( String pstCodigoError,
			String pstDescripcion ) {

		if ( pstCodigoError != null ) {
			this.stCodigoError = pstCodigoError;

			// mensaje de error
			if ( !pstCodigoError.trim ().equals ( ENBLANCO ) ) {
				final int intCod = Integer.parseInt ( pstCodigoError );
				if ( intCod < oArrMsjError.length ) {
					this.stMensajeError = oArrMsjError [intCod];
				}
			}
		}
		if ( pstDescripcion != null ) {
			this.stDescripcion = pstDescripcion;
		}
		if ( objTrazas.isEnabledFor ( Level.ERROR ) ) {
			objTrazas.error ( pstDescripcion );
		}
	}

	/**
	 * Constructor
	 * 
	 * @param pstCodigoError
	 *            codigo de error
	 * @param pstDescripcion
	 *            descripcion del error
	 * @param poExcepcionFuente
	 *            excepcion original
	 */
	public J372J001VencimientosException ( String pstCodigoError,
			String pstDescripcion, Exception poExcepcionFuente ) {

		if ( pstCodigoError != null ) {
			this.stCodigoError = pstCodigoError;

			// mensaje de error
			if ( !pstCodigoError.trim ().equals ( ENBLANCO ) ) {
				final int intCod = Integer.parseInt ( pstCodigoError );
				if ( intCod < oArrMsjError.length ) {
					this.stMensajeError = oArrMsjError [intCod];
				}
			}
		}
		if ( pstDescripcion != null ) {
			this.stDescripcion = pstDescripcion;
		}
		this.oExcepcionFuente = poExcepcionFuente;

		if ( objTrazas.isEnabledFor ( Level.ERROR ) ) {
			objTrazas.error ( pstDescripcion, poExcepcionFuente );
		}
	}

	/**
	 * @return String clase
	 */
	public String getStClase () {
		return stClase;
	}

	/**
	 * @return String metodo
	 */
	public String getStMetodo () {
		return stMetodo;
	}

	/**
	 * @param string
	 *            clase
	 */
	public void setStClase ( String string ) {
		stClase = string;
	}

	/**
	 * @param string
	 *            metodo
	 */
	public void setStMetodo ( String string ) {
		stMetodo = string;
	}

	/**
	 * @return String codigo de error
	 */
	public String getStCodigoError () {
		return stCodigoError;
	}

	/**
	 * @return String descripcion
	 */
	public String getStDescripcion () {
		return stDescripcion;
	}

	/**
	 * @return String mensaje de error
	 */
	public String getStMensajeError () {
		return stMensajeError;
	}

	/**
	 * @param string
	 *            descripcion
	 */
	public void setStDescripcion ( String string ) {
		stDescripcion = string;
	}

	/**
	 * @return String tipo de error
	 */
	public String getStTipoError () {
		return stTipoError;
	}

	/**
	 * @param string
	 *            tipo de error
	 */
	public void setStTipoError ( String string ) {
		stTipoError = string;
	}

	/**
	 * @return modo
	 */
	public String getStModal () {
		return stModal;
	}

	/**
	 * @param string
	 *            modo
	 */
	public void setStModal ( String string ) {
		stModal = string;
	}

	/**
	 * @return stCRetorno
	 */
	public String getStCRetorno () {
		return stCRetorno;
	}

	/**
	 * @param stCRetorno
	 */
	public void setStCRetorno ( String stCRetorno ) {
		this.stCRetorno = stCRetorno;
	}

	/**
	 * @return stGError
	 */
	public String getStGError () {
		return stGError;
	}

	/**
	 * @param stGError
	 */
	public void setStGError ( String stGError ) {
		this.stGError = stGError;
	}

	/**
	 * @return stGNomProg
	 */
	public String getStGNomProg () {
		return stGNomProg;
	}

	/**
	 * @param stGNomProg
	 */
	public void setStGNomProg ( String stGNomProg ) {
		this.stGNomProg = stGNomProg;
	}

}
