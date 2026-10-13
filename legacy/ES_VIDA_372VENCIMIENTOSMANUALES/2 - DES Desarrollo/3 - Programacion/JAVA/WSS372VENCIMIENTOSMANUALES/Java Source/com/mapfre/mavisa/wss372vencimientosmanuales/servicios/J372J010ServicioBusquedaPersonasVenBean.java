/* MODIFICACION : MU-2016-006673
FECHA : MARZO 2016
DESCRIPCION: Se permite modificar y guardar en BBDD el kdomiclio del beneficiario
AUTOR : RAROALE */

package com.mapfre.mavisa.wss372vencimientosmanuales.servicios;



import mapfre.wss000arquitect.accesodatos.Factoria.J000J000Conectable;
import mapfre.wss000arquitect.excepciones.J000J000Exception;
import mapfre.wss000arquitect.utilidades.J000J000Trazas;

import java.math.BigDecimal;

import org.apache.log4j.Logger;

// MU-2016-006673 - RAROALE - INI
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.UtilidadesBeanAction;
//MU-2016-006673 - RAROALE - FIN
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J008GestionExpedientesVenPageBean;


/**
 * @author everis. Se ejecuta el servicio Cobol,
 * @version 1.0 Versión inicial
 */
public class J372J010ServicioBusquedaPersonasVenBean {

	/**
	 * Constructor por defecto PRIVATE
	 * 
	 */
	private J372J010ServicioBusquedaPersonasVenBean () {
		// TODO Constructor por defecto PRIVATE
	}
	
	/**
	 * OBJTRAZAS nos mostraralas trazas de código
	 */
	private static final Logger OBJTRAZAS = J000J000Trazas.getLogger(J372J010ServicioBusquedaPersonasVenBean.class);
	/**
	 * Inializacion de la variable CRETORNO_S valor CRETORNO-S
	 */
	private static final String CRETORNO_S = "CRETORNO-S"; //$NON-NLS-1$

	/**
	 * Inializacion de la variable GERROR_S valor GERROR-S
	 */
	private static final String GERROR_S = "GERROR-S"; //$NON-NLS-1$

	/**
	 * Inializacion de la variable GNOMPROG_S valor GNOMPROG-S
	 */
	private static final String GNOMPROG_S = "GNOMPROG-S";//$NON-NLS-1$
	
	//MU-2016-006673 - RAROALE - INI
	/**
	 * Inializacion de la variable KDOMICILIO1_E valor KDOMICILIO1-E
	 */
	private static final String KDOMICILIO1_E = "KDOMICILIO1-E";
	
	/**
	 * Inializacion de la variable KDOMICILIO2_E valor KDOMICILIO2-E
	 */
	private static final String KDOMICILIO2_E = "KDOMICILIO2-E";
	
	/**
	 * Inializacion de la variable FMODIFICACION_E valor FMODIFICACION-E
	 */
	private static final String FMODIFICACION_E = "FMODIFICACION-E";
	//MU-2016-006673 - RAROALE - FIN
	
	

	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";//$NON-NLS-1$
	
	
	
	/**
	 * Ejecuta el servicio cobol de carga inicial
	 * 
	 * @param eDatos
	 *            contiene los parametros para hacer la llamada al servicio
	 * @return sDatos datos retornados por el servicio cobol
	 * @throws J362J001RescatesException
	 * 
	 */

