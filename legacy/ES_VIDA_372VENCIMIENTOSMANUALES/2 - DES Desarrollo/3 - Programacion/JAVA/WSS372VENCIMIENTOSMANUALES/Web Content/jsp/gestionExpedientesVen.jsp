<%-- MODIFICACION : MU-2016-006673
FECHA : MARZO 2016
DESCRIPCION: Se permite modificar y guardar en BBDD el kdomiclio del beneficiario
AUTOR : RAROALE --%>

<!-- MODIFICACION : MU-2016-006664
FECHA : MARZO 2016
DESCRIPCION: Se permite modificar y guardar en BBDD los importes de Coaseguros
AUTOR : RAROALE -->

<!-- MODIFICACIÓN : MU-2015-041869
FECHA : 14/10/2015
DESCRIPCION: Incluir "Año Fiscal" para informar a la BDGI.
AUTOR : INDRA -->

<%--
Descripcion : JSP de la pantalla de Gestión de Expedientes de Vencimientos
Programador : EVERIS.
Fecha : 06/2011  
 Version : 1.0
--%> 
 
<%@page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>  
<%@ taglib uri="/WEB-INF/struts-tiles.tld" prefix="tiles"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/maptags.tld" prefix="map"%>  
<%@ taglib uri="/WEB-INF/struts-nested.tld" prefix="nested"%> 
<map:alertSupport />

<%@page import="java.util.List"%>
<html>

<%@ page
	import="com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J008GestionExpedientesVenActionForm"%>
<%@ page import="com.mapfre.mavisa.wss372vencimientosmanuales.utils.Msg"%>

<!--Desde aqui nos traemos el valor de tipOperacion una vez que se carge el action-->
<%
	final J372J008GestionExpedientesVenActionForm formGestionExp = 
			(J372J008GestionExpedientesVenActionForm) request.getAttribute("formGestionExped");
	final String tipOperacionJSP = formGestionExp.getTipOperacionJSP();

	final String tipOperacion = formGestionExp.getTipOperacion();
	final String pestanaJSP = formGestionExp.getPestanaJSP();
	final List vectorMensajes = formGestionExp.getVectorMensajes();
%>


<head>
<title><bean:message key="rescate.jsp.gestion"/></title>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta name="GENERATOR" content="Rational Software Architect">
<link rel="stylesheet" type="text/css"
	href="<bean:write name="HTTP_PATH"/>/css/contenedor.css">
<link rel="stylesheet" type="text/css"
	href="<bean:write name="HTTP_PATH"/>/css/agrupacion.css" />
<link rel="stylesheet" type="text/css"
	href="<bean:write name="HTTP_PATH"/>/css/estilomapfre.css" />

<link rel="stylesheet" type="text/css"
	href="<bean:write name="HTTP_PATH"/>/css/comun.css" />
<link rel="stylesheet" type="text/css"
	href="<bean:write name="HTTP_PATH"/>/css/contenedor.css">
<%--Provincia--%>
<script src="<bean:write name="HTTP_PATH"/>/js/t01162.js"></script>
<%--Pais--%>
<script src="<bean:write name="HTTP_PATH"/>/js/t01164.js"></script>
<SCRIPT src="<bean:write name="HTTP_PATH"/>/js/t01051.js" type="text/javascript"></SCRIPT>


<SCRIPT src="<bean:write name="HTTP_PATH"/>/js/t07503.js" type="text/javascript"></SCRIPT>
<SCRIPT src="<bean:write name="HTTP_PATH"/>/js/t07504.js" type="text/javascript"></SCRIPT>
<SCRIPT src="<bean:write name="HTTP_PATH"/>/js/t07505.js" type="text/javascript"></SCRIPT>
<SCRIPT src="<bean:write name="HTTP_PATH"/>/js/t07956.js" type="text/javascript"></SCRIPT>

<script src="<bean:write name="HTTP_PATH"/>/js/comun.js"
	language="JavaScript" type="text/JavaScript"></script>
<script src="<bean:write name="HTTP_PATH"/>/js/generales.js"
	language="JavaScript" type="text/JavaScript"></script>
<script src="<bean:write name="HTTP_PATH"/>/js/validaciones.js"
	language="JavaScript" type="text/JavaScript"></script>
<script src="<%=request.getContextPath()%>/js/impuestosVen.js"
	language="JavaScript" type="text/JavaScript"></script>
<script src="<%=request.getContextPath()%>/js/psurtsub.js"
	language="JavaScript" type="text/JavaScript"></script>
<script src="<bean:write name="HTTP_PATH"/>/js/validaciones.js"
	language="JavaScript" type="text/JavaScript"></script>
<script src="<bean:write name="HTTP_PATH"/>/js/customtag.js" 
	language="JavaScript" type="text/JavaScript"></script>
<script src="<bean:write name="HTTP_PATH"/>/js/customtag-validations.js"
	language="JavaScript" type="text/JavaScript"></script>
<script src="<bean:write name="HTTP_PATH"/>/js/ValidacionesPantallas.js"
	language="JavaScript" type="text/JavaScript"></script>

<%-- R&V - Junio 2017 - REACONDICIONAMIENTO VT01 VT04 - everis(RGL) - INI --%>
<script src="<html:rewrite page="/js/GestionExpHabilitarLimpiarVen.js"/>"
	language="JavaScript" type="text/JavaScript"></script>
<%-- R&V - Junio 2017 - REACONDICIONAMIENTO VT01 VT04 - everis(RGL) - FIN --%>

<script src="<html:rewrite page="/js/GestionExpedienteVen.js"/>"
	language="JavaScript" type="text/JavaScript"></script>
	<script src="<html:rewrite page="/js/GestionExpedienteCalculoVen.js"/>"
	language="JavaScript" type="text/JavaScript"></script>
<script src="<html:rewrite page="/js/GestionPersonaVen.js"/>"
	language="JavaScript" type="text/JavaScript"></script>
<script src="<html:rewrite page="/js/GestionCalculoVen.js"/>"
	language="JavaScript" type="text/JavaScript"></script>		
<script src="<html:rewrite page="/js/GestionExpHabilitarLimpiarVen.js"/>"
	language="JavaScript" type="text/JavaScript"></script>
<script src="<html:rewrite page="/js/GenericoVen.js"/>"
	language="JavaScript" type="text/JavaScript"></script>
<%-- MU-2016-006664 - RAROALE - INI--%>  
<script src="<html:rewrite page="/js/utilidades.js"/>" language="JavaScript" type="text/JavaScript"></script>
<%-- MU-2016-006664 - RAROALE - FIN--%>

<script type="text/javascript"><!-- R&V Este comentario no estaba cerrado -->
  
   <%-- CargaInicial() se llama al realizar una carga de la pagina teniendo en cuenta dos variables tipOperacionJSP, y tipOperacion,
     para conocer su estado y tener un comportamiento inicial u otro. --%>
   
   function cargaInicial() {

        recalculaPorImportes(); // R&V Recalculamos en primer lugar

        // R&V CA Fase II CU011-COASEGURO - INI
        sumaTotalFila('1'); sumaTotalFila('2'); sumaTotalFila('3'); sumaTotalFila('4');
        sumaTotalFila('5'); sumaTotalFila('6'); sumaTotalFila('7'); sumaTotalFila('8');
        // R&V CA Fase II CU011-COASEGURO - FIN

		// R&V anoFiscal2anoVencimiento - INI
        document.getElementById('fecVencimiento_year').onchange = compruebaCampoDeCompensacionFiscal;
        document.getElementById('fecVencimiento_year').onkeyup = compruebaCampoDeCompensacionFiscal;
		// R&V anoFiscal2anoVencimiento - FIN


   		<%-- Si hay mensajes se muestran--%>
   		<% 	   		
   		if ((vectorMensajes != null) && (vectorMensajes.size()>0))
		{ 
			Msg mensaje;
			String stTipo = "";
			String descripcion = "";

			mensaje = (Msg)vectorMensajes.get(0);
			
			if (mensaje != null) {
				stTipo = mensaje.getTipo();
				descripcion = mensaje.getTexto();
			}
			if ("II".equals(stTipo)) {
			
			%>

				ctInfo('<%=descripcion%>');
				
		<%} else if ("XX".equals(stTipo)) { 
		%>
				ctError('<%=descripcion%>');
		<%}
		}%>
		
		
		<%--Cuandoestemos en la pestaña 0 se llamará a la funcion 
		calcularDuracion y si estamos en la pestaña 1 se llamará a 
		la funcion calcularFecVencimiento--%>


		document.getElementById("mypanel_t0").onfocus = calcularDuracion;
		<%-- Comprobamos si la fecha de anulación debe estar habilitado o no --%>

		document.getElementById("mypanel_t0").onblur = calculoPendiente;

		<%-- Calculo de los campos de coaseguradores.--%>
		<%-- MU-2016-006664 - RAROALE - INI--%>
		var tipo = 'P';
		if (trim(document.getElementById('Coasegur1_2').value) != "" ||
				trim(document.getElementById('Coasegur2_2').value) != "" ||
				trim(document.getElementById('Coasegur3_2').value) != "" ||
				trim(document.getElementById('Coasegur4_2').value) != "" ||
				trim(document.getElementById('Coasegur5_2').value) != "" ||
				trim(document.getElementById('Coasegur6_2').value) != "") {
			tipo = 'I';
		} else {
			tipo = 'P';
		};

        calculoPendiente(tipo);
		calculoRtoNeto('Cap', tipo);
		calculoRtoNeto('Pri', tipo);
		calculoRtoNeto('Comp', tipo);

		calculoRetencion('Cap', tipo);
		calculoRetencion('Pri', tipo);
		calculoRetencion('Comp', tipo);

		calculoLiquido(tipo);
		ponerDatosFiscales();

		modificacionComplementario1();

		modificacionComplementario2();

		cambiosTipImpuesto(tipo);

		controlCamposCoa();
		<%-- MU-2016-006664 - RAROALE - FIN--%>
		sumaTotal();
		limpiaCoase();

		calcularDuracion();

		cambiarSituacion();
		<%--marcarCheck();--%>


   		<%-- R&V Este comentario no estaba cerrado --%>
   		<%-- Comprobamos si el valor de pestaña tiene algun valor, si es asi vamos a esa pestaña.--%>
   		if ('<%=pestanaJSP%>' != "") {
   			cttDoOnclick('mypanel','<%=pestanaJSP%>');
   			cttChangePane('mypanel','<%=pestanaJSP%>');
   		}


   }

    <%-- MU-2016-006664 - RAROALE - INI--%>
 function validarCoAseguro () {
	try {
		var impTotal = 0;
		var impTotalCoa = 0;
		var ImportePri = parseFloat(cambiarPuntoComa(document.getElementById('ImportePri').value));
		var ImporteComp = parseFloat(cambiarPuntoComa(document.getElementById('ImporteComp').value));
		var ImpCoasegur1_2 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur1_2').value));
		var ImpCoasegur2_2 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur2_2').value));
		var ImpCoasegur3_2 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur3_2').value));
		var ImpCoasegur4_2 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur4_2').value));
		var ImpCoasegur5_2 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur5_2').value));
		var ImpCoasegur6_2 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur6_2').value));

		var Coasegur1 = document.getElementById('Coaseguradora1');
		var Coasegur2 = document.getElementById('Coaseguradora2');
		var Coasegur3 = document.getElementById('Coaseguradora3');
		var Coasegur4 = document.getElementById('Coaseguradora4');
		var Coasegur5 = document.getElementById('Coaseguradora5');
		var Coasegur6 = document.getElementById('Coaseguradora6');

		var Porcentaje1 = document.getElementById('Porcentaje1');
		var Porcentaje2 = document.getElementById('Porcentaje2');
		var Porcentaje3 = document.getElementById('Porcentaje3');
		var Porcentaje4 = document.getElementById('Porcentaje4');
		var Porcentaje5 = document.getElementById('Porcentaje5');
		var Porcentaje6 = document.getElementById('Porcentaje6');

		var Coasegur1_2 = document.getElementById('Coasegur1_2');
		var Coasegur2_2 = document.getElementById('Coasegur2_2');
		var Coasegur3_2 = document.getElementById('Coasegur3_2');
		var Coasegur4_2 = document.getElementById('Coasegur4_2');
		var Coasegur5_2 = document.getElementById('Coasegur5_2');
		var Coasegur6_2 = document.getElementById('Coasegur6_2');

		// Validar el porcentaje de Coaseguro
		if(trim(Porcentaje1.value) != ""){
			if(!isNaN(Porcentaje1.value)) {
				ctError('El porcentaje de Coaseguro 1 no es correcto');
				return false;
			} else {
				if(trim(Coasegur1.value) == "") {
					ctError('El porcentaje de Coaseguro 1 no es correcto');
					return false;
				}
			}
		} else {
			if(trim(Coasegur1.value) != "") {
				ctError('El porcentaje de Coaseguro 1 es obligatorio');
				return false;
			}
		}

		if(trim(Porcentaje2.value) != ""){
			if(!isNaN(Porcentaje2.value)) {
				ctError('El porcentaje de Coaseguro 2 no es correcto');
				return false;
			} else {
				if(trim(Coasegur2.value) == "") {
					ctError('El porcentaje de Coaseguro 2 no es correcto');
					return false;
				}
			}
		} else {
			if(trim(Coasegur2.value) != "") {
				ctError('El porcentaje de Coaseguro 2 es obligatorio');
				return false;
			}
		}

		if(trim(Porcentaje3.value) != ""){
			if(!isNaN(Porcentaje3.value)) {
				ctError('El porcentaje de Coaseguro 3 no es correcto');
				return false;
			} else {
				if(trim(Coasegur3.value) == "") {
					ctError('El porcentaje de Coaseguro 3 no es correcto');
					return false;
				}
			}
		} else {
			if(trim(Coasegur3.value) != "") {
				ctError('El porcentaje de Coaseguro 3 es obligatorio');
				return false;
			}
		}

		if(trim(Porcentaje4.value) != ""){
			if(!isNaN(Porcentaje4.value)) {
				ctError('El porcentaje de Coaseguro 4 no es correcto');
				return false;
			} else {
				if(trim(Coasegur4.value) == "") {
					ctError('El porcentaje de Coaseguro 4 no es correcto');
					return false;
				}
			}
		} else {
			if(trim(Coasegur4.value) != "") {
				ctError('El porcentaje de Coaseguro 4 es obligatorio');
				return false;
			}
		}

		if(trim(Porcentaje5.value) != ""){
			if(!isNaN(Porcentaje5.value)) {
				ctError('El porcentaje de Coaseguro 5 no es correcto');
				return false;
			} else {
				if(trim(Coasegur5.value) == "") {
					ctError('El porcentaje de Coaseguro 5 no es correcto');
					return false;
				}
			}
		} else {
			if(trim(Coasegur5.value) != "") {
				ctError('El porcentaje de Coaseguro 5 es obligatorio');
				return false;
			}
		}

		if(trim(Porcentaje6.value) != ""){
			if(!isNaN(Porcentaje6.value)) {
				ctError('El porcentaje de Coaseguro 6 no es correcto');
				return false;
			} else {
				if(trim(Coasegur6.value) == "") {
					ctError('El porcentaje de Coaseguro 6 no es correcto');
					return false;
				}
			}
		} else {
			if(trim(Coasegur6.value) != "") {
				ctError('El porcentaje de Coaseguro 6 es obligatorio');
				return false;
			}
		}

		// validación de importes
		if(trim(Coasegur1_2.value) != ""){
			if(!isNaN(Coasegur1_2.value)) {
				ctError('El importe de Coaseguro 1 no es correcto');
				return false;
			} else {
				if(trim(Coasegur1.value) == "") {
					ctError('El importe de Coaseguro 1 no es correcto');
					return false;
				}
				if (!validarImporte2Dec(Coasegur1_2, 2, 9999999999999, -9999999999999)) {
					ctError('El importe de Coaseguro 1 no es correcto');
					return false;
				}
			}
		} else {
			if(trim(Coasegur1.value) != "") {
				ctError('El importe de Coaseguro 1 es obligatorio');
				return false;
			}
		}

		if(trim(Coasegur2_2.value) != ""){
			if(!isNaN(Coasegur2_2.value)) {
				ctError('El importe de Coaseguro 2 no es correcto');
				return false;
			} else {
				if(trim(Coasegur2.value) == "") {
					ctError('El importe de Coaseguro 2 no es correcto');
					return false;
				}
				if (!validarImporte2Dec(Coasegur2_2, 2, 9999999999999, -9999999999999)) {
					ctError('El importe de Coaseguro 2 no es correcto');
					return false;
				}
			}
		} else {
			if(trim(Coasegur2.value) != "") {
				ctError('El importe de Coaseguro 2 es obligatorio');
				return false;
			}
		}

		if(trim(Coasegur3_2.value) != ""){
			if(!isNaN(Coasegur3_2.value)) {
				ctError('El importe de Coaseguro 3 no es correcto');
				return false;
			} else {
				if(trim(Coasegur3.value) == "") {
					ctError('El importe de Coaseguro 3 no es correcto');
					return false;
				}
				if (!validarImporte2Dec(Coasegur3_2, 2, 9999999999999, -9999999999999)) {
					ctError('El importe de Coaseguro 3 no es correcto');
					return false;
				}
			}
		} else {
			if(trim(Coasegur3.value) != "") {
				ctError('El importe de Coaseguro 3 es obligatorio');
				return false;
			}
		}

		if(trim(Coasegur4_2.value) != ""){
			if(!isNaN(Coasegur4_2.value)) {
				ctError('El importe de Coaseguro 4 no es correcto');
				return false;
			} else {
				if(trim(Coasegur4.value) == "") {
					ctError('El importe de Coaseguro 4 no es correcto');
					return false;
				}
				if (!validarImporte2Dec(Coasegur4_2, 2, 9999999999999, -9999999999999)) {
					ctError('El importe de Coaseguro 4 no es correcto');
					return false;
				}
			}
		} else {
			if(trim(Coasegur4.value) != "") {
				ctError('El importe de Coaseguro 4 es obligatorio');
				return false;
			}
		}

		if(trim(Coasegur5_2.value) != ""){
			if(!isNaN(Coasegur5_2.value)) {
				ctError('El importe de Coaseguro 5 no es correcto');
				return false;
			} else {
				if(trim(Coasegur5.value) == "") {
					ctError('El importe de Coaseguro 5 no es correcto');
					return false;
				}
				if (!validarImporte2Dec(Coasegur5_2, 2, 9999999999999, -9999999999999)) {
					ctError('El importe de Coaseguro 5 no es correcto');
					return false;
				}
			}
		} else {
			if(trim(Coasegur5.value) != "") {
				ctError('El importe de Coaseguro 5 es obligatorio');
				return false;
			}
		}

		if(trim(Coasegur6_2.value) != ""){
			if(!isNaN(Coasegur6_2.value)) {
				ctError('El importe de Coaseguro 6 no es correcto');
				return false;
			} else {
				if(trim(Coasegur6.value) == "") {
					ctError('El importe de Coaseguro 6 no es correcto');
					return false;
				}
				if (!validarImporte2Dec(Coasegur6_2, 2, 9999999999999, -9999999999999)) {
					ctError('El importe de Coaseguro 6 no es correcto');
					return false;
				}
			}
		} else {
			if(trim(Coasegur6.value) != "") {
				ctError('El importe de Coaseguro 6 es obligatorio');
				return false;
			}
		}

		return true;
	}catch(e){
		return false;
	}
 }
 <%-- MU-2016-006664 - RAROALE - FIN--%>

