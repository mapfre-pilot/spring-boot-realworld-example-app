<%--
Descripcion : JSP de peticición BDGI en Vencimientos
Programador : EVERIS
Fecha : 06/2011
 Version : 1.0
--%>

<%@page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@taglib uri="/WEB-INF/struts-tiles.tld" prefix="tiles"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/maptags.tld" prefix="map" %>
<map:alertSupport/>
<%@page import="java.util.List"%>
<html>
	<%@ page
	import="com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J006PeticionBDGIVenActionForm"%>
	<%@ page
	import="com.mapfre.mavisa.wss372vencimientosmanuales.utils.Msg"%>

<% final J372J006PeticionBDGIVenActionForm formPeticionBDGI = 
(J372J006PeticionBDGIVenActionForm) request.getAttribute ("formPeticionBDGI");

	final List vectorMensajes = formPeticionBDGI.getVectorMensajes();
%>

<head>
<title><bean:message key="rescate.jsp.peticion"/></title>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta name="GENERATOR" content="Rational Software Architect">	
	<link rel="stylesheet" type="text/css" href="<bean:write name="HTTP_PATH"/>/css/contenedor.css">
	<link rel="stylesheet" type="text/css" href="<bean:write name="HTTP_PATH"/>/css/agrupacion.css"/>
	<link rel="stylesheet" type="text/css" href="<bean:write name="HTTP_PATH"/>/css/estilomapfre.css"/>
	
	<link rel="stylesheet" type="text/css" href="<bean:write name="HTTP_PATH"/>/css/comun.css"/>
	<link rel="stylesheet" type="text/css" href="<bean:write name="HTTP_PATH"/>/css/contenedor.css">

	<script src="<bean:write name="HTTP_PATH"/>/js/t00830.js"></script><%--Idiomas--%>
	<script src="<bean:write name="HTTP_PATH"/>/js/t00013.js"></script>
	<script src="<bean:write name="HTTP_PATH"/>/js/comun.js"        language="JavaScript" type="text/JavaScript"></script>
	<script src="<bean:write name="HTTP_PATH"/>/js/generales.js"    language="JavaScript" type="text/JavaScript"></script>
	<script src="<bean:write name="HTTP_PATH"/>/js/validaciones.js" language="JavaScript" type="text/JavaScript"></script>
	<script src="<bean:write name="HTTP_PATH"/>/js/customtag.js" language="JavaScript" type="text/JavaScript"></script>
	<script src="<bean:write name="HTTP_PATH"/>/js/customtag-validations.js" language="JavaScript" type="text/JavaScript"></script>
	
	<script type="text/javascript">

<%-- CargaInicial() se llama al realizar una carga de la pagina, teniendo en cuenta dos variable y tipOperacion
   para conocer su estado y tener un comportamiento inicial u otro.--%>
   
   function cargaInicial() {
   		
   		<%-- Si hay mensajes se muestran--%>
   		
   		<% 	   		
   	if ((vectorMensajes != null) && (vectorMensajes.size()>0))
		{ 
			Msg mensaje;
			String stTipo="";
			String descripcion="";
			mensaje = (Msg)vectorMensajes.get(0);
			
			if (mensaje!=null) {
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
	}
	function aceptarFormulario(){
		var form= document.forms['formPeticionBDGI'];
		var errors = validateForm(form);		
		if(errors.length > 0) {
			return;
		}
		
		validarFecha();
		if (isFecha) {
			document.forms[0].elements['tipOperacion'].value ='AC';
			document.forms[0].submit();
		} else {
			ctInfo('Ejercicio de devengo no puede tener más de 10 años de antiguedad');
		}			
	}
	
	function validarFecha(){
		var anio= document.forms[0].elements['anio'].value;	 
		var mes= document.forms[0].elements['mes'].value;
		var fecha2 = new Date();
		var dia= fecha2.getDate();
		var valor = mes+"/"+dia+"/"+anio;
		var fecha1 = new Date(valor);
			
		var fechaResta = fecha2 - fecha1;
		
		fechaResta = ((((fechaResta/1000)/60)/60)/24)/365;
		
		if (fechaResta > 10.01) {
			isFecha= false;
		} else {
			isFecha= true;
		}
	}

	</script>
<style type="text/css">
Relleno { height: 100%}
 </style>
</head>

<map:body transition="auto" style="version1.0" onLoad="cargaInicial();">
	<html:form action="peticionBDGIVen"  >
<div id="Contenido">

<div id="CCOL">

 <label id="TC"><bean:message key="rescate.peticionBDGI.label.titulo.principal"/></label>

</div>

<map:group-box layout="line" titleKey="rescate.peticionBDGI.label.titulo.auxiliar" width="100%">
	<DIV>
			<span class="W15 I"><bean:message key="rescate.peticionBDGI.label.anio"/>:</span>
	 		<bean:define id="litAnio" type="String"><bean:message key="rescate.peticionBDGI.label.anio"/></bean:define>
	 		<map:text size="6" id="formPeticionBDGI" maxlength="4" tabindex="5" property="anio">
	 		<map:validation rule="required">
	 		 <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
			  	<bean:message key="rescate.error.obligatorio" arg0="<%=litAnio%>"/>
	 		</map:validation>
	 		<map:validation rule="integer">
			  	<bean:message key="rescate.error.numerico" arg0="<%=litAnio%>"/>
	 		</map:validation>	
	 		<map:validation rule = "intRange(0,9999)">
			  	<bean:message key="rescate.error.rango" arg0="<%=litAnio%>"/>
	 		</map:validation></map:text>
			
			
		   <span class="W15 D"><bean:message key="rescate.peticionBDGI.label.mes" />:</span>
		   <bean:define id="litPeticionBDGI" type="String"><bean:message key="rescate.peticionBDGI.label.mes"/></bean:define>
		   	<map:select showcode="false" property="mes" tabindex="10">
		   	<map:defaultOption><bean:message key="rescate.desplegable.default"/></map:defaultOption>
			  <map:optionsCollection label="prop1" value="prop2" property="mesCombo" />
			  <map:validation rule="required">
			 <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
			  	<bean:message key="rescate.error.obligatorio" arg0="<%=litPeticionBDGI%>"/>
			  </map:validation>			  
			</map:select>	
	</DIV>
	<br>	
	<DIV>
		<span class="W15 I"><bean:message key="rescate.peticionBDGI.label.fecInicio"/>:</span>
		<map:date  name="fecInicio" tabindex="15" srcName="formPeticionBDGI" srcProperty="fecInicio" srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" calendar="true"></map:date>
   
		<span class="W15 D"><bean:message key="rescate.peticionBDGI.label.fecFin"/>:</span>
		<map:date  name="fecFin"  tabindex="20" srcName="formPeticionBDGI" srcProperty="fecFin" srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" calendar="true"></map:date>
    </DIV>
	
	
</map:group-box>
</div>
	<DIV id="BA" class="MInf">
		<div class ="W100 I" id="botones1">
		<span class="W100 D">
		<input type="hidden" name="tipOperacion"/>
		<map:button name="Aceptar" title="Aceptar" onclick="aceptarFormulario();" ><bean:message key="rescate.jsp.aceptar"/></map:button>			
		</span>
		</div>	
	</DIV>
	
</html:form>
</map:body>
</html>
