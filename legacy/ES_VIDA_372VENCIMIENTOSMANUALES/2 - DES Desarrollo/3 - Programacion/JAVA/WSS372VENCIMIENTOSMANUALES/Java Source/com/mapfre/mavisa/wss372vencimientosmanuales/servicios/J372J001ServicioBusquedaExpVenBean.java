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
DESCRIPCION: Incluir "A�o Fiscal" para informar a la BDGI.
AUTOR : INDRA */

package com.mapfre.mavisa.wss372vencimientosmanuales.servicios;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import mapfre.wss000arquitect.accesodatos.Factoria.J000J000Conectable;
import mapfre.wss000arquitect.excepciones.J000J000Exception;
import mapfre.wss000arquitect.utilidades.J000J000Trazas;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J001BusquedaExpVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.UtilidadesBeanAction;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;

/**
 * @author everis
 * 
 * Clase de negocio. Contiene los metodos necesarios para ejecutar los servicios
 * cobol de carga inicial y de calculo
 * @version 1.0 Versi�n inicial
 */
public class J372J001ServicioBusquedaExpVenBean {

	/**
	 * Constructor por defecto PRIVATE
	 * 
	 */
	private J372J001ServicioBusquedaExpVenBean () {
		// TODO Constructor por defecto PRIVATE
	}

	/**
	 * objTrazas nos mostraralas trazas de c�digo
	 */
	public static Logger objTrazas = J000J000Trazas
			.getLogger(J372J001ServicioBusquedaExpVenBean.class);

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
	 * Inicializacion de la variable PRO_ANIO_S, valor PRO-ANIO-S
	 */
	private static final String PRO_ANIO_S = "PRO-ANIO-S";
	
	/**
	 * Inicializacion de la variable PRO_KEXPEDIENTE_S, valor PRO_KEXPEDIENTE-S
	 */
	private static final String PRO_KEXPEDIENTE_S = "PRO-KEXPEDIENTE-S";
	
	/**
	 * Inicializacion de la variable ANIO_S, valor ANIO-S
	 */
	private static final String ANIO_S = "ANIO-S";
	
	/**
	 * Inicializacion de la variable KEXPEDIENTE_S, valor KEXPEDIENTE-S
	 */
	private static final String KEXPEDIENTE_S = "KEXPEDIENTE-S";
	
	/**
	 * Inicializacion de la variable NSUBPOLIZA_S, valor NSUBPOLIZA-S
	 */
	private static final String NSUBPOLIZA_S = "NSUBPOLIZA-S";
	
	/**
	 * Inicializacion de la variable KCERTIFICADO_S, valor KCERTIFICADO-S
	 */
	private static final String KCERTIFICADO_S = "KCERTIFICADO-S";
	
	/**
	 * Inicializacion de la variable KMODALIDAD_S, valor KMODALIDAD-S
	 */
	private static final String KMODALIDAD_S = "KMODALIDAD-S";
	
	/**
	 * Inicializacion de la variable IPENDIENTE_S, valor IPENDIENTE-S
	 */
	private static final String IPENDIENTE_S = "IPENDIENTE-S";
	
	/**
	 * Inicializacion de la variable KPERSONA1_S, valor KPERSONA1-S
	 */
	private static final String KPERSONA1_S = "KPERSONA1-S";
	
	/**
	 * Inicializamos el IMPCAPITAL_S, con valor IMPCAPITAL_S
	 */
	private static final String IMPCAPITAL_S = "IMPCAPITAL-S";
	
	/**
	 * Inicializamos el IMPBENEFICIOS_S, con valor IMPBENEFICIOS_S
	 */
	private static final String IMPBENEFICIOS_S = "IMPBENEFICIOS-S";
	
	/**
	 * Inicializamos el IMPANTICIPO_S, con valor IMPANTICIPO_S
	 */
	private static final String IMPANTICIPO_S = "IMPANTICIPO-S";
	
	/**
	 * Inicializamos el IMPINTEPEND_S, con valor IMPINTEPEND_S
	 */
	private static final String IMPINTEPEND_S = "IMPINTEPEND-S";
	
	/**
	 * Inicializamos el IMPREDPRICAP_S, con valor IMPREDPRICAP_S
	 */
	private static final String IMPREDPRICAP_S = "IMPREDPRICAP-S";
	
	/**
	 * Inicializamos el IMPREDTRANCAP_S, con valor IMPREDTRANCAP_S
	 */
	private static final String IMPREDTRANCAP_S = "IMPREDTRANCAP-S";
	
	/**
	 * Inicializamos el IMPRTONETOCAP_S, con valor IMPRTONETOCAP_S
	 */
	private static final String IMPRTONETOCAP_S = "IMPRTONETOCAP-S";
	
	/**
	 * Inicializamos el PORRETCAP_S, con valor PORRETCAP_S
	 */
	private static final String PORRETCAP_S = "PORRETCAP-S";
	
	/**
	 * Inicializamos el IMPRETCAP_S, con valor IMPRETCAP_S
	 */
	private static final String IMPRETCAP_S = "IMPRETCAP-S";
	
	/**
	 * Inicializamos el IMPLIQCAP_S, con valor IMPLIQCAP_S
	 */
	private static final String IMPLIQCAP_S = "IMPLIQCAP-S";	
	
	/**
	 * Inicializamos el IMPCOMP1_S, con valor IMPCOMP1_S
	 */
	private static final String IMPCOMP1_S = "IMPCOMP1-S";
	
	/**
	 * Inicializamos el IMPRTOINTCOMP1_S, con valor IMPRTOINTCOMP1_S
	 */
	private static final String IMPRTOINTCOMP1_S = "IMPRTOINTCOMP1-S";
	
	/**
	 * Inicializamos el IMPREDPRICOMP1_S, con valor IMPREDPRICOMP1_S
	 */
	private static final String IMPREDPRICOMP1_S = "IMPREDPRICOMP1-S";
	
	/**
	 * Inicializamos el IREDTRANCOMP1_S, con valor IREDTRANCOMP1_S
	 */
	private static final String IREDTRANCOMP1_S = "IREDTRANCOMP1-S";
	
	/**
	 * Inicializamos el IRTONETCOMP1_S, con valor IRTONETCOMP1_S
	 */
	private static final String IRTONETCOMP1_S = "IRTONETCOMP1-S";
	
	/**
	 * Inicializamos el PORRETCOMP1_S, con valor PORRETCOMP1_S
	 */
	private static final String PORRETCOMP1_S = "PORRETCOMP1-S";
	
	/**
	 * Inicializamos el IRETCOMP1_S, con valor IRETCOMP1_S
	 */
	private static final String IRETCOMP1_S = "IRETCOMP1-S";
	
	/**
	 * Inicializamos el ILIQCOMP1_S, con valor ILIQCOMP1_S
	 */
	private static final String ILIQCOMP1_S = "ILIQCOMP1-S";	
	