// R&V Mayo 2017 - CU004 - everis(RGL) - INI
function compruebaCampoDeCompensacionFiscal(){
    var fecha = document.getElementById('fecVencimiento_year').value; // R&V anoFiscal2anoVencimiento (antes ponia 'AnioFiscal')
    var provincia = document.getElementById('ProvinciaPri').value; //podría ser provinciaPri

    // R&V CP019 apartado 2 reseteamos el valor INI

    // R&V Cuadro Normativas - IN027M - INI
    anoClave = parseInt(fecha); // R&V anoFiscal2anoVencimiento - ponia anoFiscal
    provincia = provincia.toUpperCase();
    var esProvinciaPaisVasco = provincia == "ALAVA" || provincia == "GUIPUZCOA" || provincia == "VIZCAYA" ;
    var esProvinciaNavarra = provincia == "NAVARRA";
    var esTerritorioComun = ! (esProvinciaNavarra || esProvinciaPaisVasco);
    var condicionHabilitacion = esProvinciaNavarra || (esProvinciaPaisVasco && anoClave<2016) || (esTerritorioComun && anoClave<2015); // R&V anoFiscal2anoVencimiento
    var esTipoDeImpuestoMobiliario = document.getElementById('tipImpuestoCap').value == '12'; // R&V Correccion 07/08/2017-1
    condicionHabilitacion = condicionHabilitacion && esTipoDeImpuestoMobiliario; // R&V Correccion 07/08/2017-1
    if (condicionHabilitacion) {
    // R&V Cuadro Normativas - IN027M - FIN

        document.getElementById('CompensaCap').disabled = false;
    } else {
        if (document.getElementById('CompensaCap').disabled == false) {
            document.getElementById('CompensaCap').value = '0,0';
        }
        document.getElementById('CompensaCap').disabled = true;
    }
    // R&V CP019 apartado 2 reseteamos el valor INI


    /* codigo original
    document.getElementById('CompensaCap').disabled = true;
    //Julio 2017. Se cambia 2015 por 2016
    if ( provincia.toUpperCase() == "NAVARRA" || (fecha != '' && parseInt(fecha)<2016) ) {
        document.getElementById('CompensaCap').disabled = false;
    }
    */
}
// R&V Mayo 2017 - CU004 - everis(RGL) - FIN


