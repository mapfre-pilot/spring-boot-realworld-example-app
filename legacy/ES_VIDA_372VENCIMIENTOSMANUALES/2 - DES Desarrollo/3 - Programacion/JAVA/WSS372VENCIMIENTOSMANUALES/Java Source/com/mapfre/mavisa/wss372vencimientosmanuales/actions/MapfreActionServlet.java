package com.mapfre.mavisa.wss372vencimientosmanuales.actions;

import java.io.IOException;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import mapfre.wss000arquitect.excepciones.J000J000Exception;
import mapfre.wss000arquitect.utilidades.J000J000PropiedadesArquitectura;
import mapfre.wss000arquitect.utilidades.J000J000Trazas;
import com.mapfre.mavisa.wss372vencimientosmanuales.config.J372J001ConstantesVen;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionServlet;

/**
 * @author everis
 * @version 1.0 Versión inicial Para cambiar la plantilla para este comentario
 *          de tipo generado vaya a
 *          Ventana&gt;Preferencias&gt;Java&gt;Generación de código&gt;Código y
 *          comentarios
 * 
 */

public class MapfreActionServlet extends ActionServlet {

	/**
	 * MapfreActionServlet
	 */
	public MapfreActionServlet () {
		super ();

	}

	/**
	 * @param config
	 * 
	 * @throws ServletException
	 */
	@Override
	public void init ( ServletConfig config ) throws ServletException {

		super.init ( config );

		final Logger objTrazas = J000J000Trazas.getLogger ( MapfreActionServlet.class );

		try {
			final ServletContext oContexto = config.getServletContext ();
			final String stHttpPath = J000J000PropiedadesArquitectura.getConfiguracion ().getProperty ( "HTTP_PATH" );

			final StringBuffer infoTrazas = new StringBuffer ( 50 );
			infoTrazas.append ( "MapfreActionServlet.init - PATH: " );
			infoTrazas.append ( stHttpPath );

			oContexto.setAttribute ( J372J001ConstantesVen.HTTP_PATH_ARQ,
					stHttpPath );
			objTrazas.info ( infoTrazas.toString () );

		} catch ( J000J000Exception oException ) {
			objTrazas.error ( "ERROR: MapfreActionServlet.init: "
					+ oException.toString () );
		}
	}

	/**
	 * 
	 * @param httprequest
	 * @param response
	 * @throws ServletException
	 * @throws IOException
	 */
	@Override
	public void doGet ( HttpServletRequest httprequest,
			HttpServletResponse response ) throws ServletException, IOException {
		doPost ( httprequest, response );
	}

	/**
	 * 
	 * @param request
	 * @param response
	 * @throws ServletException
	 * @throws IOException
	 */

	@Override
	public void doPost ( HttpServletRequest request,
			HttpServletResponse response ) throws ServletException, IOException {

		// control de caché
		final String contentType = "text/html;charset=ISO-8859-1";
		response.setContentType ( contentType );
		response.setHeader ( "expires", "-1" );
		response.setHeader ( "Pragma", "public" );
		response.setHeader ( "Cache-Control", "max-age=0" );

		// inicializar datos de sesion
		gestionNavegacionGesvida ( request );

		super.doPost ( request, response );
	}

	/**
	 * @param request
	 */

	private void gestionNavegacionGesvida ( HttpServletRequest request ) {
		HttpSession oSesion = request.getSession ( true );
		if ( oSesion.getAttribute ( J372J001ConstantesVen.FLAG_GESVIDA ) == null
				&& request.getParameter ( J372J001ConstantesVen.FLAG_GESVIDA ) != null ) {
			oSesion.setAttribute ( J372J001ConstantesVen.FLAG_GESVIDA, request
					.getParameter ( J372J001ConstantesVen.FLAG_GESVIDA ) );
		}
	}

}
