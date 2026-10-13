package com.mapfre.mavisa.wss372vencimientosmanuales.helperbeans;

import com.mapfre.mavisa.wss372vencimientosmanuales.actions.MapfreAction;
import com.mapfre.mavisa.wss372vencimientosmanuales.exceptions.J372J001VencimientosException;
import com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J008GestionExpedientesVenActionForm;
import com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans.J372J008GestionExpedientesVenPageBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.servicios.J372J011ServicioExpCoaseguroVenBean;
import com.mapfre.mavisa.wss372vencimientosmanuales.utils.UtilidadesBeanAction;
import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;
import java.math.BigDecimal;
import org.apache.log4j.Logger;

// R&V Junio 2017 - CU011 - everis(RGL) - INI
public class J372J010GestionExpCoaseguroVenHelperBean extends MapfreAction {

	private static final Logger OBJTRAZAS = Logger
			.getLogger ( J372J010GestionExpCoaseguroVenHelperBean.class );

	/*
	private static final String PUNTO = "."; //$NON-NLS-1$
	private static final String COMA = ","; //$NON-NLS-1$
	private static final String V = "V"; //$NON-NLS-1$
	private static final String VI = "VI"; //$NON-NLS-1$
	private static final String AN = "AN"; //$NON-NLS-1$
	private static final String ESPACIOS = "";
	private static final String CERO ="0";
	*/


	public J372J008GestionExpedientesVenPageBean recogerDatosEntrada (
			J372J008GestionExpedientesVenActionForm form,
			J000J000Usuario usuario ) {

		J372J008GestionExpedientesVenPageBean datosEntrada = new J372J008GestionExpedientesVenPageBean();
		final UtilidadesBeanAction UTIL = new UtilidadesBeanAction ();
		
		// Se recuperan los que necesitamos del formulario
		final BigDecimal CERO = new BigDecimal("0.0");
		datosEntrada.setUsuario ( usuario );
		datosEntrada.setPolizaBloq3( UTIL.rellenarCerosIzq ( 10, form.getPolizaBloq3() ) );
		datosEntrada.setSubpoliza ( UTIL.numeroBig ( UTIL.rellenarCerosIzq ( 4,	form.getSubpoliza () ) ) );
		datosEntrada.setImpCapital(form.getImpCapital().equals("")?CERO:new BigDecimal(form.getImpCapital().replace(",",".")));
		datosEntrada.setImpCoasegur1(form.getImpCoasegur1().equals("")?CERO:new BigDecimal(form.getImpCoasegur1().replace(",",".")));
		datosEntrada.setImpCoasegur2(form.getImpCoasegur2().equals("")?CERO:new BigDecimal(form.getImpCoasegur2().replace(",",".")));
		datosEntrada.setImpCoasegur3(form.getImpCoasegur3().equals("")?CERO:new BigDecimal(form.getImpCoasegur3().replace(",",".")));
		datosEntrada.setImpCoasegur4(form.getImpCoasegur4().equals("")?CERO:new BigDecimal(form.getImpCoasegur4().replace(",",".")));
		datosEntrada.setImpCoasegur5(form.getImpCoasegur5().equals("")?CERO:new BigDecimal(form.getImpCoasegur5().replace(",",".")));
		datosEntrada.setImpCoasegur6(form.getImpCoasegur6().equals("")?CERO:new BigDecimal(form.getImpCoasegur6().replace(",",".")));
		OBJTRAZAS.debug("R&V [J372J010GestionExpCoaseguroVenHelperBean.recogerDatosEntrada] he puesto poliza y subpoliza y datosEntrada.getImpCapital() = "+datosEntrada.getImpCapital().toString());
		OBJTRAZAS.debug("R&V [J372J010GestionExpCoaseguroVenHelperBean.recogerDatosEntrada] datosEntrada.getImpCoasegur1() = "+datosEntrada.getImpCoasegur1().toString());
		return datosEntrada;
	}