// R&V Junio 2017 - CU011 - everis(RGL) - INI
function recalculaPorImportes(){
    // R&V Correccion 03/08/2017-1-3 INI
    // Ahora se recalcula solo cuando la coaseguradora está informada en nombre y porcentaje
    // pero el importe está en blanco (caso de carga del cuadro de coaseguradoras)
    limpiaCoase();
    var coaseguradora = document.getElementById('Coaseguradora1').value;
    var porcentaje = document.getElementById('Porcentaje1').value;
    var importe = document.getElementById('Coasegur1_2').value;
    if (coaseguradora != "" && porcentaje != "" && porcentaje != "0,00" && importe == "0,00") {
        calculoPorImportes(1, 'P'); sumaTotal();
    }
    coaseguradora = document.getElementById('Coaseguradora2').value;
    porcentaje = document.getElementById('Porcentaje2').value;
    importe = document.getElementById('Coasegur2_2').value;
    if (coaseguradora != "" && porcentaje != "" && porcentaje != "0,00" && importe == "0,00") {
        calculoPorImportes(2, 'P'); sumaTotal();
    }
    coaseguradora = document.getElementById('Coaseguradora3').value;
    porcentaje = document.getElementById('Porcentaje3').value;
    importe = document.getElementById('Coasegur3_2').value;
    if (coaseguradora != "" && porcentaje != "" && porcentaje != "0,00" && importe == "0,00") {
        calculoPorImportes(3, 'P'); sumaTotal();
    }
    coaseguradora = document.getElementById('Coaseguradora4').value;
    porcentaje = document.getElementById('Porcentaje4').value;
    importe = document.getElementById('Coasegur4_2').value;
    if (coaseguradora != "" && porcentaje != "" && porcentaje != "0,00" && importe == "0,00") {
        calculoPorImportes(4, 'P'); sumaTotal();
    }
    coaseguradora = document.getElementById('Coaseguradora5').value;
    porcentaje = document.getElementById('Porcentaje5').value;
    importe = document.getElementById('Coasegur5_2').value;
    if (coaseguradora != "" && porcentaje != "" && porcentaje != "0,00" && importe == "0,00") {
        calculoPorImportes(5, 'P'); sumaTotal();
    }
    coaseguradora = document.getElementById('Coaseguradora6').value;
    porcentaje = document.getElementById('Porcentaje6').value;
    importe = document.getElementById('Coasegur6_2').value;
    if (coaseguradora != "" && porcentaje != "" && porcentaje != "0,00" && importe == "0,00") {
        calculoPorImportes(6, 'P'); sumaTotal();
    }
    limpiaCoase(); //Julio 2017 - CU011
    //  ajusteImportesCoa(); //Julio 2017 - CU011
    // R&V Correccion 03/08/2017-1-3 FIN
}
// R&V Junio 2017 - CU011 - everis(RGL) - INI


 <%--Al dar el boton aceptar enviaremos el formulario.--%>
 function enviarFormulario () {

     // R&V 49-1-362/372-CU011-CP041 INI
     // Validaciones cuando el Modo de VALORES MANUALES está activado y hay coaseguradoras
     var valImpTot = parseFloat(cambiarPuntoComa(document.getElementById('CoasegurTot_2').value));
     if (isNaN(valImpTot)) { valImpTot = 0.0; }
     //if (valImpTot>0.0 && document.getElementById('valoresManuales1').checked){ // Valores manuales a SI
     if (valImpTot>0.0 ){ // R&V Automatico-Manual 26/09/2017 Quitamos que se valide solo en manual
         var totA = 0.0; // Se usara para los totales de la tabla de coaseguros
         var auxB1 = 0.0; // Se toma del primer campo a sumar
         var auxB2 = 0.0; // Se toma del segundo campo a sumar
         var auxB3 = 0.0; // Se toma del tercer campo a sumar
         var totB = auxB1 + auxB2 + auxB3; // Suma de los auxB para posteriormente comparar con totA

         //Comprobacion Rto. Integro
         totA = parseFloat(cambiarPuntoComa(document.getElementById('CoasegurTot_3').value));
         auxB1 = parseFloat(cambiarPuntoComa(document.getElementById('RtoIntegroPri').value));
         auxB2 = parseFloat(cambiarPuntoComa(document.getElementById('RtoIntegroComp').value));
         auxB3 = parseFloat(cambiarPuntoComa(document.getElementById('RtoIntegroCap').value));
         if (isNaN(totA)) { totA = 0.0; }
         if (isNaN(auxB1)) { auxB1 = 0.0; }
         if (isNaN(auxB2)) { auxB2 = 0.0; }
         if (isNaN(auxB3)) { auxB3 = 0.0; }
         totB=auxB1+auxB2+auxB3;
         if (Math.abs(totA-totB)>=0.001) { // R&V Automatico-Manual 26/09/2017 Ajuste de precision del error a 0.001
             ctError ("No coincide el total de Rto. Integro con los definidos en los datos económicos.");
             return;
         }

         //Comprobacion Red. Primas
         totA = parseFloat(cambiarPuntoComa(document.getElementById('CoasegurTot_4').value));
         auxB1 = parseFloat(cambiarPuntoComa(document.getElementById('RedPrimasPri').value));
         auxB2 = parseFloat(cambiarPuntoComa(document.getElementById('RedPrimasComp').value));
         auxB3 = parseFloat(cambiarPuntoComa(document.getElementById('RedPrimasCap').value));
         if (isNaN(totA)) { totA = 0.0; }
         if (isNaN(auxB1)) { auxB1 = 0.0; }
         if (isNaN(auxB2)) { auxB2 = 0.0; }
         if (isNaN(auxB3)) { auxB3 = 0.0; }
         totB=auxB1+auxB2+auxB3;
         if (Math.abs(totA-totB)>=0.001) { // R&V Automatico-Manual 26/09/2017 Ajuste de precision del error a 0.001
             ctError ("No coincide el total de Red. Primas con los definidos en los datos económicos.");
             return;
         }

         //Comprobacion Red. Transitoria
         totA = parseFloat(cambiarPuntoComa(document.getElementById('CoasegurTot_5').value));
         auxB1 = parseFloat(cambiarPuntoComa(document.getElementById('RedTransitPri').value));
         auxB2 = parseFloat(cambiarPuntoComa(document.getElementById('RedTransitComp').value));
         auxB3 = parseFloat(cambiarPuntoComa(document.getElementById('RedTransitCap').value));
         if (isNaN(totA)) { totA = 0.0; }
         if (isNaN(auxB1)) { auxB1 = 0.0; }
         if (isNaN(auxB2)) { auxB2 = 0.0; }
         if (isNaN(auxB3)) { auxB3 = 0.0; }
         totB=auxB1+auxB2+auxB3;
         if (Math.abs(totA-totB)>=0.001) { // R&V Automatico-Manual 26/09/2017 Ajuste de precision del error a 0.001
             ctError ("No coincide el total de Red. Transitoria con los definidos en los datos económicos.");
             return;
         }

         //Comprobacion Rto. Neto
         totA = parseFloat(cambiarPuntoComa(document.getElementById('CoasegurTot_6').value));
         auxB1 = parseFloat(cambiarPuntoComa(document.getElementById('RtoNetoPri').value));
         auxB2 = parseFloat(cambiarPuntoComa(document.getElementById('RtoNetoComp').value));
         auxB3 = parseFloat(cambiarPuntoComa(document.getElementById('RtoNetoCap').value));
         if (isNaN(totA)) { totA = 0.0; }
         if (isNaN(auxB1)) { auxB1 = 0.0; }
         if (isNaN(auxB2)) { auxB2 = 0.0; }
         if (isNaN(auxB3)) { auxB3 = 0.0; }
         totB=auxB1+auxB2+auxB3;
         if (Math.abs(totA-totB)>=0.001) { // R&V Automatico-Manual 26/09/2017 Ajuste de precision del error a 0.001
             ctError ("No coincide el total de Rto. Neto con los definidos en los datos económicos.");
             return;
         }

         //Comprobacion Retencion
         totA = parseFloat(cambiarPuntoComa(document.getElementById('CoasegurTot_7').value));
         auxB1 = parseFloat(cambiarPuntoComa(document.getElementById('RetencionPri').value));
         auxB2 = parseFloat(cambiarPuntoComa(document.getElementById('RetencionComp').value));
         auxB3 = parseFloat(cambiarPuntoComa(document.getElementById('RetencionCap').value));
         if (isNaN(totA)) { totA = 0.0; }
         if (isNaN(auxB1)) { auxB1 = 0.0; }
         if (isNaN(auxB2)) { auxB2 = 0.0; }
         if (isNaN(auxB3)) { auxB3 = 0.0; }
         totB=auxB1+auxB2+auxB3;
         if (Math.abs(totA-totB)>=0.001) { // R&V Automatico-Manual 26/09/2017 Ajuste de precision del error a 0.001
             ctError ("No coincide el total de Retencion con los definidos en los datos económicos.");
             return;
         }

         //Comprobacion Compen.
         totA = parseFloat(cambiarPuntoComa(document.getElementById('CoasegurTot_8').value));
         auxB1 = parseFloat(cambiarPuntoComa(document.getElementById('CompensaCap').value));
         if (isNaN(totA)) { totA = 0.0; }
         if (isNaN(auxB1)) { auxB1 = 0.0; }
         totB=auxB1;
         if (Math.abs(totA-totB)>=0.001) { // R&V Automatico-Manual 26/09/2017 Ajuste de precision del error a 0.001
             ctError ("No coincide el total de Compensatoria con el definido en los datos económicos.");
             return;
         }

     }
     // R&V 49-1-362/372-CU011-CP041 FIN

 //R&V - CU009 - INI
   if (document.getElementById("eximido2").checked) {   //Si

           var eximidoPorcCap = document.getElementById('PorcentajeCap').value;
           if (eximidoPorcCap != '0,00' && eximidoPorcCap != '0.00' && eximidoPorcCap != '0' ) {
               ctError ("Si es eximido, el porcentaje de retención ha de ser 0,00.");
               document.getElementById('PorcentajeCap').focus();
               valorPestana('1');
               cttDoOnclick('mypanel','1');
               cttChangePane('mypanel','1');
               return;
           }

           var eximidoRetenCap = document.getElementById('RetencionCap').value;
           if (eximidoRetenCap != '0,00' && eximidoRetenCap != '0.00' && eximidoRetenPri != '0') {
               ctError ("Si es eximido, el importe de retención ha de ser 0,00.");
               document.getElementById('RetencionCap').focus();
               valorPestana('1');
               cttDoOnclick('mypanel','1');
               cttChangePane('mypanel','1');
               return;
           }

           var eximidoPorcPri = document.getElementById('PorcentajePri').value;
           if (eximidoPorcPri != '0,00' && eximidoPorcPri != '0.00' && eximidoPorcPri != '0' ) {
               ctError ("Si es eximido, el porcentaje de retención ha de ser 0,00.");
               document.getElementById('PorcentajePri').focus();
               valorPestana('2');
               cttDoOnclick('mypanel','2');
               cttChangePane('mypanel','2');
               return;
           }

           var eximidoRetenPri = document.getElementById('RetencionPri').value;
           if (eximidoRetenPri != '0,00' && eximidoRetenPri != '0.00' && eximidoRetenPri != '0') {
               ctError ("Si es eximido, el importe de retención ha de ser 0,00.");
               document.getElementById('RetencionPri').focus();
               valorPestana('2');
               cttDoOnclick('mypanel','2');
               cttChangePane('mypanel','2');
               return;
           }

           var eximidoPorcComp = document.getElementById('PorcentajeComp').value;
           if (eximidoPorcComp != '0,00' && eximidoPorcComp != '0.00' && eximidoPorcComp != '0'  ) {
               ctError ("Si es eximido, el porcentaje de retención ha de ser 0,00.");
               document.getElementById('PorcentajeComp').focus();
               valorPestana('2');
               cttDoOnclick('mypanel','2');
               cttChangePane('mypanel','2');
               return;
           }

           var eximidoRetenComp = document.getElementById('RetencionComp').value;
           if (eximidoRetenComp != '0,00' && eximidoRetenComp != '0.00' && eximidoRetenComp != '0' ) {
               ctError ("Si es eximido, el importe de retención ha de ser 0,00.");
               document.getElementById('RetencionComp').focus();
               valorPestana('2');
               cttDoOnclick('mypanel','2');
               cttChangePane('mypanel','2');
               return;
           }

        }
//R&V - CU009 - FIN

        // R&V Incidencia CP009 INI
        var imp=parseFloat(document.getElementById('ImpCapital').value.replace(",","."));
        if (imp<0.0) {
             ctInfo('No se permite un valor de Importe (principal) negativo.');
             return;
        }
        var ben=parseFloat(document.getElementById('BeneficiosPri').value.replace(",","."));
        if (imp+ben > 0.0) {
        } else {
             ctInfo('El Importe + Beneficios, debe ser mayor que cero.');
             return;
        }
        // R&V Incidencia CP009 FIN

 		// R&V Mayo 2017 - CU003 - everis(RGL) - INI
 		//Si hay un cif/nif en el beneficiario pero no hay año de nacimiento, informamos y salimos
         if (document.getElementById('NIFCIFPri').value != ""
            && document.getElementById('fecNacPri_year').value == "yyyy"
            && !(document.getElementById('TipPersona2Pri').checked)) {   //Julio 2017
             ctInfo('El campo Fecha de Nacimiento del beneficiario no está informado.');
             return;
         }
 		// R&V Mayo 2017 - CU003 - everis(RGL) - FIN

		// R&V Junio 2017 - CU001 - everis(RGL) - INI
		var mensajeError = "";
		var numErrores = 0;
		if (document.getElementById('nifCifPri').value != "" && document.getElementById("Residente2Pri").checked ){
            if (document.getElementById("PaisPri").value.toUpperCase() == "ESPAÑA"){
                mensajeError += "\nNo se permite que el primer beneficiario sea 'No Residente' y que el país sea 'ESPAÑA'.";
                numErrores ++;
            }
            /* R&V IN005M INI
            if (document.getElementById('ProvinciaPri').value.toUpperCase() != "CENTRO"){
                mensajeError += "\nNo se permite que el primer beneficiario sea 'No Residente' y que la provincia fiscal sea distinta de 'CENTRO'.";
                numErrores ++;
            }
            R&V IN005M FIN */
            if (document.getElementById('CodPostalPri').value == ""){
                mensajeError += "\nNo se permite que el primer beneficiario sea 'No Residente' y que no esté informado el 'Código Postal'.";
                numErrores ++;
            }
		}
        if (numErrores>0){
            var cabeceraError= "";
            if (numErrores>1){
                cabeceraError = "Ha de corregir los siguientes problemas :\n";
            }
            ctInfo(cabeceraError+mensajeError);
            return;
        }
        // R&V Junio 2017 - CU001 - everis(RGL) - FIN

        // R&V Junio 2017 - CU011 - everis(RGL) - INI
        var coa1 = trim(document.getElementById('Coaseguradora1').value).toUpperCase();
        var coa2 = trim(document.getElementById('Coaseguradora2').value).toUpperCase();
        var coa3 = trim(document.getElementById('Coaseguradora3').value).toUpperCase();
        var coa4 = trim(document.getElementById('Coaseguradora4').value).toUpperCase();
        var coa5 = trim(document.getElementById('Coaseguradora5').value).toUpperCase();
        var coa6 = trim(document.getElementById('Coaseguradora6').value).toUpperCase();
        var contCoa = 0 ; // contador de coaseguradoras
        var mpe = 1;  // marcador primo de existencia de coaseguros (2,3,5,7,11,13)
        var por1 = 0.0;
        if (coa1 != ""){
            por1 = parseFloat(cambiarPuntoComa(document.getElementById('Porcentaje1').value));
            contCoa++;
            mpe *= 2; // valor primo que representa la primera coaseguradora
        }
        var por2 = 0.0;
        if (coa2 != ""){
            por2 = parseFloat(cambiarPuntoComa(document.getElementById('Porcentaje2').value));
            contCoa++;
            mpe *= 3; // valor primo que representa la segunda coaseguradora
        }
        var por3 = 0.0;
        if (coa3 != ""){
            por3 = parseFloat(cambiarPuntoComa(document.getElementById('Porcentaje3').value));
            contCoa++;
            mpe *= 5; // valor primo que representa la tercera coaseguradora
        }
        var por4 = 0.0;
        if (coa4 != ""){
            por4 = parseFloat(cambiarPuntoComa(document.getElementById('Porcentaje4').value));
            contCoa++;
            mpe *= 7; // valor primo que representa la cuarta coaseguradora
        }
        var por5 = 0.0;
        if (coa5 != ""){
            por5 = parseFloat(cambiarPuntoComa(document.getElementById('Porcentaje5').value));
            contCoa++;
            mpe *= 11; // valor primo que representa la quinta coaseguradora
        }
        var por6 = 0.0;
        if (coa6 != ""){
            por6 = parseFloat(cambiarPuntoComa(document.getElementById('Porcentaje6').value));
            contCoa++;
            mpe *= 13; // valor primo que representa la sexta coaseguradora
        }

        // si no hay ninguna coaseguradora se informa de que no existe el cuadro de coa. esto tendria que estar en la carga inicial tb

        //Inicio  Julio 2017
        //1.8 Validacion Fecha Documento
         var anyoFiscal = document.getElementById('anioFiscal').value;
         var anyoVencimiento = document.getElementById('fecVencimiento_year').value; // R&V IN004
        // R&V - IN003 - INI
        if (anyoFiscal==''){
            var fechaActual =  new Date (); //Fecha actual del sistema;
            var anyoActual = fechaActual.getFullYear();
            if (anyoActual==anyoVencimiento){ // R&V IN004
                anyoFiscal = anyoActual;
            }
        }
        // R&V - IN003 - FIN

         if (parseInt(anyoFiscal) != parseInt(anyoVencimiento)) { // R&V IN004
             var anyoPago = document.getElementById('fecPagoCapital_year').value;

            // R&V - IN005 IN006 - INI
            if (anyoPago != '' && anyoPago != 'yyyy') {
                ctError ("La fecha de pago no puede estar informada cuando el año fiscal es diferente al de vencimiento.");
                return;
            }
            // R&V - IN005 IN006 - FNI
             /* R&V condigo anterior a la IN005 IN006 INI
             // Si la fecha de pago no esta informada mostramos mensaje y continuamos con la operativa
             if (anyoPago == '' || anyoPago == 'yyyy') {
                 ctInfo ("Año fiscal diferente al Año de vencimiento."); // R&V IN004
                 return;
             } else { //Mostramos mensaje de error correspondiente
                 ctError ("La fecha de pago no puede estar informada cuando el año fiscal es diferente a la vencimiento."); // R&V IN004
                 return;
             }
             condigo anterior a la IN005 IN006 FIN */
         }

        /* R&V CP020 INI Se comenta para arreglar esta incidencia
        //1.9 Validacion Importe Compensatoria
        var provinciaCompensa = document.getElementById('ProvinciaPri').value;
        if ( (provinciaCompensa.toUpperCase() != "NAVARRA") && (provinciaCompensa.toUpperCase() != "PAIS VASCO")
            && (provinciaCompensa.toUpperCase() != "PAÍS VASCO")) {
            var importeCompensatoria = document.getElementById('compensaCap').value;
            if (importeCompensatoria != '0,00' && importeCompensatoria != '0.00' ) {
                ctError ("El único valor permitido en el campo Compensatoria es 0,00.");
                return;
            }
        }
        R&V CP020 FIN */

        //1.2 Validacion NIF
        //Si la fecha de nacimiento esta informada realizamos validacion correspondiente
        var fechaActual = new Date (); //Fecha actual del sistema
        if (!(document.getElementById('fecNacPri_day').value == "dd")
            && !(document.getElementById('fecNacPri_month').value == "mm")
            && !(document.getElementById('fecNacPri_year').value == "yyyy")) {
            var fechadia=document.getElementById('fecNacPri_day').value;
            var fechames=document.getElementById('fecNacPri_month').value;
            var fechaanyo=document.getElementById('fecNacPri_year').value;
            var fecha = new Date (parseInt(fechaanyo)+14, parseInt(fechames)-1, parseInt(fechadia));
            if (fecha > fechaActual) { //Menor de 14 anyos, obligatorio informar representante legal
                if (document.getElementById('NifRepLegalPri').value == "") {
                   ctError ("Debe de informar un Representante Legal para el primer beneficiario.");
                   return;
                }
            }
        }


        //1.3 Validacion Nombre y Apellidos
        // R&V 22/01/2018 INI - Se concretan las ER para los campos: nombre, apellidos y razón
        // R&V 22/01/2018 - Las ER defines el conjunto de caracteres que serían erróneos
        // R&V 22/01/2018 - '^' podemos leerlo cono "todo lo que no sea ...", por lo que
        // R&V 22/01/2018 - los caracteres que aparecen, en realidad son los permitidos.
        var expreRegNom = new RegExp(/[^a-zA-Z0-9ñÑçÇáéíóúüÁÉÍÓÚÜàèìòùÀÈÌÒÙ &*,;:_ºª\'\.\-\s]/g);
        var expreRegApe1 = new RegExp(/[^a-zA-ZñÑçÇ \-\s]/g);
        var expreRegApe2 = new RegExp(/[^a-zA-ZñÑçÇ \-\s]/g);
        // R&V 22/01/2018 FIN
        //Valido campos de pestanya primer beneficiario
        if (document.getElementById('TipPersona1Pri').checked) { //Persona Fisica
           if (document.getElementById('NombrePri').value.length<2
                || expreRegNom.test(document.getElementById('NombrePri').value)) { // R&V 22/01/2018
                ctError ("El nombre del beneficiario no ha de tener símbolos ni empezar por espacios y su tamaño ha de ser mayor que 1."); // R&V 22/01/2018
                return;
           } else  if (document.getElementById('Apellido1Pri').value.length<2
              || expreRegApe1.test(document.getElementById('Apellido1Pri').value)) { // R&V 22/01/2018
              ctError ("El primer apellido del beneficiario no ha de tener símbolos ni acentos ni puntos ni comas y su tamaño ha de ser mayor que 1."); // R&V 22/01/2018
              return;
            } else  if (document.getElementById('Apellido2Pri').value.length>0
                && expreRegApe2.test(document.getElementById('Apellido2Pri').value)) { // R&V 22/01/2018
                ctError ("El segundo apellido del beneficiario no ha de tener símbolos ni acentos ni puntos ni comas."); // R&V 22/01/2018
                return;
            }
        } else if(document.getElementById('TipPersona2Pri').checked) { //Persona Juridica
            if (document.getElementById('RazonSocialPri').value.length>0) {
               var razonSoc = document.getElementById('RazonSocialPri').value;
                 var strRazonSoc = razonSoc.charAt(0);
                 if ( strRazonSoc==" " || strRazonSoc=="." || strRazonSoc=="," || strRazonSoc=="*"){ // R&V 22/01/2018

                    ctError ("La razón social del beneficiario no puede comenzar por espacios ni punto ni coma ni asterisco."); // R&V 22/01/2018
                     return;
                }
           }
        }

        //El cuadro de coaseguro no es obligatorio. Comentamos la comprobacion
        //if (contCoa==0) {
          //  ctInfo("El cuadro de COASEGURADORAS no puede estar vacio.");
            //return;
        //}

        // la validacion de coaseguradoras en BBDD se hace en COBOL
        // Julio 2017

        //Si hay cuadro de coaseguro realizo el resto de comprobaciones referentes a el.
        if (contCoa!=0) {
            // el total del reparto de coaseguradoras debe sumar 100.00 %
            // R&V CA Fase II CU011-COASEGURO - INI
            if (isNaN(por1)) { por1 = 0.0; }
            if (isNaN(por2)) { por2 = 0.0; }
            if (isNaN(por3)) { por3 = 0.0; }
            if (isNaN(por4)) { por4 = 0.0; }
            if (isNaN(por5)) { por5 = 0.0; }
            if (isNaN(por6)) { por6 = 0.0; }
            // R&V CA Fase II CU011-COASEGURO - FIN
            var sumaPor = por1 + por2 + por3 + por4 + por5 + por6 ;
            if ( Math.abs(sumaPor-100.0) > 0.00001)  { // R&V Correccion Error Precision 21/09/2017
              ctInfo("La suma de porcentajes no es del 100.00%. ("+sumaPor+"%)");
              return;
            }

            // la diferencia por redondeos se impute a la abridora ¿¿??

            // no se pueden repetir coaseguradoras
            if (coa1!="" && (coa1==coa2 || coa1==coa3 || coa1==coa4 || coa1==coa5 || coa1==coa6)){
              ctInfo("No se permite que la coaseguradora '"+coa1+"' está repetida.");
              return;
            }
            if (coa2!="" && (coa2==coa3 || coa2==coa4 || coa2==coa5 || coa2==coa6)){
              ctInfo("No se permite que la coaseguradora '"+coa2+"' está repetida.");
              return;
            }
            if (coa3!="" && (coa3==coa4 || coa3==coa5 || coa3==coa6)){
              ctInfo("No se permite que la coaseguradora '"+coa3+"' está repetida.");
              return;
            }
            if (coa4!="" && (coa4==coa5 || coa4==coa6)){
              ctInfo("No se permite que la coaseguradora '"+coa4+"' está repetida.");
              return;
            }
            if (coa5!="" && coa5==coa6){
              ctInfo("No se permite que la coaseguradora '"+coa5+"' está repetida.");
              return;
            }

            // al menos una coaseguradora ha de ser mapfre vida(C0511)
            var cmv = "C0511"; //Coaseguradora Mafre Vida
            if (coa1!=cmv && coa2!=cmv && coa3!=cmv && coa4!=cmv && coa5!=cmv && coa6!=cmv) {
              ctInfo("Una de las coaseguradoras ha de ser Mafre Vida ("+cmv+").");
              return;
            }

            // R&V Correccion 03/08/2017-2 - La C0511 debe tener importe > 0 - INI
            // Por las comprobaciones anteriores sabemos que C0511 está en una posicion única
            var posicionMapfre=1;
            while (posicionMapfre<=6) {
                var auxCoa = trim(document.getElementById('Coaseguradora'+ posicionMapfre.toString() ).value).toUpperCase() ;
                if ( "C0511" == auxCoa) {
                    var importeC0511 = parseFloat(document.getElementById('Coasegur'+posicionMapfre.toString()+'_2').value.replace(',','.'));
                    if ( importeC0511 <= 0.0 ) { // Si importeC0511 no es mayor que cero
                        ctInfo("El importe de la coaseguradora Mafre Vida ha de ser mayor que cero.");
                        return;
                    }
                }
                posicionMapfre++;
            }
            // R&V Correccion 03/08/2017-2 - La C0511 debe tener importe > 0 - FIN

            // no permitimos columnas en blanco entre coaseguradoras (nuevo)
            if ( mpe!=2 && mpe!=2*3 && mpe!=2*3*5 && mpe!=2*3*5*7 && mpe!=2*3*5*7*11 && mpe!=2*3*5*7*11*13  ) {
              ctInfo("No pueden haber coaseguradoras vacías entre otras coaseguradoras.");
              return;
            }
        } //Julio 2017
        // R&V Junio 2017 - CU011 - everis(RGL) - FIN


		if (trim(document.getElementById('Coasegur1_2').value) != "" ||
				trim(document.getElementById('Coasegur2_2').value) != "" ||
				trim(document.getElementById('Coasegur3_2').value) != "" ||
				trim(document.getElementById('Coasegur4_2').value) != "" ||
				trim(document.getElementById('Coasegur5_2').value) != "" ||
				trim(document.getElementById('Coasegur6_2').value) != "") {
			calculoPendiente('I');
		} else {
			calculoPendiente('P');
		}

		<%-- Recalculamos el valor del campo pendiete antes de enviar el formulario.--%>
		var form = document.forms['formGestionExped'];
		var errors = validateForm(form);
		if(errors.length > 0) {
			return;
		}

		<%-- Comproaberemos que un tipo de immpuesto TRABAJO no puede tener asociado una persona juridica --%>
		var tipImpuestoPri = document.getElementById('tipImpuestoCap').selectedIndex;
		var tipImpuestoSeg = document.getElementById('tipImpuestoComp').selectedIndex;
		var tipImpuestoTre = document.getElementById('tipImpuestoPri').selectedIndex;

		if (document.getElementById('TipPersona2Pri').checked && ( tipImpuestoPri == '1' || tipImpuestoSeg == '1' || tipImpuestoTre == '1' )) {
			ctInfo('Una persona JURIDICA no puede tener asociado un tipo de impuesto de TRABAJO');
			return;
			}

		<%-- MU-2016-006664 - RAROALE - INI--%>
		if (!validarCoAseguro()) {
			return;
		}
		<%-- MU-2016-006664 - RAROALE - FIN--%>

 		<%-- Le volvemos a dar el valor de tipOperacion del principio porque lo pierde.--%>
		if(document.forms[0].elements['tipOperacion'].value == null || document.forms[0].elements['tipOperacion'].value == ''){
			document.forms[0].elements['tipOperacion'].value = '<%=tipOperacion%>';

		}

		if (document.getElementById('polizaBloq3').value == "") {
			ctInfo('El campo POLIZA es obligatorio');
			return;
		}

		if (document.getElementById('TipSituacion2').checked ) {
			if  ((document.getElementById('fecAnul_year').value == "yyyy") ||
				(document.getElementById('fecAnul_month').value == "mm") ||
				(document.getElementById('fecAnul_day').value == "dd")) {
			ctInfo('Debe informar una fecha de anulación');
			return;
			}
		}
		pasarDatosDisabled();

		deshabilitarImportesDeCoaseguros(false); // R&V Junio 2017 - CU011 - everis(RGL)
		document.forms[0].submit();
	}

	<%--Funcionalidad al cancelar --%>
	function cancelarFormulario() {


		var form = document.forms['formGestionExped'];
		form.action = 'inicioBusquedaExpVen.do';
		form.submit();
	}


	function cambiarSituacion() {

		if (document.getElementById('TipSituacion2').checked)
	    {
	   		habilitarFechas('fecAnul');
	   		//cuando se de al radio anular se cargarála fech del día por defecto
	   		//var fechaActual = new Date();
			//document.getElementById('fecAnul_year').value = fechaActual.getFullYear();
			//document.getElementById('fecAnul_day').value = PonerCerosFecha(fechaActual.getDate());
			//document.getElementById('fecAnul_month').value = PonerCerosFecha(fechaActual.getMonth()+1);
	     }

	     if (document.getElementById('TipSituacion1').checked)
	    {
	   		desHabilitarFechas('fecAnul');
	   		limpiarFechas('fecAnul');
	     }

	}


	function marcarCheck() {
		alert("valor-->" + document.getElementById('tipSituacion').value);
	    if (document.getElementById('tipSituacion').value == 'VI'){

			document.getElementById('TipSituacion1').checked = 'checked';
			document.getElementById('TipSituacion2').checked = '';

		} else if (document.getElementById('tipSituacion').value == 'AN'){

			document.getElementById('TipSituacion1').checked = '';
			document.getElementById('TipSituacion2').checked = 'checked';
		}
	}


</script>
</head>

<map:body transition="auto" style="version1.0" onLoad="cargaInicial();">
	<html:form action="gestionExpedientesVen">


		<map:tabbed-pane name="mypanel" width="100%" height="89%">
			<map:pane selected="true" onclick="valorPestana('0');">
				<map:pane-label>
					<bean:message
						key="rescate.gestionexpedientes.label.pestana.general" />
				</map:pane-label>
				<map:pane-content>
					<br>

					<map:group-box layout="line"
						titleKey="rescate.gestionexpedientes.label.titulo.auxiliar.expedientes"
						width="100%" colorLevel="2">

						<DIV>
						<span class="W10 D">
							<bean:message key="rescate.gestionexpedientes.label.anio" />:
						</span>

						<span class="W5 I"> <bean:define id="litAnio" type="String">
							<bean:message key="rescate.gestionexpedientes.label.anio" />
						</bean:define> <map:text size="5" name="formGestionExped" id="Anio"
							maxlength="4" tabindex="5" property="anio" disabled="true">

							<map:validation rule="integer">
								<bean:message key="rescate.error.numerico" arg0="<%=litAnio%>" />
							</map:validation>
						</map:text>
						<input type="hidden"
			name="anio" id="AnioHidden" /></span>

							<span class="W10 D"><bean:message key="rescate.gestionexpedientes.label.expediente" />:
							</span>
							<span class="W14 I">
							<map:text size="10" name="formGestionExped"
							id="Expediente" maxlength="10" tabindex="10"
							property="expediente" disabled="true">
							</map:text>
						<input type="hidden"
			name="expediente" id="ExpedienteHidden" /> </span>


							<span class="W6 D">
								<bean:message key="rescate.gestionexpedientes.label.poliza" />:

							</span>
						<span class="W34">
						<span ><bean:define id="litPoliza1" type="String">
						<bean:message key="rescate.gestionexpedientes.label.ramoPol" />
						</bean:define><map:text size="5" name="formGestionExped" id="Poliza1"
							maxlength="3" tabindex="15" property="polizaBloq1">

							<map:validation rule="integer">
								<bean:message key="rescate.error.numerico"
									arg0="<%=litPoliza1%>" />
							</map:validation>
						</map:text> </span>

						<span > <bean:define id="litPoliza2" type="String">
							<bean:message key="rescate.gestionexpedientes.label.anioPol" />
						</bean:define> <map:text size="3" name="formGestionExped" id="Poliza2"
							maxlength="2" tabindex="20" property="polizaBloq2">
							<map:validation rule="integer">
								<bean:message key="rescate.error.numerico"
									arg0="<%=litPoliza2%>" />
							</map:validation>
						</map:text> </span>

						<span > <bean:define id="litPoliza3" type="String">
							<bean:message key="rescate.gestionexpedientes.label.poliza" />
						</bean:define> <map:text size="10" name="formGestionExped" id="Poliza3"
							maxlength="10" tabindex="25" property="polizaBloq3" accesskey="1">
							<map:validation rule="integer">
								<bean:message key="rescate.error.numerico"
									arg0="<%=litPoliza3%>" />
							</map:validation>
						</map:text>  </span>
						</span>

						<span class="W15 D">
							<bean:message key="rescate.gestionexpedientes.label.subpoliza" />:
						</span>
						<span class="W9 I"> <bean:define id="litSubpoliza" type="String">
							<bean:message key="rescate.gestionexpedientes.label.subpoliza" />
						</bean:define> <map:text size="7" name="formGestionExped" id="SubPoliza"
							maxlength="4" tabindex="30" property="subpoliza" accesskey="2">
							<map:validation rule="integer">
								<bean:message key="rescate.error.numerico"
									arg0="<%=litSubpoliza%>" />
							</map:validation>

						</map:text>


							</span>
							<IMG align="middle" onclick="consultaCartera();"
							name="imgNifCif" id="imgConsulta"
							src="<bean:write name="HTTP_PATH"/>/img/lupa.gif"
							alt="Consulta Póliza">
							</DIV>


						<DIV>

						<span class="W10 D">
							<bean:message key="rescate.gestionexpedientes.label.canal" />:
						</span>
						<span class="W5 I"><bean:define id="litCanalCamp" type="String">
							<bean:message key="rescate.gestionexpedientes.label.canal" />
						</bean:define> <map:text size="5" name="formGestionExped"
							id="CanalCamp" maxlength="5" tabindex="20" property="canalCamp">
						<map:validation rule="integer">
								<bean:message key="rescate.error.numerico"
									arg0="<%=litCanalCamp%>" />
							</map:validation>
						</map:text>
						</span>



						<span class="W11 D"><bean:message key="rescate.gestionexpedientes.label.codEntidad" />:
						</span>
						<span class="W14 I"><bean:define id="litEntidad" type="String">
							<bean:message key="rescate.gestionexpedientes.label.codEntidad" />
						</bean:define> <map:text size="9" name="formGestionExped"
							id="CanalCamp" maxlength="5" tabindex="20" property="entidad">
	 					<map:validation rule="integer">
								<bean:message key="rescate.error.numerico"
									arg0="<%=litEntidad%>" />
							</map:validation>
						</map:text>
						</span>


						<!-- INICIO  MU-2015-041869 -->
						<span class="W7 D">
							<bean:message key="rescate.gestionexpedientes.label.aniofiscal" />:
						</span>

						<span class="W5 I">
							<bean:define id="litAnioFiscal" type="String">
								<bean:message key="rescate.gestionexpedientes.label.aniofiscal" />
							</bean:define>
							<map:text size="5" name="formGestionExped" id="AnioFiscal"
							maxlength="4" tabindex="5" property="aniofiscal">

								<map:validation rule="integer">
									<bean:message key="rescate.error.numerico" arg0="<%=litAnioFiscal%>" />
								</map:validation>
								<!-- INICIO  MU-2015-041869 -->
								<map:validation rule="intRange(1900,9999)">
										<bean:message key="rescate.error.rango.permitido" arg0="<%=litAnioFiscal%>" arg1="1900" arg2="9999"/>
									</map:validation>
								</map:text>
								<!-- FIN  MU-2015-041869 -->
						 </span>


						<span class="W11 D"><bean:message key="rescate.gestionexpedientes.label.modalidad" />:
						</span>
						<!-- FIN MU-2015-041869-->

						<span class="W10 I"> <bean:define id="litModalidad" type="String">
							<bean:message key="rescate.gestionexpedientes.label.modalidad" />
						</bean:define> <map:text size="5" name="formGestionExped"
							id="Modalidad" maxlength="5" tabindex="10" property="modalidad">
							<map:validation rule="integer">
								<bean:message key="rescate.error.numerico"
									arg0="<%=litModalidad%>" />
							</map:validation>
						</map:text> </span>

						<span class="W13 D">
						<bean:message key="rescate.gestionexpedientes.label.certificado" />:
						</span>

						 <span class="W9 I"> <bean:define id="litCertificado" type="String">
							<bean:message key="rescate.gestionexpedientes.label.certificado" />
						</bean:define> <map:text size="6" name="formGestionExped" id="Certificado"
							maxlength="6" tabindex="35" property="certificado" accesskey="3">
							<map:validation rule="integer">
								<bean:message key="rescate.error.numerico"
									arg0="<%=litCertificado%>" />
							</map:validation>
						</map:text> </span> </DIV>



						<DIV>
						<span class="W10 D">
							<bean:message key="rescate.gestionexpedientes.label.fecEfecto" />:
						</span>
						<span class="W20 I">
						<map:date name="fecEfect"
							srcName="formGestionExped" srcProperty="fecEfect"
							srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true"
							calendar="true" onblur="calcularFecVencimiento();">
							</map:date> </span>

						<span class="W17 D">
							<bean:message key="rescate.gestionexpedientes.label.duracion" />:
						</span>
						<span class="W17 I"> <bean:define id="litDuracion" type="String"><bean:message key="rescate.gestionexpedientes.label.duracion"/></bean:define>
						<map:text size="6" name="formGestionExped"
							id="Duracion" maxlength="5" tabindex="10" property="duracion" onkeyup="calcularFecVencimiento();">
							<map:validation rule = "intRange(0,9999)">
							  	<bean:message key="rescate.error.rango" arg0="<%=litDuracion%>"/>
					 		</map:validation>
						</map:text> </span>

						<span class="W17 D">
							<bean:message
									key="rescate.gestionexpedientes.label.fecEmision" />:
						</span>
						<span class="W17 I"> <map:date name="fecEmision"
							srcName="formGestionExped" srcProperty="fecEmision"
							srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true"
							calendar="true">
							</map:date> </span>

						</DIV>
						<DIV>
						<span class="W10 D">
							<bean:message key="rescate.gestionexpedientes.label.tomador" />:
						</span>
						<span class="W90 I"> <map:text size="90%"
							name="formGestionExped" id="Tomador" maxlength="100"
							tabindex="100" property="tomador" disabled="true">

						</map:text><input type="hidden"
								name="tomador" id="TomadorHidden" />
						</span></DIV>
						

						<span class="W10 D">
							<bean:message
							key="rescate.gestionexpedientes.label.tipSituacion" />: </span>
						<span class="W13 I" style="white-space: nowrap;">
							<map:radio id="TipSituacion1" name="formGestionExped"
								property="tipSituacion" value="VI" onclick="cambiarSituacion();">
								<bean:message
									key="rescate.gestionexpedientes.label.tipSituacion.opcion1" />
	
							</map:radio> <map:radio id="TipSituacion2" name="formGestionExped"
								property="tipSituacion" value="AN" onclick="cambiarSituacion();">
								<bean:message
									key="rescate.gestionexpedientes.label.tipSituacion.opcion2" />
	
							</map:radio>
						</span>
						
						<logic:equal name="formGestionExped" property="anio" value="1950">
							<span class="W10 D">
								<bean:message key="rescate.gestionexpedientes.label.vencMigrado" />:
							</span>
							<span class="W15 I" style="white-space: nowrap;">
								<map:radio id="VencMigrado1" name="formGestionExped" property="vencimientoMigrado" 
									value="S">
									<bean:message
										key="rescate.gestionexpedientes.label.vencMigrado.opcion1" />			
								</map:radio> 
								<map:radio id="VencMigrado2" name="formGestionExped" property="vencimientoMigrado" 
									value="N">
									<bean:message
										key="rescate.gestionexpedientes.label.vencMigrado.opcion2" />			
								</map:radio>
							</span>							
						</logic:equal>

						<span class="W10 D">
							<bean:message key="rescate.gestionexpedientes.label.fecAnul" />:
						</span>

						<span class="W17 I"> <map:date name="fecAnul"
							srcName="formGestionExped" srcProperty="fecAnul"
							srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true"
							calendar="true">
							</map:date> </span>
					

					</map:group-box>
					<DIV><BR>
					<BR>
					</DIV>
					<map:group-box layout="line"
						titleKey="rescate.gestionexpedientes.label.titulo.auxiliar.destino"
						width="100%" colorLevel="2">
						<DIV><span class="W15 D"> <bean:message
							key="rescate.gestionexpedientes.label.listaRegionalPol" /> </span>:&nbsp;<map:select
							showcode="false" property="regionalPol">
							<map:defaultOption>
								<bean:message key="rescate.desplegable.default" />
							</map:defaultOption>

							<map:optionsJs tablename="t07956" lang="es" type="l"
								orderby="value" dir="asc" />


						</map:select> <span class="W15 D"> <bean:message
							key="rescate.gestionexpedientes.label.listaRegionalEnv" />:&nbsp;</span>
						<map:select showcode="false" property="regionalEnv" >
							<map:defaultOption>
								<bean:message key="rescate.desplegable.default" />
							</map:defaultOption>

							<map:optionsJs tablename="t07956" lang="es" type="l"
								orderby="value" dir="asc" />


						</map:select> </DIV>
						<DIV>
						<span class="W100 I"><bean:define id="litOficina" type="String">
							<bean:message key="rescate.gestionexpedientes.label.oficina" />
						</bean:define>&nbsp;  <map:text size="5" name="formGestionExped"
							id="Oficina" maxlength="4" tabindex="10" property="oficina">
							<map:label  width="14.35%"align="right">
								<bean:message key="rescate.gestionexpedientes.label.oficina" />:
	 					</map:label>
	 					<map:validation rule="integer">
								<bean:message key="rescate.error.numerico"
									arg0="<%=litOficina%>" />
							</map:validation>
						</map:text> </span></DIV>

					</map:group-box>
					<DIV></DIV>
					<DIV><BR>
					<BR>
					</DIV>
					<map:group-box layout="line"
						titleKey="rescate.gestionexpedientes.label.titulo.auxiliar.otros"
						width="100%" colorLevel="2">


						<DIV><span class="W10 D"> <bean:message
							key="rescate.gestionexpedientes.label.observaciones" />:&nbsp; </span>
						<span class="W70 I"> <html:textarea onkeyup="controlCaracteres(this.value);" style="overflow:auto; heigth:10px; width:90%"
							name="formGestionExped" styleId="Observaciones" tabindex="10"
							property="observaciones"></html:textarea></span>
							<span class="W19 D"> <map:text size="6" name="formGestionExped"
							id="Pendiente" maxlength="5" tabindex="10" property="pendiente"
							disabled="true">
							<map:label width="8%" align="right">
								<bean:message key="rescate.gestionexpedientes.label.pendiente" />:
	 					</map:label>
						</map:text>
						<input type="hidden"
			name="pendiente" id="PendienteHidden" /> </span>
						</DIV>
					</map:group-box>
				</map:pane-content>
			</map:pane>
			<!-- MU-2016-006664 - RAROALE - INI -->
			<!-- R&V Mayo 2017 - CU004 - everis(RGL) INI -->
			<!-- R&V Se llama a compruebaCampoDeCompensacionFiscal() al entrar en la pestaña 'PRINCIPAL'-->
			<map:pane selected="false" onclick="valorPestana('1');calculoRetencion('Cap', 'I');calculoRetencion('Pri', 'I');
							calculoRetencion('Comp', 'I'); compruebaCampoDeCompensacionFiscal();">
			<!-- R&V Mayo 2017 - CU004 - everis(RGL) FIN -->
			<!-- MU-2016-006664 - RAROALE - FIN -->
				<map:pane-label>
					<bean:message
						key="rescate.gestionexpedientes.label.pestana.rescate" />
				</map:pane-label>
				<map:pane-content>
					<map:group-box layout="line"
						titleKey="rescate.gestionexpedientes.label.titulo.auxiliar.principal"
						width="100%" colorLevel="2">

						<DIV>
						<span class="W10 D"><bean:message key="rescate.gestionexpedientes.label.importePri" />:</span>
						<!-- MU-2016-006664 - RAROALE - INI -->
						<!-- R&V - Marzo 2018 - Cambio calculoCodImportes('P') -> calculoCodImportes('I') - INI -->
						<span class="W11 I">
							<bean:define id="litImpCapital" type="String">
								<bean:message key="rescate.gestionexpedientes.label.importePri" />
							</bean:define>
							<map:text size="16" name="formGestionExped" id="ImpCapital"
								maxlength="15" tabindex="10" property="impCapital"
								onkeyup="modificacionComplementario1();calculoPendiente();calculoLiquido();"
							    onchange="recalculoCoaPorCambioDe('ImpCapital');"
								onblur="javascript: validarImporte2Dec(this,'2','100000000000','-100000000000'); calculoCodImportes('I'); sumaTotal();controlCamposCoa();limpiaCoase();">
								<map:validation rule="mask('^([-]|[0-9]){0,1}[0-9]{0,11}?([,|^,][0-9]{0,2})*$')">
									<bean:message key="rescate.error.numerico.decimal" arg0="<%=litImpCapital%>" />
								</map:validation>
							</map:text>
						</span>
						<!-- MU-2016-006664 - RAROALE - FIN -->
						<!-- MU-2016-006664 - 06-05-2016 - RAROALE - INI -->
						<span class="W8 D">
							<bean:message key="rescate.gestionexpedientes.label.beneficiosPri" />:
						</span>
						<span class="W13 I">
							<bean:define id="litBeneficiosPri" type="String">
								<bean:message key="rescate.gestionexpedientes.label.beneficiosPri"/>
							</bean:define>
							<map:text size="16" name="formGestionExped" id="BeneficiosPri"
									maxlength="15" tabindex="10" property="beneficiosPri"
									onkeyup="modificacionComplementario1();calculoPendiente();calculoLiquido();"
    							    onchange="recalculoCoaPorCambioDe('BeneficiosPri');"
									onblur="javascript: validarImporte2Dec(this,'2','100000000000','-100000000000'); calculoCodImportes('I'); sumaTotal();controlCamposCoa();limpiaCoase();">
								<map:validation rule="mask('^([-]|[0-9]){0,1}[0-9]{0,11}?([,|^,][0-9]{0,2})*$')">
									<bean:message key="rescate.error.numerico.decimal" arg0="<%=litBeneficiosPri%>" />
								</map:validation>
							</map:text>
						</span>
						<!-- MU-2016-006664 - 06-05-2016 - RAROALE - FIN -->

						<span class="W7 D">
							<bean:message key="rescate.gestionexpedientes.label.fecPagoCapital" />:
						</span>
						<span class="W15 I"> <map:date name="fecPagoCapital"
							srcName="formGestionExped" srcProperty="fecPagoCapital"
							srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" tabindex="10"
							calendar="true" onblur="calculoPendiente();">
							</map:date> </span> 
						
						<logic:equal name="formGestionExped" property="anio" value="1950">
							<span class="W7 D">
									<bean:message key="rescate.gestionexpedientes.label.usuarioPagoPri" />:
							</span>
							
							<span class="W8 I">
								<bean:define id="litUsuarioPagoPri" type="String">
									<bean:message key="rescate.gestionexpedientes.label.usuarioPagoPri" />
								</bean:define>
								<map:text size="16" name="formGestionExped" id="usuarioPagoPri"
										maxlength="15" tabindex="10" property="usuarioPagoPri">
								</map:text>
							</span> 
						</logic:equal>
						
						</DIV>
						<DIV>

						<span class="W10 D">
							<bean:message key="rescate.gestionexpedientes.label.anticipoPri" />:
						</span>
						<span class="W11 I"> <bean:define id="litImpAnticipo"
							type="String">
							<bean:message key="rescate.gestionexpedientes.label.anticipoPri" />
						</bean:define> <map:text size="16" name="formGestionExped" id="ImpAnticipo"
							maxlength="15" tabindex="10" property="impAnticipo"
							onkeyup="calculoPendiente();calculoLiquido();">
							<map:validation rule="mask('^([-]|[0-9]){0,1}[0-9]{0,11}?([,|^,][0-9]{0,2})*$')">
								<bean:message key="rescate.error.numerico.decimal"
									arg0="<%=litImpAnticipo%>" />
							</map:validation>

						</map:text> </span>

						<span class="W8 D">
							<bean:message
									key="rescate.gestionexpedientes.label.devolInterPri" />:
						</span>
						<span class="W12 I"> <bean:define id="litImpInteresPend" type="String">
							<bean:message
								key="rescate.gestionexpedientes.label.devolInterPri" />
						</bean:define> <map:text size="16" name="formGestionExped" id="ImpInteresPend"
							maxlength="15" tabindex="10" property="impInteresPend"
							onkeyup="calculoPendiente();calculoLiquido();">
							<map:validation rule="mask('^([-]|[0-9]){0,1}[0-9]{0,11}?([,|^,][0-9]{0,2})*$')">
								<bean:message key="rescate.error.numerico.decimal"
									arg0="<%=litImpInteresPend%>" />
							</map:validation>

						</map:text> </span>

						<span class="W8 D">
							<bean:message
									key="rescate.gestionexpedientes.label.fecVencimientoPri" />:
						</span>
						<span class="W15 I"> <map:date name="fecVencimiento"
							srcName="formGestionExped" srcProperty="fecVencimiento"
							srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" tabindex="10"
							calendar="true" onblur="calcularDuracion();">
							</map:date>

						 </span> 
						 
						 <logic:equal name="formGestionExped" property="anio" value="1950">
							<span class="W7 D" style="white-space: nowrap;">
									<bean:message key="rescate.gestionexpedientes.label.fecCapturaPri" />:
							</span>
							
							<span class="W9 I"style="white-space: nowrap;"> <map:date name="fecCapturaPri"
								srcName="formGestionExped" srcProperty="fecCapturaPri"
								srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" tabindex="10"
								calendar="true" > </map:date>
							</span>
			
							<span class="W11 D">
									<bean:message key="rescate.gestionexpedientes.label.usuarioCapturaPri" />:
							</span>
							
							<span class="W8 I">
								<bean:define id="litUsuarioCapturaPri" type="String">
									<bean:message key="rescate.gestionexpedientes.label.usuarioCapturaPri" />
								</bean:define>
								<map:text size="16" name="formGestionExped" id="UsuarioCapturaPri"
										maxlength="15" tabindex="10" property="usuarioCapturaPri">
								</map:text>
							</span> 				
						</logic:equal>
						 
						 </DIV>

						 <DIV>
						 <span class="W10 D">
						 	<bean:message
							key="rescate.gestionexpedientes.label.tipoImpuestoPri" />:
						 </span>
						 <!-- MU-2016-006664 - RAROALE - INI -->
						 <span class="W11 I"> <!-- R&V CU009 Se cambia W49 I por W17 I-->
						 	<map:select showcode="false" property="tipImpuestoCap" onchange="cambiosTipImpuesto('P'); compruebaCampoDeCompensacionFiscal();" tabindex="10">
								<map:defaultOption>
									<bean:message key="rescate.desplegable.default" />
								</map:defaultOption>
								<map:optionsJs tablename="IMPUESTOS_RES" lang="ES" type="L" orderby="value" dir="asc" />
							</map:select>
						</span>
						<!-- MU-2016-006664 - RAROALE - FIN -->

						<!-- R&V CU009 INI -->
                        <span class="W8 D">
                            <bean:message key="rescate.gestionexpedientes.label.eximido" />:
                        </span>
                        <span class="W13 I">
                            <map:radio id="eximido1" name="formGestionExped" property="eximido" value="N">
                                <bean:message key="rescate.gestionexpedientes.label.eximido.opcion1" />

                            </map:radio>
                            <map:radio id="eximido2" name="formGestionExped" property="eximido"  value="S">
                                <bean:message key="rescate.gestionexpedientes.label.eximido.opcion2" />
                            </map:radio>
                        </span>
                        <!-- R&V CU009 FIN -->

						<span class="W7 D">
							<bean:message
									key="rescate.gestionexpedientes.label.fecImpresionCap" />:
						</span>

						<span class="W15 I"> <map:date name="fecImpreCap"
							srcName="formGestionExped" srcProperty="fecImpreCap"
							srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true"
							calendar="true" disabled="true">
							</map:date> </span>
							
						<logic:equal name="formGestionExped" property="anio" value="1950">
							<span class="W7 D">
									<bean:message key="rescate.gestionexpedientes.label.formaPagoPri" />:
							</span>
							
							<span class="W8 I">
								<bean:define id="litFormaPagoPri" type="String">
									<bean:message key="rescate.gestionexpedientes.label.formaPagoPri" />
								</bean:define>
								<map:text size="25" name="formGestionExped" id="DescFormaPagoPri"
										maxlength="15" tabindex="10" property="descFormaPagoPri">
								</map:text>
							</span>
							
							<logic:equal name="formGestionExped" property="formaPagoPri" value="F">
								<span class="W12 D">
										<bean:message
											key="rescate.gestionexpedientes.label.numCuentaPri" />:
								</span>
								
								<span class="W8 I"> <bean:define id="litNumCuentaPri" type="String">
									<bean:message
										key="rescate.gestionexpedientes.label.numCuentaPri" />
								</bean:define> <map:text size="25" name="formGestionExped" id="NumCuentaPri"
									maxlength="20" tabindex="10" property="numCuentaPri">
								</map:text> 
								</span>
							</logic:equal>
							
							<logic:equal name="formGestionExped" property="formaPagoPri" value="Q">
								<span class="W12 D">
										<bean:message
											key="rescate.gestionexpedientes.label.numChequePri" />:
								</span>
								
								<span class="W8 I"> <bean:define id="litNumChequePri" type="String">
									<bean:message
										key="rescate.gestionexpedientes.label.numChequePri" />
								</bean:define> <map:text size="16" name="formGestionExped" id="NumChequePri"
									maxlength="15" tabindex="10" property="numChequePri">
								</map:text> 
								</span>
							</logic:equal>
							
							<logic:notEqual name="formGestionExped" property="formaPagoPri" value="F">
								<logic:notEqual name="formGestionExped" property="formaPagoPri" value="Q">
									<span class="W12 D">
											<bean:message
												key="rescate.gestionexpedientes.label.refReinversionPri" />:
									</span>
									
									<span class="W8 I"> <bean:define id="litRefReinversionPri" type="String">
										<bean:message
											key="rescate.gestionexpedientes.label.refReinversionPri" />
									</bean:define> <map:text size="16" name="formGestionExped" id="RefReinversionPri"
										maxlength="15" tabindex="10" property="refReinversionPri">
									</map:text> 
									</span>
								</logic:notEqual>
							</logic:notEqual>
						</logic:equal>	
						
						
						</DIV>

					</map:group-box>
					<map:group-box layout="line"
						titleKey="rescate.gestionexpedientes.label.titulo.auxiliar.irpf"
						width="100%" colorLevel="2">
						<DIV>
						<span class="W15 D">
							<bean:message
									key="rescate.gestionexpedientes.label.rtoIntegroPri" />:
						</span>
						<span class="W17 I"> <bean:define id="litRtoIntegroCap"
							type="String">
							<bean:message
								key="rescate.gestionexpedientes.label.rtoIntegroPri" />
						</bean:define> <map:text size="16" name="formGestionExped" id="RtoIntegroCap"
							maxlength="15" tabindex="10" property="rtoIntegroCap"
							onkeyup="calculoRtoNeto('Cap');calculoLiquido();calculoRetencion('Cap');">
							<map:validation rule="mask('^([-]|[0-9]){0,1}[0-9]{0,11}?([,|^,][0-9]{0,2})*$')">
								<bean:message key="rescate.error.numerico.decimal"
									arg0="<%=litRtoIntegroCap%>" />
							</map:validation>
						</map:text> </span>

						<span class="W15 D">
							<bean:message
									key="rescate.gestionexpedientes.label.redPrimasPri" />:
						</span>
						<span class="W17 I"> <bean:define id="litRedPrimasCap" type="String">
							<bean:message key="rescate.gestionexpedientes.label.redPrimasPri" />
						</bean:define> <map:text size="16" name="formGestionExped" id="RedPrimasCap"
							maxlength="15" tabindex="10" property="redPrimasCap"
							onkeyup="calculoRtoNeto('Cap');calculoLiquido('Cap');calculoRetencion('Cap');">
							<map:validation rule="mask('^([-]|[0-9]){0,1}[0-9]{0,11}?([,|^,][0-9]{0,2})*$')">
								<bean:message key="rescate.error.numerico.decimal"
									arg0="<%=litRedPrimasCap%>" />
							</map:validation>

						</map:text> </span>
						<span class="W15 D">
							<bean:message
									key="rescate.gestionexpedientes.label.redTransitPri" />:
						</span>
						<span class="W17 I"> <bean:define id="litRedTransitCap" type="String">
							<bean:message
								key="rescate.gestionexpedientes.label.redTransitPri" />
						</bean:define> <map:text size="16" name="formGestionExped" id="RedTransitCap"
							maxlength="15" tabindex="10" property="redTransitCap"
							onkeyup="calculoRtoNeto('Cap');calculoLiquido();calculoRetencion('Cap');">
							<map:validation rule="mask('^([-]|[0-9]){0,1}[0-9]{0,11}?([,|^,][0-9]{0,2})*$')">
								<bean:message key="rescate.error.numerico.decimal"
									arg0="<%=litRedTransitCap%>" />
							</map:validation>

						</map:text> </span> </DIV>


						<DIV>
						<span class="W15 D">
							<bean:message key="rescate.gestionexpedientes.label.rtoNetoPri" />:
						</span>
						<span class="W17 I"> <map:text size="16" name="formGestionExped"
							id="RtoNetoCap" maxlength="15" tabindex="10"
							property="rtoNetoCap" disabled="true">
							</map:text>
						<input type="hidden"
			name="rtoNetoCap" id="RtoNetoCapHidden" /> </span>

						<span class="W15 D">
							<bean:message
									key="rescate.gestionexpedientes.label.porcentajePri" />:
						</span>
					 <span class="W17 I"> <bean:define id="litPorcentajeCap" type="String">
							<bean:message
								key="rescate.gestionexpedientes.label.porcentajePri" />
						</bean:define> <map:text size="6" name="formGestionExped" id="PorcentajeCap"
							maxlength="5" tabindex="10" property="porcentajeCap"
							onkeyup="calculoRtoNeto('Cap');calculoLiquido();calculoRetencion('Cap');">
							<map:validation rule="mask('^[0-9]{1,3}?([,|^,][0-9]{0,2})*$')">
								<bean:message key="rescate.error.numerico.decimal.porcentaje"
									arg0="<%=litPorcentajeCap%>" />
							</map:validation>

						</map:text> </span>

						<span class="W15 D">
							<bean:message
									key="rescate.gestionexpedientes.label.retencionPri" />:
						</span>
						<span class="W17 I"> <bean:define id="litRetencionCap" type="String">
							<bean:message key="rescate.gestionexpedientes.label.retencionPri" />
						</bean:define> <map:text size="16" name="formGestionExped" id="RetencionCap"
							maxlength="15" tabindex="10" property="retencionCap"
							onkeyup="calculoRtoNeto('Cap');calculoLiquido();calculoRetencion('Cap');">

						</map:text> <input type="hidden"
			name="retencionCap" id="RetencionCapHidden" /> </span> </DIV>

						<DIV>

						<span class="W15 D">
							<bean:message
									key="rescate.gestionexpedientes.label.fecPagoIRPFPri" />:
						</span>
						<span class="W17 I"> <map:date name="fecPagoIRPFCap"
							srcName="formGestionExped" srcProperty="fecPagoIRPFCap"
							srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" tabindex="10"
							calendar="true">
							</map:date> </span>
						<span class="W15 D">
							<bean:message key="rescate.gestionexpedientes.label.compensaPri" />:
						</span>
						<span class="W17 I"> <bean:define id="litCompensaCap" type="String">
							<bean:message key="rescate.gestionexpedientes.label.compensaPri" />
						</bean:define> <map:text size="16" name="formGestionExped" id="CompensaCap"
							maxlength="15" tabindex="10" property="compensaCap" onchange="calculoLiquido(); recalculoCoaPorCambioDe('CompensaCap','0');">
							<map:validation rule="mask('^([-]|[0-9]){0,1}[0-9]{0,11}?([,|^,][0-9]{0,2})*$')">
								<bean:message key="rescate.error.numerico.decimal"
									arg0="<%=litCompensaCap%>" />
							</map:validation>

						</map:text> </span>
						<span class="W15 D">
							<bean:message key="rescate.gestionexpedientes.label.liquidoPri" />:
						</span>
						<span class="W17 I"> <bean:define id="litLiquidoCap" type="String">
							<bean:message key="rescate.gestionexpedientes.label.liquidoPri" />
						</bean:define> <map:text size="16" name="formGestionExped" id="LiquidoCap"
							maxlength="15" tabindex="10" property="liquidoCap">
							<map:validation rule="mask('^([-]|[0-9]){0,1}[0-9]{0,11}?([,|^,][0-9]{0,2})*$')">
								<bean:message key="rescate.error.numerico.decimal"
									arg0="<%=litLiquidoCap%>" />
							</map:validation>

						</map:text> </span></DIV>
					</map:group-box>
					<DIV class="ContenidoSeparador"></DIV>
					<!-- INICIO MODIFICACION EVERIS -->

					<map:group-box layout="line"
						width="100%" colorLevel="2">
				 	<DIV>
				 		<span class="W15 D">
								<bean:message
								key="rescate.gestionexpedientes.label.fechaBDGI" />:
						</span>
						<span class="W17 I">
							<map:date name="fecBDGICap"
								srcName="formGestionExped" srcProperty="fecBDGICap"
								srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true"
								calendar="true" disabled="true">
							</map:date>
							<input type="hidden"
								name="fecBDGICap" id="fecBDGICapHidden" />
						</span>






			</DIV>
			</map:group-box>
			<!-- FIN MODIFICACION EVERIS -->
				</map:pane-content>
			</map:pane>
			<map:pane selected="false" onclick="valorPestana('2');">
				<map:pane-label>
					<bean:message
						key="rescate.gestionexpedientes.label.pestana.primerbeneficiario" />
				</map:pane-label>
				<map:pane-content>
					<map:group-box layout="line"
						titleKey="rescate.gestionexpedientes.label.titulo.auxiliar.complementario1"
						width="100%" colorLevel="2">

						<DIV>
							<span class="W10 D">
								<bean:message key="rescate.gestionexpedientes.label.importePri" />:
							</span>
							<span class="W10 I">
								<bean:define id="litImportePri" type="String">
									<bean:message key="rescate.gestionexpedientes.label.importePri" />
								</bean:define>
								<!-- MU-2016-006664 - RAROALE - INI -->
								<map:text size="16" name="formGestionExped" id="ImportePri"
									maxlength="15" tabindex="10" property="importePri"
									onkeyup="modificacionComplementario2();calculoPendiente();calculoLiquido();"
    							    onchange="recalculoCoaPorCambioDe('ImportePri');"
									onblur="javascript: validarImporte2Dec(this,'2','100000000000','-100000000000'); calculoCodImportes('I'); sumaTotal();controlCamposCoa();limpiaCoase();">
										<map:validation rule="mask('^([-]|[0-9]){0,1}[0-9]{0,11}?([,|^,][0-9]{0,2})*$')">
										<bean:message key="rescate.error.numerico.decimal"
									arg0="<%=litImportePri%>" />
									</map:validation>
								</map:text>
								<!-- MU-2016-006664 - RAROALE - FIN -->
							</span>

						<span class="W14 D">
							<bean:message key="rescate.gestionexpedientes.label.fecPagoIRPFPri" />:
						</span>

						<span class="W11 I"> <map:date name="fecPagoPri"
							srcName="formGestionExped" srcProperty="fecPagoPri"
							srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" tabindex="10"
							calendar="true" onblur="calculoPendiente();">

						</map:date> </span>

						<span class="W14 D">
							<bean:message
									key="rescate.gestionexpedientes.label.fecEmisionPri" />:
						</span>
						<span class="W15 I"> <map:date name="fecEmisionPri"
							srcName="formGestionExped" srcProperty="fecEmisionPri"
							srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" tabindex="10"
							calendar="true">

						</map:date> </span>
						
						<logic:equal name="formGestionExped" property="anio" value="1950">
							<span class="W7 D">
									<bean:message key="rescate.gestionexpedientes.label.usuarioPagoPri" />:
							</span>
							
							<span class="W8 I">
								<bean:define id="litUsuarioPagoComp" type="String">
									<bean:message key="rescate.gestionexpedientes.label.usuarioPagoPri" />
								</bean:define>
								<map:text size="16" name="formGestionExped" id="UsuarioPagoComp1"
										maxlength="15" tabindex="10" property="usuarioPagoComp1">
								</map:text>
							</span> 
						</logic:equal>

						</DIV>
						<DIV>

						<span class="W10 D">
							<bean:message key="rescate.gestionexpedientes.label.tipoImpuestoPri" />:
						</span>


						<span class="W10 I">
							<map:select
							showcode="false" property="tipImpuestoPri"
							onchange="cambiosTipImpuestoPri();" tabindex="10">
							<map:defaultOption>
								<bean:message key="rescate.desplegable.default" />
							</map:defaultOption>

							<map:optionsJs tablename="IMPUESTOS_RES" lang="ES" type="L"
								orderby="value" dir="asc" />
							</map:select>
						</span>



						<span class="W14 D">
							<bean:message
									key="rescate.gestionexpedientes.label.fecImpresionPri" />:
						</span>
						<span class="W11 I">
							<map:date name="fecImprePri"
							srcName="formGestionExped" srcProperty="fecImprePri"
							srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true"
							calendar="true" disabled="true">
							</map:date>
						</span>
						
						<logic:equal name="formGestionExped" property="anio" value="1950">	
							<span class="W14 D">
									<bean:message key="rescate.gestionexpedientes.label.fecCapturaPri" />:
							</span>
							
							<span class="W15 I"> <map:date name="fecCapturaComp1"
								srcName="formGestionExped" srcProperty="fecCapturaComp1"
								srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" tabindex="10"
								calendar="true" > </map:date>
							</span>
			
							<span class="W7 D">
									<bean:message key="rescate.gestionexpedientes.label.usuarioCapturaPri" />:
							</span>
							
							<span class="W8 I">
								<bean:define id="litUsuarioCapturaComp1" type="String">
									<bean:message key="rescate.gestionexpedientes.label.usuarioCapturaPri" />
								</bean:define>
								<map:text size="16" name="formGestionExped" id="UsuarioCapturaComp1"
										maxlength="15" tabindex="10" property="usuarioCapturaComp1">
								</map:text>
							</span> 	
						</logic:equal>

						</DIV>
						
						<logic:equal name="formGestionExped" property="anio" value="1950">
							<DIV>
								<span class="W10 D">
										<bean:message key="rescate.gestionexpedientes.label.formaPagoPri" />:
								</span>
								
								<span class="W10 I">
									<bean:define id="litFormaPagoComp1" type="String">
										<bean:message key="rescate.gestionexpedientes.label.formaPagoPri" />
									</bean:define>
									<map:text size="16" name="formGestionExped" id="DescFormaPagoPri1"
											maxlength="15" tabindex="10" property="descFormaPagoComp1">
									</map:text>
								</span>
								
								<logic:equal name="formGestionExped" property="formaPagoComp1" value="Q">
									<span class="W14 D">
											<bean:message
												key="rescate.gestionexpedientes.label.numChequePri" />:
									</span>
									
									<span class="W11 I"> <bean:define id="litNumChequePri1" type="String">
										<bean:message
											key="rescate.gestionexpedientes.label.numChequePri" />
									</bean:define> <map:text size="16" name="formGestionExped" id="NumChequePri1"
										maxlength="15" tabindex="10" property="numChequeComp1">
									</map:text> 
									</span>
								</logic:equal>
								
								<logic:equal name="formGestionExped" property="formaPagoComp1" value="F">
									<span class="W14 D">
											<bean:message
												key="rescate.gestionexpedientes.label.numCuentaPri" />:
									</span>
									
									<span class="W11 I"> <bean:define id="litNumCuentaPri1" type="String">
										<bean:message
											key="rescate.gestionexpedientes.label.numCuentaPri" />
									</bean:define> <map:text size="25" name="formGestionExped" id="NumCuentaPri1"
										maxlength="20" tabindex="10" property="numCuentaComp1">
									</map:text> 
									</span>
								</logic:equal>
							</DIV>
						</logic:equal>

					</map:group-box>
					<map:group-box layout="line"
						titleKey="rescate.gestionexpedientes.label.titulo.auxiliar.irpf"
						width="100%" colorLevel="2">
						<DIV>
						<span class="W15 D">
							<bean:message
									key="rescate.gestionexpedientes.label.rtoIntegroPri" />:
						</span>

						<span class="W17 I"> <bean:define id="litRtoIntegroPri"
							type="String">
							<bean:message
								key="rescate.gestionexpedientes.label.rtoIntegroPri" />
						</bean:define> <map:text size="16" name="formGestionExped" id="RtoIntegroPri"
							maxlength="15" tabindex="10" property="rtoIntegroPri"
							onkeyup="calculoRtoNeto('Pri');calculoRetencion('Pri');calculoLiquido();">
								<map:validation rule="mask('^([-]|[0-9]){0,1}[0-9]{0,11}?([,|^,][0-9]{0,2})*$')">
								<bean:message key="rescate.error.numerico.decimal"
									arg0="<%=litRtoIntegroPri%>" />
							</map:validation>
						</map:text> </span>


						<span class="W15 D">
							<bean:message
									key="rescate.gestionexpedientes.label.redPrimasPri" />:
						</span>
						 <span class="W17 I"> <bean:define id="litRedPrimasPri" type="String">
							<bean:message key="rescate.gestionexpedientes.label.redPrimasPri" />
						</bean:define> <map:text size="16" name="formGestionExped" id="RedPrimasPri"
							maxlength="15" tabindex="10" property="redPrimasPri"
							onkeyup="calculoRtoNeto('Pri');calculoRetencion('Pri');calculoLiquido();">
							<map:validation rule="mask('^([-]|[0-9]){0,1}[0-9]{0,11}?([,|^,][0-9]{0,2})*$')">
								<bean:message key="rescate.error.numerico.decimal"
									arg0="<%=litRedPrimasPri%>" />
							</map:validation>

						</map:text> </span>


						<span class="W15 D">
							<bean:message
									key="rescate.gestionexpedientes.label.redTransitPri" />:
						</span>
						<span class="W17 I"> <bean:define id="litRedTransitPri" type="String">
							<bean:message
								key="rescate.gestionexpedientes.label.redTransitPri" />
						</bean:define> <map:text size="16" name="formGestionExped" id="RedTransitPri"
							maxlength="15" tabindex="10" property="redTransitPri"
							onkeyup="calculoRtoNeto('Pri');calculoRetencion('Pri');calculoLiquido();">

							<map:validation rule="mask('^([-]|[0-9]){0,1}[0-9]{0,11}?([,|^,][0-9]{0,2})*$')">
								<bean:message key="rescate.error.numerico.decimal"
									arg0="<%=litRedTransitPri%>" />
							</map:validation>

						</map:text> </span></DIV>


						<DIV>
						<span class="W15 D">
							<bean:message key="rescate.gestionexpedientes.label.rtoNetoPri" />:
						</span>
						 <span class="W17 I"> <map:text size="16" name="formGestionExped"
							id="RtoNetoPri" maxlength="15" tabindex="10"
							property="rtoNetoPri" disabled="true">

						</map:text>
						<input type="hidden"
			name="rtoNetoPri" id="RtoNetoPriHidden" /> </span>
						<span class="W15 D">
							<bean:message
									key="rescate.gestionexpedientes.label.porcentajePri" />:
						</span>
					<span class="W17 I"> <bean:define id="litPorcentajePri" type="String">
							<bean:message
								key="rescate.gestionexpedientes.label.porcentajePri" />
						</bean:define> <map:text size="6" name="formGestionExped" id="PorcentajePri"
							maxlength="5" tabindex="10" property="porcentajePri"
							onkeyup="calculoRtoNeto('Pri');calculoRetencion('Pri');calculoLiquido();">

							<map:validation rule="mask('^[0-9]{1,3}?([,|^,][0-9]{0,2})*$')">
								<bean:message key="rescate.error.numerico.decimal.porcentaje"
									arg0="<%=litPorcentajePri%>" />
							</map:validation>

						</map:text> </span>
						<span class="W15 D">
							<bean:message
									key="rescate.gestionexpedientes.label.retencionPri" />:
						</span>
						<span class="W17 I"> <bean:define id="litRetencionPri" type="String">
							<bean:message key="rescate.gestionexpedientes.label.retencionPri" />
						</bean:define> <map:text size="16" name="formGestionExped" id="RetencionPri"
							maxlength="15" tabindex="10" property="retencionPri"
							onkeyup="calculoRtoNeto('Pri');calculoRetencion('Pri');calculoLiquido();">
							</map:text> <input type="hidden"
			name="retencionPri" id="RetencionPriHidden" /> </span></DIV>


						<DIV>
						<span class="W15 D">
							<bean:message
									key="rescate.gestionexpedientes.label.fecPagoIRPFPri" />:
						</span>

						<span class="W17 I" > <map:date name="fecPagoIRPFPri"
							srcName="formGestionExped" srcProperty="fecPagoIRPFPri"
							srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" tabindex="10"
							calendar="true">
							</map:date> </span>
						<span class="W32 D"> </span>

						<span class="W15 D">
							<bean:message key="rescate.gestionexpedientes.label.liquidoPri" />:
						</span>
						<span class="W17 I"> <bean:define id="litLiquidoPri" type="String">
							<bean:message key="rescate.gestionexpedientes.label.liquidoPri" />
						</bean:define> <map:text size="16" name="formGestionExped" id="LiquidoPri"
							maxlength="15" tabindex="10" property="liquidoPri">
							<map:validation rule="mask('^([-]|[0-9]){0,1}[0-9]{0,11}?([,|^,][0-9]{0,2})*$')">
								<bean:message key="rescate.error.numerico.decimal"
									arg0="<%=litLiquidoPri%>" />
							</map:validation>

						</map:text> </span></DIV>
					</map:group-box>
					<DIV class="ContenidoSeparador"></DIV>

					<!-- INICIO MODIFICACION EVERIS -->
				 	<map:group-box layout="line"
						width="100%" colorLevel="2">
				 	<DIV>
				 		<span class="W15 D">
								<bean:message
								key="rescate.gestionexpedientes.label.fechaBDGI" />:
						</span>
						<span class="W17 I">
							<map:date name="fecBDGIComp1"
								srcName="formGestionExped" srcProperty="fecBDGIComp1"
								srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true"
								calendar="true" disabled="true">
							</map:date>

				 		<input type="hidden"
							name="fecBDGIComp1" id="fecBDGIComp1Hidden" />
						</span>
			</DIV>
			</map:group-box>
			<!-- FIN MODIFICACION EVERIS -->
					<map:group-box layout="line"
						titleKey="rescate.gestionexpedientes.label.titulo.auxiliar.complementario"
						width="100%" colorLevel="2">
						<DIV><span class="W10 D">
								<bean:message key="rescate.gestionexpedientes.label.importeComp" />:
						</span>
						<%-- MU-2016-006664 - RAROALE - INI--%>
						<span class="W10 I">
							<bean:define id="litImporteComp" type="String">
								<bean:message key="rescate.gestionexpedientes.label.importeComp" />
							</bean:define>
							<map:text size="16" name="formGestionExped" id="ImporteComp"
								maxlength="15" tabindex="10" property="importeComp"
							 	onkeyup="calculoPendiente();calculoCodImportes('I');calculoLiquido();" onchange="calculoLiquido();"
							    onchange="recalculoCoaPorCambioDe('ImporteComp');"
							 	onblur="javascript: validarImporte2Dec(this,'2','100000000000','-100000000000'); calculoCodImportes('I'); sumaTotal();">
									<map:validation rule="mask('^([-]|[0-9]){0,1}[0-9]{0,11}?([,|^,][0-9]{0,2})*$')">
										<bean:message key="rescate.error.numerico.decimal" arg0="<%=litImporteComp%>" />
									</map:validation>
							</map:text>
						</span>
						<span class="W14 D">
								<bean:message key="rescate.gestionexpedientes.label.fecPagoComp"/>:
						</span>
						<span class="W11 I">
							<map:date name="fecPagoComp" srcName="formGestionExped" srcProperty="fecPagoComp"
								srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" tabindex="10"
								calendar="true" onblur="calculoPendiente();">
							</map:date>
						</span>
						<%-- MU-2016-006664 - RAROALE - FIN--%>

						<span class="W14 D">
								<bean:message
									key="rescate.gestionexpedientes.label.fecEmisionComp" />:
						</span>
						<span class="W15 I"> <map:date name="fecEmisionComp"
							srcName="formGestionExped" srcProperty="fecEmisionComp"
							srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" tabindex="10"
							calendar="true">
							</map:date> </span> 
							
						<logic:equal name="formGestionExped" property="anio" value="1950">
							<span class="W7 D">
									<bean:message key="rescate.gestionexpedientes.label.usuarioPagoComp" />:
							</span>
							
							<span class="W8 I">
								<bean:define id="litUsuarioPagoComp" type="String">
									<bean:message key="rescate.gestionexpedientes.label.usuarioPagoComp" />
								</bean:define>
								<map:text size="16" name="formGestionExped" id="UsuarioPagoComp2"
										maxlength="15" tabindex="10" property="usuarioPagoComp2">
								</map:text>
							</span> 
						</logic:equal>
						
						</DIV>

						<DIV>


						<span class="W10 D">
								<bean:message
							key="rescate.gestionexpedientes.label.tipoImpuestoComp" />:
						</span>
						<span class="W10 I">  <map:select
							showcode="false" property="tipImpuestoComp" disabled="true" tabindex="10" onchange="cambiosTipImpuestoComp();">
							<map:defaultOption>
								<bean:message key="rescate.desplegable.default" />
							</map:defaultOption>

							<map:optionsJs tablename="IMPUESTOS_RES" lang="ES" type="L"
								orderby="value" dir="asc" />


						</map:select>
						</span>

						<span class="W14 D">
								<bean:message
									key="rescate.gestionexpedientes.label.fecImpresionComp" />:
						</span>
						<span class="W11 I"> <map:date name="fecImpreComp"
							srcName="formGestionExped" srcProperty="fecImpreComp"
							srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true"
							calendar="true" disabled="true">
							</map:date>
						</span>
						
						<logic:equal name="formGestionExped" property="anio" value="1950">	
							<span class="W14 D">
									<bean:message key="rescate.gestionexpedientes.label.fecCapturaComp" />:
							</span>
							
							<span class="W15 I"> <map:date name="fecCapturaComp2"
								srcName="formGestionExped" srcProperty="fecCapturaComp2"
								srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" tabindex="10"
								calendar="true" > </map:date>
							</span>
			
							<span class="W7 D">
									<bean:message key="rescate.gestionexpedientes.label.usuarioCapturaComp" />:
							</span>
							
							<span class="W8 I">
								<bean:define id="litUsuarioCapturaComp2" type="String">
									<bean:message key="rescate.gestionexpedientes.label.usuarioCapturaComp" />
								</bean:define>
								<map:text size="16" name="formGestionExped" id="UsuarioCapturaComp2"
										maxlength="15" tabindex="10" property="usuarioCapturaComp2">
								</map:text>
							</span> 	
						</logic:equal>

						</DIV>
						
						<logic:equal name="formGestionExped" property="anio" value="1950">
							<DIV>
								<span class="W10 D">
										<bean:message key="rescate.gestionexpedientes.label.formaPagoComp" />:
								</span>
								
								<span class="W10 I">
									<bean:define id="litFormaPagoComp1" type="String">
										<bean:message key="rescate.gestionexpedientes.label.formaPagoComp" />
									</bean:define>
									<map:text size="16" name="formGestionExped" id="DescFormaPagoComp2"
											maxlength="15" tabindex="10" property="descFormaPagoComp2">
									</map:text>
								</span>
								
								<logic:equal name="formGestionExped" property="formaPagoComp2" value="Q">
									<span class="W14 D">
											<bean:message
												key="rescate.gestionexpedientes.label.numChequeComp" />:
									</span>
									
									<span class="W11 I"> <bean:define id="litNumChequeComp2" type="String">
										<bean:message
											key="rescate.gestionexpedientes.label.numChequeComp" />
									</bean:define> <map:text size="16" name="formGestionExped" id="NumChequeComp2"
										maxlength="15" tabindex="10" property="numChequeComp2">
									</map:text> 
									</span>
								</logic:equal>
								
								<logic:equal name="formGestionExped" property="formaPagoComp2" value="F">
									<span class="W14 D">
											<bean:message
												key="rescate.gestionexpedientes.label.numCuentaComp" />:
									</span>
									
									<span class="W11 I"> <bean:define id="litNumCuentaComp2" type="String">
										<bean:message
											key="rescate.gestionexpedientes.label.numCuentaComp" />
									</bean:define> <map:text size="25" name="formGestionExped" id="NumCuentaComp2"
										maxlength="20" tabindex="10" property="numCuentaComp2">
									</map:text> 
									</span>
								</logic:equal>
							</DIV>
						</logic:equal>

					</map:group-box>
					<map:group-box layout="line"
						titleKey="rescate.gestionexpedientes.label.titulo.auxiliar.irpf"
						width="100%" colorLevel="2">
						<DIV>
						<span class="W15 D">
								<bean:message
									key="rescate.gestionexpedientes.label.rtoIntegroComp" />:
						</span>
						<span class="W17 I"> <bean:define id="litRtoIntegroComp"
							type="String">
							<bean:message
								key="rescate.gestionexpedientes.label.rtoIntegroComp" />
						</bean:define> <map:text size="16" name="formGestionExped" id="RtoIntegroComp"
							maxlength="15" tabindex="10" property="rtoIntegroComp"
							onkeyup="calculoRtoNeto('Comp');calculoRetencion('Comp');calculoLiquido();">
							<map:validation rule="mask('^([-]|[0-9]){0,1}[0-9]{0,11}?([,|^,][0-9]{0,2})*$')">
								<bean:message key="rescate.error.numerico.decimal"
									arg0="<%=litRtoIntegroComp%>" />
							</map:validation>

						</map:text> </span>

						 <span class="W15 D">
						 	<bean:message
									key="rescate.gestionexpedientes.label.redPrimasComp" />:
						 </span>

						 <span class="W17 I"> <bean:define id="litRedPrimasComp" type="String">
							<bean:message
								key="rescate.gestionexpedientes.label.redPrimasComp" />
						</bean:define> <map:text size="16" name="formGestionExped" id="RedPrimasComp"
							maxlength="15" tabindex="10" property="redPrimasComp"
							 onkeyup="calculoRtoNeto('Comp');calculoRetencion('Comp');calculoLiquido();">
							<map:validation rule="mask('^([-]|[0-9]){0,1}[0-9]{0,11}?([,|^,][0-9]{0,2})*$')">
								<bean:message key="rescate.error.numerico.decimal"
									arg0="<%=litRedPrimasComp%>" />
							</map:validation>

						</map:text> </span>


						<span class="W15 D">
							<bean:message
									key="rescate.gestionexpedientes.label.redTransitComp" />:
						</span>
						<span class="W17 I"> <bean:define id="litRedTransitComp" type="String">
							<bean:message
								key="rescate.gestionexpedientes.label.redTransitComp" />
						</bean:define> <map:text size="16" name="formGestionExped" id="RedTransitComp"
							maxlength="15" tabindex="10" property="redTransitComp"
							 onkeyup="calculoRtoNeto('Comp');calculoRetencion('Comp');calculoLiquido();">
							<map:validation rule="mask('^([-]|[0-9]){0,1}[0-9]{0,11}?([,|^,][0-9]{0,2})*$')">
								<bean:message key="rescate.error.numerico.decimal"
									arg0="<%=litRedTransitComp%>" />
							</map:validation>

						</map:text> </span> </div>


						<DIV>
			<span class="W15 D">
								<bean:message key="rescate.gestionexpedientes.label.rtoNetoComp" />:
						</span>
			<span class="W17 I"> <map:text size="16" name="formGestionExped"
							id="RtoNetoComp" maxlength="15" tabindex="10"
							property="rtoNetoComp" disabled="true">
							</map:text>
						<input type="hidden"
			name="rtoNetoComp" id="RtoNetoCompHidden" /> </span>

			 <span class="W15 D">
								<bean:message
									key="rescate.gestionexpedientes.label.porcentajeComp" />:
						</span>
						<%-- MU-2016-006664 - RAROALE - INI--%>
			 			<span class="W17 I">
			 				<bean:define id="litPorcentajeComp" type="String">
								<bean:message key="rescate.gestionexpedientes.label.porcentajeComp" />
							</bean:define>
							<map:text size="7" name="formGestionExped" id="PorcentajeComp"
								maxlength="7" tabindex="10" property="porcentajeComp"
								onkeyup="calculoRetencion('Comp');calculoCodImportes('I');"
								onchange="calculoLiquido();">
								<map:validation rule="mask('^[0-9]{1,3}?([,|^,][0-9]{0,2})*$')">
									<bean:message key="rescate.error.numerico.decimal.porcentaje" arg0="<%=litPorcentajeComp%>" />
								</map:validation>
							</map:text>
						</span>
						<%-- MU-2016-006664 - RAROALE - FIN--%>


						 <span class="W15 D">
								<bean:message
									key="rescate.gestionexpedientes.label.retencionComp" />:
						</span>
						 <span class="W17 I"> <bean:define id="litRetencionComp" type="String">
							<bean:message key="rescate.gestionexpedientes.label.retencionComp" />
						</bean:define> <map:text size="16" name="formGestionExped" id="RetencionComp"
							maxlength="15" tabindex="10" property="retencionComp"
							onkeyup="calculoLiquido();" onchange="calculoLiquido();">
							<map:validation rule="mask('^([-]|[0-9]){0,1}[0-9]{0,11}?([,|^,][0-9]{0,2})*$')">
								<bean:message key="rescate.error.numerico.decimal"
									arg0="<%=litRetencionComp%>" />
							</map:validation>

						</map:text>
						<input type="hidden"
						name="retencionComp" id="RetencionCompHidden" /> </span></DIV>

						<DIV>
						<span class="W15 D">
								<bean:message
									key="rescate.gestionexpedientes.label.fecPagoIRPFComp" />:
						</span>
						<span class="W17 I"> <map:date name="fecPagoIRPFComp"
							srcName="formGestionExped" srcProperty="fecPagoIRPFComp"
							srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" tabindex="10"
							calendar="true">
							</map:date> </span>

						<span class="W32 I"></span>

						<span class="W15 D">
								<bean:message key="rescate.gestionexpedientes.label.liquidoComp" />:
						</span>
						<span class="W17 I"> <bean:define id="litLiquidoComp" type="String">
							<bean:message key="rescate.gestionexpedientes.label.liquidoComp" />
						</bean:define> <map:text size="16" name="formGestionExped" id="LiquidoComp"
							maxlength="15" tabindex="10" property="liquidoComp">
							<map:validation rule="mask('^([-]|[0-9]){0,1}[0-9]{0,11}?([,|^,][0-9]{0,2})*$')">
								<bean:message key="rescate.error.numerico.decimal"
									arg0="<%=litLiquidoComp%>" />
							</map:validation>

						</map:text> </span></DIV>
					</map:group-box>
					<DIV class="ContenidoSeparador"></DIV>
					<!-- INICIO MODIFICACION EVERIS -->
				 	<map:group-box layout="line"
						width="100%" colorLevel="2">
				 	<DIV>


				 	<span class="W15 D">
				 		<bean:message
								key="rescate.gestionexpedientes.label.fechaBDGI" />:
				 	</span>
				 	<span class="W17 I">
				 		<map:date name="fecBDGIComp2"
							srcName="formGestionExped" srcProperty="fecBDGIComp2"
							srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true"
							calendar="true" disabled="true">
						</map:date>
						<input type="hidden"
							name="fecBDGIComp2" id="fecBDGIComp2Hidden" />
					</span>
			</DIV>
			</map:group-box>
			<!-- FIN MODIFICACION EVERIS -->
				</map:pane-content>
			</map:pane>
			<map:pane selected="false" onclick="valorPestana('3');">
				<map:pane-label>
					<bean:message
						key="rescate.gestionexpedientes.label.pestana.segundobeneficiario" />
				</map:pane-label>
				<map:pane-content>
					<map:group-box layout="line"
						titleKey="rescate.gestionexpedientes.label.titulo.auxiliar.beneficiario"
						width="100%" colorLevel="2">
						<DIV><span class="W10 D">

									<bean:message key="rescate.gestionexpedientes.label.nifCifPri" />:

	 						</span>

							<span class="W15 I"> <map:text size="11"
							name="formGestionExped" id="NIFCIFPri" maxlength="10"
							tabindex="10" property="nifCifPri" disabled="false">


						</map:text> <IMG align="middle"
							onclick="abrirPopupPersonas('Pri');" name="imgNifCif"
							id="imgNifCifPri"
							src="<bean:write name="HTTP_PATH"/>/img/lupa.gif"
							alt="Buscar NIF/CIF"> </span> </DIV>

					<DIV>

					<span id="capaCamposNombrePri">

							<span class="W10 D">

									<bean:message key="rescate.gestionexpedientes.label.nombrePri" />:

	 						</span>
							<span class="W20 I"> <map:text size="20"
							name="formGestionExped" id="NombrePri" maxlength="15"
							tabindex="10" property="nombrePri" disabled="true">

						</map:text>
						<input type="hidden" name="nombrePri" id="NombrePriHidden" /> </span>

						<%-- MU-2016-006673 - RAROALE - INI--%>
						<span style="display:none">
							<map:text size="15" name="formGestionExped" id="kpersonaPri" property="kpersonaPri"></map:text>
							<map:text size="15" name="formGestionExped" id="kdomicilioPri" property="kdomicilioPri"></map:text>
							<map:text size="15" name="formGestionExped" id="fmodificacion" property="fmodificacion"></map:text>
						</span>
						<%-- MU-2016-006673 - RAROALE - FIN--%>


	 						<span class="W15 D">
								<bean:message
									key="rescate.gestionexpedientes.label.apellido1Pri" />:
	 						</span>
						<span class="W20 I"> <map:text size="20" name="formGestionExped"
							id="Apellido1Pri" maxlength="15" tabindex="10"
							property="apellido1Pri" disabled="true">
							</map:text>
						<input type="hidden"
			name="apellido1Pri" id="Apellido1PriHidden" /> </span>



	 						<span class="W15 D">
								<bean:message
									key="rescate.gestionexpedientes.label.apellido2Pri" />:
	 						</span>

			 <span class="W20 I"> <map:text size="20" name="formGestionExped"
							id="Apellido2Pri" maxlength="15" tabindex="10"
							property="apellido2Pri" disabled="true">
							</map:text>
						<input type="hidden"
			name="apellido2Pri" id="Apellido2PriHidden" />  </span>
		</span>
			<span id="capaRazonSocialPri" style="display=none">
						 <map:text size="50"
							name="formGestionExped" id="RazonSocialPri" maxlength="50"
							tabindex="10" property="razonSocialPri">
							<map:label width="10%" align="right">
								<bean:message key="rescate.gestionexpedientes.label.razonSocial" />:
	 				</map:label>
						</map:text>
						<input type="hidden"
			name="razonSocialPri" id="RazonSocialPriHidden" /> </span> </DIV>

					<DIV>

					<span class="W35 C"> <bean:message
							key="rescate.gestionexpedientes.label.tipPersona" />: <BR>
						<span style="display:none"> <map:text size="5"
							maxlength="5" name="formGestionExped" id="tipPersonaPri"
							property="tipPersonaPriValue">
						</map:text> </span> <map:radio id="TipPersona1Pri" name="formGestionExped" value="F"
							property="tipPersonaPri" disabled="true">
							<bean:message
								key="rescate.gestionexpedientes.label.tipPersona.opcion1" />

						</map:radio> <map:radio id="TipPersona2Pri" name="formGestionExped" value="J"
							property="tipPersonaPri" disabled="true">
							<bean:message
								key="rescate.gestionexpedientes.label.tipPersona.opcion2" />

						</map:radio>
						<input type="hidden"
			name="tipPersonaPri" id="TipPersonaPriHidden" /></span>


						<span class="W35 C"> <bean:message
							key="rescate.gestionexpedientes.label.tipResidente" />: <BR>

						 <map:radio id="Residente1Pri" name="formGestionExped" value="1"
							 property="residentePri">
							<bean:message
								key="rescate.gestionexpedientes.label.tipResidente.opcion1" />

						</map:radio> <map:radio id="Residente2Pri" name="formGestionExped" value="2"
						 property="residentePri">
							<bean:message
								key="rescate.gestionexpedientes.label.tipResidente.opcion2" />

						</map:radio> </span></DIV>


						<DIV>
							<span class="W10 D">
								<bean:message key="rescate.gestionexpedientes.label.domicilioPri" />:
	 		 				</span>

							<span class="W55 I"> <map:text size="75"
							name="formGestionExped" id="DomicilioPri" maxlength="75"
							tabindex="10" property="domicilioPri" disabled="true">

						</map:text>

						 <!-- R&V CU001 INI -->
						 <input type="hidden" name="tipoDomicilioPri" id="TipoDomicilioPri"  />
						 <!-- R&V CU001 FIN -->

						<input type="hidden"
			name="domicilioPri" id="DomicilioPriHidden" />  </span>


	 						<span class="W15 D">
								<bean:message
									key="rescate.gestionexpedientes.label.codPostalPri" />:
	 						</span>

			 <span class="W14 I"> <map:text size="6" name="formGestionExped"
							id="CodPostalPri" maxlength="5" tabindex="10"
							property="codPostalPri" disabled="true">
							</map:text>
						<input type="hidden"
			name="codPostalPri" id="CodPostalPriHidden" />
			 </span></DIV>














			 	<DIV>
							<span class="W10 D">
								<bean:message key="rescate.gestionexpedientes.label.localidadPri" />:
	 						</span>
							<span class="W20 I">
								<map:text size="30"
									name="formGestionExped" id="LocalidadPri" maxlength="30"
									tabindex="10" property="localidadPri" disabled="true">
								</map:text>
								<input type="hidden" name="localidadPri" id="LocalidadPriHidden" />
							</span>


	 						<span class="W17 D">
								<bean:message
									key="rescate.gestionexpedientes.label.provinciaPri" />:
	 						</span>
							<span class="W16 I">
								<map:text size="15" name="formGestionExped"
									id="ProvinciaPri" maxlength="10" tabindex="10"
									property="provinciaPri" disabled="true">
								</map:text>
								<input type="hidden" name="provinciaPri" id="ProvinciaPriHidden" />
							</span>



	 						<span class="W16 D">
								<bean:message key="rescate.gestionexpedientes.label.paisPri" />:
	 						</span>

			 				<span class="W20 I">
			 					<map:text size="14" name="formGestionExped"
									id="PaisPri" maxlength="10" tabindex="10"
									property="paisPri" disabled="true">
								</map:text>
								<input type="hidden" name="paisPri" id="PaisPriHidden" />
							</span>
					</DIV>




						<DIV>
							<span class="W17 D">

								<bean:message key="rescate.gestionexpedientes.label.fecNacPri" />:

	 						</span>

							<span class="W35 I"> <map:date name="fecNacPri"
							srcName="formGestionExped" srcProperty="fecNacPri"
							srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true"
							calendar="false" disabled="true">

						</map:date> </span>

						<span class="W3 D">	</span>
						<span class="W25 D">
								<bean:message
									key="rescate.gestionexpedientes.label.nifRepLegalPri" />:
	 						</span>
						<span class="W15 I"> <map:text size="11" name="formGestionExped"
							id="NifRepLegalPri" maxlength="10" tabindex="10"
							property="nifRepLegalPri" disabled="true">
							</map:text>
						<input type="hidden"
			name="nifRepLegalPri" id="NifRepLegalPriHidden" /> </span></DIV>
					</map:group-box>
					<map:group-box layout="line"
						titleKey="rescate.gestionexpedientes.label.titulo.auxiliar.datosfiscales"
						width="100%" colorLevel="2">




						<DIV>
							<span class="W20 D">
							<bean:message
									key="rescate.gestionexpedientes.label.discapacitadoPri"  />:
	 					</span>
						<span class="W25 I"> <map:text size="25"
							name="formGestionExped" id="DiscapacitadoPri" maxlength="40"
							tabindex="10" property="discapacitadoPri" disabled="true">

						</map:text>
						<input type="hidden"
			name="discapacitadoPri" id="DiscapacitadoPriHidden" /> </span>


			<span class="W25 D">
							<bean:message
									key="rescate.gestionexpedientes.label.prestViviendoPri" />:
	 					</span>
			<span class="W25 I"> <map:text size="2"
							name="formGestionExped" id="PrestViviendoPri" maxlength="2"
							tabindex="10" property="prestViviendoPri" disabled="true" >
							<input type="hidden"
			name="prestViviendoPri" id="PrestViviendoPriHidden" />
						</map:text>
						</span>
						</DIV>
			<DIV>
						<span class="W20 D">
							<bean:message
									key="rescate.gestionexpedientes.label.sitFamiliarPri" />:
	 					</span>
						<span class="W25 I">
							<map:text size="25"
								name="formGestionExped" id="SitFamiliarPri" maxlength="40"
								tabindex="10" property="sitFamiliarPri" disabled="true">
							</map:text>
						<input type="hidden"
			name="sitFamiliarPri" id="SitFamiliarPriHidden" /> </span>

						<span class="W25 D">
							<bean:message
									key="rescate.gestionexpedientes.label.nifConyugePri" />:
	 					</span>

						<span class="W25 I"> <map:text size="10" name="formGestionExped"
							id="NifConyugePri" maxlength="12" tabindex="10"
							property="nifConyugePri" disabled="true" >

						</map:text>
						<input type="hidden"
			name="nifConyugePri" id="NifConyugePriHidden" />
						 </span>

					</DIV>
					<DIV>
						<span class="W20 D">
							<bean:message key="rescate.gestionexpedientes.label.penCompPri" />:
	 					</span>

						<span class="W25 I"><map:text size="25"
							name="formGestionExped" id="PenComPri" maxlength="40"
							tabindex="10" property="penCompPri" disabled="true" >

						</map:text><input type="hidden"
			name="penCompPri" id="PenCompPriHidden" /> </span>

						<span class="W25 D">
							<bean:message
									key="rescate.gestionexpedientes.label.anulAlimenHijosPri" />:
	 					</span>

			 <span class="W25 I"> <map:text size="15" name="formGestionExped"
							id="AnulAlimenHijosPri" maxlength="40" tabindex="10"
							property="anulAlimenHijosPri" disabled="true">

						</map:text>
						<input type="hidden"
			name="anulAlimenHijosPri" id="AnulAlimenHijosPriHidden" /></span></DIV>
					</map:group-box>

				</map:pane-content>
			</map:pane>

<!-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  R&V Junio 2017 - CU011 - everis(RGL) - INI -->
<!-- La pestaña nueva COASEGURO, se ha desplazado de PRIMER BENEFICIARIO -->
			<map:pane selected="false" onclick="valorPestana('4');recalculaPorImportes();">
				<map:pane-label>
					<bean:message
						key="rescate.gestionexpedientes.label.pestana.coaseguro" />
				</map:pane-label>
				<map:pane-content>

                <!-- R&V CA Fase II CU011-COASEGURO - INI -->
                <!-- R&V Se cambia de sitio el botón: Añadir Cuadro Coaseguro y el radio TOTAL PAGO MAPFRE -->
                <!-- R&V Se añade en radio VALORES MANUALES -->

                <map:group-box>
                    <DIV>
                        <span class="W100 C">
                            <map:contextualButton
                                    name="botonAnadirCuadroCoaseguro"
                                    title="Añade Cuadro de Coaseguros"
                                    onclick="anadirCuadroCoaseguro();">
                                <bean:message key="rescate.gestionexpedientes.label.boton.anadircuadrocoaseguro"/>
                            </map:contextualButton>
                        </span>
                    </DIV>

                    <DIV><span class="W55 I"> <bean:message
                        key="rescate.gestionexpedientes.label.valoresManuales" />:

                    <map:radio id="valoresManuales1" name="formGestionExped"
                        onclick="clickEnValoresManuales('S');"
                        property="valoresManuales" value="S">
                        <bean:message
                            key="rescate.gestionexpedientes.label.valoresManuales.opcion1" />

                    </map:radio> <map:radio id="valoresManuales2" name="formGestionExped"
                        onclick="clickEnValoresManuales('N');"
                        property="valoresManuales" value="N">
                        <bean:message
                            key="rescate.gestionexpedientes.label.valoresManuales.opcion2" />

                    </map:radio> </span></DIV>

                    <DIV><span class="W55 I"> <bean:message
                        key="rescate.gestionexpedientes.label.totPagMapfre" />:

                    <map:radio id="totPagMafre1" name="formGestionExped"
                        property="totPagMapfre" value="1">
                        <bean:message
                            key="rescate.gestionexpedientes.label.totPagMapfre.opcion1" />

                    </map:radio> <map:radio id="totPagMafre2" name="formGestionExped"
                        property="totPagMapfre" value="2">
                        <bean:message
                            key="rescate.gestionexpedientes.label.totPagMapfre.opcion2" />

                    </map:radio> </span></DIV>


                </map:group-box>

                <!-- R&V CA Fase II CU011-COASEGURO - FIN -->



					<map:group-box layout="line"
						titleKey="rescate.gestionexpedientes.label.titulo.auxiliar.coaseguradoras"
						width="100%" colorLevel="2">
						<!-- INICIO MODIFICACION EVERIS -->
						<DIV>
						<span>
							<span class="W12 I"></span>
						</span>

						<span class="W12 I">

								<bean:message key="rescate.gestionexpedientes.label.codCoasegur1" />:

	 					</span>

	 					<span class="W12 I">
								<bean:message key="rescate.gestionexpedientes.label.codCoasegur2" />:

	 					</span>


						<span class="W12 I"> <bean:message key="rescate.gestionexpedientes.label.codCoasegur3" />:
	 						</span>

	 					<span class="W12 I">

								<bean:message key="rescate.gestionexpedientes.label.codCoasegur4" />:

	 						</span>

	 					<span class="W12 I">

								<bean:message key="rescate.gestionexpedientes.label.codCoasegur5" />:

	 					</span>

	 					<span class="W12 I">

								<bean:message key="rescate.gestionexpedientes.label.codCoasegur6" />:

	 						</span>

	 					<span class="W12 C"> <bean:message key="rescate.gestionexpedientes.label.tipRescate.opcion1" />
	 					 <br>
	 					 </span>

						</DIV>

						<DIV class="ContenidoSeparador"></DIV>

						<DIV>
						<span>
							<span class="W12 I"></span>
						</span>

                        <!-- R&V Correccion 03/08/2017-1-3 INI -->
                        <!-- R&V Se eliminan las continuas llamadas a recalculos y se canalizan las llamadas -->
                        <!-- R&V solo por onchange(recalculoCoaPorCambioDe) y onkeypress(pulsaEnter).        -->

						<!-- MU-2016-006664 - RAROALE - INI -->
						<span class="W12 I">
							<map:text size="6" name="formGestionExped" id="Coaseguradora1" maxlength="5"
							    onchange="recalculoCoaPorCambioDe('Coaseguradora1','1');" onkeypress="pulsaEnter(event,'Coaseguradora1','1');"
								tabindex="10" property="codCoasegur1" onkeyup="controlCamposCoa();" onblur="limpiaCoase(); sumaTotal(); ">
	 						</map:text>
	 					</span>
	 					<span class="W12 I">
	 						<map:text size="6" name="formGestionExped" id="Coaseguradora2" maxlength="5"
							    onchange="recalculoCoaPorCambioDe('Coaseguradora2','2');" onkeypress="pulsaEnter(event,'Coaseguradora2','2');"
								tabindex="10" property="codCoasegur2" onkeyup="controlCamposCoa();" onblur="limpiaCoase(); sumaTotal();">
	 						</map:text>
	 					</span>
						<span class="W12 I">
	 						<map:text size="6" name="formGestionExped" id="Coaseguradora3" maxlength="5"
							    onchange="recalculoCoaPorCambioDe('Coaseguradora3','3');" onkeypress="pulsaEnter(event,'Coaseguradora3','3');"
								tabindex="10" property="codCoasegur3" onkeyup="controlCamposCoa();" onblur="limpiaCoase(); sumaTotal();">
	 						</map:text>
	 					</span>
	 					<span class="W12 I">
	 						<map:text size="6" name="formGestionExped" id="Coaseguradora4" maxlength="5"
							    onchange="recalculoCoaPorCambioDe('Coaseguradora4','4');" onkeypress="pulsaEnter(event,'Coaseguradora4','4');"
								tabindex="10" property="codCoasegur4" onkeyup="controlCamposCoa();" onblur="limpiaCoase(); sumaTotal();">
	 						</map:text>
	 					</span>
	 					<span class="W12 I">
							<map:text size="6" name="formGestionExped" id="Coaseguradora5" maxlength="5"
							    onchange="recalculoCoaPorCambioDe('Coaseguradora5','5');" onkeypress="pulsaEnter(event,'Coaseguradora5','5');"
								tabindex="10" property="codCoasegur5" onkeyup="controlCamposCoa();" onblur="limpiaCoase(); sumaTotal();">
	 						</map:text>
	 					</span>
	 					<span class="W12 I">
	 						<map:text size="6" name="formGestionExped" id="Coaseguradora6" maxlength="5"
							    onchange="recalculoCoaPorCambioDe('Coaseguradora6','6');" onkeypress="pulsaEnter(event,'Coaseguradora6','6');"
								tabindex="10" property="codCoasegur6" onkeyup="controlCamposCoa();" onblur="limpiaCoase(); sumaTotal();">
	 						</map:text>
	 					</span>
	 					<span class="W12 I"> </span>
	 					<!-- MU-2016-006664 - RAROALE - FIN -->

						</DIV>
						<DIV class="ContenidoSeparador"></DIV>
						<DIV><span>
							<span class="W12 I">
								<bean:message key="rescate.gestionexpedientes.label.porcent" />
							</span>
						</span>

						<%-- MU-2016-006664 - RAROALE - INI--%>
						<span class="W12 I">
							<map:text size="12" name="formGestionExped"
								id="Porcentaje1" maxlength="5" tabindex="12" disabled="true"
								onchange="recalculoCoaPorCambioDe('Porcentaje1','1');"
								property="porCoasegur1"
								onkeypress="pulsaEnter(event,'Porcentaje1','1'); pulsada(event,catImporte,this); validaPermitidos(event,'DECIMAL',this.value);" onblur="javascript: validarImporteDecRanInc(this,'2','100','-100');">
							</map:text>
						</span>
						<span class="W12 I">
							<map:text size="12" name="formGestionExped"
								id="Porcentaje2" maxlength="5" tabindex="12" disabled="true"
								onchange="recalculoCoaPorCambioDe('Porcentaje2','2');"
								property="porCoasegur2"
								onkeypress="pulsaEnter(event,'Porcentaje2','2'); pulsada(event,catImporte,this); validaPermitidos(event,'DECIMAL',this.value);" onblur="javascript: validarImporteDecRanInc(this,'2','100','-100');">
							</map:text>
						</span>
						<span class="W12 I">
							<map:text size="12" name="formGestionExped"
								id="Porcentaje3" maxlength="5" tabindex="12" disabled="true"
								onchange="recalculoCoaPorCambioDe('Porcentaje3','3');"
								property="porCoasegur3"
								onkeypress="pulsaEnter(event,'Porcentaje3','3'); pulsada(event,catImporte,this); validaPermitidos(event,'DECIMAL',this.value);" onblur="javascript: validarImporteDecRanInc(this,'2','100','-100');">
							</map:text>
						</span>
						<span class="W12 I">
							<map:text size="12" name="formGestionExped"
								id="Porcentaje4" maxlength="5" tabindex="12" disabled="true"
								onchange="recalculoCoaPorCambioDe('Porcentaje4','4');"
								property="porCoasegur4"
								onkeypress="pulsaEnter(event,'Porcentaje4','4'); pulsada(event,catImporte,this); validaPermitidos(event,'DECIMAL',this.value);" onblur="javascript: validarImporteDecRanInc(this,'2','100','-100');">
							</map:text>
						</span>
						<span class="W12 I">
							<map:text size="12" name="formGestionExped"
								id="Porcentaje5" maxlength="5" tabindex="12" disabled="true"
								onchange="recalculoCoaPorCambioDe('Porcentaje5','5');"
								property="porCoasegur5"
								onkeypress="pulsaEnter(event,'Porcentaje5','5'); pulsada(event,catImporte,this); validaPermitidos(event,'DECIMAL',this.value);" onblur="javascript: validarImporteDecRanInc(this,'2','100','-100');">
							</map:text>
						</span>
						<span class="W12 I">
							<map:text size="12" name="formGestionExped"
								id="Porcentaje6" maxlength="5" tabindex="12" disabled="true"
								onchange="recalculoCoaPorCambioDe('Porcentaje6','6');"
								property="porCoasegur6"
								onkeypress="pulsaEnter(event,'Porcentaje6','6'); pulsada(event,catImporte,this); validaPermitidos(event,'DECIMAL',this.value);" onblur="javascript: validarImporteDecRanInc(this,'2','100','-100');">
							</map:text>
						</span>
						<span class="W12 I">
							<map:text size="12" name="formGestionExped"
								id="PorcentajeTot" maxlength="5" tabindex="12"
								onkeyup= "calculoCodImportes('I'); sumaTotal();" onchange="limpiaCoase();">
							</map:text>
						</span>
						<%-- MU-2016-006664 - RAROALE - FIN--%>
                        <!-- R&V - Marzo 2018 - Cambio calculoCodImportes('P') -> calculoCodImportes('I') - FIN -->
						</DIV>

						<DIV class="ContenidoSeparador"></DIV>
						<DIV>
						<span class="W12 I">
								<bean:message
									key="rescate.gestionexpedientes.label.importe" />

						</span>

						<!-- MU-2016-006664 - RAROALE - INI -->
						<span class="W12 I">
							<map:text size="12" name="formGestionExped"
								id="Coasegur1_2" maxlength="15" tabindex="12" disabled="true"
								onchange="recalculoCoaPorCambioDe('Coasegur1_2','1');"
								property="impCoasegur1"
								onkeypress="pulsaEnter(event,'Coasegur1_2','1'); pulsada(event,catImporte,this); validaPermitidos(event,'DECIMAL',this.value);" onblur="javascript: validarImporte2Dec(this,'2','100000000000','-100000000000');">
							</map:text>
						</span>
						<span class="W12 I">
							<map:text size="12" name="formGestionExped"
								id="Coasegur2_2" maxlength="15" tabindex="12" disabled="true"
								onchange="recalculoCoaPorCambioDe('Coasegur2_2','2');"
								property="impCoasegur2"
								onkeypress="pulsaEnter(event,'Coasegur2_2','2'); pulsada(event,catImporte,this); validaPermitidos(event,'DECIMAL',this.value);" onblur="javascript: validarImporte2Dec(this,'2','100000000000','-100000000000');">
							</map:text>
						</span>
						<span class="W12 I">
							<map:text size="12" name="formGestionExped"
								id="Coasegur3_2" maxlength="15" tabindex="12" disabled="true"
								onchange="recalculoCoaPorCambioDe('Coasegur3_2','3');"
								property="impCoasegur3"
								onkeypress="pulsaEnter(event,'Coasegur3_2','3'); pulsada(event,catImporte,this); validaPermitidos(event,'DECIMAL',this.value);" onblur="javascript: validarImporte2Dec(this,'2','100000000000','-100000000000');">
							</map:text>
						</span>
						<span class="W12 I">
							<map:text size="12" name="formGestionExped"
								id="Coasegur4_2" maxlength="15" tabindex="12" disabled="true"
								onchange="recalculoCoaPorCambioDe('Coasegur4_2','4');"
								property="impCoasegur4"
								onkeypress="pulsaEnter(event,'Coasegur4_2','4'); pulsada(event,catImporte,this); validaPermitidos(event,'DECIMAL',this.value);" onblur="javascript: validarImporte2Dec(this,'2','100000000000','-100000000000');">
							</map:text>
						</span>
						<span class="W12 I">
							<map:text size="12" name="formGestionExped"
								id="Coasegur5_2" maxlength="15" tabindex="12" disabled="true"
								onchange="recalculoCoaPorCambioDe('Coasegur5_2','5');"
								property="impCoasegur5"
								onkeypress="pulsaEnter(event,'Coasegur5_2','5'); pulsada(event,catImporte,this); validaPermitidos(event,'DECIMAL',this.value);" onblur="javascript: validarImporte2Dec(this,'2','100000000000','-100000000000');">
							</map:text>
						</span>
						<span class="W12 I">
							<map:text size="12" name="formGestionExped"
								id="Coasegur6_2" maxlength="15" tabindex="12" disabled="true"
								onchange="recalculoCoaPorCambioDe('Coasegur6_2','6');"
								property="impCoasegur6"
								onkeypress="pulsaEnter(event,'Coasegur6_2','6'); pulsada(event,catImporte,this); validaPermitidos(event,'DECIMAL',this.value);" onblur="javascript: validarImporte2Dec(this,'2','100000000000','-100000000000');">
							</map:text>
						</span>
						<!-- MU-2016-006664 - RAROALE - FIN -->

                        <!-- R&V Correccion 03/08/2017-1-3 FIN -->

						<span class="W12 I"> <map:text size="12" name="formGestionExped"
							id="CoasegurTot_2" maxlength="5" tabindex="12"
							disabled="true">

						</map:text> </span>

						</DIV>
						<DIV class="ContenidoSeparador"></DIV>
						<DIV>
						<span class="W12 I">
								<bean:message
									key="rescate.gestionexpedientes.label.rtoIntegro" />

						</span>

                        <!-- R&V CA Fase II CU011-COASEGURO - INI -->
                        <!-- R&V Incorporamos onchange y onkeypress para dar funcionalidad al radio Valores Manuales -->
                        <!-- R&V Afectará unicamente para el caso de la suma de totales si manual -->
                        <!-- R&V También se cambian los maxlength de 5 a 15 -->

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="rtoIntegroCoa1"
							id="Coasegur1_3" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur1_3','1');" onkeypress="pulsaEnter(event,'Coasegur1_3','1');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="rtoIntegroCoa2"
							id="Coasegur2_3" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur2_3','2');" onkeypress="pulsaEnter(event,'Coasegur2_3','2');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="rtoIntegroCoa3"
							id="Coasegur3_3" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur3_3','3');" onkeypress="pulsaEnter(event,'Coasegur3_3','3');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="rtoIntegroCoa4"
							id="Coasegur4_3" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur4_3','4');" onkeypress="pulsaEnter(event,'Coasegur4_3','4');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="rtoIntegroCoa5"
							id="Coasegur5_3" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur5_3','5');" onkeypress="pulsaEnter(event,'Coasegur5_3','5');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="rtoIntegroCoa6"
							id="Coasegur6_3" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur6_3','6');" onkeypress="pulsaEnter(event,'Coasegur6_3','6');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped"
							id="CoasegurTot_3" maxlength="15" tabindex="12"
							disabled="true">

						</map:text> </span>

						</DIV>
						<DIV class="ContenidoSeparador"></DIV>
						<DIV>
						<span class="W12 I">
								<bean:message
									key="rescate.gestionexpedientes.label.redPrimas" />
						</span>


						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="redPrimasCoa1"
							id="Coasegur1_4" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur1_4','1');" onkeypress="pulsaEnter(event,'Coasegur1_4','1');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="redPrimasCoa2"
							id="Coasegur2_4" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur2_4','2');" onkeypress="pulsaEnter(event,'Coasegur2_4','2');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="redPrimasCoa3"
							id="Coasegur3_4" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur3_4','3');" onkeypress="pulsaEnter(event,'Coasegur3_4','3');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="redPrimasCoa4"
							id="Coasegur4_4" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur4_4','4');" onkeypress="pulsaEnter(event,'Coasegur4_4','4');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="redPrimasCoa5"
							id="Coasegur5_4" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur5_4','5');" onkeypress="pulsaEnter(event,'Coasegur5_4','5');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="redPrimasCoa6"
							id="Coasegur6_4" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur6_4','6');" onkeypress="pulsaEnter(event,'Coasegur6_4','6');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped"
							id="CoasegurTot_4" maxlength="15" tabindex="12"
							disabled="true">

						</map:text> </span>

						</DIV>
						<DIV class="ContenidoSeparador"></DIV>
						<DIV>
						<span class="W12 I">
								<bean:message
									key="rescate.gestionexpedientes.label.redTransitoria" />
						</span>


						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="redTransitoriaCoa1"
							id="Coasegur1_5" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur1_5','1');" onkeypress="pulsaEnter(event,'Coasegur1_5','1');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="redTransitoriaCoa2"
							id="Coasegur2_5" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur2_5','2');" onkeypress="pulsaEnter(event,'Coasegur2_5','2');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="redTransitoriaCoa3"
							id="Coasegur3_5" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur3_5','3');" onkeypress="pulsaEnter(event,'Coasegur3_5','3');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="redTransitoriaCoa4"
							id="Coasegur4_5" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur4_5','4');" onkeypress="pulsaEnter(event,'Coasegur4_5','4');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="redTransitoriaCoa5"
							id="Coasegur5_5" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur5_5','5');" onkeypress="pulsaEnter(event,'Coasegur5_5','5');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="redTransitoriaCoa6"
							id="Coasegur6_5" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur6_5','6');" onkeypress="pulsaEnter(event,'Coasegur6_5','6');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped"
							id="CoasegurTot_5" maxlength="15" tabindex="12"
							disabled="true">

						</map:text> </span>

						</DIV>
						<DIV class="ContenidoSeparador"></DIV>
						<DIV>
						<span class="W12 I">
								<bean:message
									key="rescate.gestionexpedientes.label.rtoNeto" />
						</span>


						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="rtoNetoCoa1"
							id="Coasegur1_6" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur1_6','1');" onkeypress="pulsaEnter(event,'Coasegur1_6','1');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="rtoNetoCoa2"
							id="Coasegur2_6" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur2_6','2');" onkeypress="pulsaEnter(event,'Coasegur2_6','2');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="rtoNetoCoa3"
							id="Coasegur3_6" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur3_6','3');" onkeypress="pulsaEnter(event,'Coasegur3_6','3');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="rtoNetoCoa4"
							id="Coasegur4_6" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur4_6','4');" onkeypress="pulsaEnter(event,'Coasegur4_6','4');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="rtoNetoCoa5"
							id="Coasegur5_6" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur5_6','5');" onkeypress="pulsaEnter(event,'Coasegur5_6','5');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="rtoNetoCoa6"
							id="Coasegur6_6" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur6_6','6');" onkeypress="pulsaEnter(event,'Coasegur6_6','6');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped"
							id="CoasegurTot_6" maxlength="15" tabindex="12"
							disabled="true">

						</map:text> </span>

						</DIV>
						<DIV class="ContenidoSeparador"></DIV>
						<DIV>
						<span class="W12 I">
								<bean:message
									key="rescate.gestionexpedientes.label.retencion" />
						</span>


						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="retencionCoa1"
							id="Coasegur1_7" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur1_7','1');" onkeypress="pulsaEnter(event,'Coasegur1_7','1');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="retencionCoa2"
							id="Coasegur2_7" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur2_7','2');" onkeypress="pulsaEnter(event,'Coasegur2_7','2');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="retencionCoa3"
							id="Coasegur3_7" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur3_7','3');" onkeypress="pulsaEnter(event,'Coasegur3_7','3');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="retencionCoa4"
							id="Coasegur4_7" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur4_7','4');" onkeypress="pulsaEnter(event,'Coasegur4_7','4');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="retencionCoa5"
							id="Coasegur5_7" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur5_7','5');" onkeypress="pulsaEnter(event,'Coasegur5_7','5');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="retencionCoa6"
							id="Coasegur6_7" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur6_7','6');" onkeypress="pulsaEnter(event,'Coasegur6_7','6');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped"
							id="CoasegurTot_7" maxlength="15" tabindex="12"
							disabled="true">

						</map:text> </span>

						</DIV>
						<DIV class="ContenidoSeparador"></DIV>
						<DIV>
						<span class="W12 I">
						<bean:message
									key="rescate.gestionexpedientes.label.compen" />

						</span>


						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="compenCoa1"
							id="Coasegur1_8" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur1_8','1');" onkeypress="pulsaEnter(event,'Coasegur1_8','1');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="compenCoa2"
							id="Coasegur2_8" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur2_8','2');" onkeypress="pulsaEnter(event,'Coasegur2_8','2');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="compenCoa3"
							id="Coasegur3_8" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur3_8','3');" onkeypress="pulsaEnter(event,'Coasegur3_8','3');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="compenCoa4"
							id="Coasegur4_8" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur4_8','4');" onkeypress="pulsaEnter(event,'Coasegur4_8','4');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="compenCoa5"
							id="Coasegur5_8" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur5_8','5');" onkeypress="pulsaEnter(event,'Coasegur5_8','5');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped" property="compenCoa6"
							id="Coasegur6_8" maxlength="15" tabindex="12"
							onchange="recalculoCoaPorCambioDe('Coasegur6_8','6');" onkeypress="pulsaEnter(event,'Coasegur6_8','6');"
							disabled="true">

						</map:text> </span>

						<span class="W12 I"> <map:text size="12" name="formGestionExped"
							id="CoasegurTot_8" maxlength="15" tabindex="12"
							disabled="true">

						</map:text> </span>

						</DIV>

                        <!-- R&V CA Fase II CU011-COASEGURO - FIN -->


						<!-- FIN MODIFICACION EVERIS -->

					</map:group-box>


				</map:pane-content>
			</map:pane>

<!-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  R&V Junio 2017 - CU011 - everis(RGL) - FIN  -->
		</map:tabbed-pane>
		
		<input id="kPersonaPri" type="hidden" name="kPersonaPri" />
		<%-- MU-2016-006673 - RAROALE - INI--%>
		<input id="kDomicilioPri" type="hidden" name="kDomicilioPri"/>
		<input id="fmodificacion" type="hidden" name="fmodificacion"/>
		<%-- MU-2016-006673 - RAROALE - FIN--%>
		<input id="sBDGICap" type="hidden" name="sBDGICap" />
		<input id="sBDGIComp" type="hidden" name="sBDGIComp" />
		<input id="sBDGIComp2" type="hidden" name="sBDGIComp2" />
		<input
			type="hidden" name="tipOperacion" />
		<input type="hidden" name="pestanaJSP" />
		 
	</html:form> 
	
<!-- 
	<DIV class="D MInf"><span id="BOTONES1" >
		<map:contextualButton name="Aceptar" title="Aceptar"
			onclick="enviarFormulario();"><bean:message key="rescate.jsp.aceptar"/></map:contextualButton> <map:contextualButton
			name="Cancelar" title="Cancelar" onclick="cancelarFormulario();"><bean:message key="rescate.jsp.cancelar"/></map:contextualButton>
		</span></DIV>
		
 -->			
</map:body>
</html>

