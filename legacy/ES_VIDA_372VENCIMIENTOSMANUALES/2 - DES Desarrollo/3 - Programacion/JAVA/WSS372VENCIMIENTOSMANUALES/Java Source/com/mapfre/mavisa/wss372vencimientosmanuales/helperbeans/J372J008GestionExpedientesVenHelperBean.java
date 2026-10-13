/* MODIFICACION : MU-2016-006673
FECHA : MARZO 2016
DESCRIPCION: Se permite modificar y guardar en BBDD el kdomiclio del beneficiario
AUTOR : RAROALE */

/*MODIFICACION : MU-2016-006664
FECHA : MARZO 2016
DESCRIPCION: Se permite modificar y guardar en BBDD los importes de Coaseguros
AUTOR : RAROALE */

/*MODIFICACION : MU-2015-041869
FECHA : 14/10/2015
DESCRIPCION: Incluir "Año Fiscal" para informar a la BDGI.
AUTOR : INDRA */

package com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans;

import java.util.GregorianCalendar;

import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;
import com.mapfre.mavisa.wss372vencimientosmanuales.actions.MapfreAction;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J001BusquedaExpVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J008GestionExpedientesVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J008GestionExpedientesVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.servicios.J372J005ServicioGestionExpVenBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.UtilidadesBeanAction;
import org.apache.log4j.Logger;

/**
 * @author everis
 * @version 1.0 Versión inicial Clase de negocio. Recoge los datos del
 *          formulario de entrada y los almacena en una tabla generica. Realiza
 *          la llamada al servicio cobol, recuperando los datos en una tabla
 *          generica. Rellena el obteto de salida con los datos de la tabla de
 *          salida del servicio cobol.
 *
 */

public class J372J008GestionExpedientesVenHelperBean extends MapfreAction {

	/**
	 * objTrazas nos mostraralas trazas de código
	 */
	private static Logger OBJTRAZAS = Logger.getLogger ( J372J008GestionExpedientesVenHelperBean.class );

	/**
	 * Inicializacion de la variable COMA, valor COMA
	 */
	private static final String COMA = ",";

	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String PUNTO = ".";

	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";


