package com.mapfre.mavisa.wss372vencimientosmanuales.servicios;

import mapfre.wss000arquitect.accesodatos.Factoria.J000J000Conectable;
import mapfre.wss000arquitect.accesodatos.Factoria.J000J000FactoriaAccesoDatos;
import mapfre.wss000arquitect.accesodatos.FactoriaServicio.J000J000GestorServicios;
import mapfre.wss000arquitect.accesodatos.FactoriaServicio.J000J000Servicio;
import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;
import mapfre.wss000arquitect.excepciones.J000J000Exception;
import mapfre.wss000arquitect.utilidades.J000J000Trazas;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;

import org.apache.log4j.Logger;

/**
 * @author everis Prepara la llamada al servicio Cobol estableciendo la conexión
 *         con el mismo.
 * @version 1.0 Versión inicial
 */

public class J372J003ServicioCobol {

	/**
	 * @param pstInterface
	 * @param pstServicio
	 * @param pOUsuario
	 * @return oConector
	 * @throws J372J001VencimientosException
	 */
	public J000J000Conectable prepararLlamada ( String pstInterface,
			String pstServicio, J000J000Usuario pOUsuario )
			throws J372J001VencimientosException {

		// Instancia del objeto conector
		J000J000Conectable oConector = null;

		try {
			// Instacia del objeto servicios
			final J000J000GestorServicios oGestorServicios = J000J000GestorServicios.getInstance ();

			// Instancia del objeto servicio
			J000J000Servicio oServicio = null;

			oServicio = oGestorServicios.obtenerServicioHost ( pstInterface,
					pstServicio );

			// Se crea el conector
			oConector = J000J000FactoriaAccesoDatos.crearConector ( oServicio,
					pOUsuario );

		} catch ( J000J000Exception oExceptionArquitectura ) {
			throw new J372J001VencimientosException ( "[prepararLlamada()] "
					+ this.getClass ().getName () + ' '
					+ oExceptionArquitectura.getStDetalleDescripcionError () );

		}

		return oConector;

	} 
}