	/**
	 * Inicializamos el IMPCOMP2_S, con valor IMPCOMP2_S
	 */
	private static final String IMPCOMP2_S = "IMPCOMP2-S";
	
	/**
	 * Inicializamos el IMPRTOINTCOMP2_S, con valor IMPRTOINTCOMP2_S
	 */
	private static final String IMPRTOINTCOMP2_S = "IMPRTOINTCOMP2-S";
	
	/**
	 * Inicializamos el IMPREDPRICOMP2_S, con valor IMPREDPRICOMP2_S
	 */
	private static final String IMPREDPRICOMP2_S = "IMPREDPRICOMP2-S";
	
	/**
	 * Inicializamos el IREDTRANCOMP2_S, con valor IREDTRANCOMP2_S
	 */
	private static final String IREDTRANCOMP2_S = "IREDTRANCOMP2-S";
	
	/**
	 * Inicializamos el IMPCOMPENSATORIA_S, con valor IMPCOMPENSATORIA_S
	 */
	private static final String IMPCOMPENSATORIA_S= "IMPCOMPENSATORIA-S";
	
	/**
	 * Inicializamos el IRTONETCOMP2_S, con valor IRTONETCOMP2_S
	 */
	private static final String IRTONETCOMP2_S = "IRTONETCOMP2-S";
	
	/**
	 * Inicializamos el PORRETCOMP2_S, con valor PORRETCOMP2_S
	 */
	private static final String PORRETCOMP2_S = "PORRETCOMP2-S";
	
	/**
	 * Inicializamos el IRETCOMP2_S, con valor IRETCOMP2_S
	 */
	private static final String IRETCOMP2_S = "IRETCOMP2-S";
	
	/**
	 * Inicializamos el ILIQCOMP2_S, con valor ILIQCOMP2_S
	 */
	private static final String ILIQCOMP2_S = "ILIQCOMP2-S";	
	
	/**
	 * Inicializamos el PORCOA1_S, con valor PORCOA1_S
	 */
	private static final String PORCOA1_S = "PORCOA1-S";
	
	/**
	 * Inicializamos el PORCOA2_S, con valor PORCOA2_S
	 */
	private static final String PORCOA2_S = "PORCOA2-S";
	
	/**
	 * Inicializamos el PORCOA3_S, con valor PORCOA3_S
	 */
	private static final String PORCOA3_S = "PORCOA3-S";
	
	/**
	 * Inicializamos el PORCOA4_S, con valor PORCOA4_S
	 */
	private static final String PORCOA4_S = "PORCOA4-S";
	
	/**
	 * Inicializamos el PORCOA5_S, con valor PORCOA5_S
	 */
	private static final String PORCOA5_S = "PORCOA5-S";
	
	/**
	 * Inicializamos el PORCOA6_S, con valor PORCOA6_S
	 */
	private static final String PORCOA6_S = "PORCOA6-S";	
	
	//MU-2016-006664 - RAROALE - INI
	/**
	 * Inicializamos el IMPCOA1_S, con valor IMPCOA1_S
	 */
	private static final String IMPCOA1_S = "IMPCOA1-S";
	/**
	 * Inicializamos el IMPCOA2_S, con valor IMPCOA2_S
	 */
	private static final String IMPCOA2_S = "IMPCOA2-S";
	/**
	 * Inicializamos el IMPCOA3_S, con valor IMPCOA3_S
	 */
	private static final String IMPCOA3_S = "IMPCOA3-S";
	/**
	 * Inicializamos el IMPCOA4_S, con valor IMPCOA4_S
	 */
	private static final String IMPCOA4_S = "IMPCOA4-S";
	/**
	 * Inicializamos el IMPCOA5_S, con valor IMPCOA5_S
	 */
	private static final String IMPCOA5_S = "IMPCOA5-S";
	/**
	 * Inicializamos el IMPCOA6_S, con valor IMPCOA6_S
	 */
	private static final String IMPCOA6_S = "IMPCOA6-S";
	//MU-2016-006664 - RAROALE - FIN
	
	// MU-2016-006673 - RAROALE - INI
	/**
	 * Inicializamos el KDOMICILIO1_S, con valor KDOMICILIO1-S
	 */
	private static final String KDOMICILIO1_S = "KDOMICILIO1-S";
	
	/**
	 * Inicializamos el FECMODIFICA_S, con valor FECMODIFICA-S
	 */
	private static final String FECMODIFICA_S = "FECMODIFICA-S";
	// MU-2016-006673 - RAROALE - FIN
	
	
	/**
	 * Inicializamos el IMPRTOINTEGRCAP_S, con valor IMPRTOINTEGRCAP_S
	 */
	private static final String IMPRTOINTEGRCAP_S = "IMPRTOINTEGRCAP-S";
	
	
	/**
	 * Inicializamos el TOMADOR_S, con valor IMPRTOINTEGRCAP_S
	 */
	private static final String TOMADOR_S = "TOMADOR-S";

	/**
	 * Inicializamos el EXIMIDO_S, con valor EXIMIDO-S
	 */
	private static final String EXIMIDO_S = "EXIMIDO-S";  //R&V - CU009
	
	
	/**
	 * Ejecuta el servicio cobol de carga inicial
	 * 
	 * @param eDatos
	 *            contiene los parametros para hacer la llamada al servicio
	 * @return sDatos datos retornados por el servicio cobol
	 * @throws J372J001VencimientosException
	 * 
	 */

