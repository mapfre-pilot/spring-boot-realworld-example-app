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

package com.mapfre.mavisa.wss372vencimientosmanuales.servicios;

import java.math.BigDecimal;
import mapfre.wss000arquitect.accesodatos.Factoria.J000J000Conectable;
import mapfre.wss000arquitect.excepciones.J000J000Exception;
import mapfre.wss000arquitect.utilidades.J000J000Trazas;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J008GestionExpedientesVenPageBean;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

/**
 * @author everis
 * 
 * Clase de negocio. Contiene los metodos necesarios para ejecutar los servicios
 * cobol de carga inicial y de calculo
 * @version 1.0 Versión inicial
 */
public class J372J005ServicioGestionExpVenBean {

	/**
	 * Constructor por defecto PRIVATE
	 * 
	 */
	private J372J005ServicioGestionExpVenBean () {
		// TODO Constructor por defecto PRIVATE
	}

	/**
	 * objTrazas nos mostraralas trazas de código
	 */
	final private static Logger OBJTRAZAS = J000J000Trazas.getLogger ( J372J005ServicioGestionExpVenBean.class );

	/**
	 * Inializacion de la variable CRETORNO_S valor CRETORNO-S
	 */
	private static final String CRETORNO_S = "CRETORNO-S";

	/**
	 * Inializacion de la variable GERROR_S valor GERROR-S
	 */
	private static final String GERROR_S = "GERROR-S";

	/**
	 * Inializacion de la variable GNOMPROG_S valor GNOMPROG-S
	 */
	private static final String GNOMPROG_S = "GNOMPROG-S";

	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inializacion de la variable KEXPEDIENTE_S valor KEXPEDIENTE-S
	 */
	private static final String KEXPEDIENTE_S = "KEXPEDIENTE-S";

	/**
	 * Inializacion de la variable ANIO_S valor ANIO-S
	 */
	private static final String ANIO_S = "ANIO-S";

	/**
	 * Inicializamos el IMPREDPRICAP_S, con valor IMPREDPRICAP-S
	 */
	private static final String IMPREDPRICAP_S = "IMPREDPRICAP-S";

	/**
	 * Inicializamos el IMPREDTRANCAP_S, con valor IMPREDTRANCAP-S
	 */
	private static final String IMPREDTRANCAP_S = "IMPREDTRANCAP-S";

	/**
	 * Inicializamos el IMPRETCAP_S, con valor IMPRETCAP-S
	 */
	private static final String IMPRETCAP_S = "IMPRETCAP-S";

	/**
	 * Inicializamos el IMPRTONETOCAP_S, con valor IMPRTONETOCAP-S
	 */
	private static final String IMPRTONETOCAP_S = "IMPRTONETOCAP-S";

	/**
	 * Inicializamos el CODCALFISCAP_S, con valor CODCALFISCAP-S
	 */
	private static final String CODCALFISCAP_S = "CODCALFISCAP-S";

	/**
	 * Inicializamos el CODCALFISCOMP1_S, con valor CODCALFISCOMP1-S
	 */
	private static final String CODCALFISCOMP1_S = "CODCALFISCOMP1-S";

	/**
	 * Inicializamos el CODCALFISCOMP2_S, con valor CODCALFISCOMP2-S
	 */
	private static final String CODCALFISCOMP2_S = "CODCALFISCOMP2-S";
	
	//MU-2016-006664 - RAROALE - INI
	/**
	 * Inicializamos el IMPCOA1, con valor IMPCOA1-S
	 */
	private static final String IMPCOA1_E = "IMPCOA1-E";
	
	/**
	 * Inicializamos el IMPCOA2, con valor IMPCOA2-S
	 */
	private static final String IMPCOA2_E = "IMPCOA2-E";
	
	/**
	 * Inicializamos el IMPCOA3, con valor IMPCOA3-S
	 */
	private static final String IMPCOA3_E = "IMPCOA3-E";
	
	/**
	 * Inicializamos el IMPCOA4, con valor IMPCOA4-S
	 */
	private static final String IMPCOA4_E = "IMPCOA4-E";
	
	/**
	 * Inicializamos el IMPCOA5, con valor IMPCOA5-S
	 */
	private static final String IMPCOA5_E = "IMPCOA5-E";
	
	/**
	 * Inicializamos el IMPCOA6, con valor IMPCOA6-S
	 */
	private static final String IMPCOA6_E = "IMPCOA6-E";
	//MU-2016-006664 - RAROALE - FIN
	
	// MU-2016-006673 - RAROALE - INI
	/**
	 * Inicializamos el KPERSONA1_E, con valor KPERSONA1-E
	 */
	private static final String KPERSONA1_E = "KPERSONA1-E";
	
	/**
	 * Inicializamos el KDOMICILIO1_E, con valor KDOMICILIO1-E
	 */
	private static final String KDOMICILIO1_E = "KDOMICILIO1-E";
	
	/**
	 * Inicializamos el FECMODIFICA_E, con valor FECMODIFICA-E
	 */
	private static final String FECMODIFICA_E = "FECMODIFICA-E";
	
	// MU-2016-006673 - RAROALE - FIN

