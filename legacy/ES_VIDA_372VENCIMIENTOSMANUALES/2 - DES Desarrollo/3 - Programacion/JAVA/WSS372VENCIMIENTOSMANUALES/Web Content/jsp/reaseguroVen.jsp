<%--
Descripcion : JSP reaseguro en Vencimientos
Programador : EVERIS
Fecha : 06/2011
 Version : 1.0
--%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-tiles.tld" prefix="tiles" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/maptags.tld" prefix="map" %>
<map:alertSupport/>

<%@page import="java.util.List"%>
<html>

	<%@ page
	import="com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J007ReaseguroVenActionForm"%>
	<%@ page
	import="com.mapfre.mavisa.wss372vencimientosmanuales.utils.Msg"%>


<%	
final J372J007ReaseguroVenActionForm formReaseguro = 
	(J372J007ReaseguroVenActionForm) request.getAttribute("formReaseguro");
				
	final List vectorMensajes = formReaseguro.getVectorMensajes();
				
%>

<head>
<title><bean:message key="rescate.jsp.reaseguro"/></title>
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
		var form= document.forms['formReaseguro'];
		var errors = validateForm(form);		
		if(errors.length > 0) {
			return;
		}
		document.forms[0].elements['operacion'].value ='M3';
		document.forms[0].submit();		
	}

	</script>
<style type="text/css">
Relleno { height: 100%}
 </style>
</head>

<map:body transition="auto" style="version1.0" onLoad="cargaInicial()">
	<html:form action="reaseguroVen"  >
<div id="Contenido">

<div id="CCOL">

 <label id="TC"><bean:message key="rescate.reaseguro.label.titulo.principal"/></label>

</div>

<map:group-box layout="line" titleKey="rescate.reaseguro.label.titulo.auxiliar" width="100%">
	<br>
	<DIV>
		<span class="W60 I">
		<input type="hidden" name="operacion"/>		
		<map:contextualButton name="Aceptar" title="Aceptar"  onclick="aceptarFormulario();"><bean:message key="rescate.reaseguro.label.aceptar"/></map:contextualButton>			
		</span>	
	</DIV>
	<br>
</map:group-box>
<div class="Relleno" >
</div>
</div>
	
	
</html:form>
</map:body>
</html>

<!-- Tratamiento Mensajes -->		

