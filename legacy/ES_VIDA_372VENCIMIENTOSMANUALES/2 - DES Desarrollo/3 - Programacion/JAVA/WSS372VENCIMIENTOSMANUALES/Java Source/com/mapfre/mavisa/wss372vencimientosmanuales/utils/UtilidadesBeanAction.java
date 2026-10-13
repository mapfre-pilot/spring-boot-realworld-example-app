package com.mapfre.mavisa.wss372vencimientosmanuales.utils;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;
import java.util.Vector;
import mapfreUVD.WSS960TGENERALE.tabtabla.J960J001_Consulta_desplegable_tab_tabla;
import com.mapfre.mavisa.wss372vencimientosmanuales.actions.MapfreAction;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;

/**
 * @author everis
 * @version 1.0 Versión inicial Clase de utilidades
 * 
 */
public class UtilidadesBeanAction extends MapfreAction {

	/**
	 * Inicializamos el ENBLANCO, con valor "".
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inicializamos el UNCERO, con valor 0.
	 */
	private static final String UNCERO = "0";

	/**
	 * Comprueba si un número es de un sólo caracter, si es así, le coloca un 0
	 * delante.
	 * 
	 * @param numero
	 * @return String
	 */
	public String rellenaCeros ( String numero ) {
		final StringBuffer RELLENAR = new StringBuffer ( UNCERO );

		final String FORMATEADO;

		if ( numero.length () == 1 ) {
			FORMATEADO = RELLENAR.append ( numero ).toString ();
		} else {
			FORMATEADO = numero;
		}

		return FORMATEADO;
	}

	/**
	 * Una utilidad para dividir un String según un caracter separador (en la
	 * versión 1.4 hay un método similar pero falta en la versión 1.3)
	 * 
	 * Ejemplos de uso:
	 * 
	 * splitString("a;b;c", ';') -> {"a", "b", "c"} splitString(";;", ';') ->
	 * {"", "", ""} splitString("b", ';') -> {"b"} splitString("", ';') -> {""}
	 * 
	 * @param str
	 * @param sep
	 * @return results
	 */
	public static String [] splitString ( String str, char sep ) {
		int strlen = str.length ();
		final char [] NUMERO = { '0', '1', '2', '3', '4', '5', '6', '7', '8',
				'9', '&' };
		StringBuffer datos = new StringBuffer ( UNCERO );

		for ( int i = 0; i < strlen; i++ ) {
			for ( int j = 0; j < NUMERO.length; j++ ) {
				if ( str.charAt ( i ) == NUMERO [j] ) {
					datos = datos.append ( str.charAt ( i ) );
					break;
				}
			}
		}
		final String ELESTR = datos.toString ();
		// Cuenta el nº de elementos
		strlen = ELESTR.length ();
		int numItems = 1; // (mínimo = 1 item)
		for ( int i = 0; i < strlen; i++ ) {
			if ( ELESTR.charAt ( i ) == sep ) {
				numItems++;
			}
		}
		String [] results = new String [numItems];

		// Asigna cada subcadena a cada elemento del array.
		for ( int i = 0, pos = 0, fin = -1; fin < strlen; i++, pos = fin + 1 ) {
			fin = ELESTR.indexOf ( sep, pos );
			if ( fin == -1 ) {
				fin = strlen;
			}
			results [i] = ELESTR.substring ( pos, fin );
		}

		return results;
	}

	/**
	 * Formatea la fecha
	 * 
	 * @param stFecha
	 *            Fecha a formatear
	 * @return Fecha formateada
	 */
	public static String darFormatoFecha ( String stFecha ) {
		final StringBuffer RETFECHA = new StringBuffer ( 50 );
		String dia = ENBLANCO;
		String mes = ENBLANCO;
		String anyo = ENBLANCO;
		final String BAR = "/";

		if ( stFecha != null && !ENBLANCO.equals ( stFecha )
				&& stFecha.length () >= 8 ) {
			dia = stFecha.substring ( 6, 8 );
			mes = stFecha.substring ( 4, 6 );
			anyo = stFecha.substring ( 0, 4 );

			RETFECHA.append ( dia ).append ( BAR ).append ( mes ).append ( BAR )
					.append ( anyo );

		}

		return RETFECHA.toString ();

	}