	/**
	 * Mapea datos del form de entrada en el datosEntrada
	 *
	 * @param form
	 * @param usuario
	 * @return datosEntrada
	 */
	public J372J008GestionExpedientesVenPageBean recogerDatosEntrada (
			J372J008GestionExpedientesVenActionForm form,
			J000J000Usuario usuario )  {

		J372J008GestionExpedientesVenPageBean datosEntrada = new J372J008GestionExpedientesVenPageBean ();
		final UtilidadesBeanAction UTIL = new UtilidadesBeanAction ();

		final StringBuffer VALORMASCERO = new StringBuffer ( "0" );
		final StringBuffer VALORMASCERODIA = new StringBuffer ( "0" );
		datosEntrada.setUsuario ( usuario );
		datosEntrada.setAnio ( UTIL.numeroBig ( form.getAnio () ) );
		datosEntrada.setExpediente ( UTIL.numeroBig ( form.getExpediente () ) );
		datosEntrada.setPolizaBloq2 ( form.getPolizaBloq2 () );
		datosEntrada.setPolizaBloq1 ( form.getPolizaBloq1 () );
		datosEntrada.setPolizaBloq3 ( UTIL.rellenarCerosIzq ( 10, form.getPolizaBloq3 ()) );
		datosEntrada.setSubpoliza ( UTIL.numeroBig (UTIL.rellenarCerosIzq ( 4, form.getSubpoliza () )) );
		datosEntrada.setCertificado ( UTIL.numeroBig (UTIL.rellenarCerosIzq ( 6, form.getCertificado () )) );
		datosEntrada.setModalidad ( UTIL.numeroBig ( form.getModalidad () ) );
		datosEntrada.setCanalCamp ( form.getCanalCamp () );
		datosEntrada.setEntidad ( form.getEntidad () );
		datosEntrada.setTipRescate ( form.getTipRescate () );

		datosEntrada.setTipSituacion(form.getTipSituacion());
		datosEntrada.setFecAnul( form.getFecAnul() );

		datosEntrada.setFecEfect ( form.getFecEfect () );
		datosEntrada.setDuracion ( UTIL.numeroBig ( form.getDuracion () ) );
		datosEntrada.setFecEmision ( form.getFecEmision () );
		datosEntrada.setReaseguro ( form.getReaseguro () );
		datosEntrada.setRegionalEnv ( form.getRegionalEnv () );
		datosEntrada.setOficina ( form.getOficina () );
		datosEntrada.setResidentePri ( form.getResidentePri () );
		datosEntrada.setResidenteSeg ( form.getResidenteSeg () );
		datosEntrada.setObservaciones ( form.getObservaciones () );

		/*INICIO  MU-2015-041869 */
		datosEntrada.setAniofiscal( UTIL.numeroBig( form.getAniofiscal() ) );
		/*FIN  MU-2015-041869 */

		datosEntrada.setPendiente ( UTIL.numeroBig ( form.getPendiente () ) );
		datosEntrada.setTipPersonaPri ( form.getTipPersonaPriValue () );
		/* toUpperCase nos permite pasar de minuscas a mayusculas la variabble
		 * que nos venga Tambien rellenamos con ceros a la izquierda hasta que
		 * completamos el string siempre y cuando no empiece por una letra. */
		if ( !"".equals ( form.getNifCifPri ().trim () ) ) {
			if ( UTIL.isEntero ( form.getNifCifPri ().substring ( 0, 1 ) ) ) {
				datosEntrada.setNifCifPri ( UTIL.rellenarCerosIzq ( 10, form
						.getNifCifPri ().toUpperCase () ) );
			} else {
				datosEntrada
						.setNifCifPri ( form.getNifCifPri ().toUpperCase () );
			}
		}

		datosEntrada.setKPersonaPri ( UTIL.numeroBig ( form.getKpersonaPri () ) );
		// MU-2016-006673 - RAROALE - INI
		datosEntrada.setKDomicilioPri(UTIL.numeroBig(form.getKdomicilioPri()));
		datosEntrada.setFmodificacion(form.getFmodificacion());
		// MU-2016-006673 - RAROALE - FIN
		datosEntrada.setImpCapital ( UTIL.numeroBig ( form.getImpCapital () ) );
		datosEntrada.setBeneficiosPri ( UTIL.numeroBig ( form.getBeneficiosPri () ) );
		datosEntrada.setFecPagoCapital ( form.getFecPagoCapital () );
		datosEntrada.setImpAnticipo ( UTIL.numeroBig ( form.getImpAnticipo () ) );
		datosEntrada.setImpInteresPend ( UTIL.numeroBig ( form.getImpInteresPend () ) );
		datosEntrada.setFecVencimiento ( form.getFecVencimiento () );
		datosEntrada.setTipImpuestoCap ( form.getTipImpuestoCap () );
		datosEntrada.setRtoIntegroCap ( UTIL.numeroBig ( form.getRtoIntegroCap () ) );
		datosEntrada.setRedPrimasCap ( UTIL.numeroBig ( form.getRedPrimasCap () ) );
		datosEntrada.setRedTransitCap ( UTIL.numeroBig ( form.getRedTransitCap () ) );
		datosEntrada.setCompensaCap ( UTIL.numeroBig ( form.getCompensaCap () ) );
        datosEntrada.setRtoNetoCap ( UTIL.numeroBig ( form.getRtoNetoCap () ) );
        datosEntrada.setPorcentajeCap ( UTIL.numeroBig ( form.getPorcentajeCap () ) );
        datosEntrada.setRetencionCap ( UTIL.numeroBig ( form.getRetencionCap () ) );
		datosEntrada.setLiquidoCap ( UTIL.numeroBig ( form.getLiquidoCap () ) );
		datosEntrada.setFecImpreCap ( form.getFecImpreCap () );
		datosEntrada.setFecPagoIRPFCap ( form.getFecPagoIRPFCap () );
		datosEntrada.setImportePri ( UTIL.numeroBig ( form.getImportePri () ) );
		datosEntrada.setFecEmisionPri ( form.getFecEmisionPri () );
		datosEntrada.setFecPagoPri ( form.getFecPagoPri () );
		datosEntrada.setTipImpuestoPri ( form.getTipImpuestoPri () );
		datosEntrada.setRtoIntegroPri ( UTIL.numeroBig ( form.getRtoIntegroPri () ) );
		datosEntrada.setRedPrimasPri ( UTIL.numeroBig ( form.getRedPrimasPri () ) );
		datosEntrada.setRedTransitPri ( UTIL.numeroBig ( form.getRedTransitPri () ) );
        datosEntrada.setRtoNetoPri ( UTIL.numeroBig ( form.getRtoNetoPri () ) );
        datosEntrada.setPorcentajePri ( UTIL.numeroBig ( form.getPorcentajePri () ) );
        datosEntrada.setRetencionCap ( UTIL.numeroBig ( form.getRetencionCap () ) );
		datosEntrada.setRetencionPri ( UTIL.numeroBig ( form.getRetencionPri () ) );
		datosEntrada.setLiquidoPri ( UTIL.numeroBig ( form.getLiquidoPri () ) );
		datosEntrada.setFecImprePri ( form.getFecImprePri () );
		datosEntrada.setFecPagoIRPFPri ( form.getFecPagoIRPFPri () );
		datosEntrada.setCodCoasegur1 ( form.getCodCoasegur1 () );
		datosEntrada.setCodCoasegur2 ( form.getCodCoasegur2 () );
		datosEntrada.setCodCoasegur3 ( form.getCodCoasegur3 () );
		datosEntrada.setCodCoasegur4 ( form.getCodCoasegur4 () );
		datosEntrada.setCodCoasegur5 ( form.getCodCoasegur5 () );
		datosEntrada.setCodCoasegur6 ( form.getCodCoasegur6 () );
		datosEntrada.setPorCoasegur1 ( UTIL.numeroBig ( form.getPorCoasegur1 () ) );
		datosEntrada.setPorCoasegur2 ( UTIL.numeroBig ( form.getPorCoasegur2 () ) );
		datosEntrada.setPorCoasegur3 ( UTIL.numeroBig ( form.getPorCoasegur3 () ) );
		datosEntrada.setPorCoasegur4 ( UTIL.numeroBig ( form.getPorCoasegur4 () ) );
		datosEntrada.setPorCoasegur5 ( UTIL.numeroBig ( form.getPorCoasegur5 () ) );
		datosEntrada.setPorCoasegur6 ( UTIL.numeroBig ( form.getPorCoasegur6 () ) );
		// R&V 48-1-362/372-CU011-CP043-(2) - INI
		datosEntrada.setRtoIntegroCoa1( UTIL.numeroBig ( form.getRtoIntegroCoa1 () ) );
		datosEntrada.setRtoIntegroCoa2( UTIL.numeroBig ( form.getRtoIntegroCoa2 () ) );
		datosEntrada.setRtoIntegroCoa3( UTIL.numeroBig ( form.getRtoIntegroCoa3 () ) );
		datosEntrada.setRtoIntegroCoa4( UTIL.numeroBig ( form.getRtoIntegroCoa4 () ) );
		datosEntrada.setRtoIntegroCoa5( UTIL.numeroBig ( form.getRtoIntegroCoa5 () ) );
		datosEntrada.setRtoIntegroCoa6( UTIL.numeroBig ( form.getRtoIntegroCoa6 () ) );
		datosEntrada.setRedPrimasCoa1( UTIL.numeroBig ( form.getRedPrimasCoa1 () ) );
		datosEntrada.setRedPrimasCoa2( UTIL.numeroBig ( form.getRedPrimasCoa2 () ) );
		datosEntrada.setRedPrimasCoa3( UTIL.numeroBig ( form.getRedPrimasCoa3 () ) );
		datosEntrada.setRedPrimasCoa4( UTIL.numeroBig ( form.getRedPrimasCoa4 () ) );
		datosEntrada.setRedPrimasCoa5( UTIL.numeroBig ( form.getRedPrimasCoa5 () ) );
		datosEntrada.setRedPrimasCoa6( UTIL.numeroBig ( form.getRedPrimasCoa6 () ) );
		datosEntrada.setRedTransitoriaCoa1( UTIL.numeroBig ( form.getRedTransitoriaCoa1 () ) );
		datosEntrada.setRedTransitoriaCoa2( UTIL.numeroBig ( form.getRedTransitoriaCoa2 () ) );
		datosEntrada.setRedTransitoriaCoa3( UTIL.numeroBig ( form.getRedTransitoriaCoa3 () ) );
		datosEntrada.setRedTransitoriaCoa4( UTIL.numeroBig ( form.getRedTransitoriaCoa4 () ) );
		datosEntrada.setRedTransitoriaCoa5( UTIL.numeroBig ( form.getRedTransitoriaCoa5 () ) );
		datosEntrada.setRedTransitoriaCoa6( UTIL.numeroBig ( form.getRedTransitoriaCoa6 () ) );
		datosEntrada.setRtoNetoCoa1( UTIL.numeroBig ( form.getRtoNetoCoa1 () ) );
		datosEntrada.setRtoNetoCoa2( UTIL.numeroBig ( form.getRtoNetoCoa2 () ) );
		datosEntrada.setRtoNetoCoa3( UTIL.numeroBig ( form.getRtoNetoCoa3 () ) );
		datosEntrada.setRtoNetoCoa4( UTIL.numeroBig ( form.getRtoNetoCoa4 () ) );
		datosEntrada.setRtoNetoCoa5( UTIL.numeroBig ( form.getRtoNetoCoa5 () ) );
		datosEntrada.setRtoNetoCoa6( UTIL.numeroBig ( form.getRtoNetoCoa6 () ) );
		datosEntrada.setRetencionCoa1( UTIL.numeroBig ( form.getRetencionCoa1 () ) );
		datosEntrada.setRetencionCoa2( UTIL.numeroBig ( form.getRetencionCoa2 () ) );
		datosEntrada.setRetencionCoa3( UTIL.numeroBig ( form.getRetencionCoa3 () ) );
		datosEntrada.setRetencionCoa4( UTIL.numeroBig ( form.getRetencionCoa4 () ) );
		datosEntrada.setRetencionCoa5( UTIL.numeroBig ( form.getRetencionCoa5 () ) );
		datosEntrada.setRetencionCoa6( UTIL.numeroBig ( form.getRetencionCoa6 () ) );
		datosEntrada.setCompenCoa1( UTIL.numeroBig ( form.getCompenCoa1 () ) );
		datosEntrada.setCompenCoa2( UTIL.numeroBig ( form.getCompenCoa2 () ) );
		datosEntrada.setCompenCoa3( UTIL.numeroBig ( form.getCompenCoa3 () ) );
		datosEntrada.setCompenCoa4( UTIL.numeroBig ( form.getCompenCoa4 () ) );
		datosEntrada.setCompenCoa5( UTIL.numeroBig ( form.getCompenCoa5 () ) );
		datosEntrada.setCompenCoa6( UTIL.numeroBig ( form.getCompenCoa6 () ) );
		// R&V 48-1-362/372-CU011-CP043-(2) - FIN
		// MU-2016-006664 - RAROALE - INI
		datosEntrada.setImpCoasegur1(UTIL.numeroBig(form.getImpCoasegur1()));
		datosEntrada.setImpCoasegur2(UTIL.numeroBig(form.getImpCoasegur2()));
		datosEntrada.setImpCoasegur3(UTIL.numeroBig(form.getImpCoasegur3()));
		datosEntrada.setImpCoasegur4(UTIL.numeroBig(form.getImpCoasegur4()));
		datosEntrada.setImpCoasegur5(UTIL.numeroBig(form.getImpCoasegur5()));
		datosEntrada.setImpCoasegur6(UTIL.numeroBig(form.getImpCoasegur6()));
		// MU-2016-006664 - RAROALE - FIN
		datosEntrada.setTotPagMapfre ( form.getTotPagMapfre () );
		datosEntrada.setFecBDGICap ( form.getFecBDGICap () );
		datosEntrada.setFecBDGIComp1( form.getFecBDGIComp1 () );
		datosEntrada.setFecBDGIComp2 ( form.getFecBDGIComp2 () );
		datosEntrada.setSBDGICap ( form.getSBDGICap () );
		datosEntrada.setSBDGIComp ( form.getSBDGIComp () );
		datosEntrada.setSBDGIComp2 ( form.getSBDGIComp2 () );
		// Complementario2
		datosEntrada.setImporteComp ( UTIL.numeroBig ( form.getImporteComp () ) );
		datosEntrada.setFecEmisionComp ( form.getFecEmisionComp () );
		datosEntrada.setFecPagoComp ( form.getFecPagoComp () );
		datosEntrada.setTipImpuestoComp ( form.getTipImpuestoComp () );
		datosEntrada.setRtoIntegroComp ( UTIL.numeroBig ( form.getRtoIntegroComp () ) );
		datosEntrada.setRedPrimasComp ( UTIL.numeroBig ( form.getRedPrimasComp () ) );
		datosEntrada.setRedTransitComp ( UTIL.numeroBig ( form.getRedTransitComp () ) );
		datosEntrada.setRtoNetoComp ( UTIL.numeroBig ( form.getRtoNetoComp () ) );
		datosEntrada.setPorcentajeComp ( UTIL.numeroBig ( form.getPorcentajeComp () ) );
		datosEntrada.setRetencionComp ( UTIL.numeroBig ( form.getRetencionComp () ) );
		datosEntrada.setLiquidoComp ( UTIL.numeroBig ( form.getLiquidoComp () ) );
		datosEntrada.setFecImpreComp ( form.getFecImpreComp () );
		datosEntrada.setFecPagoIRPFComp ( form.getFecPagoIRPFComp () );
		datosEntrada.setRegionalPol ( form.getRegionalPol () );
		if ( "AL".equals ( form.getTipOperacion () ) ) {
			datosEntrada.setOperacion ( "A1" );
		}

		if ( "MO".equals ( form.getTipOperacion () ) ) {
			datosEntrada.setOperacion ( "M1" );
		}

		// Cargamos la fecha actual en la modificación
		final GregorianCalendar FECHAHOY = new GregorianCalendar ();

		final StringBuffer STRFECHA = new StringBuffer ( "" );

		STRFECHA.append ( FECHAHOY.get ( GregorianCalendar.YEAR ) );

		final String mesActual = String.valueOf ( FECHAHOY.get ( GregorianCalendar.MONTH ) + 1 );
		final String diaActual = String.valueOf ( FECHAHOY.get ( GregorianCalendar.DAY_OF_MONTH ) );

		// Si es menor a dos digitos añadimos un cero.
		if ( mesActual.length () < 2 ) {

			STRFECHA.append ( VALORMASCERO.append ( FECHAHOY.get ( GregorianCalendar.MONTH ) + 1 ) );

		} else {
			STRFECHA.append ( FECHAHOY.get ( GregorianCalendar.MONTH ) + 1 );
		}

		// Si es menos a dos digitos añadimos un cero.
		if ( diaActual.length () < 2 ) {

			STRFECHA.append ( VALORMASCERODIA.append ( FECHAHOY.get ( GregorianCalendar.DAY_OF_MONTH ) ) );

		} else {
			STRFECHA.append ( FECHAHOY.get ( GregorianCalendar.DAY_OF_MONTH ) );
		}

		datosEntrada.setFecModi ( STRFECHA.toString () );

		//R&V - CU009 - INI
		datosEntrada.setEximido( form.getEximido () );
		//R&V - CU009 - FIN

		return datosEntrada;
	}

