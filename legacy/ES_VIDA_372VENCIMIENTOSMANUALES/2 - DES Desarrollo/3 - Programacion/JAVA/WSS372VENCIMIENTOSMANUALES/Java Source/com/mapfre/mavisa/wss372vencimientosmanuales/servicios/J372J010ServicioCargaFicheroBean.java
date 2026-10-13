package com.mapfre.mavisa.wss372vencimientosmanuales.servicios;


import mapfre.wss000arquitect.accesodatos.Factoria.J000J000Conectable;
import mapfre.wss000arquitect.excepciones.J000J000Exception;
import mapfre.wss000arquitect.utilidades.J000J000Trazas;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J010CargaFicheroVenPageBean;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;

/**
 * @author everis
 * @version 1.0 Versión inicial Clase de negocio. Contiene los metodos
 *          necesarios para ejecutar los servicios cobol de carga inicial y de
 *          calculo
 * 
 */
public class J372J010ServicioCargaFicheroBean {
	
	/**
	 * Constructor por defecto PRIVATE
	 *
	 */	
	private J372J010ServicioCargaFicheroBean(){
		//	 TODO Constructor por defecto PRIVATE	
	}
	/**
	 * objTrazas nos mostraralas trazas de código
	 */
	private static final Logger OBJTRAZAS = J000J000Trazas.getLogger(J372J010ServicioCargaFicheroBean.class);

	/**
	 * Inicializacion de la variable ENBLANCO, 
	 * valor BLANCO
	 */
	private static final String ENBLANCO = "";
	
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
	 * Ejecuta el servicio cobol de carga inicial
	 * 
	 * @param eDatos
	 *            contiene los parametros para hacer la llamada al servicio
	 * @return sDatos datos retornados por el servicio cobol
	 * @throws J372J001VencimientosException
	 */
	public static J372J010CargaFicheroVenPageBean ejecutaServicioCobol (
			J372J010CargaFicheroVenPageBean eDatos)
			throws J372J001VencimientosException {

		final J372J003ServicioCobol oGesServicios = new J372J003ServicioCobol();

		J000J000Conectable oConector;
		J372J010CargaFicheroVenPageBean sDatos = new J372J010CargaFicheroVenPageBean();
		if (OBJTRAZAS.isDebugEnabled()) {
		OBJTRAZAS
				.debug("J372J010CargaFicheroVenPageBean: CARGA DE DATOS COBOL");
		}
		try {
			
			oConector = oGesServicios.prepararLlamada (
					"IN372VENCIMIENTOSMANUALES",
					"B372VT07CargaFicheroVen", eDatos.getUsuario () );
			oConector.setCampo ( "KSERVICIO-C", "B372VT08" );

			// cabecera de control
			oConector.setCampo ( "CCANAL-C", "01" );
			oConector.setCampo ( "KEMPRESA-C", "MAV" );
			oConector.setCampo ( "KDEPARTA-C", "ISA" );
			oConector.setCampo ( "KUSUARIO-C", eDatos.getUsuario ()
					.getStUsuario_Racf () );
			oConector.setCampo ( "KCADISTR-C", ENBLANCO );

			// Entrada
			oConector.setCampo ( "TIPOEMI-E", eDatos.getTipo ().toString () );
			
			// logs de datos de entrada
			if (OBJTRAZAS.isDebugEnabled()) {
			OBJTRAZAS.debug(" TIPOEMI-E = "
					+ oConector.getCampo("TIPOEMI-E"));
			}
			oConector.ejecutarServicio();

			final String SRESULTADO = oConector.getCampo(CRETORNO_S);
			
			if (SRESULTADO.compareTo("00") == 0) {
				sDatos.setDesRetorno(oConector.getCampo(GERROR_S));
				sDatos.setRetorno(oConector.getCampo(CRETORNO_S));
				sDatos.setNomPrograma(oConector.getCampo(GNOMPROG_S));
				sDatos.setTipo(oConector.getCampo("TIPOEMI-E"));
				if (OBJTRAZAS.isDebugEnabled()) {
				OBJTRAZAS.debug("CargaFicheroBean: GNOMPROG-S = "
						+ oConector.getCampo(GNOMPROG_S));
				OBJTRAZAS.debug("CargaFicheroBean: GERROR-S   = "
						+ oConector.getCampo(GERROR_S));
				OBJTRAZAS.debug("CargaFicheroBean: CRETORNO-S = "
						+ oConector.getCampo(CRETORNO_S));
				}
				return sDatos;
			} else {
				if (OBJTRAZAS.isEnabledFor(Level.ERROR)) {
				OBJTRAZAS.error("CargaFicheroBean: GNOMPROG-S = "
						+ oConector.getCampo(GNOMPROG_S));
				OBJTRAZAS.error("CargaFicheroBean: GERROR-S   = "
						+ oConector.getCampo(GERROR_S));
				OBJTRAZAS.error("CargaFicheroBean: CRETORNO-S = "
						+ oConector.getCampo(CRETORNO_S));
				}
				J372J001VencimientosException objException = 
					 new J372J001VencimientosException (J372J001VencimientosException.ERROR_NEGOCIO, ENBLANCO);
				objException.setStMetodo("ejecutaServicio()");
				objException.setStClase("CargaFicheroBean");
				final StringBuffer descriBuffer = new StringBuffer("0");
				descriBuffer.append(SRESULTADO).append(": ").append(oConector.getCampo(GERROR_S));
				objException.setStDescripcion(descriBuffer.toString());
				objException.setStGNomProg(oConector.getCampo(GNOMPROG_S));
				objException.setStGError(oConector.getCampo(GERROR_S));
				objException.setStCRetorno(oConector.getCampo(CRETORNO_S));
				throw objException;
			
				}
			}
		 catch (J372J001VencimientosException e) {
			throw e;
		} catch (J000J000Exception e) {
			J372J001VencimientosException objException = new J372J001VencimientosException(
					J372J001VencimientosException.ERROR_GENERICO_CICS, ENBLANCO);
			objException.setStDescripcion(e.getLocalizedMessage());
			objException.setStClase(e.getClass().toString());
			objException.setStGNomProg(ENBLANCO);
			objException.setStGError("Error Genérico CICS");
			objException.setStCRetorno(ENBLANCO);

			throw objException;
		}

	}

}