	/**
	 * Formatea la fecha
	 * 
	 * @param stFecha
	 *            Fecha a formatear
	 * @return Fecha formateada
	 */
	public static Boolean comprobarFormatoFecha ( String stFecha ) {
		String dia = ENBLANCO;
		String mes = ENBLANCO;
		String anyo = ENBLANCO;
		boolean T = true;
		boolean F = false;

		if ( stFecha != null && !ENBLANCO.equals ( stFecha )
				&& stFecha.length () >= 8 ) {
			dia = stFecha.substring ( 6, 8 );
			mes = stFecha.substring ( 4, 6 );
			anyo = stFecha.substring ( 0, 4 );

			if ( ENBLANCO != dia && ENBLANCO != mes && ENBLANCO != anyo ) {
				return T;
			} else {
				return F;
			}

		} else {

			return F;

		}
	}

	/**
	 * Transforma el vector proporcionado del servicio de obtener tablas de la
	 * arquitectura, a otro vector con el formato usado en los desplegables del
	 * formulario.
	 * 
	 * @param datosTabla
	 * @return datosDesplegable
	 */

	public List pasarValoresCombo ( Vector datosTabla ) {

		List <Object> datosDesplegable = Collections
				.synchronizedList ( new Vector <Object> () );

		for ( int i = 0; i < datosTabla.size (); i++ ) {

			CombosBean bean = new CombosBean ();

			final J960J001_Consulta_desplegable_tab_tabla VALUEDESPLEGABLE = ( J960J001_Consulta_desplegable_tab_tabla ) datosTabla
					.get ( i );

			bean.setProp1 ( VALUEDESPLEGABLE.getGEtiqueta () );
			bean.setProp2 ( VALUEDESPLEGABLE.getK2_tab_tabla () );

			datosDesplegable.add ( bean );

		}
		return datosDesplegable;
	}

	/**
	 * Enviando un string y un numero de digitos, se rellena el string con ceros
	 * a la izquierda hasta completar el tamaño. Este metodo se utilizará
	 * principalmente para el campo getPolizaBloq3 del formulario de gestion
	 * expediente general.
	 * 
	 * @param longitud
	 * @param valor
	 * @return valor
	 */
	public String rellenarCerosIzq ( int longitud, String valor ) {

		String valorInicial = valor;

		if ( valor != null ) {

			String valorBuffer = valor;

			for ( int i = valor.length (); i < longitud; i++ ) {

				final StringBuffer VALORCERO = new StringBuffer ( UNCERO );

				valorBuffer = VALORCERO.append ( valorBuffer ).toString ();

			}

			valorInicial = valorBuffer;
		}
		return valorInicial;
	}

	/**
	 * @param valor
	 * @return false
	 */
	public boolean isEntero ( String valor ) {
		try {

			if ( isNull ( valor ) ) {
				return false;
			} else {
				new Integer ( valor );
				return true;
			}
		} catch ( NumberFormatException e ) {
			return false;
		}
	}

	/**
	 * @param valor
	 * @return false
	 */
	public boolean isBigDecimal ( String valor ) {
		try {
			if ( isNull ( valor ) ) {
				return false;
			} else {

				final String VALORSINCOMAS = pasarComaAPunto ( valor );
				new BigDecimal ( VALORSINCOMAS );
				return true;

			}
		} catch ( NumberFormatException e ) {
			return false;
		}
	}