	public static J372J008GestionExpedientesVenPageBean ejecutaServicioCobol (
			J372J008GestionExpedientesVenPageBean eDatos)
			throws J372J001VencimientosException {

		final J372J003ServicioCobol oGesServicios = new J372J003ServicioCobol();
		J372J008GestionExpedientesVenPageBean sDatos = eDatos ;
		// MU-2016-006673 - RAROALE - INI
		final UtilidadesBeanAction util = new UtilidadesBeanAction ();
		// MU-2016-006673 - RAROALE - FIN

		J000J000Conectable oConector;
		

		if (OBJTRAZAS.isDebugEnabled()) {
			OBJTRAZAS.debug("ServicioBusquedaExpVenBean: CARGA DE DATOS COBOL");
		}
		try {

			oConector = oGesServicios.prepararLlamada("IN372VENCIMIENTOSMANUALES",
					"B372VT11GestionPersonasVen", eDatos.getUsuario());

			oConector.setCampo("KSERVICIO-C", "B372VT11");

			/* cabecera de control */
			oConector.setCampo("CCANAL-C", "01");
			oConector.setCampo("KEMPRESA-C", "MAV");
			oConector.setCampo("KDEPARTA-C", "ISA");
			oConector.setCampo("KUSUARIO-C", eDatos.getUsuario()
					.getStUsuario_Racf());
			oConector.setCampo("KCADISTR-C", ENBLANCO);

			/* Entrada */
			//MU-2016-006673 - RAROALE - INI
			oConector.setCampo("KPERSONA1-E", eDatos.getKPersonaPri().toString());
			oConector.setCampo("KPERSONA2-E", eDatos.getKPersonaSeg().toString());
			oConector.setCampo(KDOMICILIO1_E, eDatos.getKDomicilioPri().toString());
			if (ENBLANCO.equals(eDatos.getFmodificacion())) {
				oConector.setCampo(FMODIFICACION_E, "00000000");
			} else {
				oConector.setCampo(FMODIFICACION_E, eDatos.getFmodificacion());
			}
			//MU-2016-006673 - RAROALE - FIN
			
			oConector.ejecutarServicio();

			/* Datos de salida */
			

				sDatos.setDesRetorno(oConector.getCampo(GERROR_S));
				sDatos.setRetorno(oConector.getCampo(CRETORNO_S));
				sDatos.setNomPrograma(oConector.getCampo(GNOMPROG_S));

				if (OBJTRAZAS.isDebugEnabled()) {
					
					OBJTRAZAS
							.debug("ServicioBusquedaExpResBean_Datos salida: GERROR-S = "
									+ oConector.getCampo(GERROR_S));
					OBJTRAZAS
							.debug("ServicioBusquedaExpResBean_Datos salida: CRETORNO-S = "
									+ oConector.getCampo(CRETORNO_S));
					OBJTRAZAS
							.debug("ServicioBusquedaExpResBean_Datos salida: GNOMPROG-S = "
									+ oConector.getCampo(GNOMPROG_S));
				}

					sDatos.setNombrePri ( oConector.getCampo("GNOMBRELARGO-S") );
					sDatos.setApellido1Pri ( oConector.getCampo("GAPELLIDO1-S") );
					sDatos.setApellido2Pri ( oConector.getCampo("GAPELLIDO2-S") );
					sDatos.setDomicilioPri ( oConector.getCampo("GDOMICILIO-S") );
					sDatos.setCodPostalPri ( oConector.getCampo("CCODPOST-S") );
					sDatos.setLocalidadPri ( oConector.getCampo("GPOBLACION-S") );
					sDatos.setProvinciaPri ( oConector.getCampo("CPROVINCIA-S") );
					sDatos.setPaisPri ( oConector.getCampo("CPAIS-S") );
					sDatos.setFecNacPri ( oConector.getCampo("FNACIMIENTO-S") );
					sDatos.setNifRepLegalPri ( oConector.getCampo("CNIFLEGAL-S") );
					
					if (eDatos.getAnio().compareTo(new BigDecimal ("1950")) != 0) {
					    sDatos.setDiscapacitadoPri ( oConector.getCampo("K2GRADODISC-S") );
					    sDatos.setSitFamiliarPri ( oConector.getCampo("K2SITFAM-S") );
					    sDatos.setPenComPri ( oConector.getCampo("IPENSIONCOM-S") );
					    sDatos.setAnulAlimenHijosPri ( oConector.getCampo("IANUALALIM-S") );
					
					} else {
					    sDatos.setDiscapacitadoPri(eDatos.getDiscapacitadoPri());
					    sDatos.setSitFamiliarPri(eDatos.getSitFamiliarPri());
					    sDatos.setPenComPri(eDatos.getPenComPri());
					    sDatos.setAnulAlimenHijosPri(eDatos.getAnulAlimenHijosPri());
					    sDatos.setPrestViviendoPri(eDatos.getPrestViviendoPri());
					    sDatos.setNifConyugePri(eDatos.getNifConyugePri());
					    
					}
					
					// MU-2016-006673 - RAROALE - INI
					sDatos.setKDomicilioPri(util.numeroBig(oConector.getCampo(KDOMICILIO1_E)));
					// MU-2016-006673 - RAROALE - FIN

				return sDatos;
			
		
		} catch (J000J000Exception e) {
			J372J001VencimientosException objException = new J372J001VencimientosException(
					J372J001VencimientosException.ERROR_GENERICO_CICS, ENBLANCO);
			objException.setStDescripcion(e.getLocalizedMessage());
			objException.setStClase(e.getClass().toString());
			objException.setStGNomProg(ENBLANCO);
			objException.setStGError("Error Genérico CICS"); //$NON-NLS-1$
			objException.setStCRetorno(ENBLANCO);

			throw objException;
		}
	}

}
