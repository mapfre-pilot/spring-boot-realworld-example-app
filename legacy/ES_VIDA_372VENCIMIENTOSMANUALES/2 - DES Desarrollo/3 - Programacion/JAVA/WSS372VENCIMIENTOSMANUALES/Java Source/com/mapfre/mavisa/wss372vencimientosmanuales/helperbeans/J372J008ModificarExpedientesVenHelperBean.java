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
DESCRIPCION: Incluir "Aï¿½o Fiscal" para informar a la BDGI.
AUTOR : INDRA */

package com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans;

import java.math.BigDecimal;

import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;

import org.apache.log4j.Logger;

import com.mapfre.mavisa.wss372vencimientosmanuales.actions.MapfreAction;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J001BusquedaExpVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J008GestionExpedientesVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J001BusquedaExpVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J008GestionExpedientesVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.servicios.J372J001ServicioBusquedaExpVenBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.servicios.J372J010ServicioBusquedaPersonasVenBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.UtilidadesBeanAction;

/**
 * @author everis
 * @version 1.0 Versiï¿½n inicial Clase de negocio. Recoge los datos del
 *          formulario de entrada y los almacena en una tabla generica. Realiza
 *          la llamada al servicio cobol, recuperando los datos en una tabla
 *          generica. Rellena el obteto de salida con los datos de la tabla de
 *          salida del servicio cobol.
 * 
 */

public class J372J008ModificarExpedientesVenHelperBean extends MapfreAction {

	/**
	 * objTrazas nos mostraralas trazas de cï¿½digo
	 */
	final private static Logger OBJTRAZAS = Logger.getLogger ( J372J008ModificarExpedientesVenHelperBean.class );

	/**
	 * Inicializacion de la variable COMA, valor COMA
	 */
	private static final String COMA = ","; //$NON-NLS-1$

	/**
	 * Inicializacion de la variable PUNTO, valor punto
	 */
	private static final String PUNTO = "."; //$NON-NLS-1$
	// RAROALE - MU-2015-041869 - INI
	/**
	 * Inicializacion de la variable ESPACIOS
	 */
	private static final String ESPACIOS = "";
	
	/**
	 * Inicializacion de la variable CERO
	 */
	private static final String CERO ="0";
	// RAROALE - MU-2015-041869 - FIN
	
	/**
	 * Inicializacion de la variable ANIOMIGRACION
	 */
	private static final String ANIOMIGRACION ="1950";
	
	/**
	 * Mapea datos del form de entrada en el datosEntrada
	 * 
	 * @param form
	 * @param usuario
	 * @return datosEntrada
	 */
	public J372J001BusquedaExpVenPageBean recogerDatosEntrada (
			J372J001BusquedaExpVenActionForm form,
			J000J000Usuario usuario )  {

		J372J001BusquedaExpVenPageBean datosEntrada = new J372J001BusquedaExpVenPageBean();
		final UtilidadesBeanAction UTIL = new UtilidadesBeanAction ();
		

		final String[] KEYVALUES = (form.getAnioSel () != null) ? UTIL.splitString(form.getAnioSel (), '&') : new String[2];
		final BigDecimal EXPSEL = new BigDecimal(KEYVALUES[0] );
		final BigDecimal ANIOSEL = new BigDecimal(KEYVALUES[1] );
		datosEntrada.setExpediente (EXPSEL);
		datosEntrada.setAnio ( ANIOSEL );
		datosEntrada.setUsuario ( usuario );
		/*
		 * toUpperCase nos permite pasar de minuscas a mayusculas la variabble
		 * que nos venga Tambien rellenamos con ceros a la izquierda hasta que
		 * completamos el string
		 */
		datosEntrada.setNifCif ( UTIL.rellenarCerosIzq ( 10, form.getNifCif ()
				.toUpperCase () ) );

		/*
		 * llamamos al metodo de la clase UtilidadesBean, para que rellene el
		 * string con ceros a la izquierda hasta completar el tamaï¿½o.
		 */
		datosEntrada
				.setRdPoliza ( UTIL.rellenarCerosIzq ( 10, form.getPolizaSel() ));
		
		datosEntrada.setRdSubpoliza ( UTIL.rellenarCerosIzq ( 4 , form.getSubpolizaSel () ) );
		
		datosEntrada.setRdCertificado ( UTIL.rellenarCerosIzq ( 6 , form.getCertificadoSel () ) );

		datosEntrada.setAntAnio ( UTIL.numeroBig ( form.getAntAnio () ) );
		
		datosEntrada.setAntExpediente ( UTIL.numeroBig ( form.getAntExpediente () ) );

		datosEntrada.setLugarEnvio ( form.getLugarEnvio () );

		datosEntrada.setFecCalculo ( form.getFecCalculo () );

		datosEntrada.setUsuario ( usuario );

		
		datosEntrada.setOperacion ( "CI" );		

		return datosEntrada;
	}

	/**
	 * Llamada al servicio
	 * 
	 * @param datosEntrada
	 * @return datosSalida
	 * @throws J362J001RescatesException
	 */
	public J372J001BusquedaExpVenPageBean llamarServicio (
			J372J001BusquedaExpVenPageBean datosEntrada )
			throws J372J001VencimientosException {

		J372J001BusquedaExpVenPageBean datosSalida = new J372J001BusquedaExpVenPageBean();

		try {
			datosSalida = J372J001ServicioBusquedaExpVenBean
					.ejecutaServicioCobol ( datosEntrada );

		} catch ( J372J001VencimientosException e ) {
			throw e;
		}
		return datosSalida;
	}
	
