<%--
Descripcion : JSP de busqueda de Expedientes Listado en Vencimiento
Programador : EVERIS
Fecha : 06/2011
 Version : 1.0
--%>

<%@page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@taglib uri="/WEB-INF/struts-tiles.tld" prefix="tiles"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/maptags.tld" prefix="map"%>
<map:alertSupport />
<%@page import="java.util.List"%>
<html>

	<%@ page
	import="com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J001BusquedaExpVenActionForm"%>
	<%@ page
	import="com.mapfre.mavisa.wss372vencimientosmanuales.utils.Msg"%>

<%	final J372J001BusquedaExpVenActionForm formBusquedaExp = (J372J001BusquedaExpVenActionForm) 
							request.getAttribute("formBusquedaExp");
				
	final List vectorMensajes = formBusquedaExp.getVectorMensajes();
%>

<head>

<title><bean:message key="rescate.jsp.busqueda"/></title>

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

<script src="<bean:write name="HTTP_PATH"/>/js/t00830.js"></script>
<%--Idiomas--%>
<script src="<bean:write name="HTTP_PATH"/>/js/t00013.js"></script>
<script src="<bean:write name="HTTP_PATH"/>/js/comun.js"
	language="JavaScript" type="text/JavaScript"></script>
<script src="<bean:write name="HTTP_PATH"/>/js/generales.js"
	language="JavaScript" type="text/JavaScript"></script>
<script src="<bean:write name="HTTP_PATH"/>/js/validaciones.js"
	language="JavaScript" type="text/JavaScript"></script>
<script src="<bean:write name="HTTP_PATH"/>/js/customtag.js"
	language="JavaScript" type="text/JavaScript"></script>
<script src="<bean:write name="HTTP_PATH"/>/js/customtag-validations.js"
	language="JavaScript" type="text/JavaScript"></script>
<script src="<bean:write name="HTTP_PATH"/>/js/ValidacionesPantallas.js"
	language="JavaScript" type="text/JavaScript"></script>

<script type="text/javascript">

 <%-- CargaInicial() se llama al realizar una carga de la pagina, teniendo en cuenta dos variable y tipOperacion
   para conocer su estado y tener un comportamiento inicial u otro.--%>
   
   function cargaInicial() {
   		
   		 <%--Si hay mensajes se muestran--%>
   		
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
			
		if (document.forms[0].checked == null){
			
			document.getElementById("rdAnioExp").checked='true';
			
		}
	}

var tipoOperacion = "";
<%--Accion botonbuscar	--%>
function enviarFormulario(){
		
		var form = document.forms['formBusquedaExp'];
		var errors = validateForm(form);		
		if(errors.length > 0) {
			return;
		}
		var objeto = new Object();
	
	objeto.ventana = window;
	objeto.nombre = "ventanaEmergente1";
	
	var anio = document.getElementById("Anio").value;
	var operacion = document.forms[0].checked; 
	var poliza = document.getElementById("Poliza").value;
	var expediente = document.getElementById("Expediente").value;
	var nifCif = document.getElementById("NifCif").value; 
	
	abrirVentana(String('/WSS372VENCIMIENTOSMANUALES/busquedaExpFormVen.do?tipOperacion=INICIO&anio=' + anio + '&operacion=' + operacion + '&poliza=' + poliza + '&expediente=' + expediente + '&nifCif=' + nifCif),objeto,"dialogwidth=750px;dialogheight=600px;dialogLeft=80px;dialogTop=30px;help=no;status=no");
	}
	
	<%--Funcion para pasar los valores de la pantalla hija a la padre, 
	es decir le pasamos valores del listado a gestion expediente --%>
	  function pasarValoresGestExp(busqueda){
		
		window.dialogArguments.ventana.pasarValoresGestExp(busqueda);
		window.close();
	}
	
	
<%--OCULTA/MUESTRA LA CAPA año, expediente, poliza, nif/cif, cuando  selecciones radiobutton--%>
	
function rdAnioExpFormulario()
{   
     document.getElementById('anio').value = '';
     document.getElementById('expediente').value = '';
     document.getElementById('poliza').value = '';
     document.getElementById('nifCif').value = '';

    
     
     
   if (document.forms[0].checked = "CI")
    
   {
   		document.getElementById("datosAnioExp").style.display="block";
   		document.getElementById("datosPoliza").style.display="none";
		document.getElementById("datosNifCif").style.display="none";
		 document.getElementById("rdPoliza").checked='false';
     	document.getElementById("rdNifCif").checked='false';
     	document.getElementById("rdAnioExp").checked='true';
   	}
  return true; 
  }
   
function rdPolizaFormulario()
{   
     document.getElementById('anio').value = '';
     document.getElementById('expediente').value = '';
     document.getElementById('poliza').value = '';
     document.getElementById('nifCif').value = '';
     
     
     
   if (document.forms[0].checked = "LP")
   {
   
 		document.getElementById("datosAnioExp").style.display="none";
		document.getElementById("datosPoliza").style.display="block";  
		document.getElementById("datosNifCif").style.display="none";
		document.getElementById("rdAnioExp").checked='false';
     document.getElementById("rdNifCif").checked='false';
     document.getElementById("rdPoliza").checked='true';
   	}
  return true; 
  }
