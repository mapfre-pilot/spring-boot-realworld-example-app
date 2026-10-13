package com.mapfre.mavisa.wss372vencimientosmanuales.actions;

import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J008GestionExpedientesVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans.J372J010GestionExpCoaseguroVenHelperBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J008GestionExpedientesVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.Mensajes;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;
import mapfre.wss000arquitect.utilidades.J000J000Trazas;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


// R&V - Junio 2017 - CU011 - everis(RGL)
// Nueva clase para tratar la accion de la llamada al servicio B372VT12GestionExpCoaseguroRes
public class J372J020GestionExpCoaseguroVenAction extends MapfreAction

{







	/**
	 * OBJTRAZAS
	 */
	private static final Logger OBJTRAZAS = J000J000Trazas.getLogger(J372J020GestionExpCoaseguroVenAction.class);
	/**
	 * Inicializacion de la variable FORM_GESTION_EXPED, valor formGestionExped
	 */
	private static final String FORM_GESTION_EXPED = "formGestionExped";

	/**
	 * Inicializacion de la variable ENBLANCO,
	 * valor BLANCO
	 */
	private static final String ENBLANCO = "";
	/**
	 * Inicializacion de la variable OK,
	 * valor OK
	 */
	private static final String OK = "OK";
	/**
	 * Inicializacion de la variable TEXTOERROR,
	 * valor Error no controlado
	 */
	private static final String TEXTOERROR = "Error no controlado";