	/**
	 * @param valor
	 * @return false
	 */
	public BigDecimal numeroBig ( String valor ) {
		BigDecimal numero = new BigDecimal ( 0 );
		try {
			if ( !isNull ( valor ) ) {
				final String VALORSINCOMAS = pasarComaAPunto ( valor );
				numero = new BigDecimal ( VALORSINCOMAS );
			}
		} catch ( NumberFormatException e ) {
			return numero;
		}
		return numero;

	}

	/**
	 * @param valor
	 * @return false
	 */
	public int numeroEntero ( String valor ) {
		int numero = 0;
		try {
			if ( !isNull ( valor ) ) {
				final String VALORSINCOMAS = pasarComaAPunto ( valor );
				numero = Integer.parseInt ( VALORSINCOMAS );
			}
		} catch ( NumberFormatException e ) {
			return numero;
		}
		return numero;

	}

	/**
	 * @param valor
	 * @return false
	 */
	public String esCero ( BigDecimal valor ) {
		String numero = "";
		final BigDecimal CERO = new BigDecimal ( 0.00 );

		if ( !valor.equals ( CERO ) ) {
			numero = valor.toString ();
		}

		return numero;
	}

	/**
	 * @param valor
	 * @return false
	 */
	public String esCeroString ( String valor ) {
		String numero = "";
		final String CERO = "0,00";

		if ( !valor.equals ( CERO ) ) {
			numero = valor;
		}

		return numero;
	}

	/**
	 * @param valor
	 * @return false
	 */
	public boolean isNull ( String valor ) {

		if ( valor == null ) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Cambia las comas por puntos en un String
	 * 
	 * @param valor
	 * @return valor
	 */
	public String pasarComaAPunto ( String valor ) {

		final String VALORSINCOMAS = valor.replace ( ",", "." );

		return VALORSINCOMAS;
	}

	/**
	 * Quita los ceros de las cifras retornadas por los servicios cobol
	 * 
	 * @param pStValor
	 *            valor a formatear
	 * @return valor formateado
	 * @throws J362J001RescatesException
	 */
	public static String quitaCeros ( String pStValor )
			throws J372J001VencimientosException {
		final StringBuffer RETORNO = new StringBuffer ( "0" );
		String stSigno = null;
		String stParteEntera = null;
		String stParteReal = null;
		String stResParteEntera = null;
		int intRecorre = 0;
		boolean blContinuar = true;

		if ( pStValor != null && pStValor.compareTo ( ENBLANCO ) != 0 ) {
			if ( pStValor.indexOf ( '.' ) == -1 ) {
				stParteEntera = pStValor;
				stParteReal = ENBLANCO;
			} else {
				stParteEntera = pStValor
						.substring ( 0, pStValor.indexOf ( '.' ) );
				stParteReal = pStValor.substring (
						pStValor.indexOf ( '.' ) + 1, pStValor.length () );

			}

			if ( pStValor.charAt ( 0 ) == '-' ) {
				stSigno = "-";
				stParteEntera = pStValor
						.substring ( 1, stParteEntera.length () );
			} else {
				stSigno = ENBLANCO;
			}
			// for (blContinuar && (intRecorre<stParteEntera.length())){
			while ( ( blContinuar ) && ( intRecorre < stParteEntera.length () ) ) {
				if ( stParteEntera.charAt ( intRecorre ) == '0' ) {
					intRecorre++;
				} else {
					blContinuar = false;
				}
			}

			if ( intRecorre == stParteEntera.length () ) {
				stResParteEntera = "0";
			} else {
				stResParteEntera = stParteEntera.substring ( intRecorre,
						stParteEntera.length () );
			}

			if ( ENBLANCO.equals ( stParteReal ) ) {
				RETORNO.append ( stSigno ).append ( stResParteEntera );
				return RETORNO.toString ();
			} else {
				RETORNO.append ( stSigno ).append ( stResParteEntera ).append (
						"," ).append ( stParteReal );

				return RETORNO.toString ();
			}
		} else {
			return ENBLANCO;
		}

	}
}