	/**
	 * Ejecuta el servicio cobol de carga inicial
	 * 
	 * @param eDatos
	 *            contiene los parametros para hacer la llamada al servicio
	 * @return sDatos datos retornados por el servicio cobol
	 * @throws J372J001VencimientosException
	 */
	public static J372J008GestionExpedientesVenPageBean ejecutaServicioCobol (
			J372J008GestionExpedientesVenPageBean eDatos )
			throws J372J001VencimientosException {

		final J372J003ServicioCobol oGesServicios = new J372J003ServicioCobol ();

		J000J000Conectable oConector;
		J372J008GestionExpedientesVenPageBean sDatos = new J372J008GestionExpedientesVenPageBean ();
		if ( OBJTRAZAS.isDebugEnabled () ) {
			OBJTRAZAS.debug ( "CARGA DE DATOS COBOL" );
		}
		try {
			oConector = oGesServicios.prepararLlamada (
					"IN372VENCIMIENTOSMANUALES",
					"B372VT01GestionExpedientesVen", eDatos.getUsuario () );
			oConector.setCampo ( "KSERVICIO-C", "B372VT01" );
			// cabecera de control
			oConector.setCampo ( "CCANAL-C", "01" );
			oConector.setCampo ( "KEMPRESA-C", "MAV" );
			oConector.setCampo ( "KDEPARTA-C", "ISA" );
			oConector.setCampo ( "KUSUARIO-C", eDatos.getUsuario ()
					.getStUsuario_Racf () );
			oConector.setCampo ( "KCADISTR-C", ENBLANCO );

			// Entrada

			oConector.setCampo ( "OPERACION-E", eDatos.getOperacion ()
					.toString () );
			oConector.setCampo ( "ANIO-E", eDatos.getAnio ().toString () );
			oConector.setCampo ( "KEXPEDIENTE-E", eDatos.getExpediente ()
					.toString () );
			oConector.setCampo ( "KRAMO-E", eDatos.getPolizaBloq1 ()
					.toString () );
			oConector.setCampo ( "ANIOPOL-E", eDatos.getPolizaBloq2 ()
					.toString () );
			oConector.setCampo ( "KPOLIZA-E", eDatos.getPolizaBloq3 ()
					.toString () );
			oConector.setCampo ( "NSUBPOLIZA-E", eDatos.getSubpoliza ()
					.toString () );
			oConector.setCampo ( "KCERTIFICADO-E", eDatos.getCertificado ()
					.toString () );
			oConector.setCampo ( "KMODALIDAD-E", eDatos.getModalidad ()
					.toString () );

			oConector.setCampo ( "CCANALCAMP-E", eDatos.getCanalCamp ()
					.toString () );
			oConector
					.setCampo ( "CENTIDAD-E", eDatos.getEntidad ().toString () );

			oConector.setCampo ( "FECEFECTO-E", eDatos.getFecEfect ()
					.toString () );
			oConector.setCampo ( "KDURACION-E", eDatos.getDuracion ()
					.toString () );
			oConector.setCampo ( "FECEMISION-E", eDatos.getFecEmision ()
					.toString () );
			oConector.setCampo ( "CCARTERA-E", eDatos.getTipRescate ()
					.toString () );
			oConector.setCampo ( "SREASEGURO-E", eDatos.getReaseguro ()
					.toString () );
			oConector.setCampo ( "REGIONAL-E", eDatos.getRegionalPol ()
					.toString () );
			oConector.setCampo ( "LUGARENVIO-E", eDatos.getRegionalEnv ()
					.toString () );
			oConector
					.setCampo ( "KOFICINA-E", eDatos.getOficina ().toString () );
			oConector.setCampo ( "IPENDIENTE-E", eDatos.getPendiente ()
					.toString () );
			oConector.setCampo ( "CTIPOPERS1-E", eDatos.getTipPersonaPri ()
					.toString () );
			oConector.setCampo ( "SRESIDENTE1-E", eDatos.getResidentePri ()
					.toString () );
			oConector.setCampo ( "NIF1-E", eDatos.getNifCifPri ().toString () );
			// MU-2016-006673 - RAROALE - INI
			oConector.setCampo(KPERSONA1_E, eDatos.getKPersonaPri().toString());
			oConector.setCampo(KDOMICILIO1_E, eDatos.getKDomicilioPri().toString());
			oConector.setCampo(FECMODIFICA_E, eDatos.getFecModi().toString());
			// MU-2016-006673 - RAROALE - FIN
			oConector.setCampo ( "IMPCAPITAL-E", eDatos.getImpCapital ()
					.toString () );
			oConector.setCampo ( "IMPBENEFICIOS-E", eDatos.getBeneficiosPri ()
					.toString () );
			oConector.setCampo ( "FECPAGOCAPITAL-E", eDatos
					.getFecPagoCapital ().toString () );

			oConector.setCampo ( "IMPANTICIPO-E", eDatos.getImpAnticipo ()
					.toString () );
			oConector.setCampo ( "IMPINTEPEND-E", eDatos.getImpInteresPend ()
					.toString () );
			oConector.setCampo ( "FECVENCIMICAP-E", eDatos.getFecVencimiento ()
					.toString () );
			oConector.setCampo ( "TIPIMPUESTCAP-E", eDatos.getTipImpuestoCap ()
					.toString () );
			oConector.setCampo ( "IMPRTOINTEGRCAP-E", eDatos
					.getRtoIntegroCap ().toString () );
			oConector.setCampo ( "IMPREDPRICAP-E", eDatos.getRedPrimasCap ()
					.toString () );
			oConector.setCampo ( "IMPREDTRANCAP-E", eDatos.getRedTransitCap ()
					.toString () );
			oConector.setCampo ( "IMPCOMPENSATORIA-E", eDatos.getCompensaCap ()
					.toString () );
			oConector.setCampo ( "IMPRTONETOCAP-E", eDatos.getRtoNetoCap ()
					.toString () );
			oConector.setCampo ( "PORRETCAP-E", eDatos.getPorcentajeCap ()
					.toString () );
			oConector.setCampo ( "IMPRETCAP-E", eDatos.getRetencionCap ()
					.toString () );
			oConector.setCampo ( "IMPLIQCAP-E", eDatos.getLiquidoCap ()
					.toString () );
			oConector.setCampo ( "FECIMPRECAP-E", eDatos.getFecImpreCap ()
					.toString () );

			oConector.setCampo ( "FECPAGRET-E", eDatos.getFecPagoIRPFCap ()
					.toString () );
			oConector.setCampo ( "IMPCOMP1-E", eDatos.getImportePri ()
					.toString () );

			oConector.setCampo ( "FECEMICOMP1-E", eDatos.getFecEmisionPri ()
					.toString () );
			oConector.setCampo ( "FECPAGCOMP1-E", eDatos.getFecPagoPri ()
					.toString () );

			oConector.setCampo ( "TIPIMPUESTCOMP1-E", eDatos
					.getTipImpuestoPri ().toString () );
			oConector.setCampo ( "IMPRTOINTCOMP1-E", eDatos.getRtoIntegroPri ()
					.toString () );
			oConector.setCampo ( "IMPREDPRICOMP1-E", eDatos.getRedPrimasPri ()
					.toString () );
			oConector.setCampo ( "IREDTRANCOMP1-E", eDatos.getRedTransitPri ()
					.toString () );
			oConector.setCampo ( "IRTONETCOMP1-E", eDatos.getRtoNetoPri ()
					.toString () );
			oConector.setCampo ( "PORRETCOMP1-E", eDatos.getPorcentajePri ()
					.toString () );
			oConector.setCampo ( "IRETCOMP1-E", eDatos.getRetencionPri ()
					.toString () );

			oConector.setCampo ( "ILIQCOMP1-E", eDatos.getLiquidoPri ()
					.toString () );

			oConector.setCampo ( "FECIMPRECOMP1-E", eDatos.getFecImprePri ()
					.toString () );

			oConector.setCampo ( "FECPAGRETCOM1-E", eDatos.getFecPagoIRPFPri ()
					.toString () );

			oConector.setCampo ( "IMPCOMP2-E", eDatos.getImporteComp ()
					.toString () );

			oConector.setCampo ( "FECEMICOMP2-E", eDatos.getFecEmisionComp ()
					.toString () );
			oConector.setCampo ( "FECPAGCOMP2-E", eDatos.getFecPagoComp ()
					.toString () );

			oConector.setCampo ( "TIPIMPUESTCOMP2-E", eDatos
					.getTipImpuestoComp ().toString () );
			oConector.setCampo ( "IMPRTOINTCOMP2-E", eDatos
					.getRtoIntegroComp ().toString () );
			oConector.setCampo ( "IMPREDPRICOMP2-E", eDatos.getRedPrimasComp ()
					.toString () );
			oConector.setCampo ( "IREDTRANCOMP2-E", eDatos.getRedTransitComp ()
					.toString () );
			oConector.setCampo ( "IRTONETCOMP2-E", eDatos.getRtoNetoComp ()
					.toString () );
			oConector.setCampo ( "PORRETCOMP2-E", eDatos.getPorcentajeComp ()
					.toString () );
			oConector.setCampo ( "IRETCOMP2-E", eDatos.getRetencionComp ()
					.toString () );

			oConector.setCampo ( "ILIQCOMP2-E", eDatos.getLiquidoComp ()
					.toString () );

			oConector.setCampo ( "FECIMPRECOMP2-E", eDatos.getFecImpreComp ()
					.toString () );

			oConector.setCampo ( "FECPAGRETCOM2-E", eDatos
					.getFecPagoIRPFComp ().toString () );

			// R&V Junio 2017 - REACONDICIONAMIENTO VT01 VT04 - everis(RGL) - INI
			/******************* BLOQUE ORIGINAL INI
			oConector.setCampo ( "CODCOA1-E", eDatos.getCodCoasegur1 ()
					.toString () );
			oConector.setCampo ( "PORCOA1-E", eDatos.getPorCoasegur1 ()
					.toString () );
			oConector.setCampo ( "CODCOA2-E", eDatos.getCodCoasegur2 ()
					.toString () );
			oConector.setCampo ( "PORCOA2-E", eDatos.getPorCoasegur2 ()
					.toString () );
			oConector.setCampo ( "CODCOA3-E", eDatos.getCodCoasegur3 ()
					.toString () );
			oConector.setCampo ( "PORCOA3-E", eDatos.getPorCoasegur3 ()
					.toString () );
			oConector.setCampo ( "CODCOA4-E", eDatos.getCodCoasegur4 ()
					.toString () );
			oConector.setCampo ( "PORCOA4-E", eDatos.getPorCoasegur4 ()
					.toString () );
			oConector.setCampo ( "CODCOA5-E", eDatos.getCodCoasegur5 ()
					.toString () );
			oConector.setCampo ( "PORCOA5-E", eDatos.getPorCoasegur5 ()
					.toString () );
			oConector.setCampo ( "CODCOA6-E", eDatos.getCodCoasegur6 ()
					.toString () );
			oConector.setCampo ( "PORCOA6-E", eDatos.getPorCoasegur6 ()
					.toString () );
			 *********** BLOQUE ORIGINAL FIN *********/
			// R&V Busco cuántas aseguradoras hay contíguas de izq a der.
			int numCoaseguros = 0 ;
			if (eDatos.getCodCoasegur1().trim().compareTo("")!=0){
				numCoaseguros = 1;
				if (eDatos.getCodCoasegur2().trim().compareTo("")!=0){
					numCoaseguros = 2;
					if (eDatos.getCodCoasegur3().trim().compareTo("")!=0){
						numCoaseguros = 3;
						if (eDatos.getCodCoasegur4().trim().compareTo("")!=0){
							numCoaseguros = 4;
							if (eDatos.getCodCoasegur5().trim().compareTo("")!=0){
								numCoaseguros = 5;
								if (eDatos.getCodCoasegur6().trim().compareTo("")!=0){
									numCoaseguros = 6;
								}
							}
						}
					}
				}
			}

			oConector.setCampo("COASEGUROS-OCCURS-E", "6"); //R&V le paso 6 siempre para que COBOL sume bien todos los totales

			// R&V 48-1-362/372-CU011-CP043-(3) - INI
			// Paso a 6 decimales en los porcentajes desde los importes para gardar en BBDD
			int NUMDEC = 6;
			java.math.BigDecimal impCoa1,impCoa2,impCoa3,impCoa4,impCoa5,impCoa6;
			java.math.BigDecimal porCoa1,porCoa2,porCoa3,porCoa4,porCoa5,porCoa6;
			java.math.BigDecimal impCap,impPri,impComp,benePri,impTotal,bdAux;
			java.math.BigDecimal cero = new java.math.BigDecimal("0");
			java.math.BigDecimal cien = new java.math.BigDecimal("100");
			impCap = eDatos.getImpCapital();
			impPri = eDatos.getImportePri();
			impComp = eDatos.getImporteComp();
			benePri = eDatos.getBeneficiosPri();
			impTotal = impCap.add(impPri.add(impComp.add(benePri)));
			impCoa1 = eDatos.getImpCoasegur1();
			impCoa2 = eDatos.getImpCoasegur2();
			impCoa3 = eDatos.getImpCoasegur3();
			impCoa4 = eDatos.getImpCoasegur4();
			impCoa5 = eDatos.getImpCoasegur5();
			impCoa6 = eDatos.getImpCoasegur6();
			if (impTotal.compareTo(cero) == 1 ){ //impTotal>0.0
				porCoa1= impCoa1.multiply(cien).divide(impTotal, NUMDEC, BigDecimal.ROUND_HALF_UP);
				porCoa2= impCoa2.multiply(cien).divide(impTotal, NUMDEC, BigDecimal.ROUND_HALF_UP);
				porCoa3= impCoa3.multiply(cien).divide(impTotal, NUMDEC, BigDecimal.ROUND_HALF_UP);
				porCoa4= impCoa4.multiply(cien).divide(impTotal, NUMDEC, BigDecimal.ROUND_HALF_UP);
				porCoa5= impCoa5.multiply(cien).divide(impTotal, NUMDEC, BigDecimal.ROUND_HALF_UP);
				porCoa6= impCoa6.multiply(cien).divide(impTotal, NUMDEC, BigDecimal.ROUND_HALF_UP);
			} else {
				porCoa1= cero.setScale(NUMDEC, BigDecimal.ROUND_HALF_UP);
				porCoa2= cero.setScale(NUMDEC, BigDecimal.ROUND_HALF_UP);
				porCoa3= cero.setScale(NUMDEC, BigDecimal.ROUND_HALF_UP);
				porCoa4= cero.setScale(NUMDEC, BigDecimal.ROUND_HALF_UP);
				porCoa5= cero.setScale(NUMDEC, BigDecimal.ROUND_HALF_UP);
				porCoa6= cero.setScale(NUMDEC, BigDecimal.ROUND_HALF_UP);
			}
			if (eDatos.getCodCoasegur1().toUpperCase().equals("C0511")) {
				bdAux = porCoa2.add(porCoa3.add(porCoa4.add(porCoa5.add(porCoa6))));
				porCoa1 = cien.subtract(bdAux).setScale(NUMDEC, BigDecimal.ROUND_HALF_UP);
			}
			if (eDatos.getCodCoasegur2().toUpperCase().equals("C0511")) {
				bdAux = porCoa1.add(porCoa3.add(porCoa4.add(porCoa5.add(porCoa6))));
				porCoa2 = cien.subtract(bdAux).setScale(NUMDEC, BigDecimal.ROUND_HALF_UP);
			}
			if (eDatos.getCodCoasegur3().toUpperCase().equals("C0511")) {
				bdAux = porCoa1.add(porCoa2.add(porCoa4.add(porCoa5.add(porCoa6))));
				porCoa3 = cien.subtract(bdAux).setScale(NUMDEC, BigDecimal.ROUND_HALF_UP);
			}
			if (eDatos.getCodCoasegur4().toUpperCase().equals("C0511")) {
				bdAux = porCoa1.add(porCoa2.add(porCoa3.add(porCoa5.add(porCoa6))));
				porCoa4 = cien.subtract(bdAux).setScale(NUMDEC, BigDecimal.ROUND_HALF_UP);
			}
			if (eDatos.getCodCoasegur5().toUpperCase().equals("C0511")) {
				bdAux = porCoa1.add(porCoa2.add(porCoa3.add(porCoa4.add(porCoa6))));
				porCoa5 = cien.subtract(bdAux).setScale(NUMDEC, BigDecimal.ROUND_HALF_UP);
			}
			if (eDatos.getCodCoasegur6().toUpperCase().equals("C0511")) {
				bdAux = porCoa1.add(porCoa2.add(porCoa3.add(porCoa4.add(porCoa5))));
				porCoa6 = cien.subtract(bdAux).setScale(NUMDEC, BigDecimal.ROUND_HALF_UP);
			}
			// R&V 48-1-362/372-CU011-CP043-(3) - FIN


			// R&V Primera coaseguradora
			if (numCoaseguros>=1) { // R&V Si existe esta coaseguradora... informo
				oConector.setCampo("CODCOA-E", eDatos.getCodCoasegur1().toString());
				oConector.setCampo("PORCOA-E", porCoa1.toString()); //R&V 48-1-362/372-CU011-CP043-(3) ANTES eDatos.getPorCoasegur1().toString());
				oConector.setCampo("IMPCOA-E", eDatos.getImpCoasegur1().toString());
				oConector.setCampo("IMPRTOINTEGRCOA-E", eDatos.getRtoIntegroCoa1().toString());
				oConector.setCampo("IMPREDPRICOA-E", eDatos.getRedPrimasCoa1().toString());
				oConector.setCampo("IMPREDTRANCOA-E", eDatos.getRedTransitoriaCoa1().toString());
				oConector.setCampo("IMPRTONETOCOA-E", eDatos.getRtoNetoCoa1().toString());
				oConector.setCampo("IMPRETCOA-E", eDatos.getRetencionCoa1().toString());
				oConector.setCampo("IMPCOMPENSATCOA-E", eDatos.getCompenCoa1().toString());
			} else { // R&V si no existe ... informo con 0's para que COBOL pueda sumar sin dar errores
				oConector.setCampo("CODCOA-E", "");
				oConector.setCampo("PORCOA-E", "0.0");
				oConector.setCampo("IMPCOA-E", "0.0");
				oConector.setCampo("IMPRTOINTEGRCOA-E", "0.0");
				oConector.setCampo("IMPREDPRICOA-E", "0.0");
				oConector.setCampo("IMPREDTRANCOA-E", "0.0");
				oConector.setCampo("IMPRTONETOCOA-E", "0.0");
				oConector.setCampo("IMPRETCOA-E", "0.0");
				oConector.setCampo("IMPCOMPENSATCOA-E", "0.0");
			}

			// R&V Segunda coaseguradora
			oConector.next("COASEGUROS-E");
			if (numCoaseguros>=2) { // R&V Si existe esta coaseguradora... informo
				oConector.setCampo("CODCOA-E", eDatos.getCodCoasegur2().toString());
				oConector.setCampo("PORCOA-E", porCoa2.toString()); //R&V 48-1-362/372-CU011-CP043-(3) ANTES eDatos.getPorCoasegur2().toString());
				oConector.setCampo("IMPCOA-E", eDatos.getImpCoasegur2().toString());
				oConector.setCampo("IMPRTOINTEGRCOA-E", eDatos.getRtoIntegroCoa2().toString());
				oConector.setCampo("IMPREDPRICOA-E", eDatos.getRedPrimasCoa2().toString());
				oConector.setCampo("IMPREDTRANCOA-E", eDatos.getRedTransitoriaCoa2().toString());
				oConector.setCampo("IMPRTONETOCOA-E", eDatos.getRtoNetoCoa2().toString());
				oConector.setCampo("IMPRETCOA-E", eDatos.getRetencionCoa2().toString());
				oConector.setCampo("IMPCOMPENSATCOA-E", eDatos.getCompenCoa2().toString());
			} else { // R&V si no existe ... informo con 0's para que COBOL pueda sumar sin dar errores
				oConector.setCampo("CODCOA-E", "");
				oConector.setCampo("PORCOA-E", "0.0");
				oConector.setCampo("IMPCOA-E", "0.0");
				oConector.setCampo("IMPRTOINTEGRCOA-E", "0.0");
				oConector.setCampo("IMPREDPRICOA-E", "0.0");
				oConector.setCampo("IMPREDTRANCOA-E", "0.0");
				oConector.setCampo("IMPRTONETOCOA-E", "0.0");
				oConector.setCampo("IMPRETCOA-E", "0.0");
				oConector.setCampo("IMPCOMPENSATCOA-E", "0.0");
			}

			// R&V Tercera coaseguradora
			oConector.next("COASEGUROS-E");
			if (numCoaseguros>=3) { // R&V Si existe esta coaseguradora... informo
				oConector.setCampo("CODCOA-E", eDatos.getCodCoasegur3().toString());
				oConector.setCampo("PORCOA-E", porCoa3.toString()); //R&V 48-1-362/372-CU011-CP043-(3) ANTES eDatos.getPorCoasegur3().toString());
				oConector.setCampo("IMPCOA-E", eDatos.getImpCoasegur3().toString());
				oConector.setCampo("IMPRTOINTEGRCOA-E", eDatos.getRtoIntegroCoa3().toString());
				oConector.setCampo("IMPREDPRICOA-E", eDatos.getRedPrimasCoa3().toString());
				oConector.setCampo("IMPREDTRANCOA-E", eDatos.getRedTransitoriaCoa3().toString());
				oConector.setCampo("IMPRTONETOCOA-E", eDatos.getRtoNetoCoa3().toString());
				oConector.setCampo("IMPRETCOA-E", eDatos.getRetencionCoa3().toString());
				oConector.setCampo("IMPCOMPENSATCOA-E", eDatos.getCompenCoa3().toString());
			} else { // R&V si no existe ... informo con 0's para que COBOL pueda sumar sin dar errores
				oConector.setCampo("CODCOA-E", "");
				oConector.setCampo("PORCOA-E", "0.0");
				oConector.setCampo("IMPCOA-E", "0.0");
				oConector.setCampo("IMPRTOINTEGRCOA-E", "0.0");
				oConector.setCampo("IMPREDPRICOA-E", "0.0");
				oConector.setCampo("IMPREDTRANCOA-E", "0.0");
				oConector.setCampo("IMPRTONETOCOA-E", "0.0");
				oConector.setCampo("IMPRETCOA-E", "0.0");
				oConector.setCampo("IMPCOMPENSATCOA-E", "0.0");
			}

			// R&V Cuarta coaseguradora
			oConector.next("COASEGUROS-E");
			if (numCoaseguros>=4) { // R&V Si existe esta coaseguradora... informo
				oConector.setCampo("CODCOA-E", eDatos.getCodCoasegur4().toString());
				oConector.setCampo("PORCOA-E", porCoa4.toString()); //R&V 48-1-362/372-CU011-CP043-(3) ANTES eDatos.getPorCoasegur4().toString());
				oConector.setCampo("IMPCOA-E", eDatos.getImpCoasegur4().toString());
				oConector.setCampo("IMPRTOINTEGRCOA-E", eDatos.getRtoIntegroCoa4().toString());
				oConector.setCampo("IMPREDPRICOA-E", eDatos.getRedPrimasCoa4().toString());
				oConector.setCampo("IMPREDTRANCOA-E", eDatos.getRedTransitoriaCoa4().toString());
				oConector.setCampo("IMPRTONETOCOA-E", eDatos.getRtoNetoCoa4().toString());
				oConector.setCampo("IMPRETCOA-E", eDatos.getRetencionCoa4().toString());
				oConector.setCampo("IMPCOMPENSATCOA-E", eDatos.getCompenCoa4().toString());
			} else { // R&V si no existe ... informo con 0's para que COBOL pueda sumar sin dar errores
				oConector.setCampo("CODCOA-E", "");
				oConector.setCampo("PORCOA-E", "0.0");
				oConector.setCampo("IMPCOA-E", "0.0");
				oConector.setCampo("IMPRTOINTEGRCOA-E", "0.0");
				oConector.setCampo("IMPREDPRICOA-E", "0.0");
				oConector.setCampo("IMPREDTRANCOA-E", "0.0");
				oConector.setCampo("IMPRTONETOCOA-E", "0.0");
				oConector.setCampo("IMPRETCOA-E", "0.0");
				oConector.setCampo("IMPCOMPENSATCOA-E", "0.0");
			}

			// R&V Quinta coaseguradora
			oConector.next("COASEGUROS-E");
			if (numCoaseguros>=5) { // R&V Si existe esta coaseguradora... informo
				oConector.setCampo("CODCOA-E", eDatos.getCodCoasegur5().toString());
				oConector.setCampo("PORCOA-E", porCoa5.toString()); //R&V 48-1-362/372-CU011-CP043-(3) ANTES eDatos.getPorCoasegur5().toString());
				oConector.setCampo("IMPCOA-E", eDatos.getImpCoasegur5().toString());
				oConector.setCampo("IMPRTOINTEGRCOA-E", eDatos.getRtoIntegroCoa5().toString());
				oConector.setCampo("IMPREDPRICOA-E", eDatos.getRedPrimasCoa5().toString());
				oConector.setCampo("IMPREDTRANCOA-E", eDatos.getRedTransitoriaCoa5().toString());
				oConector.setCampo("IMPRTONETOCOA-E", eDatos.getRtoNetoCoa5().toString());
				oConector.setCampo("IMPRETCOA-E", eDatos.getRetencionCoa5().toString());
				oConector.setCampo("IMPCOMPENSATCOA-E", eDatos.getCompenCoa5().toString());
			} else { // R&V si no existe ... informo con 0's para que COBOL pueda sumar sin dar errores
				oConector.setCampo("CODCOA-E", "");
				oConector.setCampo("PORCOA-E", "0.0");
				oConector.setCampo("IMPCOA-E", "0.0");
				oConector.setCampo("IMPRTOINTEGRCOA-E", "0.0");
				oConector.setCampo("IMPREDPRICOA-E", "0.0");
				oConector.setCampo("IMPREDTRANCOA-E", "0.0");
				oConector.setCampo("IMPRTONETOCOA-E", "0.0");
				oConector.setCampo("IMPRETCOA-E", "0.0");
				oConector.setCampo("IMPCOMPENSATCOA-E", "0.0");
			}

			// R&V Sexta coaseguradora
			oConector.next("COASEGUROS-E");
			if (numCoaseguros>=6) { // R&V Si existe esta coaseguradora... informo
				oConector.setCampo("CODCOA-E", eDatos.getCodCoasegur6().toString());
				oConector.setCampo("PORCOA-E", porCoa6.toString()); //R&V 48-1-362/372-CU011-CP043-(3) ANTES eDatos.getPorCoasegur6().toString());
				oConector.setCampo("IMPCOA-E", eDatos.getImpCoasegur6().toString());
				oConector.setCampo("IMPRTOINTEGRCOA-E", eDatos.getRtoIntegroCoa6().toString());
				oConector.setCampo("IMPREDPRICOA-E", eDatos.getRedPrimasCoa6().toString());
				oConector.setCampo("IMPREDTRANCOA-E", eDatos.getRedTransitoriaCoa6().toString());
				oConector.setCampo("IMPRTONETOCOA-E", eDatos.getRtoNetoCoa6().toString());
				oConector.setCampo("IMPRETCOA-E", eDatos.getRetencionCoa6().toString());
				oConector.setCampo("IMPCOMPENSATCOA-E", eDatos.getCompenCoa6().toString());
			} else { // R&V si no existe ... informo con 0's para que COBOL pueda sumar sin dar errores
				oConector.setCampo("CODCOA-E", "");
				oConector.setCampo("PORCOA-E", "0.0");
				oConector.setCampo("IMPCOA-E", "0.0");
				oConector.setCampo("IMPRTOINTEGRCOA-E", "0.0");
				oConector.setCampo("IMPREDPRICOA-E", "0.0");
				oConector.setCampo("IMPREDTRANCOA-E", "0.0");
				oConector.setCampo("IMPRTONETOCOA-E", "0.0");
				oConector.setCampo("IMPRETCOA-E", "0.0");
				oConector.setCampo("IMPCOMPENSATCOA-E", "0.0");
			}
			// R&V Junio 2017 - REACONDICIONAMIENTO VT01 VT04 - everis(RGL) - FIN


			oConector.setCampo ( "PAGOTOT-E", eDatos.getTotPagMapfre ()
					.toString () );

			// R&V Junio 2017 - REACONDICIONAMIENTO VT01 VT04 - everis(RGL) - INI
			/******************* BLOQUE ORIGINAL INI
			// MU-2016-006664 - RAROALE - INI
			oConector.setCampo(IMPCOA1_E, eDatos.getImpCoasegur1().toString());
			oConector.setCampo(IMPCOA2_E, eDatos.getImpCoasegur2().toString());
			oConector.setCampo(IMPCOA3_E, eDatos.getImpCoasegur3().toString());
			oConector.setCampo(IMPCOA4_E, eDatos.getImpCoasegur4().toString());
			oConector.setCampo(IMPCOA5_E, eDatos.getImpCoasegur5().toString());
			oConector.setCampo(IMPCOA6_E, eDatos.getImpCoasegur6().toString());
			************ BLOQUE ORIGINAL FIN */
			// R&V Junio 2017 - REACONDICIONAMIENTO VT01 VT04 - everis(RGL) - FIN

			// MU-2016-006664 - RAROALE - FIN			
			oConector.setCampo ( "FECBDGICAP-E", eDatos.getFecBDGICap ()
					.toString () );
			oConector.setCampo ( "FECBDGICOMP1-E", eDatos.getFecBDGIComp1 ()
					.toString () );
			oConector.setCampo ( "FECBDGICOMP2-E", eDatos.getFecBDGIComp2 ()
					.toString () );
			
			oConector.setCampo ( "SBDGICAP-E", eDatos.getSBDGICap  ()
					.toString () );
			oConector.setCampo ( "SBDGICOMP1-E", eDatos.getSBDGIComp ()
					.toString () );
			oConector.setCampo ( "SBDGICOMP2-E", eDatos.getSBDGIComp2 ()
					.toString () );

			oConector.setCampo ( "GOBSERVACION-E", eDatos.getObservaciones ()
					.toString () );
			
			oConector.setCampo ( "STIPSITUACION-E", eDatos.getTipSituacion()
					.toString () );
			
			oConector.setCampo ( "FANULACION-E", eDatos.getFecAnul()
					.toString () );
			
			/* INICIO  MU-2015-041869*/
			oConector.setCampo( "ANIOFISCAL-E", eDatos.getAniofiscal().toString() );
			/* FIN  MU-2015-041869*/

			// R&V Junio 2017 - CU011 - everis(RGL) - INI
			//oConector.setCampo( "FECMODIFICA-E", eDatos.getFecModi().toString() ); // Este campo no estaba antes lo dejo, por ahora comentado
			oConector.setCampo( "EXIMIDO-E", eDatos.getEximido().toString() );
			oConector.setCampo( "KDOMCOM-E", eDatos.getKdomcom().toString() );
			// R&V Junio 2017 - CU011 - everis(RGL) - FIN


			oConector.ejecutarServicio ();

			final String sResultado = oConector.getCampo ( CRETORNO_S );

			if ( OBJTRAZAS.isDebugEnabled () ) {
				OBJTRAZAS.debug ( "ServicioGestionExpVenBean: KEXPEDIENTE-S = "
						+ oConector.getCampo ( KEXPEDIENTE_S ) );
				OBJTRAZAS.debug ( "ServicioGestionExpVenBean: ANIO-S   = "
						+ oConector.getCampo ( ANIO_S ) );
				OBJTRAZAS.debug ( "ServicioGestionExpVenBean: GNOMPROG-S = "
						+ oConector.getCampo ( GNOMPROG_S ) );
				OBJTRAZAS.debug ( "ServicioGestionExpVenBean: GERROR-S   = "
						+ oConector.getCampo ( GERROR_S ) );
				OBJTRAZAS.debug ( "ServicioGestionExpVenBean: CRETORNO-S = "
						+ oConector.getCampo ( CRETORNO_S ) );
			}
			if ( sResultado.compareTo ( "00" ) == 0 ) {
				if ( ENBLANCO.equals ( oConector.getCampo ( ANIO_S ) ) ) {
					sDatos.setAnio ( new BigDecimal ( 0 ) );
				} else {
					sDatos.setAnio ( new BigDecimal ( oConector
							.getCampo ( ANIO_S ) ) );
				}

				if ( ENBLANCO.equals ( oConector.getCampo ( KEXPEDIENTE_S ) ) ) {
					sDatos.setExpediente ( new BigDecimal ( 0 ) );
				} else {
					sDatos.setExpediente ( new BigDecimal ( oConector
							.getCampo ( KEXPEDIENTE_S ) ) );
				}

				if ( ENBLANCO.equals ( oConector.getCampo ( IMPREDPRICAP_S ) ) ) {
					sDatos.setRedPrimasPri ( new BigDecimal ( 0 ) );
				} else {
					sDatos.setRedPrimasPri ( new BigDecimal ( oConector
							.getCampo ( IMPREDPRICAP_S ) ) );
				}

				if ( ENBLANCO.equals ( oConector.getCampo ( IMPREDTRANCAP_S ) ) ) {
					sDatos.setRedTransitPri ( new BigDecimal ( 0 ) );
				} else {
					sDatos.setRedTransitPri ( new BigDecimal ( oConector
							.getCampo ( IMPREDTRANCAP_S ) ) );
				}

				if ( ENBLANCO.equals ( oConector.getCampo ( IMPRETCAP_S ) ) ) {
					sDatos.setRetencionPri ( new BigDecimal ( 0 ) );
				} else {
					sDatos.setRetencionPri ( new BigDecimal ( oConector
							.getCampo ( IMPRETCAP_S ) ) );
				}

				if ( ENBLANCO.equals ( oConector.getCampo ( IMPRTONETOCAP_S ) ) ) {
					sDatos.setRtoNetoPri ( new BigDecimal ( 0 ) );
				} else {
					sDatos.setRtoNetoPri ( new BigDecimal ( oConector
							.getCampo ( IMPRTONETOCAP_S ) ) );
				}
				sDatos.setDesRetorno ( oConector.getCampo ( GERROR_S ) );
				if (sResultado.compareTo ( "00" ) == 0 ) {
					//R&V - CU006 - INI
					//Si ya existe otro expediente con esa misma poliza me retornara una S en la ultima posicion de DesRetorno
					//y en ese caso mostrare mensaje adicional.
					String stResultado = "";
					if (sDatos.getDesRetorno()!=null && sDatos.getDesRetorno().length()>0) {
						String estaPolizaEnOtroExp = sDatos.getDesRetorno().substring(sDatos.getDesRetorno().length()-1);
						if (estaPolizaEnOtroExp != null && estaPolizaEnOtroExp != "" && estaPolizaEnOtroExp != " "
								&& estaPolizaEnOtroExp.equals("S")) {
							stResultado       += "Ya existe esta póliza en otro expediente. "; // R&V CU006 - 14/Sep Quitamos <br> del final
							sDatos.setDesRetorno(sDatos.getDesRetorno().substring(0,sDatos.getDesRetorno().length()-1));
						}
					}
					//String stResultado = "Operación realizada correctamente" + "<br>";
					stResultado += "Operación realizada correctamente" + "<br>";
					//R&V - CU006 - FIN

					stResultado       += sDatos.getDesRetorno();
					sDatos.setDesRetorno ( stResultado.toString() );
				}
				
				sDatos.setRetorno ( oConector.getCampo ( CRETORNO_S ) );
				sDatos.setNomPrograma ( oConector.getCampo ( GNOMPROG_S ) );
				if ( OBJTRAZAS.isDebugEnabled () ) {
					OBJTRAZAS
							.debug ( "ServicioGestionExpVenBean: GNOMPROG-S = "
									+ oConector.getCampo ( GNOMPROG_S ) );
					OBJTRAZAS
							.debug ( "ServicioGestionExpVenBean: GERROR-S   = "
									+ oConector.getCampo ( GERROR_S ) );
					OBJTRAZAS
							.debug ( "ServicioGestionExpVenBean: CRETORNO-S = "
									+ oConector.getCampo ( CRETORNO_S ) );
				}
				return sDatos;
			} else {
				if ( OBJTRAZAS.isEnabledFor ( Level.ERROR ) ) {
					OBJTRAZAS
							.error ( "ServicioGestionExpVenBean: GNOMPROG-S = "
									+ oConector.getCampo ( GNOMPROG_S ) );
					OBJTRAZAS
							.error ( "ServicioGestionExpVenBean: GERROR-S   = "
									+ oConector.getCampo ( GERROR_S ) );
					OBJTRAZAS
							.error ( "ServicioGestionExpVenBean: CRETORNO-S = "
									+ oConector.getCampo ( CRETORNO_S ) );
				}
				final StringBuffer descripcion = new StringBuffer ( "0" );
				J372J001VencimientosException objException = 
							new J372J001VencimientosException (J372J001VencimientosException.ERROR_NEGOCIO, ENBLANCO );
				objException.setStMetodo ( "ejecutaServicio()" );

				descripcion.append ( sResultado ).append ( ": " ).append (
						oConector.getCampo ( GERROR_S ) );
				objException.setStDescripcion ( descripcion.toString () );

				objException.setStGNomProg ( oConector.getCampo ( GNOMPROG_S ) );
				objException.setStGError ( oConector.getCampo ( GERROR_S ) );
				objException.setStCRetorno ( oConector.getCampo ( CRETORNO_S ) );
				throw objException;
			}

		} catch ( J372J001VencimientosException e ) {
			throw e;
		} catch ( J000J000Exception e ) {
			J372J001VencimientosException objException = new J372J001VencimientosException (
					J372J001VencimientosException.ERROR_GENERICO_CICS, ENBLANCO );
			objException.setStDescripcion ( e.getLocalizedMessage () );
			objException.setStClase ( e.getClass ().toString () );
			objException.setStGNomProg ( ENBLANCO );
			objException.setStGError ( "Error Genérico CICS" );
			objException.setStCRetorno ( ENBLANCO );

			throw objException;
		}

	}

}