	/**
	 * Llamada al servicio
	 *
	 * @param datosEntrada
	 * @return datosSalida
	 * @throws J372J001VencimientosException
	 */
	public J372J008GestionExpedientesVenPageBean llamarServicio (
			J372J008GestionExpedientesVenPageBean datosEntrada )
			throws J372J001VencimientosException {

		J372J008GestionExpedientesVenPageBean datosSalida = new J372J008GestionExpedientesVenPageBean ();

		try {
			datosSalida = J372J005ServicioGestionExpVenBean
					.ejecutaServicioCobol ( datosEntrada );

		} catch ( J372J001VencimientosException e ) {
			throw e;
		}
		return datosSalida;
	}

	/**
	 * Completa el bean de salida
	 *
	 * @param datosSalida
	 * @param form
	 * @return form
	 */
	public J372J008GestionExpedientesVenActionForm ponerDatosSalida (
			J372J008GestionExpedientesVenPageBean datosSalida,
			J372J008GestionExpedientesVenActionForm form ) {

		// nos devuelven
		form.setAnio ( datosSalida.getAnio ().toString () );
		form.setFecModi ( datosSalida.getFecModi ().toString () );
		form.setExpediente ( datosSalida.getExpediente ().toString () );
		//FER
//		form.setPolizaBloq2(datosSalida.getAnio ().toString ());
		/*form.setRedPrimasCap ( datosSalida.getRedPrimasCap ().toString ()
				.replace (PUNTO, COMA ) );
		form.setRedTransitCap ( datosSalida.getRedTransitCap ().toString ()
				.replace ( PUNTO, COMA ) );
		form.setRetencionCap ( datosSalida.getRetencionCap ().toString ()
				.replace (PUNTO, COMA ) );
		form.setRtoNetoCap ( datosSalida.getRtoNetoCap ().toString ().replace (
				PUNTO, COMA ) );*/

		// R&V CU006 - 14/Sep - INI
		//int posicion = datosSalida.getDesRetorno().length();
		//if (posicion > 37) {
		//	form.setObservaciones(datosSalida.getDesRetorno().substring(37));
		//}
		// Se comenta el codigo antiguo (anterior) y se iguala con el de rescates (abajo)
		int posicion = datosSalida.getDesRetorno().indexOf("<br>");
		if (posicion > -1) {
			form.setObservaciones(datosSalida.getDesRetorno().substring(posicion + 4));
		}
		// R&V CU006 - 14/Sep - FIN


		form.setDesRetorno ( datosSalida.getDesRetorno () );
		form.setRetorno ( datosSalida.getRetorno () );
		form.setNomPrograma ( datosSalida.getDesRetorno () );
		if ( OBJTRAZAS.isDebugEnabled () ) {
			OBJTRAZAS.debug ( "GestionExpedientesResHelperBean-S: anio "
					+ form.getAnio ().toString () );
			OBJTRAZAS.debug ( "GestionExpedientesResHelperBean-S: Expediente "
					+ form.getExpediente ().toString () );
			OBJTRAZAS.debug ( "GestionExpedientesResHelperBean-S: retorno "
					+ form.getRetorno ().toString () );
			OBJTRAZAS.debug ( "GestionExpedientesResHelperBean-S: desRetorno "
					+ form.getDesRetorno ().toString () );
			OBJTRAZAS.debug ( "GestionExpedientesResHelperBean-S: nomPrograma "
					+ form.getNomPrograma ().toString () );
		}

		return form;
	}