	public static J372J001BusquedaExpVenPageBean ejecutaServicioCobol (
			J372J001BusquedaExpVenPageBean eDatos)
			throws J372J001VencimientosException {

		final J372J003ServicioCobol oGesServicios = new J372J003ServicioCobol();
		final UtilidadesBeanAction UTIL = new UtilidadesBeanAction ();

		J000J000Conectable oConector;
		J000J000Conectable oConector2;
		J372J001BusquedaExpVenPageBean sDatos = new J372J001BusquedaExpVenPageBean();

		if (objTrazas.isDebugEnabled()) {
			objTrazas.debug("ServicioBusquedaExpVenBean: CARGA DE DATOS COBOL");
		}
		try {

			oConector = oGesServicios.prepararLlamada(
					"IN372VENCIMIENTOSMANUALES", "B372VT04BusquedaExpVen",
					eDatos.getUsuario());

			oConector.setCampo("KSERVICIO-C", "B372VT04");

			/* cabecera de control */
			oConector.setCampo("CCANAL-C", "01");
			oConector.setCampo("KEMPRESA-C", "MAV");
			oConector.setCampo("KDEPARTA-C", "ISA");
			oConector.setCampo("KUSUARIO-C", eDatos.getUsuario()
					.getStUsuario_Racf());
			oConector.setCampo("KCADISTR-C", ENBLANCO);

			/* Entrada */
			oConector.setCampo("OPERACION-E", eDatos.getOperacion());
			oConector.setCampo("ANIO-E", eDatos.getAnio().toString());
			oConector.setCampo("KEXPEDIENTE-E", eDatos.getExpediente()
					.toString());
			oConector.setCampo("KPOLIZA-E", eDatos.getRdPoliza().toString());
			oConector.setCampo("NSUBPOLIZA-E", eDatos.getRdSubpoliza  ().toString());
			oConector.setCampo("KCERTIFICADO-E", eDatos.getRdCertificado ().toString());
			oConector.setCampo("NIF-E", eDatos.getRdNifCif ());
			oConector.setCampo("LUGARENVIO-E", eDatos.getLugarEnvio()
					.toString());
			oConector.setCampo("FECCALCULO-E", eDatos.getFecCalculo()
					.toString());
			
			oConector.setCampo("STIPSITUACION-E", eDatos.getTipSituacion()
					.toString());
			
			oConector.setCampo("ANT-KEXPEDIENTE-E", eDatos.getAntExpediente()
					.toString());
			oConector.setCampo("ANT-ANIO-E", eDatos.getAntAnio().toString());

			/* logs de datos de entrada */
			// TODO A�adir trazas en los logs
			if (objTrazas.isDebugEnabled()) {
				objTrazas
						.debug("ServicioBusquedaExpVenBean_Datos entrada: ANIO-E = "
								+ oConector.getCampo("ANIO-E"));
				objTrazas
						.debug("ServicioBusquedaExpVenBean_Datos entrada: ANT-KEXPEDIENTE-E = "
								+ oConector.getCampo("ANT-KEXPEDIENTE-E"));
				objTrazas
						.debug("ServicioBusquedaExpVenBean_Datos entrada: KEXPEDIENTE-E = "
								+ oConector.getCampo("KEXPEDIENTE-E"));
				objTrazas
						.debug("ServicioBusquedaExpVenBean_Datos entrada: OPERACION-E = "
								+ oConector.getCampo("OPERACION-E"));
				objTrazas
						.debug("ServicioBusquedaExpVenBean_Datos entrada: NIF-E = "
								+ oConector.getCampo("NIF-E"));
				objTrazas
						.debug("ServicioBusquedaExpVenBean_Datos entrada: KPOLIZA-E = "
								+ oConector.getCampo("KPOLIZA-E"));
				objTrazas
						.debug("ServicioBusquedaExpVenBean_Datos entrada: ANT-ANIO-E = "
								+ oConector.getCampo("ANT-ANIO-E"));
			}
			oConector.ejecutarServicio();

			/* Datos de salida */
			final String sResultado = oConector.getCampo(CRETORNO_S);

			objTrazas.debug("R&V [J372J001ServicioBusquedaExpVenBean.ejecutaServicioCobol] sResultado = "+sResultado);
			if (sResultado.compareTo("00") == 0) {

				sDatos.setPaginacion(oConector.getCampo("SPAGINACION-S"));
				if (ENBLANCO.equals(oConector.getCampo(PRO_KEXPEDIENTE_S))) {
					sDatos.setProExpediente(new BigDecimal(0));
				} else {
					sDatos.setProExpediente(new BigDecimal(oConector
							.getCampo(PRO_KEXPEDIENTE_S)));
				}
				if (ENBLANCO.equals(oConector.getCampo(PRO_ANIO_S))) {
					sDatos.setProAnio(new BigDecimal(0));
				} else {
					sDatos.setProAnio(new BigDecimal(oConector
							.getCampo(PRO_ANIO_S)));
				}
				sDatos.setNumRegistros(oConector.getCampo("NUM-REGISTROS-S"));
				sDatos.setDesRetorno(oConector.getCampo(GERROR_S));
				sDatos.setRetorno(oConector.getCampo(CRETORNO_S));
				sDatos.setNomPrograma(oConector.getCampo(GNOMPROG_S));
				sDatos.setTomador( (String) oConector.getCampo ( TOMADOR_S ) );

				if (objTrazas.isDebugEnabled()) {
					objTrazas
							.debug("ServicioBusquedaExpVenBean_Datos salida: NUMITERACIONES = "
									+ oConector.getCampo("NUM-REGISTROS-S"));
					objTrazas
							.debug("ServicioBusquedaExpVenBean_Datos salida: GERROR-S = "
									+ oConector.getCampo(GERROR_S));
					objTrazas
							.debug("ServicioBusquedaExpVenBean_Datos salida: CRETORNO-S = "
									+ oConector.getCampo(CRETORNO_S));
					objTrazas
							.debug("ServicioBusquedaExpVenBean_Datos salida: GNOMPROG-S = "
									+ oConector.getCampo(GNOMPROG_S));
				}
				sDatos.setPoliza ( eDatos.getRdPoliza () );
				sDatos.setSubPoliza ( new BigDecimal (eDatos.getRdSubpoliza ()));
				sDatos.setCertificado ( new BigDecimal (eDatos.getRdCertificado ()) );
				
				
				List listaExpediente = new ArrayList();
				/* Declaracion de variables locales */
				int i ;
				final int IREGS = Integer.parseInt(oConector
						.getCampo("NUM-REGISTROS-S"));
				for (i = 0 ; i < IREGS; i++) {

					J372J001BusquedaExpVenPageBean pageBean = new J372J001BusquedaExpVenPageBean();
					
					
					pageBean.setAnio(UTIL.numeroBig ( oConector.getCampo(ANIO_S) ));
					pageBean.setExpediente(UTIL.numeroBig ( oConector.getCampo(KEXPEDIENTE_S) ));

					pageBean.setRamo(oConector.getCampo("KRAMO-S"));
					pageBean.setAnioPoliza(oConector.getCampo("ANIOPOL-S"));
					pageBean.setNumPoliza(oConector.getCampo("KPOLIZA-S"));

					if (ENBLANCO.equals(oConector.getCampo(NSUBPOLIZA_S))) {
						pageBean.setSubPoliza(new BigDecimal(0));
					} else {
						pageBean.setSubPoliza(new BigDecimal(oConector
								.getCampo(NSUBPOLIZA_S)));
					}

					if (ENBLANCO.equals(oConector.getCampo(KCERTIFICADO_S))) {
						pageBean.setCertificado(new BigDecimal(0));
					} else {
						pageBean.setCertificado(new BigDecimal(oConector
								.getCampo(KCERTIFICADO_S)));
					}

					if (ENBLANCO.equals(oConector.getCampo(KMODALIDAD_S))) {
						pageBean.setModalidad(new BigDecimal(0));
					} else {
						pageBean.setModalidad(new BigDecimal(oConector
								.getCampo(KMODALIDAD_S)));
					}

					pageBean.setCanalCamp(oConector.getCampo("CCANALCAMP-S"));
					pageBean.setEntidad(oConector.getCampo("CENTIDAD-S"));

					pageBean.setFecEfecto(oConector.getCampo("FECEFECTO-S"));
					pageBean.setDuracion(oConector.getCampo("KDURACION-S"));
					pageBean.setFecEmision(oConector.getCampo("FECEMISION-S"));
					pageBean.setCartera(oConector.getCampo("CCARTERA-S"));
					pageBean.setReaseguro(oConector.getCampo("SREASEGURO-S"));
					pageBean.setRegional(oConector.getCampo("REGIONAL-S"));
					pageBean.setLugarEnvio(oConector.getCampo("LUGARENVIO-S"));
					pageBean.setOficina(oConector.getCampo("KOFICINA-S"));

					if (ENBLANCO.equals(oConector.getCampo(IPENDIENTE_S))) {
						pageBean.setPendiente(new BigDecimal(0));
					} else {
						pageBean.setPendiente(new BigDecimal(oConector
								.getCampo(IPENDIENTE_S)));
					}

					pageBean.setTipoPers1(oConector.getCampo("CTIPOPERS1-S"));
					pageBean.setResidente1(oConector.getCampo("SRESIDENTE1-S"));
					pageBean.setNif1(oConector.getCampo("NIF1-S"));

					if (ENBLANCO.equals(oConector.getCampo(KPERSONA1_S))) {
						pageBean.setPersona1(new BigDecimal(0));
					} else {
						pageBean.setPersona1(new BigDecimal(oConector
								.getCampo(KPERSONA1_S)));
					}
					
					// MU-2016-006673 - RAROALE - INI
					if (ENBLANCO.equals(oConector.getCampo(KDOMICILIO1_S))) {
						pageBean.setDomicilio1(new BigDecimal(0));
					} else {
						pageBean.setDomicilio1(new BigDecimal(oConector.getCampo(KDOMICILIO1_S)));
					}
					pageBean.setFmodificacion(oConector.getCampo(FECMODIFICA_S));
					
					// MU-2016-006673 - RAROALE - FIN

					if (ENBLANCO.equals(oConector.getCampo(IMPCAPITAL_S))) {
						pageBean.setImpCapital(new BigDecimal(0));
					} else {
						pageBean.setImpCapital(new BigDecimal(oConector
								.getCampo(IMPCAPITAL_S)));
					}

					if (ENBLANCO.equals(oConector.getCampo(IMPBENEFICIOS_S))) {
						pageBean.setImpBeneficios(new BigDecimal(0));
					} else {
						pageBean.setImpBeneficios(new BigDecimal(oConector
								.getCampo(IMPBENEFICIOS_S)));
					}
					pageBean.setFecPagoCapital(oConector
							.getCampo("FECPAGOCAPITAL-S"));

					if (ENBLANCO.equals(oConector.getCampo(IMPANTICIPO_S))) {
						pageBean.setImpAnticipo(new BigDecimal(0));
					} else {
						pageBean.setImpAnticipo(new BigDecimal(oConector
								.getCampo(IMPANTICIPO_S)));
					}

					if (ENBLANCO.equals(oConector.getCampo(IMPINTEPEND_S))) {
						pageBean.setImpInteresPendiente(new BigDecimal(0));
					} else {
						pageBean.setImpInteresPendiente(new BigDecimal(
								oConector.getCampo(IMPINTEPEND_S)));
					}
					pageBean.setFecVencimientoCap(oConector
							.getCampo("FECVENCIMICAP-S"));
					pageBean.setTipImpuestoCap(oConector
							.getCampo("TIPIMPUESTCAP-S"));

					if (ENBLANCO
							.equals(oConector.getCampo(IMPRTOINTEGRCAP_S))) {
						pageBean.setImpRtorintegrcap(new BigDecimal(0));
					} else {
						pageBean.setImpRtorintegrcap(new BigDecimal(oConector
								.getCampo(IMPRTOINTEGRCAP_S)));
					}

					if (ENBLANCO.equals(oConector.getCampo(IMPREDPRICAP_S))) {
						pageBean.setImpRedPriCap(new BigDecimal(0));
					} else {
						pageBean.setImpRedPriCap(new BigDecimal(oConector
								.getCampo(IMPREDPRICAP_S)));
					}

					if (ENBLANCO.equals(oConector.getCampo(IMPREDTRANCAP_S))) {
						pageBean.setImpRedTranCap(new BigDecimal(0));
					} else {
						pageBean.setImpRedTranCap(new BigDecimal(oConector
								.getCampo(IMPREDTRANCAP_S)));
					}

					objTrazas.debug("R&V###### oConector.getCampo(IMPCOMPENSATORIA_S) = "+oConector.getCampo(IMPCOMPENSATORIA_S));
					if (ENBLANCO.equals(oConector
							.getCampo(IMPCOMPENSATORIA_S))) {
						pageBean.setImpCompensatoria(new BigDecimal(0));
					} else {
						pageBean.setImpCompensatoria(new BigDecimal(oConector
								.getCampo(IMPCOMPENSATORIA_S)));
					}
					objTrazas.debug("R&V###### pageBean.getImpCompensatoria() = "+pageBean.getImpCompensatoria());

					if (ENBLANCO.equals(oConector.getCampo(IMPRTONETOCAP_S))) {
						pageBean.setImpRtonetoCap(new BigDecimal(0));
					} else {
						pageBean.setImpRtonetoCap(new BigDecimal(oConector
								.getCampo(IMPRTONETOCAP_S)));
					}

					if (ENBLANCO.equals(oConector.getCampo(PORRETCAP_S))) {
						pageBean.setPorretCap(new BigDecimal(0));
					} else {
						pageBean.setPorretCap(new BigDecimal(oConector
								.getCampo(PORRETCAP_S)));
					}

					if (ENBLANCO.equals(oConector.getCampo(IMPRETCAP_S))) {
						pageBean.setImpretCap(new BigDecimal(0));
					} else {
						pageBean.setImpretCap(new BigDecimal(oConector
								.getCampo(IMPRETCAP_S)));
					}

					if (ENBLANCO.equals(oConector.getCampo(IMPLIQCAP_S))) {
						pageBean.setImpliqCap(new BigDecimal(0));
					} else {
						pageBean.setImpliqCap(new BigDecimal(oConector
								.getCampo(IMPLIQCAP_S)));
					}
					pageBean
							.setFecImpreCap(oConector.getCampo("FECIMPRECAP-S"));

					pageBean.setFecPagret(oConector.getCampo("FECPAGRET-S"));

					if (ENBLANCO.equals(oConector.getCampo(IMPCOMP1_S))) {
						pageBean.setImpComp(new BigDecimal(0));
					} else {
						pageBean.setImpComp(new BigDecimal(oConector
								.getCampo(IMPCOMP1_S)));
					}

					pageBean
							.setFecCemiComp(oConector.getCampo("FECEMICOMP1-S"));
					pageBean.setFecPagComp(oConector.getCampo("FECPAGCOMP1-S"));

					pageBean.setTipImpuestComp(oConector
							.getCampo("TIPIMPUESTCOMP1-S"));

					if (ENBLANCO.equals(oConector.getCampo(IMPRTOINTCOMP1_S))) {
						pageBean.setImpRtointComp(new BigDecimal(0));
					} else {
						pageBean.setImpRtointComp(new BigDecimal(oConector
								.getCampo(IMPRTOINTCOMP1_S)));
					}

					if (ENBLANCO.equals(oConector.getCampo(IMPREDPRICOMP1_S))) {
						pageBean.setImpRedpriComp(new BigDecimal(0));
					} else {
						pageBean.setImpRedpriComp(new BigDecimal(oConector
								.getCampo(IMPREDPRICOMP1_S)));
					}

					if (ENBLANCO.equals(oConector.getCampo(IREDTRANCOMP1_S))) {
						pageBean.setImpRedTranComp(new BigDecimal(0));
					} else {
						pageBean.setImpRedTranComp(new BigDecimal(oConector
								.getCampo(IREDTRANCOMP1_S)));
					}

					if (ENBLANCO.equals(oConector.getCampo(IRTONETCOMP1_S))) {
						pageBean.setIrTonetComp(new BigDecimal(0));
					} else {
						pageBean.setIrTonetComp(new BigDecimal(oConector
								.getCampo(IRTONETCOMP1_S)));
					}

					if (ENBLANCO.equals(oConector.getCampo( PORRETCOMP1_S ))) {
						pageBean.setPorretComp(new BigDecimal(0));
					} else {
						pageBean.setPorretComp(new BigDecimal(oConector
								.getCampo( PORRETCOMP1_S )));
					}

					if (ENBLANCO.equals(oConector.getCampo( IRETCOMP1_S ))) {
						pageBean.setIretComp(new BigDecimal(0));
					} else {
						pageBean.setIretComp(new BigDecimal(oConector
								.getCampo( IRETCOMP1_S )));
					}

					if (ENBLANCO.equals(oConector.getCampo( ILIQCOMP1_S ))) {
						pageBean.setIliqComp(new BigDecimal(0));
					} else {
						pageBean.setIliqComp(new BigDecimal(oConector
								.getCampo( ILIQCOMP1_S )));
					}

					pageBean.setFecImpreComp(oConector
							.getCampo("FECIMPRECOMP1-S"));

					pageBean.setFecPagretCom(oConector
							.getCampo("FECPAGRETCOM1-S"));

					if (ENBLANCO.equals(oConector.getCampo( IMPCOMP2_S ))) {
						pageBean.setImpComp2(new BigDecimal(0));
					} else {
						pageBean.setImpComp2(new BigDecimal(oConector
								.getCampo( IMPCOMP2_S )));
					}

					pageBean.setFecCemiComp2(oConector
							.getCampo("FECEMICOMP2-S"));
					pageBean
							.setFecPagComp2(oConector.getCampo("FECPAGCOMP2-S"));

					pageBean.setTipImpuestComp2(oConector
							.getCampo("TIPIMPUESTCOMP2-S"));

					if (ENBLANCO.equals(oConector.getCampo( IMPRTOINTCOMP2_S ))) {
						pageBean.setImpRtointComp2(new BigDecimal(0));
					} else {
						pageBean.setImpRtointComp2(new BigDecimal(oConector
								.getCampo( IMPRTOINTCOMP2_S )));
					}

					if (ENBLANCO.equals(oConector.getCampo( IMPREDPRICOMP2_S ))) {
						pageBean.setImpRedpriComp2(new BigDecimal(0));
					} else {
						pageBean.setImpRedpriComp2(new BigDecimal(oConector
								.getCampo( IMPREDPRICOMP2_S )));
					}

					if (ENBLANCO.equals(oConector.getCampo( IREDTRANCOMP2_S ))) {
						pageBean.setImpRedTranComp2(new BigDecimal(0));
					} else {
						pageBean.setImpRedTranComp2(new BigDecimal(oConector
								.getCampo( IREDTRANCOMP2_S )));
					}

					if (ENBLANCO.equals(oConector.getCampo( IRTONETCOMP2_S ))) {
						pageBean.setIrTonetComp2(new BigDecimal(0));
					} else {
						pageBean.setIrTonetComp2(new BigDecimal(oConector
								.getCampo( IRTONETCOMP2_S )));
					}

					if (ENBLANCO.equals(oConector.getCampo( PORRETCOMP2_S ))) {
						pageBean.setPorretComp2(new BigDecimal(0));
					} else {
						pageBean.setPorretComp2(new BigDecimal(oConector
								.getCampo( PORRETCOMP2_S )));
					}

					if (ENBLANCO.equals(oConector.getCampo( IRETCOMP2_S ))) {
						pageBean.setIretComp2(new BigDecimal(0));
					} else {
						pageBean.setIretComp2(new BigDecimal(oConector
								.getCampo( IRETCOMP2_S )));
					}

					if (ENBLANCO.equals(oConector.getCampo( ILIQCOMP2_S ))) {
						pageBean.setIliqComp2(new BigDecimal(0));
					} else {
						pageBean.setIliqComp2(new BigDecimal(oConector
								.getCampo( ILIQCOMP2_S )));
					}

					pageBean.setFecImpreComp2(oConector
							.getCampo("FECIMPRECOMP2-S"));

					pageBean.setFecPagretCom2(oConector
							.getCampo("FECPAGRETCOM2-S"));


					objTrazas.debug("R&V [J372J001ServicioBusquedaExpVenBean.ejecutaServicioCobol] entro en mi bloque.");
					// R&V Junio 2017 - REACONDICIONAMIENTO VT01 VT04 - everis(RGL) - INI
					final int numeroDeCoasegurodoras = Integer.parseInt ( oConector.getCampo ( "COASEGUROS-OCCURS-S" ) );;
					if (numeroDeCoasegurodoras>0) {
						pageBean.setCodCoA1( oConector.getCampo ( "CODCOA-S" ) );
						pageBean.setPorCoA1 ( UTIL.numeroBig ( oConector.getCampo ( "PORCOA-S" ) ) );
						if (ENBLANCO.equals(oConector.getCampo("IMPCOA-S"))){
							pageBean.setImpCoA1(new BigDecimal(0));
						} else {
							pageBean.setImpCoA1(UTIL.numeroBig(oConector.getCampo("IMPCOA-S")));
						}

						// R&V Correccion 03/08/2017-1-3 INI
						pageBean.setRtoIntegroCoa1(UTIL.numeroBig(oConector.getCampo("IMPRTOINTEGRCOA-S")));
						pageBean.setRedPrimasCoa1(UTIL.numeroBig(oConector.getCampo("IMPREDPRICOA-S")));
						pageBean.setRedTransitoriaCoa1(UTIL.numeroBig(oConector.getCampo("IMPREDTRANCOA-S")));
						pageBean.setRtoNetoCoa1(UTIL.numeroBig(oConector.getCampo("IMPRTONETOCOA-S")));
						pageBean.setRetencionCoa1(UTIL.numeroBig(oConector.getCampo("IMPRETCOA-S")));
						pageBean.setCompenCoa1(UTIL.numeroBig(oConector.getCampo("IMPCOMPENSATCOA-S")));
						// R&V Correccion 03/08/2017-1-3 FIN

						if (oConector.next("COASEGUROS-S")){
							pageBean.setCodCoA2( oConector.getCampo ( "CODCOA-S" ) );
							pageBean.setPorCoA2 ( UTIL.numeroBig ( oConector.getCampo ( "PORCOA-S" ) ) );
							if (ENBLANCO.equals(oConector.getCampo("IMPCOA-S"))){
								pageBean.setImpCoA2(new BigDecimal(0));
							} else {
								pageBean.setImpCoA2(UTIL.numeroBig(oConector.getCampo("IMPCOA-S")));
							}

							// R&V Correccion 03/08/2017-1-3 INI
							pageBean.setRtoIntegroCoa2(UTIL.numeroBig(oConector.getCampo("IMPRTOINTEGRCOA-S")));
							pageBean.setRedPrimasCoa2(UTIL.numeroBig(oConector.getCampo("IMPREDPRICOA-S")));
							pageBean.setRedTransitoriaCoa2(UTIL.numeroBig(oConector.getCampo("IMPREDTRANCOA-S")));
							pageBean.setRtoNetoCoa2(UTIL.numeroBig(oConector.getCampo("IMPRTONETOCOA-S")));
							pageBean.setRetencionCoa2(UTIL.numeroBig(oConector.getCampo("IMPRETCOA-S")));
							pageBean.setCompenCoa2(UTIL.numeroBig(oConector.getCampo("IMPCOMPENSATCOA-S")));
							// R&V Correccion 03/08/2017-1-3 FIN

							if (oConector.next("COASEGUROS-S")){
								pageBean.setCodCoA3( oConector.getCampo ( "CODCOA-S" ) );
								pageBean.setPorCoA3 ( UTIL.numeroBig ( oConector.getCampo ( "PORCOA-S" ) ) );
								if (ENBLANCO.equals(oConector.getCampo("IMPCOA-S"))){
									pageBean.setImpCoA3(new BigDecimal(0));
								} else {
									pageBean.setImpCoA3(UTIL.numeroBig(oConector.getCampo("IMPCOA-S")));
								}

								// R&V Correccion 03/08/2017-1-3 INI
								pageBean.setRtoIntegroCoa3(UTIL.numeroBig(oConector.getCampo("IMPRTOINTEGRCOA-S")));
								pageBean.setRedPrimasCoa3(UTIL.numeroBig(oConector.getCampo("IMPREDPRICOA-S")));
								pageBean.setRedTransitoriaCoa3(UTIL.numeroBig(oConector.getCampo("IMPREDTRANCOA-S")));
								pageBean.setRtoNetoCoa3(UTIL.numeroBig(oConector.getCampo("IMPRTONETOCOA-S")));
								pageBean.setRetencionCoa3(UTIL.numeroBig(oConector.getCampo("IMPRETCOA-S")));
								pageBean.setCompenCoa3(UTIL.numeroBig(oConector.getCampo("IMPCOMPENSATCOA-S")));
								// R&V Correccion 03/08/2017-1-3 FIN

								if (oConector.next("COASEGUROS-S")){
									pageBean.setCodCoA4( oConector.getCampo ( "CODCOA-S" ) );
									pageBean.setPorCoA4 ( UTIL.numeroBig ( oConector.getCampo ( "PORCOA-S" ) ) );
									if (ENBLANCO.equals(oConector.getCampo("IMPCOA-S"))){
										pageBean.setImpCoA4(new BigDecimal(0));
									} else {
										pageBean.setImpCoA4(UTIL.numeroBig(oConector.getCampo("IMPCOA-S")));
									}

									// R&V Correccion 03/08/2017-1-3 INI
									pageBean.setRtoIntegroCoa4(UTIL.numeroBig(oConector.getCampo("IMPRTOINTEGRCOA-S")));
									pageBean.setRedPrimasCoa4(UTIL.numeroBig(oConector.getCampo("IMPREDPRICOA-S")));
									pageBean.setRedTransitoriaCoa4(UTIL.numeroBig(oConector.getCampo("IMPREDTRANCOA-S")));
									pageBean.setRtoNetoCoa4(UTIL.numeroBig(oConector.getCampo("IMPRTONETOCOA-S")));
									pageBean.setRetencionCoa4(UTIL.numeroBig(oConector.getCampo("IMPRETCOA-S")));
									pageBean.setCompenCoa4(UTIL.numeroBig(oConector.getCampo("IMPCOMPENSATCOA-S")));
									// R&V Correccion 03/08/2017-1-3 FIN

									if (oConector.next("COASEGUROS-S")){
										pageBean.setCodCoA5( oConector.getCampo ( "CODCOA-S" ) );
										pageBean.setPorCoA5 ( UTIL.numeroBig ( oConector.getCampo ( "PORCOA-S" ) ) );
										if (ENBLANCO.equals(oConector.getCampo("IMPCOA-S"))){
											pageBean.setImpCoA5(new BigDecimal(0));
										} else {
											pageBean.setImpCoA5(UTIL.numeroBig(oConector.getCampo("IMPCOA-S")));
										}

										// R&V Correccion 03/08/2017-1-3 INI
										pageBean.setRtoIntegroCoa5(UTIL.numeroBig(oConector.getCampo("IMPRTOINTEGRCOA-S")));
										pageBean.setRedPrimasCoa5(UTIL.numeroBig(oConector.getCampo("IMPREDPRICOA-S")));
										pageBean.setRedTransitoriaCoa5(UTIL.numeroBig(oConector.getCampo("IMPREDTRANCOA-S")));
										pageBean.setRtoNetoCoa5(UTIL.numeroBig(oConector.getCampo("IMPRTONETOCOA-S")));
										pageBean.setRetencionCoa5(UTIL.numeroBig(oConector.getCampo("IMPRETCOA-S")));
										pageBean.setCompenCoa5(UTIL.numeroBig(oConector.getCampo("IMPCOMPENSATCOA-S")));
										// R&V Correccion 03/08/2017-1-3 FIN

										if (oConector.next("COASEGUROS-S")){
											pageBean.setCodCoA6( oConector.getCampo ( "CODCOA-S" ) );
											pageBean.setPorCoA6 ( UTIL.numeroBig ( oConector.getCampo ( "PORCOA-S" ) ) );
											if (ENBLANCO.equals(oConector.getCampo("IMPCOA-S"))){
												pageBean.setImpCoA6(new BigDecimal(0));
											} else {
												pageBean.setImpCoA6(UTIL.numeroBig(oConector.getCampo("IMPCOA-S")));
											}

											// R&V Correccion 03/08/2017-1-3 INI
											pageBean.setRtoIntegroCoa6(UTIL.numeroBig(oConector.getCampo("IMPRTOINTEGRCOA-S")));
											pageBean.setRedPrimasCoa6(UTIL.numeroBig(oConector.getCampo("IMPREDPRICOA-S")));
											pageBean.setRedTransitoriaCoa6(UTIL.numeroBig(oConector.getCampo("IMPREDTRANCOA-S")));
											pageBean.setRtoNetoCoa6(UTIL.numeroBig(oConector.getCampo("IMPRTONETOCOA-S")));
											pageBean.setRetencionCoa6(UTIL.numeroBig(oConector.getCampo("IMPRETCOA-S")));
											pageBean.setCompenCoa6(UTIL.numeroBig(oConector.getCampo("IMPCOMPENSATCOA-S")));
											// R&V Correccion 03/08/2017-1-3 FIN

										}
									}
								}
							}
						}
					}
					// R&V Junio 2017 - REACONDICIONAMIENTO VT01 VT04 - everis(RGL) - FIN
					objTrazas.debug("R&V [J372J001ServicioBusquedaExpVenBean.ejecutaServicioCobol] salgo de mi bloque.");



					/*************BLOQUE ORIGINAL INI  ******
					pageBean.setCodCoA1(oConector.getCampo("CODCOA1-S"));

					if (ENBLANCO.equals(oConector.getCampo( PORCOA1_S ))) {
						pageBean.setPorCoA1(new BigDecimal(0));
					} else {
						pageBean.setPorCoA1(new BigDecimal(oConector
								.getCampo( PORCOA1_S )));
					}

					pageBean.setCodCoA2(oConector.getCampo("CODCOA2-S"));

					if (ENBLANCO.equals(oConector.getCampo( PORCOA2_S ))) {
						pageBean.setPorCoA2(new BigDecimal(0));
					} else {
						pageBean.setPorCoA2(new BigDecimal(oConector
								.getCampo( PORCOA2_S )));
					}

					pageBean.setCodCoA3(oConector.getCampo("CODCOA3-S"));

					if (ENBLANCO.equals(oConector.getCampo( PORCOA3_S ))) {
						pageBean.setPorCoA3(new BigDecimal(0));
					} else {
						pageBean.setPorCoA3(new BigDecimal(oConector
								.getCampo( PORCOA3_S )));
					}

					pageBean.setCodCoA4(oConector.getCampo("CODCOA4-S"));

					if (ENBLANCO.equals(oConector.getCampo( PORCOA4_S ))) {
						pageBean.setPorCoA4(new BigDecimal(0));
					} else {
						pageBean.setPorCoA4(new BigDecimal(oConector
								.getCampo( PORCOA4_S )));
					}

					pageBean.setCodCoA5(oConector.getCampo("CODCOA5-S"));

					if (ENBLANCO.equals(oConector.getCampo( PORCOA5_S ))) {
						pageBean.setPorCoA5(new BigDecimal(0));
					} else {
						pageBean.setPorCoA5(new BigDecimal(oConector
								.getCampo( PORCOA5_S )));
					}

					pageBean.setCodCoA6(oConector.getCampo("CODCOA6-S"));

					if (ENBLANCO.equals(oConector.getCampo( PORCOA6_S ))) {
						pageBean.setPorCoA6(new BigDecimal(0));
					} else {
						pageBean.setPorCoA6(new BigDecimal(oConector
								.getCampo( PORCOA6_S )));
					}
					 ********* BLOQUE ORIGINAL FIN  ****************************/

					pageBean.setPagotot(oConector.getCampo("PAGOTOT-S"));

					/******************** BLOQUE ORIGINAL INI
					//MU-2016-006664 - RAROALE - INI
					// Se recuperan los importes de CoAseguro
					if (ENBLANCO.equals(oConector.getCampo(IMPCOA1_S))){
						pageBean.setImpCoA1(new BigDecimal(0));
					} else {
						pageBean.setImpCoA1(new BigDecimal(oConector.getCampo(IMPCOA1_S)));
					}
					if (ENBLANCO.equals(oConector.getCampo(IMPCOA2_S))){
						pageBean.setImpCoA2(new BigDecimal(0));
					} else {
						pageBean.setImpCoA2(new BigDecimal(oConector.getCampo(IMPCOA2_S)));
					}
					if (ENBLANCO.equals(oConector.getCampo(IMPCOA1_S))){
						pageBean.setImpCoA3(new BigDecimal(0));
					} else {
						pageBean.setImpCoA3(new BigDecimal(oConector.getCampo(IMPCOA3_S)));
					}
					if (ENBLANCO.equals(oConector.getCampo(IMPCOA4_S))){
						pageBean.setImpCoA4(new BigDecimal(0));
					} else {
						pageBean.setImpCoA4(new BigDecimal(oConector.getCampo(IMPCOA4_S)));
					}
					if (ENBLANCO.equals(oConector.getCampo(IMPCOA5_S))){
						pageBean.setImpCoA5(new BigDecimal(0));
					} else {
						pageBean.setImpCoA5(new BigDecimal(oConector.getCampo(IMPCOA5_S)));
					}
					if (ENBLANCO.equals(oConector.getCampo(IMPCOA6_S))){
						pageBean.setImpCoA6(new BigDecimal(0));
					} else {
						pageBean.setImpCoA6(new BigDecimal(oConector.getCampo(IMPCOA6_S)));
					}
					//MU-2016-006664 - RAROALE - FIN
					 ********* BLOQUE ORIGINAL FIN  ****************************/

					pageBean.setFecBDGICap ( oConector.getCampo("FECBDGICAP-S") );
					pageBean.setFecBDGIComp1 ( oConector.getCampo("FECBDGICOMP1-S") );
					pageBean.setFecBDGIComp2 ( oConector.getCampo("FECBDGICOMP2-S") );
					
					pageBean.setSBDGICap ( oConector.getCampo("SBDGICAP-S") );
					pageBean.setSBDGIComp ( oConector.getCampo("SBDGICOMP1-S") );
					pageBean.setSBDGIComp2 ( oConector.getCampo("SBDGICOMP2-S") );

					

					pageBean.setUsuarioC(oConector.getCampo("CUSUARIO-S"));
					pageBean.setObservacionesG(oConector
							.getCampo("GOBSERVACION-S"));
					
					pageBean.setTipSituacion(oConector
							.getCampo("STIPSITUACION-S"));
					if ( pageBean.getTipSituacion().equals("A") ) {
						pageBean.setDesSituacion("ANULADO");
					} else {
						pageBean.setDesSituacion("VIGOR");
					}
					
					pageBean.setFecAnul(oConector
							.getCampo("FANULACION-S"));
					
					/* INICIO  MU-2015-041869*/
					pageBean.setAniofiscal( new BigDecimal( oConector.getCampo("ANIOFISCAL-S")));
					/* FIN  MU-2015-041869*/
					
					//R&V - CU009 - INICIO
					pageBean.setEximido( oConector.getCampo ( "EXIMIDO-S" ) );
					//R&V - CU009 - FIN
					
					String anio = oConector.getCampo ( ANIO_S );
					
					if (anio.compareTo("1950") == 0){					    
					    	
					    oConector2 =  oGesServicios.prepararLlamada("IN372VENCIMIENTOSMANUALES", 
						    "B372VT08BusquedaAdicExpVen", eDatos.getUsuario());

					    oConector2.setCampo ("ANIO-E", pageBean.getAnio().toString());
					    oConector2.setCampo ("KEXPEDIENTE-E", pageBean.getExpediente().toString());
					    oConector2.setCampo ("OPERACION-E", "D" );
					    oConector2.setCampo ("ANT-KEXPEDIENTE-E", sDatos.getProExpediente().toString());
					    oConector2.setCampo ("ANT-ANIO-E", sDatos.getProAnio().toString());
        				
					    oConector2.ejecutarServicio ();
					    
					    /* Datos de salida */
					    String resultado = oConector2.getCampo ("CRETORNO-S");
					    
					    if ( resultado.compareTo ( "00" ) == 0 ) {
						
						pageBean.setVencimientoMigrado(oConector2.getCampo ("VEN-MIGR-S"));
						pageBean.setUsuarioPagoPri(oConector2.getCampo ("USUARIO-PAGO-S"));
						pageBean.setFecCapturaPri(oConector2.getCampo ("FCAPTURA-S"));
						pageBean.setUsuarioCapturaPri(oConector2.getCampo ("CUSUARIO-CAPT-S"));
						pageBean.setFormaPagoPri(oConector2.getCampo ("FORMAPAGO-S"));
						pageBean.setRefReinversionPri(oConector2.getCampo ("REF-REINVERSION-S"));
						pageBean.setNumChequePri(UTIL.numeroBig(oConector2.getCampo ("NUM-CHEQUE-S")));
						pageBean.setNumCuentaPri(oConector2.getCampo ("NUM-CUENTA-S"));
						pageBean.setUsuarioPagoComp1(oConector2.getCampo ("CUSU-PAGO-COMP1-S"));
						pageBean.setFecCapturaComp1(oConector2.getCampo ("FCAPTURA-COMP1-S"));
						pageBean.setUsuarioCapturaComp1(oConector2.getCampo ("CUSU-CAPT-COMP1-S"));
						pageBean.setFormaPagoComp1(oConector2.getCampo ("FORMAPAGO-COMP1-S"));
						pageBean.setNumChequeComp1(UTIL.numeroBig(oConector2.getCampo ("NCHEQUE-COMP1-S")));
						pageBean.setNumCuentaComp1(oConector2.getCampo ("NCUENTA-COMP1-S"));
						pageBean.setUsuarioPagoComp2(oConector2.getCampo ("CUSU-PAGO-COMP2-S"));
						pageBean.setFecCapturaComp2(oConector2.getCampo ("FCAPTURA-COMP2-S"));
						pageBean.setUsuarioCapturaComp2(oConector2.getCampo ("CUSU-CAPT-COMP2-S"));
						pageBean.setFormaPagoComp2(oConector2.getCampo ("FORMAPAGO-COMP2-S"));
						pageBean.setNumChequeComp2(UTIL.numeroBig(oConector2.getCampo ("NCHEQUE-COMP2-S")));
						pageBean.setNumCuentaComp2(oConector2.getCampo ("NCUENTA-COMP2-S"));
						pageBean.setDiscapacitadoPri(oConector2.getCampo("GRADO-DISCAP-S"));
						pageBean.setPrestViviendoPri(oConector2.getCampo("PREST-VIVIENDA-S"));
						pageBean.setSitFamiliarPri(oConector2.getCampo("SITU-FAMILIAR-S"));
						pageBean.setNifConyugePri(oConector2.getCampo("NIF-CONYUGUE-S"));
						pageBean.setPenCompPri(oConector2.getCampo("ICOMPENSATORIA-S"));
						pageBean.setAnulAlimenHijosPri(oConector2.getCampo("IMPALIMENHIJOS-S"));
						
					    }else {
						J372J001VencimientosException objException = new J372J001VencimientosException (
						J372J001VencimientosException.ERROR_NEGOCIO, ENBLANCO );
                				objException.setStMetodo ( "ejecutaServicio()" );
                				objException.setStGError ( oConector2.getCampo ( GERROR_S ) );
                				objException.setStCRetorno ( oConector2.getCampo ( CRETORNO_S ) );
                				throw objException;
					    }

					}

					listaExpediente.add(pageBean);

					oConector.next("REGISTROS-OCC-S");

				}
				/*
				 * En los datos de salida vamos a tener la lista con todos sus
				 * campos y por otro lado la paginacion que ir� independiente de
				 * los datos de la lista
				 */

				sDatos.setListadoExp(listaExpediente);

				if (objTrazas.isDebugEnabled()) {
					objTrazas
							.debug("ServicioBusquedaExpVenBean_Datos salida: REGISTROS-OCC-S   = "
									+ oConector.getCampo("REGISTROS-OCC-S"));

					objTrazas
							.debug("ServicioBusquedaExpVenBean_Datos salida: GERROR-S   = "
									+ oConector.getCampo(GERROR_S));
					objTrazas
							.debug("ServicioBusquedaExpVenBean_Datos salida: CRETORNO-S = "
									+ oConector.getCampo(CRETORNO_S));
				}
				return sDatos;
			} else {
				if (objTrazas.isEnabledFor(Level.ERROR)) {
					objTrazas.error("ServicioBusquedaExpVenBean: GERROR-S   = "
							+ oConector.getCampo(GERROR_S));
					objTrazas.error("ServicioBusquedaExpVenBean: CRETORNO-S = "
							+ oConector.getCampo(CRETORNO_S));
				}
				J372J001VencimientosException objException = new J372J001VencimientosException(
						J372J001VencimientosException.ERROR_NEGOCIO, ENBLANCO);
				objException.setStMetodo("ejecutaServicio()");
				objException.setStGError(oConector.getCampo(GERROR_S));
				objException.setStCRetorno(oConector.getCampo(CRETORNO_S));
				throw objException;
			}

		} catch (J372J001VencimientosException  e) {
			objTrazas.debug("R&V [J372J001ServicioBusquedaExpVenBean.ejecutaServicioCobol] se ha producido una excepcion J372J001VencimientosException");
			throw e;
		} catch (J000J000Exception e) {
			J372J001VencimientosException objException = new J372J001VencimientosException(
					J372J001VencimientosException.ERROR_GENERICO_CICS, ENBLANCO);
			objException.setStDescripcion(e.getLocalizedMessage());
			objException.setStClase(e.getClass().toString());
			objException.setStGNomProg(ENBLANCO);
			objException.setStGError("Error Gen�rico CICS");
			objException.setStCRetorno(ENBLANCO);

			throw objException;
		}

	}

}