	/**
	 * Llamada al servicio
	 * 
	 * @param datosEntrada
	 * @return datosSalida
	 * @throws J362J001RescatesException
	 */
	public J372J008GestionExpedientesVenPageBean llamarServicio (
			J372J008GestionExpedientesVenPageBean datosEntrada )
			throws J372J001VencimientosException {

		J372J008GestionExpedientesVenPageBean datosSalida = new J372J008GestionExpedientesVenPageBean ();

		try {
			datosSalida = J372J010ServicioBusquedaPersonasVenBean.ejecutaServicioCobol ( datosEntrada );
			
			

		} catch ( J372J001VencimientosException e ) {
			throw e;
		}
		return datosSalida;
	}

	
	/**
	 * Completa el bean de salida
	 * 
	 * @param entrada
	 * @param form
	 * @return form
	 * @throws J362J001RescatesException
	 */
	public J372J008GestionExpedientesVenPageBean ponerDatosSalida (
			J372J001BusquedaExpVenPageBean entrada,
			J372J008GestionExpedientesVenPageBean eDatos ) {
		final J372J001BusquedaExpVenPageBean DATOSENTRADA = (J372J001BusquedaExpVenPageBean) entrada.getListadoExp ().get ( 0 );

		// R&V Correccion 03/08/2017-1-3 INI
		eDatos.setRtoIntegroCoa1( DATOSENTRADA.getRtoIntegroCoa1() );
		eDatos.setRtoIntegroCoa2( DATOSENTRADA.getRtoIntegroCoa2() );
		eDatos.setRtoIntegroCoa3( DATOSENTRADA.getRtoIntegroCoa3() );
		eDatos.setRtoIntegroCoa4( DATOSENTRADA.getRtoIntegroCoa4() );
		eDatos.setRtoIntegroCoa5( DATOSENTRADA.getRtoIntegroCoa5() );
		eDatos.setRtoIntegroCoa6( DATOSENTRADA.getRtoIntegroCoa6() );

		eDatos.setRedPrimasCoa1( DATOSENTRADA.getRedPrimasCoa1() );
		eDatos.setRedPrimasCoa2( DATOSENTRADA.getRedPrimasCoa2() );
		eDatos.setRedPrimasCoa3( DATOSENTRADA.getRedPrimasCoa3() );
		eDatos.setRedPrimasCoa4( DATOSENTRADA.getRedPrimasCoa4() );
		eDatos.setRedPrimasCoa5( DATOSENTRADA.getRedPrimasCoa5() );
		eDatos.setRedPrimasCoa6( DATOSENTRADA.getRedPrimasCoa6() );

		eDatos.setRedTransitoriaCoa1( DATOSENTRADA.getRedTransitoriaCoa1() );
		eDatos.setRedTransitoriaCoa2( DATOSENTRADA.getRedTransitoriaCoa2() );
		eDatos.setRedTransitoriaCoa3( DATOSENTRADA.getRedTransitoriaCoa3() );
		eDatos.setRedTransitoriaCoa4( DATOSENTRADA.getRedTransitoriaCoa4() );
		eDatos.setRedTransitoriaCoa5( DATOSENTRADA.getRedTransitoriaCoa5() );
		eDatos.setRedTransitoriaCoa6( DATOSENTRADA.getRedTransitoriaCoa6() );

		eDatos.setRtoNetoCoa1( DATOSENTRADA.getRtoNetoCoa1() );
		eDatos.setRtoNetoCoa2( DATOSENTRADA.getRtoNetoCoa2() );
		eDatos.setRtoNetoCoa3( DATOSENTRADA.getRtoNetoCoa3() );
		eDatos.setRtoNetoCoa4( DATOSENTRADA.getRtoNetoCoa4() );
		eDatos.setRtoNetoCoa5( DATOSENTRADA.getRtoNetoCoa5() );
		eDatos.setRtoNetoCoa6( DATOSENTRADA.getRtoNetoCoa6() );

		eDatos.setRetencionCoa1( DATOSENTRADA.getRetencionCoa1() );
		eDatos.setRetencionCoa2( DATOSENTRADA.getRetencionCoa2() );
		eDatos.setRetencionCoa3( DATOSENTRADA.getRetencionCoa3() );
		eDatos.setRetencionCoa4( DATOSENTRADA.getRetencionCoa4() );
		eDatos.setRetencionCoa5( DATOSENTRADA.getRetencionCoa5() );
		eDatos.setRetencionCoa6( DATOSENTRADA.getRetencionCoa6() );

		eDatos.setCompenCoa1( DATOSENTRADA.getCompenCoa1() );
		eDatos.setCompenCoa2( DATOSENTRADA.getCompenCoa2() );
		eDatos.setCompenCoa3( DATOSENTRADA.getCompenCoa3() );
		eDatos.setCompenCoa4( DATOSENTRADA.getCompenCoa4() );
		eDatos.setCompenCoa5( DATOSENTRADA.getCompenCoa5() );
		eDatos.setCompenCoa6( DATOSENTRADA.getCompenCoa6() );
		// R&V Correccion 03/08/2017-1-3 FIN

		eDatos.setAnio  ( DATOSENTRADA.getAnio () );
		eDatos.setExpediente ( DATOSENTRADA.getExpediente () );
		eDatos.setCanalCamp ( DATOSENTRADA.getCanalCamp ());
		eDatos.setDuracion( new BigDecimal(DATOSENTRADA.getDuracion ()));
		
		eDatos.setTipSituacion( DATOSENTRADA.getTipSituacion() );
		eDatos.setFecAnul( DATOSENTRADA.getFecAnul() );
		
		eDatos.setCertificado ( (DATOSENTRADA.getCertificado () ) );
		eDatos.setCompensaCap ( (DATOSENTRADA.getImpCompensatoria ()) );
		eDatos.setEntidad ( DATOSENTRADA.getEntidad ());
		eDatos.setKPersonaPri ( DATOSENTRADA.getPersona1 ());
		// MU-2016-006673 - RAROALE - INI
		eDatos.setKDomicilioPri(DATOSENTRADA.getDomicilio1());
		eDatos.setFmodificacion(DATOSENTRADA.getFmodificacion());
		// MU-2016-006673 - RAROALE - FIN
		eDatos.setResidentePri ( DATOSENTRADA.getResidente1 () );
		eDatos.setFecEmision ( DATOSENTRADA.getFecEmision () );
		eDatos.setFecEmisionPri ( DATOSENTRADA.getFecCemiComp () );
		eDatos.setFecEmisionComp( DATOSENTRADA.getFecCemiComp2 () );
		eDatos.setFecBDGICap ( DATOSENTRADA.getFecBDGICap () );
		eDatos.setFecBDGIComp1 ( DATOSENTRADA.getFecBDGIComp1 () );
		eDatos.setFecBDGIComp2 ( DATOSENTRADA.getFecBDGIComp2 () );
		eDatos.setSBDGICap ( DATOSENTRADA.getSBDGICap () );
		eDatos.setSBDGIComp ( DATOSENTRADA.getSBDGIComp () );
		eDatos.setSBDGIComp2 ( DATOSENTRADA.getSBDGIComp2 () );
		eDatos.setFecEfect( DATOSENTRADA.getFecEfecto () );
		eDatos.setFecImpreCap ( DATOSENTRADA.getFecImpreCap () );
		eDatos.setFecImprePri ( DATOSENTRADA.getFecImpreComp () );
		eDatos.setFecImpreComp ( DATOSENTRADA.getFecImpreComp2 () );
		eDatos.setFecModi ( DATOSENTRADA.getFecModifica () );
		eDatos.setFecPagoCapital ( DATOSENTRADA.getFecPagoCapital () );
		eDatos.setFecPagoPri ( DATOSENTRADA.getFecPagComp () );
		eDatos.setFecPagoComp ( DATOSENTRADA.getFecPagComp2 () );
		eDatos.setFecPagoIRPFPri ( DATOSENTRADA.getFecPagretCom () );
		eDatos.setFecPagoIRPFCap( DATOSENTRADA.getFecPagret () );
		eDatos.setFecPagoIRPFComp ( DATOSENTRADA.getFecPagretCom2 () );
		eDatos.setFecVencimiento( DATOSENTRADA.getFecVencimientoCap() );
		eDatos.setImpAnticipo ( (DATOSENTRADA.getImpAnticipo () ) );
		eDatos.setBeneficiosPri( (DATOSENTRADA.getImpBeneficios ()) );
		eDatos.setAnticipoPri ( (DATOSENTRADA.getImpAnticipo ()) );
		eDatos.setImpInteresPend( (DATOSENTRADA.getImpInteresPendiente  ()) );
		eDatos.setImpCapital ( DATOSENTRADA.getImpCapital () );
		eDatos.setImportePri (  DATOSENTRADA.getImpComp  () );
		eDatos.setImporteComp( (DATOSENTRADA.getImpComp2 ()) );
		eDatos.setCompensaCap ( (DATOSENTRADA.getImpCompensatoria  ()) );
		eDatos.setRedPrimasCap( (DATOSENTRADA.getImpRedPriCap  ()) );
		eDatos.setRedPrimasPri( (DATOSENTRADA.getImpRedpriComp  ()) );
		eDatos.setRedPrimasComp( (DATOSENTRADA.getImpRedpriComp2  ()) );
		eDatos.setRedTransitCap( (DATOSENTRADA.getImpRedTranCap  ()) );
		eDatos.setRedTransitPri( (DATOSENTRADA.getImpRedTranComp  () ) );
		eDatos.setRedTransitComp( (DATOSENTRADA.getImpRedTranComp2  () ) );
		eDatos.setRetencionCap( (DATOSENTRADA.getImpretCap  ()) );
		eDatos.setRetencionPri(( DATOSENTRADA.getIretComp  ()) );
		eDatos.setRetencionComp(( DATOSENTRADA.getIretComp2  ()) );
		eDatos.setRtoIntegroCap (( DATOSENTRADA.getImpRtorintegrcap  ()) );
		eDatos.setRtoIntegroPri ( (DATOSENTRADA.getImpRtointComp  ()) );
		eDatos.setRtoIntegroComp( (DATOSENTRADA.getImpRtointComp2  ()) );
		eDatos.setRtoNetoCap( (DATOSENTRADA.getImpRtonetoCap () ) );
		eDatos.setRtoNetoPri ( DATOSENTRADA.getIrTonetComp ()  );
		eDatos.setRtoNetoComp ( DATOSENTRADA.getIrTonetComp2 ()  );
		eDatos.setTipImpuestoCap( DATOSENTRADA.getTipImpuestoCap  () );
		eDatos.setTipImpuestoPri( DATOSENTRADA.getTipImpuestComp () );
		eDatos.setTipImpuestoComp ( DATOSENTRADA.getTipImpuestComp2 () );
		eDatos.setPorcentajeCap ( DATOSENTRADA.getPorretCap ());
		eDatos.setPorcentajeComp ( (DATOSENTRADA.getPorretComp () ) );
		eDatos.setPorcentajePri (( DATOSENTRADA.getPorretComp2  () ) );
		eDatos.setLiquidoCap ( ( DATOSENTRADA.getImpliqCap ()) );
		eDatos.setLiquidoPri ( (DATOSENTRADA.getIliqComp () ) );
		eDatos.setLiquidoComp ( DATOSENTRADA.getIliqComp2 () );
		eDatos.setReaseguro( DATOSENTRADA.getReaseguro  ());
		eDatos.setTipPersonaPri ( DATOSENTRADA.getTipoPers1 ());
		eDatos.setModalidad ( (DATOSENTRADA.getModalidad () ) );
		eDatos.setNifCifPri ( DATOSENTRADA.getNif1 () );
		eDatos.setNifCifSeg ( DATOSENTRADA.getNif2 () );
		eDatos.setObservaciones ( DATOSENTRADA.getObservacionesG () );
		eDatos.setOficina ( DATOSENTRADA.getOficina () );
		eDatos.setPendiente ( (DATOSENTRADA.getPendiente () ) );
		eDatos.setPolizaBloq1 ( DATOSENTRADA.getRamo () );
		eDatos.setPolizaBloq2 ( DATOSENTRADA.getAnioPoliza () );
		eDatos.setPolizaBloq3 ( DATOSENTRADA.getNumPoliza () );
		eDatos.setRegionalEnv ( DATOSENTRADA.getLugarEnvio () );
		eDatos.setRegionalPol ( DATOSENTRADA.getRegional () );
		eDatos.setSubpoliza (( DATOSENTRADA.getSubPoliza ()) );
		eDatos.setTotPagMapfre ( DATOSENTRADA.getPagotot () );
		eDatos.setCodCoasegur1 ( DATOSENTRADA.getCodCoA1 () );
		eDatos.setCodCoasegur2 ( DATOSENTRADA.getCodCoA2 () );
		eDatos.setCodCoasegur3 ( DATOSENTRADA.getCodCoA3 () );
		eDatos.setCodCoasegur4 ( DATOSENTRADA.getCodCoA4 () );
		eDatos.setCodCoasegur5 ( DATOSENTRADA.getCodCoA5 () );
		eDatos.setCodCoasegur6 ( DATOSENTRADA.getCodCoA6 () );
		eDatos.setPorCoasegur1 ( (DATOSENTRADA.getPorCoA1 ()) );
		eDatos.setPorCoasegur2 ( (DATOSENTRADA.getPorCoA2 ()) );
		eDatos.setPorCoasegur3 ( (DATOSENTRADA.getPorCoA3 ()) );
		eDatos.setPorCoasegur4 ( (DATOSENTRADA.getPorCoA4 ()) );
		eDatos.setPorCoasegur5 ( (DATOSENTRADA.getPorCoA5 ()) );
		eDatos.setPorCoasegur6 ( (DATOSENTRADA.getPorCoA6 ()) );
		//MU-2016-006664 - RAROALE - INI
		eDatos.setImpCoasegur1((DATOSENTRADA.getImpCoA1()));
		eDatos.setImpCoasegur2((DATOSENTRADA.getImpCoA2()));
		eDatos.setImpCoasegur3((DATOSENTRADA.getImpCoA3()));
		eDatos.setImpCoasegur4((DATOSENTRADA.getImpCoA4()));
		eDatos.setImpCoasegur5((DATOSENTRADA.getImpCoA5()));
		eDatos.setImpCoasegur6((DATOSENTRADA.getImpCoA6()));
		//MU-2016-006664 - RAROALE - INI
		
		eDatos.setTomador( ( (entrada.getTomador() ) ) );
		
		/*  INICIO  MU-2015-041869 */
		eDatos.setAniofiscal( DATOSENTRADA.getAniofiscal()  );
		/*  FIN  MU-2015-041869 */
		
		//R&V - CU009 - INI
		eDatos.setEximido (DATOSENTRADA.getEximido());
		//R&V - CU009 - FIN
		
		eDatos.setVencimientoMigrado(DATOSENTRADA.getVencimientoMigrado());
		eDatos.setUsuarioPagoPri(DATOSENTRADA.getUsuarioPagoPri());
		eDatos.setFecCapturaPri(DATOSENTRADA.getFecCapturaPri());
		eDatos.setUsuarioCapturaPri(DATOSENTRADA.getUsuarioCapturaPri());
		eDatos.setFormaPagoPri(DATOSENTRADA.getFormaPagoPri());
		eDatos.setRefReinversionPri(DATOSENTRADA.getRefReinversionPri());
		eDatos.setNumChequePri(DATOSENTRADA.getNumChequePri());
		eDatos.setNumCuentaPri(DATOSENTRADA.getNumCuentaPri());
		eDatos.setUsuarioPagoComp1(DATOSENTRADA.getUsuarioPagoComp1());
		eDatos.setFecCapturaComp1(DATOSENTRADA.getFecCapturaComp1());
		eDatos.setUsuarioCapturaComp1(DATOSENTRADA.getUsuarioCapturaComp1());
		eDatos.setFormaPagoComp1(DATOSENTRADA.getFormaPagoComp1());
		eDatos.setNumChequeComp1(DATOSENTRADA.getNumChequeComp1());
		eDatos.setNumCuentaComp1(DATOSENTRADA.getNumCuentaComp1());
		eDatos.setUsuarioPagoComp2(DATOSENTRADA.getUsuarioPagoComp2());
		eDatos.setFecCapturaComp2(DATOSENTRADA.getFecCapturaComp2());
		eDatos.setUsuarioCapturaComp2(DATOSENTRADA.getUsuarioCapturaComp2());
		eDatos.setFormaPagoComp2(DATOSENTRADA.getFormaPagoComp2());
		eDatos.setNumChequeComp2(DATOSENTRADA.getNumChequeComp2());
		eDatos.setNumCuentaComp2(DATOSENTRADA.getNumCuentaComp2());		
		eDatos.setDiscapacitadoPri(DATOSENTRADA.getDiscapacitadoPri());
		eDatos.setSitFamiliarPri(DATOSENTRADA.getSitFamiliarPri());
		eDatos.setNifConyugePri(DATOSENTRADA.getNifConyugePri());
		eDatos.setPenComPri(DATOSENTRADA.getPenCompPri());
		eDatos.setAnulAlimenHijosPri(DATOSENTRADA.getAnulAlimenHijosPri());
		eDatos.setPrestViviendoPri(DATOSENTRADA.getPrestViviendoPri());
		
		
		return eDatos;
	}
	//FIN MODIFICACION EVERIS
	