function rdNifCifFormulario()
{   
     document.getElementById('anio').value = '';
     document.getElementById('expediente').value = '';
     document.getElementById('poliza').value = '';
     document.getElementById('nifCif').value = '';
      
     
   if (document.forms[0].checked = "LN")
   {
   		document.getElementById("datosAnioExp").style.display="none";
		document.getElementById("datosPoliza").style.display="none";  
		document.getElementById("datosNifCif").style.display="block";
		document.getElementById("rdPoliza").checked='false';
     document.getElementById("rdAnioExp").checked='false';
      document.getElementById("rdNifCif").checked='true';
   	}
  return true; 
  }

	</script>

</head>

<map:body transition="auto" style="version1.0" onLoad="cargaInicial();">

	<html:form action="busquedaExpFormVen">

		<div id="Contenido">
		<div id="CCOL"><label id="TC"><bean:message
			key="rescate.BusquedaExp.label.titulo.principal" /></label></div>
		<br>
		<map:group-box width="100%">
			<DIV><span class="W15 I" style="color: blue;"><bean:message
				key="rescate.BusquedaExp.label.tituloAux" /></span></DIV>
			<br>
			<DIV><span class="W20 I"> <map:radio value="CI" property="operacion"
				title="rdAnioExp" id="rdAnioExp" onclick="rdAnioExpFormulario();"><bean:message key="rescate.jsp.anio"/></map:radio>
			</span></DIV>
			<br>
			<DIV><span class="W15 I"> <map:radio value="LP" property="operacion"
				title="rdPoliza" id="rdPoliza" onclick="rdPolizaFormulario();"><bean:message key="rescate.jsp.poliza"/></map:radio>
			</span></DIV>
			<br>
			<DIV><span class="W15 I"> <map:radio value="LN" property="operacion"
				title="rdNifCif" id="rdNifCif" onclick="rdNifCifFormulario();"><bean:message key="rescate.jsp.nif"/></map:radio>
			</span></D201IV>
			<br>
			<DIV id="datosAnioExp"><span><bean:message
				key="rescate.BusquedaExp.label.anio" />:&nbsp;</span> 
				<bean:define id="litAnio" type="String"><bean:message key="rescate.BusquedaExp.label.anio"/></bean:define>
				<map:text size="6" name="formBusquedaExp" id="Anio" maxlength="4" tabindex="10"
				property="anio">
	 		 <%--  Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion--%>
	 		 	<map:validation rule="integer">
			  	<bean:message key="rescate.error.numerico" arg0="<%=litAnio%>"/>
	 		</map:validation>	
	 		<map:validation rule = "intRange(0,9999)">
			  	<bean:message key="rescate.error.rango" arg0="<%=litAnio%>"/>
	 		</map:validation>
			</map:text> <span><bean:message
				key="rescate.BusquedaExp.label.expediente" />:&nbsp;</span> 
				<bean:define id="litExpediente" type="String"><bean:message key="rescate.BusquedaExp.label.expediente"/></bean:define>
				<map:text size="11" name="formBusquedaExp" id="Expediente" maxlength="10"
				tabindex="15" property="expediente">
				<%--  Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
	 		 	<map:validation rule="integer">
			  	<bean:message key="rescate.error.numerico" arg0="<%=litExpediente%>"/>
	 		</map:validation>
				</map:text></DIV> 
			<DIV id="datosPoliza" style="display:none"><span><bean:message
				key="rescate.BusquedaExp.label.poliza" />:&nbsp;</span> 
				<bean:define id="litPoliza" type="String"><bean:message key="rescate.BusquedaExp.label.poliza"/></bean:define>
				<map:text size="11"	name="formBusquedaExp" id="Poliza" maxlength="10" tabindex="20"
				property="poliza">
				 <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
	 		 	<map:validation rule="integer">
			  	<bean:message key="rescate.error.numerico" arg0="<%=litPoliza%>"/>
	 		</map:validation>
				</map:text></DIV>

			<DIV id="datosnifCif" style="display:none"><span><bean:message
				key="rescate.BusquedaExp.label.nifCif" />:&nbsp;</span> <map:text size="11"
				name="formBusquedaExp" id="NifCif" maxlength="10" tabindex="25"
				property="nifCif">
			</map:text>
			</DIV>

			<br>
		</map:group-box> <br>
		<br>
		<div><span class="W60 C"> <span><input type="hidden"
			name="tipOperacion" /> <map:contextualButton name="Buscar"
			title="Buscar" onclick="enviarFormulario();"><bean:message key="rescate.jsp.buscar"/></map:contextualButton>
		</span>
		<span> <input type="hidden"
			name="tipOperacion" /> <map:contextualButton name="Volver"
			title="Volver" onclick="window.close();"><bean:message key="rescate.jsp.volver"/></map:contextualButton>
		</span></span></div>
		</div>
	</html:form>
</map:body>
</html>