	public J372J008GestionExpedientesVenPageBean llamarServicio (J372J008GestionExpedientesVenPageBean datosEntrada)
			throws J372J001VencimientosException {

		J372J008GestionExpedientesVenPageBean datosSalida = new J372J008GestionExpedientesVenPageBean();

		try {
			OBJTRAZAS.debug("R&V [J372J010GestionExpCoaseguroVenHelperBean.llamarServicio] llamo al servicio COBOL ...");
			OBJTRAZAS.debug("R&V [J372J010GestionExpCoaseguroVenHelperBean.llamarServicio] datosEntrada.getImportePri() = "+datosEntrada.getImportePri());
			datosSalida = J372J011ServicioExpCoaseguroVenBean.ejecutaServicioCobol(datosEntrada);
			OBJTRAZAS.debug("R&V [J372J010GestionExpCoaseguroVenHelperBean.llamarServicio] ... de regreso de la llamada al servicio COBOL, salgo");
		} catch ( J372J001VencimientosException e ) {
			throw e;
		}
		return datosSalida;
	}
	
	public J372J008GestionExpedientesVenActionForm ponerDatosSalida (
			J372J008GestionExpedientesVenPageBean entrada,
			J372J008GestionExpedientesVenActionForm form ) {
		OBJTRAZAS.debug("R&V [J372J010GestionExpCoaseguroVenHelperBean.ponerDatosSalida] actualizo datos del cuadro y retorno el nuevo form");

		form.setDesRetorno ( entrada.getDesRetorno () );
		form.setRetorno ( entrada.getRetorno () );
		form.setNomPrograma ( entrada.getNomPrograma() );

		form.setCodCoasegur1(entrada.getCodCoasegur1());
		form.setPorCoasegur1(entrada.getPorCoasegur1().toString());
		form.setCodCoasegur2(entrada.getCodCoasegur2());
		form.setPorCoasegur2(entrada.getPorCoasegur2().toString());
		form.setCodCoasegur3(entrada.getCodCoasegur3());
		form.setPorCoasegur3(entrada.getPorCoasegur3().toString());
		form.setCodCoasegur4(entrada.getCodCoasegur4());
		form.setPorCoasegur4(entrada.getPorCoasegur4().toString());
		form.setCodCoasegur5(entrada.getCodCoasegur5());
		form.setPorCoasegur5(entrada.getPorCoasegur5().toString());
		form.setCodCoasegur6(entrada.getCodCoasegur6());
		form.setPorCoasegur6(entrada.getPorCoasegur6().toString());

		//Ajuste para escribir los importes, de otra forma el formulario no muestra bien todos los valores
		form.setImpCoasegur1(entrada.getImpCoasegur1().toString());
		form.setImpCoasegur2(entrada.getImpCoasegur2().toString());
		form.setImpCoasegur3(entrada.getImpCoasegur3().toString());
		form.setImpCoasegur4(entrada.getImpCoasegur4().toString());
		form.setImpCoasegur5(entrada.getImpCoasegur5().toString());
		form.setImpCoasegur6(entrada.getImpCoasegur6().toString());


		OBJTRAZAS.debug("R&V [J372J010GestionExpCoaseguroVenHelperBean.ponerDatosSalida] form.getPorCoasegur1() = " + form.getPorCoasegur1() );

		return form;
	}


	public J372J008GestionExpedientesVenActionForm ponerDatosFormulario (
			J372J008GestionExpedientesVenPageBean eDatos ) {

		J372J008GestionExpedientesVenActionForm form = new J372J008GestionExpedientesVenActionForm ();

		OBJTRAZAS.debug("R&V [J372J010GestionExpCoaseguroVenHelperBean.ponerDatosFormulario] retorno un form 'vacio'!!!!!");
		return form;
	}

}
// R&V Junio 2017 - CU011 - everis(RGL) - FIN