	/**
	 * Completa el bean de salida
	 * 
	 * 
	 * @param eDatos
	 * @return form
	 */
	public J372J008GestionExpedientesVenActionForm ponerDatosFormulario (
			J372J008GestionExpedientesVenPageBean eDatos ) {
		
		final UtilidadesBeanAction UTIL = new UtilidadesBeanAction ();
				
		J372J008GestionExpedientesVenActionForm form = new J372J008GestionExpedientesVenActionForm ();
		form.setAnio  ( eDatos.getAnio ().toString () );
		form.setExpediente ( eDatos.getExpediente ().toString ());
		form.setCanalCamp ( eDatos.getCanalCamp ().replace ( PUNTO , COMA ) );
		form.setDuracion( eDatos.getDuracion ().toString ());
		
		if ( eDatos.getTipSituacion().equals("")) {
			form.setTipSituacion( "VI" );
			form.setDesSituacion("VIGOR");
		} else {
			if ( eDatos.getTipSituacion().equals("V")) {
				form.setTipSituacion( "VI" );
				form.setDesSituacion("VIGOR");
			} else {
				form.setTipSituacion( "AN" );
				form.setDesSituacion("ANULADO");
			}
		}
		form.setFecAnul( eDatos.getFecAnul() );
		
		form.setCertificado ( (eDatos.getCertificado ().toString () ) );
		form.setCompensaCap ( (eDatos.getCompensaCap ().toString ().replace ( PUNTO, COMA )));
		form.setEntidad ( eDatos.getEntidad ().replace ( PUNTO, COMA ) );
		form.setKpersonaPri (  eDatos.getKPersonaPri ().toString ().replace ( PUNTO, COMA ));
		// MU-2016-006673 - RAROALE - INI
		form.setKdomicilioPri( eDatos.getKDomicilioPri().toString().replace ( PUNTO, COMA ));
		form.setFmodificacion( eDatos.getFmodificacion().toString());
		// MU-2016-006673 - RAROALE - FIN
		form.setResidentePri ( eDatos.getResidentePri () );
		// R&V 46-1-372-CU003-CP015 INI
		form.setTipPersonaPri( eDatos.getTipPersonaPri() );
		// R&V 46-1-372-CU003-CP015 FIN
		form.setFecEmision ( eDatos.getFecEmision () );
		form.setFecEmisionPri ( eDatos.getFecEmisionPri () );
		form.setFecEmisionComp( eDatos.getFecEmisionComp () );
		form.setFecBDGICap ( eDatos.getFecBDGICap () );
		form.setFecBDGIComp1 ( eDatos.getFecBDGIComp1 () );
		form.setFecBDGIComp2 ( eDatos.getFecBDGIComp2 () );
		form.setSBDGICap ( eDatos.getSBDGICap () );
		form.setSBDGIComp ( eDatos.getSBDGIComp () );
		form.setSBDGIComp2 ( eDatos.getSBDGIComp2 () );
		form.setFecEfect( eDatos.getFecEfect () );
		form.setFecImpreCap ( eDatos.getFecImpreCap () );
		form.setFecImprePri ( eDatos.getFecImprePri  () );
		form.setFecImpreComp ( eDatos.getFecImpreComp () );
		form.setFecModi ( eDatos.getFecModi () );
		form.setFecPagoCapital ( eDatos.getFecPagoCapital () );
		form.setFecPagoPri ( eDatos.getFecPagoPri () );
		form.setFecPagoComp ( eDatos.getFecPagoComp () );
		form.setFecPagoIRPFCap( eDatos.getFecPagoIRPFCap () );
		form.setFecPagoIRPFPri ( eDatos.getFecPagoIRPFPri () );
		form.setFecPagoIRPFComp ( eDatos.getFecPagoIRPFComp () );
		form.setFecVencimiento( eDatos.getFecVencimiento () );
		form.setImpAnticipo ( (eDatos.getImpAnticipo () ).toString ().replace ( PUNTO, COMA ));
		form.setBeneficiosPri( (eDatos.getBeneficiosPri ()).toString ().replace ( PUNTO, COMA ) );
		form.setAnticipoPri ( (eDatos.getAnticipoPri ()).toString ().replace ( PUNTO, COMA ) );
		form.setImpInteresPend( (eDatos.getImpInteresPend  ()).toString ().replace ( PUNTO, COMA ) );
		form.setImpCapital ( eDatos.getImpCapital ().toString ().replace ( PUNTO, COMA ) );
		form.setImportePri (  eDatos.getImportePri  ().toString ().replace ( PUNTO, COMA ) );
		form.setImporteComp( (eDatos.getImporteComp ()).toString ().replace ( PUNTO, COMA ) );
		form.setCompensaCap ( (eDatos.getCompensaCap ()).toString ().replace ( PUNTO, COMA ) );
		form.setRedPrimasCap( (eDatos.getRedPrimasCap  ()).toString ().replace ( PUNTO, COMA ) );
		form.setRedPrimasPri( (eDatos.getRedPrimasPri  ()).toString ().replace ( PUNTO, COMA ));
		form.setRedPrimasComp( (eDatos.getRedPrimasComp ()).toString ().replace ( PUNTO, COMA ) );
		form.setRedTransitCap( (eDatos.getRedTransitCap  ()).toString ().replace ( PUNTO, COMA ) );
		form.setRedTransitPri( (eDatos.getRedTransitPri  () ).toString ().replace ( PUNTO, COMA ) );
		form.setRedTransitComp( (eDatos.getRedTransitComp  ().toString ().replace ( PUNTO, COMA ) ) );
		form.setRetencionCap( (eDatos.getRetencionCap  ()).toString ().replace ( PUNTO, COMA )  );
		form.setRetencionPri(( eDatos.getRetencionPri  ()).toString ().replace ( PUNTO, COMA )  );
		form.setRetencionComp(( eDatos.getRetencionComp  ()).toString ().replace ( PUNTO, COMA )  );
		form.setRtoIntegroCap (( eDatos.getRtoIntegroCap  ()).toString ().replace ( PUNTO, COMA ) );
		form.setRtoIntegroPri ( (eDatos.getRtoIntegroPri  ()).toString ().replace ( PUNTO, COMA ) );
		form.setRtoIntegroComp( (eDatos.getRtoIntegroComp  ()).toString ().replace ( PUNTO, COMA ) );
		form.setRtoNetoCap( (eDatos.getRtoNetoCap () ).toString ().replace ( PUNTO, COMA ) );
		form.setRtoNetoPri ( eDatos.getRtoNetoPri ().toString ().replace ( PUNTO, COMA ) );
		form.setRtoNetoComp ( eDatos.getRtoNetoComp ().toString ().replace ( PUNTO, COMA )  );
		form.setTipImpuestoCap( eDatos.getTipImpuestoCap  () );
		form.setTipImpuestoPri( eDatos.getTipImpuestoPri () );
		form.setTipImpuestoComp ( eDatos.getTipImpuestoComp () );
		form.setPorcentajeCap ( eDatos.getPorcentajeCap ().toString ().replace ( PUNTO, COMA ));
		form.setPorcentajeComp ( (eDatos.getPorcentajePri () ).toString ().replace ( PUNTO, COMA ) );
		form.setPorcentajePri (( eDatos.getPorcentajeComp () ).toString ().replace ( PUNTO, COMA ) );
		form.setLiquidoCap ( ( eDatos.getLiquidoCap ()).toString ().replace ( PUNTO, COMA ) );
		form.setLiquidoPri ( (eDatos.getLiquidoPri() ).toString ().replace ( PUNTO, COMA ) );
		form.setLiquidoComp ( eDatos.getLiquidoComp ().toString ().replace ( PUNTO, COMA ));
		form.setReaseguro( eDatos.getReaseguro  ().replace ( PUNTO, COMA ) );
		form.setTipPersonaPriValue ( eDatos.getTipPersonaPri ());
		form.setModalidad ( (eDatos.getModalidad () ).toString () );
		form.setNifCifPri ( eDatos.getNifCifPri ());
		form.setObservaciones ( eDatos.getObservaciones () );
		form.setOficina ( eDatos.getOficina () );
		form.setPendiente ( (eDatos.getPendiente ().toString () ).replace ( PUNTO, COMA ) );
		form.setPolizaBloq1 ( eDatos.getPolizaBloq1 () );
		form.setPolizaBloq2 ( eDatos.getPolizaBloq2 () );
		form.setPolizaBloq3 ( eDatos.getPolizaBloq3 () );
		form.setRegionalEnv ( eDatos.getRegionalEnv () );
		form.setRegionalPol ( eDatos.getRegionalPol () );
		form.setSubpoliza ( eDatos.getSubpoliza ().toString () );
		form.setTotPagMapfre ( eDatos.getTotPagMapfre () );
		form.setCodCoasegur1 ( eDatos.getCodCoasegur1 () );
		form.setCodCoasegur2 ( eDatos.getCodCoasegur2 () );
		form.setCodCoasegur3 ( eDatos.getCodCoasegur3 () );
		form.setCodCoasegur4 ( eDatos.getCodCoasegur4 () );
		form.setCodCoasegur5 ( eDatos.getCodCoasegur5 () );
		form.setCodCoasegur6 ( eDatos.getCodCoasegur6 () );
		form.setPorCoasegur1 ( UTIL.esCeroString ( eDatos.getPorCoasegur1 ().toString () .replace ( PUNTO,
				COMA ) ) );
		form.setPorCoasegur2 ( UTIL.esCeroString ( eDatos.getPorCoasegur2 ().toString () .replace ( PUNTO,
				COMA ) ) );
		form.setPorCoasegur3 ( UTIL.esCeroString ( eDatos.getPorCoasegur3 ().toString () .replace ( PUNTO,
				COMA ) ) );
		form.setPorCoasegur4 ( UTIL.esCeroString ( eDatos.getPorCoasegur4 ().toString () .replace ( PUNTO,
				COMA ) ) );
		form.setPorCoasegur5 ( UTIL.esCeroString ( eDatos.getPorCoasegur5 ().toString () .replace ( PUNTO,
				COMA ) ) );
		form.setPorCoasegur6 ( UTIL.esCeroString ( eDatos.getPorCoasegur6 ().toString () .replace ( PUNTO,
				COMA ) ) );
		
		//MU-2016-006664 - RAROALE - INI
		form.setImpCoasegur1(UTIL.esCeroString(eDatos.getImpCoasegur1().toString().replace(PUNTO, COMA)));
		form.setImpCoasegur2(UTIL.esCeroString(eDatos.getImpCoasegur2().toString().replace(PUNTO, COMA)));
		form.setImpCoasegur3(UTIL.esCeroString(eDatos.getImpCoasegur3().toString().replace(PUNTO, COMA)));
		form.setImpCoasegur4(UTIL.esCeroString(eDatos.getImpCoasegur4().toString().replace(PUNTO, COMA)));
		form.setImpCoasegur5(UTIL.esCeroString(eDatos.getImpCoasegur5().toString().replace(PUNTO, COMA)));
		form.setImpCoasegur6(UTIL.esCeroString(eDatos.getImpCoasegur6().toString().replace(PUNTO, COMA)));
		//MU-2016-006664 - RAROALE - INI
		
		form.setNombrePri ( eDatos.getNombrePri () );
		form.setApellido1Pri ( eDatos.getApellido1Pri () );
		form.setApellido2Pri ( eDatos.getApellido2Pri () );
		form.setDomicilioPri ( eDatos.getDomicilioPri () );
		form.setCodPostalPri ( eDatos.getCodPostalPri () );
		form.setLocalidadPri ( eDatos.getLocalidadPri () );
		form.setProvinciaPri ( eDatos.getProvinciaPri () );
		form.setPaisPri ( eDatos.getPaisPri () );
		form.setFecNacPri ( eDatos.getFecNacPri () );
		form.setNifRepLegalPri ( eDatos.getNifRepLegalPri () );
		
		if (form.getAnio().equals(ANIOMIGRACION)) {
		    if (!eDatos.getDiscapacitadoPri().equals("")) {
        		    switch (eDatos.getDiscapacitadoPri().charAt(0)) {
                		case '0':
                		    form.setDiscapacitadoPri("Sin Discapacidad");
                		    break;
                		case '1':
                		    form.setDiscapacitadoPri("Discapacidad Grado 1");
                		    break;
                		case '2':
                		    form.setDiscapacitadoPri("Discapacidad Grado 2");
                		    break;
                		case '3':
                		    form.setDiscapacitadoPri("Discapacidad Grado 3");
                		    break;
        		    }
		    }else {
			form.setDiscapacitadoPri(" ");	
		    }
		    
		}else {
		    form.setDiscapacitadoPri ( eDatos.getDiscapacitadoPri () );
		}
		
		form.setSitFamiliarPri ( eDatos.getSitFamiliarPri () );
		form.setPenCompPri ( UTIL.numeroBig( eDatos.getPenComPri ()).toString () .replace ( PUNTO,
				COMA ) .toString ()  );
		form.setAnulAlimenHijosPri ( UTIL.numeroBig( eDatos.getAnulAlimenHijosPri ()).toString () .replace ( PUNTO,
				COMA ) .toString () );
		form.setNifConyugePri(eDatos.getNifConyugePri());
		form.setPrestViviendoPri(eDatos.getPrestViviendoPri());
		
		form.setTomador(eDatos.getTomador());
		
		/*  INICIO  MU-2015-041869 */
		// RAROALE - MU-2015-041869 - INI
		if (CERO.equals(eDatos.getAniofiscal().toString())) {
			form.setAniofiscal(ESPACIOS);
		} else {
			form.setAniofiscal( eDatos.getAniofiscal().toString() );
		}
		// RAROALE - MU-2015-041869 - FIN
		/*  FIN  MU-2015-041869 */

		//R&V - CU009 - INI
		form.setEximido (eDatos.getEximido().toString());
		//R&V - CU009 - FIN
		
		// R&V Correccion 03/08/2017-1-3 INI
		form.setRtoIntegroCoa1( eDatos.getRtoIntegroCoa1().toString().replace(PUNTO,COMA) );
		form.setRedPrimasCoa1( eDatos.getRedPrimasCoa1().toString().replace(PUNTO,COMA) );
		form.setRedTransitoriaCoa1( eDatos.getRedTransitoriaCoa1().toString().replace(PUNTO,COMA) );
		form.setRtoNetoCoa1( eDatos.getRtoNetoCoa1().toString().replace(PUNTO,COMA) );
		form.setRetencionCoa1( eDatos.getRetencionCoa1().toString().replace(PUNTO,COMA) );
		form.setCompenCoa1( eDatos.getCompenCoa1().toString().replace(PUNTO,COMA) );

		form.setRtoIntegroCoa2( eDatos.getRtoIntegroCoa2().toString().replace(PUNTO,COMA) );
		form.setRedPrimasCoa2( eDatos.getRedPrimasCoa2().toString().replace(PUNTO,COMA) );
		form.setRedTransitoriaCoa2( eDatos.getRedTransitoriaCoa2().toString().replace(PUNTO,COMA) );
		form.setRtoNetoCoa2( eDatos.getRtoNetoCoa2().toString().replace(PUNTO,COMA) );
		form.setRetencionCoa2( eDatos.getRetencionCoa2().toString().replace(PUNTO,COMA) );
		form.setCompenCoa2( eDatos.getCompenCoa2().toString().replace(PUNTO,COMA) );

		form.setRtoIntegroCoa3( eDatos.getRtoIntegroCoa3().toString().replace(PUNTO,COMA) );
		form.setRedPrimasCoa3( eDatos.getRedPrimasCoa3().toString().replace(PUNTO,COMA) );
		form.setRedTransitoriaCoa3( eDatos.getRedTransitoriaCoa3().toString().replace(PUNTO,COMA) );
		form.setRtoNetoCoa3( eDatos.getRtoNetoCoa3().toString().replace(PUNTO,COMA) );
		form.setRetencionCoa3( eDatos.getRetencionCoa3().toString().replace(PUNTO,COMA) );
		form.setCompenCoa3( eDatos.getCompenCoa3().toString().replace(PUNTO,COMA) );

		form.setRtoIntegroCoa4( eDatos.getRtoIntegroCoa4().toString().replace(PUNTO,COMA) );
		form.setRedPrimasCoa4( eDatos.getRedPrimasCoa4().toString().replace(PUNTO,COMA) );
		form.setRedTransitoriaCoa4( eDatos.getRedTransitoriaCoa4().toString().replace(PUNTO,COMA) );
		form.setRtoNetoCoa4( eDatos.getRtoNetoCoa4().toString().replace(PUNTO,COMA) );
		form.setRetencionCoa4( eDatos.getRetencionCoa4().toString().replace(PUNTO,COMA) );
		form.setCompenCoa4( eDatos.getCompenCoa4().toString().replace(PUNTO,COMA) );

		form.setRtoIntegroCoa5( eDatos.getRtoIntegroCoa5().toString().replace(PUNTO,COMA) );
		form.setRedPrimasCoa5( eDatos.getRedPrimasCoa5().toString().replace(PUNTO,COMA) );
		form.setRedTransitoriaCoa5( eDatos.getRedTransitoriaCoa5().toString().replace(PUNTO,COMA) );
		form.setRtoNetoCoa5( eDatos.getRtoNetoCoa5().toString().replace(PUNTO,COMA) );
		form.setRetencionCoa5( eDatos.getRetencionCoa5().toString().replace(PUNTO,COMA) );
		form.setCompenCoa5( eDatos.getCompenCoa5().toString().replace(PUNTO,COMA) );

		form.setRtoIntegroCoa6( eDatos.getRtoIntegroCoa6().toString().replace(PUNTO,COMA) );
		form.setRedPrimasCoa6( eDatos.getRedPrimasCoa6().toString().replace(PUNTO,COMA) );
		form.setRedTransitoriaCoa6( eDatos.getRedTransitoriaCoa6().toString().replace(PUNTO,COMA) );
		form.setRtoNetoCoa6( eDatos.getRtoNetoCoa6().toString().replace(PUNTO,COMA) );
		form.setRetencionCoa6( eDatos.getRetencionCoa6().toString().replace(PUNTO,COMA) );
		form.setCompenCoa6( eDatos.getCompenCoa6().toString().replace(PUNTO,COMA) );
		// R&V Correccion 03/08/2017-1-3 FIN
		
		form.setVencimientoMigrado(eDatos.getVencimientoMigrado());
		form.setUsuarioPagoPri(eDatos.getUsuarioPagoPri());
		form.setFecCapturaPri(eDatos.getFecCapturaPri());
		form.setUsuarioCapturaPri(eDatos.getUsuarioCapturaPri());
		form.setFormaPagoPri(eDatos.getFormaPagoPri());
		if (!form.getFormaPagoPri().equals("")) {
        		switch (form.getFormaPagoPri().charAt(0)) {
        		case 'F':
        		    form.setDescFormaPagoPri("TRANSFERENCIA");
        		    break;
        		case 'Q':
        		    form.setDescFormaPagoPri("CHEQUE");
        		    break;
        		case 'N':
        		    form.setDescFormaPagoPri("REINVERSIÓN NOVA");
        		    break;
        		case 'V':
        		    form.setDescFormaPagoPri("REINVERSIÓN VIDA");
        		    break;
        		case 'I':
        		    form.setDescFormaPagoPri("REINVERSIÓN INVERSIÓN");
        		    break;
        		case 'P':
        		    form.setDescFormaPagoPri("REINVERSIÓN PENSIONES");
        		    break;
        		}        		
		}
		form.setRefReinversionPri(eDatos.getRefReinversionPri());
		form.setNumChequePri(eDatos.getNumChequePri().toString().replace(PUNTO,COMA) );
		form.setNumCuentaPri(eDatos.getNumCuentaPri());
		form.setUsuarioPagoComp1(eDatos.getUsuarioPagoComp1());
		form.setFecCapturaComp1(eDatos.getFecCapturaComp1());
		form.setUsuarioCapturaComp1(eDatos.getUsuarioCapturaComp1());
		form.setFormaPagoComp1(eDatos.getFormaPagoComp1());
		if (!form.getFormaPagoComp1().equals("")) {
        		switch (form.getFormaPagoComp1().charAt(0)) {
        		case 'F':
        		    form.setDescFormaPagoComp1("TRANSFERENCIA");
        		    break;
        		case 'Q':
        		    form.setDescFormaPagoComp1("CHEQUE");
        		    break;		
        		}
		}else {
		    form.setDescFormaPagoComp1(" ");
		}
		form.setNumChequeComp1(eDatos.getNumChequeComp1().toString().replace(PUNTO,COMA) );
		form.setNumCuentaComp1(eDatos.getNumCuentaComp1());
		form.setUsuarioPagoComp2(eDatos.getUsuarioPagoComp2());
		form.setFecCapturaComp2(eDatos.getFecCapturaComp2());
		form.setUsuarioCapturaComp2(eDatos.getUsuarioCapturaComp2());
		form.setFormaPagoComp2(eDatos.getFormaPagoComp2());
		if (!form.getFormaPagoComp2().equals("")) {
        		switch (form.getFormaPagoComp2().charAt(0)) {
        		case 'F':
        		    form.setDescFormaPagoComp2("TRANSFERENCIA");
        		    break;
        		case 'Q':
        		    form.setDescFormaPagoComp2("CHEQUE");
        		    break;		
        		}
		}else {
		    form.setDescFormaPagoComp2(" ");
		}
		form.setNumChequeComp2(eDatos.getNumChequeComp2().toString().replace(PUNTO,COMA) );
		form.setNumCuentaComp2(eDatos.getNumCuentaComp2());

		return form;
		
	}
	
}