	//INICIO MODIFICACION EVERIS
	public J372J008GestionExpedientesVenActionForm modificarExped (
			J372J001BusquedaExpVenActionForm datosEntrada,
			J372J008GestionExpedientesVenActionForm form ) {

		final UtilidadesBeanAction UTIL = new UtilidadesBeanAction ();

		form.setAnio ( datosEntrada.getAnio () );
		form.setExpediente ( datosEntrada.getExpediente () );
		form.setAnticipoPri ( datosEntrada.getImpAnticipo ().replace (PUNTO, COMA ) );
		form.setBeneficiosPri ( datosEntrada.getImpBeneficios ().replace (PUNTO, COMA ) );
		form.setCanalCamp ( datosEntrada.getCanalCamp ().replace (PUNTO, COMA ) );
		form.setDuracion( datosEntrada.getDuracion ().replace (PUNTO, COMA ) );
		form.setCertificado ( datosEntrada.getCertificado ().replace (PUNTO, COMA ) );
		form.setCompensaPri ( datosEntrada.getImpCompensatoria ().replace (PUNTO, COMA ) );
		form.setEntidad ( datosEntrada.getEntidad ().replace ( PUNTO, COMA ) );

		if ( datosEntrada.getTipSituacion().equals("")) {
			form.setTipSituacion( "VI" );
			form.setDesSituacion("VIGOR");
		} else {
			if ( datosEntrada.getTipSituacion().equals("VI")) {
				form.setTipSituacion( "VI" );
				form.setDesSituacion("VIGOR");
			} else {
				form.setTipSituacion( datosEntrada.getTipSituacion() );
				form.setDesSituacion("ANULADO");
			}
		}
		form.setFecAnul( datosEntrada.getFecAnul() );

		form.setKpersonaPri ( datosEntrada.getPersona1 () );
		// MU-2016-006673 - RAROALE - INI
		form.setKdomicilioPri(datosEntrada.getDomicilio1());
		form.setFmodificacion(datosEntrada.getFmodificacion());
		// MU-2016-006673 - RAROALE - FIN
		form.setResidentePri ( datosEntrada.getResidente1 () );
		form.setFecEmisionComp( datosEntrada.getFecCemiComp () );
		form.setFecBDGICap ( datosEntrada.getFecBDGICap () );
		form.setFecBDGIComp1 ( datosEntrada.getFecBDGIComp1 () );
		form.setFecBDGIComp2 ( datosEntrada.getFecBDGIComp2 () );
		form.setSBDGICap ( datosEntrada.getSBDGICap () );
		form.setSBDGIComp ( datosEntrada.getSBDGIComp () );
		form.setSBDGIComp2 ( datosEntrada.getSBDGIComp2 () );
		form.setFecEfect( datosEntrada.getFecEfecto () );
		form.setFecEmision ( datosEntrada.getFecEmision () );
		form.setFecImpreCap ( datosEntrada.getFecImpreCap () );
		form.setFecImpreComp ( datosEntrada.getFecImpreComp () );
		form.setFecPagoCapital ( datosEntrada.getFecPagoCapital () );
		form.setFecPagoPri ( datosEntrada.getFecPagoCapital () );
		form.setFecPagoIRPFComp ( datosEntrada.getFecPagretCom () );
		form.setFecPagoIRPFPri ( datosEntrada.getFecPagret () );
		form.setFecPagoIRPFCap( datosEntrada.getFecPagoCapital() );
		form.setFecVencimiento( datosEntrada.getFecVencimientoCap() );
		form.setImpReciboComp( datosEntrada.getIliqComp ().replace (PUNTO, COMA ) );
		form.setImpAnticipo ( datosEntrada.getImpAnticipo ().replace (PUNTO, COMA ) );
		form.setBeneficiosPri( datosEntrada.getImpBeneficios ().replace (PUNTO, COMA ) );
		form.setImporteComp( datosEntrada.getImpComp().replace (PUNTO, COMA ) );
		form.setImportePri ( datosEntrada.getImpCapital ().replace (PUNTO, COMA ) );
		form.setImporteComp ( datosEntrada.getImpComp ().replace (PUNTO, COMA ) );
		form.setImporteComp( datosEntrada.getImpCompensatoria  ().replace (PUNTO, COMA ) );
		form.setImpInteresPend( datosEntrada.getImpInteresPendiente  ().replace (PUNTO, COMA ) );
		form.setImpCapital( datosEntrada.getImpliqCap  ().replace (PUNTO, COMA ) );
		form.setRedPrimasCap( datosEntrada.getImpRedPriCap  ().replace (PUNTO, COMA ) );
		form.setRedPrimasComp( datosEntrada.getImpRedpriComp  ().replace (PUNTO, COMA ) );
		form.setRedTransitCap( datosEntrada.getImpRedTranCap  ().replace (PUNTO, COMA ) );
		form.setRedTransitComp( datosEntrada.getImpRedTranComp  ().replace (PUNTO, COMA ) );
		form.setRetencionCap( datosEntrada.getImpretCap  ().replace (PUNTO, COMA ) );
		form.setRtoIntegroComp( datosEntrada.getImpRtointComp  ().replace (PUNTO, COMA ) );
		form.setRtoNetoComp( datosEntrada.getImpRtonetoCap ().replace (PUNTO, COMA ) );
		form.setRtoIntegroCap( datosEntrada.getImpRtorintegrcap  ().replace (PUNTO, COMA ) );
		form.setRetencionComp( datosEntrada.getIretComp  ().replace (PUNTO, COMA ) );
		form.setRtoNetoComp( datosEntrada.getIrTonetComp ().replace (PUNTO, COMA ) );
		form.setTipImpuestoCap( datosEntrada.getTipImpuestoCap  ().replace (PUNTO, COMA ) );
		form.setReaseguro( datosEntrada.getReaseguro  ().replace (PUNTO, COMA ) );
		form.setTipPersonaPriValue( datosEntrada.getTipoPers1 ().replace (PUNTO, COMA ) );
		form.setLiquidoPri ( datosEntrada.getImpliqCap ().replace (PUNTO, COMA ) );
		form.setModalidad ( datosEntrada.getModalidad ().replace (PUNTO, COMA ) );
		form.setNifCifPri ( datosEntrada.getNif1 () );
		form.setNifCifSeg ( datosEntrada.getNif2 () );
		form.setObservaciones ( datosEntrada.getObservacionesG () );
		form.setOficina ( datosEntrada.getOficina () );
		form.setPendiente ( datosEntrada.getPendiente ().replace (PUNTO, COMA ) );
		form.setPolizaBloq1 ( datosEntrada.getRamo () );
		form.setPolizaBloq2 ( datosEntrada.getAnioPoliza () );
		form.setPolizaBloq3 ( datosEntrada.getNumPoliza () );
		form.setPorcentajeCap ( datosEntrada.getPorretCap ().replace (PUNTO, COMA ) );
		form.setPorcentajeComp ( datosEntrada.getPorretComp2 ().replace (PUNTO, COMA ) );
		form.setPorcentajePri ( datosEntrada.getPorretComp1 ().replace (PUNTO, COMA ) );
		form.setRedPrimasPri ( datosEntrada.getImpRedPriCap ().replace (PUNTO, COMA ) );
		form.setRedPrimasComp ( datosEntrada.getImpRedpriComp ().replace (PUNTO, COMA ) );
		form.setRedTransitComp ( datosEntrada.getImpRedTranComp ().replace (PUNTO, COMA ) );
		form.setRedTransitPri ( datosEntrada.getImpRedTranCap ().replace (PUNTO, COMA ) );
		form.setRegionalEnv ( datosEntrada.getLugarEnvio () );
		form.setRegionalPol ( datosEntrada.getRegional () );
		form.setRetencionPri ( datosEntrada.getImpretCap ().replace (PUNTO, COMA ) );
		form.setRtoIntegroComp ( datosEntrada.getImpRtointComp ().replace (PUNTO, COMA ) );
		form.setRtoIntegroPri ( datosEntrada.getImpRtonetoCap ().replace (PUNTO, COMA ) );
		form.setRtoNetoComp ( datosEntrada.getIrTonetComp ().replace (PUNTO, COMA ) );
		form.setRtoNetoPri ( datosEntrada.getImpRtonetoCap ().replace (PUNTO, COMA ) );
		form.setSubpoliza ( datosEntrada.getSubPoliza ().replace (PUNTO, COMA ) );
		form.setTipoImpuestoComp ( datosEntrada.getTipImpuestComp ().replace (PUNTO, COMA ) );
		form.setTotPagMapfre ( datosEntrada.getPagotot () );
		form.setCodCoasegur1 ( datosEntrada.getCodCoA1 () );
		form.setCodCoasegur2 ( datosEntrada.getCodCoA2 () );
		form.setCodCoasegur3 ( datosEntrada.getCodCoA3 () );
		form.setCodCoasegur4 ( datosEntrada.getCodCoA4 () );
		form.setCodCoasegur5 ( datosEntrada.getCodCoA5 () );
		form.setCodCoasegur6 ( datosEntrada.getCodCoA6 () );
		form.setPorCoasegur1 ( datosEntrada.getPorCoA1 ().replace ( PUNTO, COMA ) );
		form.setPorCoasegur2 ( datosEntrada.getPorCoA2 ().replace ( PUNTO, COMA ) );
		form.setPorCoasegur3 ( datosEntrada.getPorCoA3 ().replace ( PUNTO, COMA ) );
		form.setPorCoasegur4 ( datosEntrada.getPorCoA4 ().replace ( PUNTO, COMA ) );
		form.setPorCoasegur5 ( datosEntrada.getPorCoA5 ().replace ( PUNTO, COMA ) );
		form.setPorCoasegur6 ( datosEntrada.getPorCoA6 ().replace ( PUNTO, COMA ) );
		// MU-2016-006664 - RAROALE - INI
		form.setImpCoasegur1(datosEntrada.getImpCoA1().replace(PUNTO, COMA));
		form.setImpCoasegur2(datosEntrada.getImpCoA2().replace(PUNTO, COMA));
		form.setImpCoasegur3(datosEntrada.getImpCoA3().replace(PUNTO, COMA));
		form.setImpCoasegur4(datosEntrada.getImpCoA4().replace(PUNTO, COMA));
		form.setImpCoasegur5(datosEntrada.getImpCoA5().replace(PUNTO, COMA));
		form.setImpCoasegur6(datosEntrada.getImpCoA6().replace(PUNTO, COMA));
		// MU-2016-006664 - RAROALE - INI

		//R&V - CU009 - INI
		form.setEximido( datosEntrada.getEximido());
		//R&V - CU009 - FIN

		// R&V Junio 2017 - REACONDICIONAMIENTO VT01 VT04 - everis(RGL) - INI
		// recojo datos de entrada del formulario form que me pasan
		datosEntrada.setRtoIntegroCoa1(form.getRtoIntegroCoa1().replace(COMA, PUNTO));
		datosEntrada.setRtoIntegroCoa2(form.getRtoIntegroCoa2().replace(COMA, PUNTO));
		datosEntrada.setRtoIntegroCoa3(form.getRtoIntegroCoa3().replace(COMA, PUNTO));
		datosEntrada.setRtoIntegroCoa4(form.getRtoIntegroCoa4().replace(COMA, PUNTO));
		datosEntrada.setRtoIntegroCoa5(form.getRtoIntegroCoa5().replace(COMA, PUNTO));
		datosEntrada.setRtoIntegroCoa6(form.getRtoIntegroCoa6().replace(COMA, PUNTO));
		datosEntrada.setRedPrimasCoa1(form.getRedPrimasCoa1().replace(COMA, PUNTO));
		datosEntrada.setRedPrimasCoa2(form.getRedPrimasCoa2().replace(COMA, PUNTO));
		datosEntrada.setRedPrimasCoa3(form.getRedPrimasCoa3().replace(COMA, PUNTO));
		datosEntrada.setRedPrimasCoa4(form.getRedPrimasCoa4().replace(COMA, PUNTO));
		datosEntrada.setRedPrimasCoa5(form.getRedPrimasCoa5().replace(COMA, PUNTO));
		datosEntrada.setRedPrimasCoa6(form.getRedPrimasCoa6().replace(COMA, PUNTO));
		datosEntrada.setRedTransitoriaCoa1(form.getRedTransitoriaCoa1().replace(COMA, PUNTO));
		datosEntrada.setRedTransitoriaCoa2(form.getRedTransitoriaCoa2().replace(COMA, PUNTO));
		datosEntrada.setRedTransitoriaCoa3(form.getRedTransitoriaCoa3().replace(COMA, PUNTO));
		datosEntrada.setRedTransitoriaCoa4(form.getRedTransitoriaCoa4().replace(COMA, PUNTO));
		datosEntrada.setRedTransitoriaCoa5(form.getRedTransitoriaCoa5().replace(COMA, PUNTO));
		datosEntrada.setRedTransitoriaCoa6(form.getRedTransitoriaCoa6().replace(COMA, PUNTO));
		datosEntrada.setRtoNetoCoa1(form.getRtoNetoCoa1().replace(COMA, PUNTO));
		datosEntrada.setRtoNetoCoa2(form.getRtoNetoCoa2().replace(COMA, PUNTO));
		datosEntrada.setRtoNetoCoa3(form.getRtoNetoCoa3().replace(COMA, PUNTO));
		datosEntrada.setRtoNetoCoa4(form.getRtoNetoCoa4().replace(COMA, PUNTO));
		datosEntrada.setRtoNetoCoa5(form.getRtoNetoCoa5().replace(COMA, PUNTO));
		datosEntrada.setRtoNetoCoa6(form.getRtoNetoCoa6().replace(COMA, PUNTO));
		datosEntrada.setRetencionCoa1(form.getRetencionCoa1().replace(COMA, PUNTO));
		datosEntrada.setRetencionCoa2(form.getRetencionCoa2().replace(COMA, PUNTO));
		datosEntrada.setRetencionCoa3(form.getRetencionCoa3().replace(COMA, PUNTO));
		datosEntrada.setRetencionCoa4(form.getRetencionCoa4().replace(COMA, PUNTO));
		datosEntrada.setRetencionCoa5(form.getRetencionCoa5().replace(COMA, PUNTO));
		datosEntrada.setRetencionCoa6(form.getRetencionCoa6().replace(COMA, PUNTO));
		datosEntrada.setCompenCoa1(form.getCompenCoa1().replace(COMA, PUNTO));
		datosEntrada.setCompenCoa2(form.getCompenCoa2().replace(COMA, PUNTO));
		datosEntrada.setCompenCoa3(form.getCompenCoa3().replace(COMA, PUNTO));
		datosEntrada.setCompenCoa4(form.getCompenCoa4().replace(COMA, PUNTO));
		datosEntrada.setCompenCoa5(form.getCompenCoa5().replace(COMA, PUNTO));
		datosEntrada.setCompenCoa6(form.getCompenCoa6().replace(COMA, PUNTO));
		// R&V Junio 2017 - REACONDICIONAMIENTO VT01 VT04 - everis(RGL) - FIN



		return form;
	}
	//FIN MODIFICACION EVERIS
	
}