	@Override
	public ActionForward execute ( ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response )
			throws J372J001VencimientosException {

		ActionForward forward = new ActionForward ();




		Mensajes mensaje = new Mensajes();
		J372J008GestionExpedientesVenActionForm formConsulta = new J372J008GestionExpedientesVenActionForm();
		J372J008GestionExpedientesVenActionForm formConsultaSalida = new J372J008GestionExpedientesVenActionForm();

		try {
			/* Bean de Entrada y Salida en la llamada al servicio Cobol */
			final J372J010GestionExpCoaseguroVenHelperBean HELPERBEAN = new J372J010GestionExpCoaseguroVenHelperBean();
			J372J008GestionExpedientesVenPageBean pageBeanEntrada = new J372J008GestionExpedientesVenPageBean();
			J372J008GestionExpedientesVenPageBean pageBeanSalida = new J372J008GestionExpedientesVenPageBean();

			/* Pasamos el formulario generico a uno especifico */
			formConsulta = (J372J008GestionExpedientesVenActionForm) form;
			final J000J000Usuario USUARIO = J000J000Usuario.getUsuarioArquitectura(request);

			OBJTRAZAS.debug("R&V [J372J020GestionExpCoaseguroVenAction.execute] voy a recogerDatosEntrada");
			OBJTRAZAS.debug("R&V [J372J020GestionExpCoaseguroVenAction.execute] formConsulta.getImpCapital() = "+formConsulta.getImpCapital());
			/* Invocamos al metodo recogerDatosEntrada pasando los datos del
			 * formulario y el usuario al pagebean de entrada del servicio. */
			pageBeanEntrada = HELPERBEAN.recogerDatosEntrada ( formConsulta , USUARIO);

			OBJTRAZAS.debug("R&V [J372J020GestionExpCoaseguroVenAction.execute] pageBeanEntrada.getImpCapital() = "+pageBeanEntrada.getImpCapital());
			OBJTRAZAS.debug("R&V [J372J020GestionExpCoaseguroVenAction.execute] voy a llamarServicio");
			/* Llamamos al servicio cobol pasandole los datos de entrada */
			pageBeanSalida = HELPERBEAN.llamarServicio(pageBeanEntrada);

			OBJTRAZAS.debug("R&V [J372J020GestionExpCoaseguroVenAction.execute] voy a ponerDatosSalida");
			/* Pasamos los parametros de salida del servicio desde el pagebean
			 * de salida al formulario. */
			//formConsultaSalida = HELPERBEAN.ponerDatosSalida(pageBeanSalida, formConsultaSalida); //R&V linea original
			formConsultaSalida = HELPERBEAN.ponerDatosSalida(pageBeanSalida, formConsulta); //R&V mi modificacion

			OBJTRAZAS.debug("R&V [J372J020GestionExpCoaseguroVenAction.execute] muestro mensaje por pantalla");
			/* Mostramos mensajes por pantalla
			 * Si ha ido bien mandará mensaje ok y si no mandará la descripcion de cobol */
			formConsultaSalida .setTipOperacionJSP("OKCONSULTA");
			if ("00".equals(formConsultaSalida .getRetorno().trim())){
				mensaje.setMensaje(1,"II",ENBLANCO,"El cuadro de coaseguradoras se ha cargado satisfactoriamente.",ENBLANCO,ENBLANCO);
			} else {
				mensaje.setMensaje(1,"II",ENBLANCO,"Se ha producido un problema al cargar el cuadro de coaseguradoras.",ENBLANCO,ENBLANCO);
			}
			/*
			if ("00".equals(formConsultaSalida .getRetorno().trim())&& ENBLANCO .equals(formConsultaSalida .getDesRetorno().trim())) {
				mensaje.setMensaje(1, "II", ENBLANCO, getResources(request)
						.getMessage("vencimiento.mensaje.ok"), ENBLANCO, ENBLANCO); //R&V ojo con vencimiento.mensaje.ok es copia de rescate.mensaje.ok
			}else {
				mensaje.setMensaje(1, "II", ENBLANCO , formConsultaSalida .getDesRetorno(), ENBLANCO , ENBLANCO );
			}
			*/

		} catch (J372J001VencimientosException e) {

			if (OBJTRAZAS.isEnabledFor(Level.ERROR)) {
			/*
			 * LOGS trazas para poder seguir las diferentes exception de
			 * J372J001VencimientosException
			 */
				OBJTRAZAS
						.error("J372J020GestionExpCoaseguroVenAction - Excepcion - Descripcion: "
								+ e.getStDescripcion());
				OBJTRAZAS
						.error("J372J020GestionExpCoaseguroVenAction - Excepcion - Localized:"
								+ e.getLocalizedMessage());
				OBJTRAZAS
						.error("J372J020GestionExpCoaseguroVenAction - Excepcion - Clase:"
								+ e.getStClase());
				OBJTRAZAS
						.error("J372J020GestionExpCoaseguroVenAction - Excepcion - Error:"
								+ e.getStMensajeError());
				OBJTRAZAS
						.error("J372J020GestionExpCoaseguroVenAction - Excepcion - Metodo:"
								+ e.getStMetodo());
			}
			final String DESCODERROR = e.getStGError();
			formConsulta.setTipOperacionJSP("NOKCONSULTA");

			mensaje.setMensaje(1, "XX", ENBLANCO, DESCODERROR, ENBLANCO,
					ENBLANCO);

			mensaje.setMensaje(3, "XX", "!!", TEXTOERROR, this.getClass()
					.getName(), TEXTOERROR);

		} finally {
			/* Finally. Siempre se va a ejecutar, nos mostrara mensaje por pantalla*/
			formConsulta.setVectorMensajes(mensaje.getVectorMensajes()); // R&V IN007 (la linea original tenia formConsultaSalida)
			/* Devolvemos el formulario a la request donde lo deja guardado para
			 * recuperarlo despues. */
			//request.setAttribute("formEmisionFiniquitos", formConsulta);
			OBJTRAZAS.debug("R&V [J372J020GestionExpCoaseguroVenAction.execute] formConsultaSalida.getPorCoasegur1() = "+formConsultaSalida.getPorCoasegur1());
			request.setAttribute ( FORM_GESTION_EXPED, formConsulta ); // R&V IN007 (la linea original tenia formConsultaSalida)
			String parametro = new String("true");
			request.setAttribute( "ActualizacionCuadroCoaseguros", parametro);
		}

		/* Finish with */
		// formConsulta.setVectorMensajes(mensaje.getVectorMensajes());

		forward = mapping.findForward ( "OK" );

		return (forward);
	}
}
