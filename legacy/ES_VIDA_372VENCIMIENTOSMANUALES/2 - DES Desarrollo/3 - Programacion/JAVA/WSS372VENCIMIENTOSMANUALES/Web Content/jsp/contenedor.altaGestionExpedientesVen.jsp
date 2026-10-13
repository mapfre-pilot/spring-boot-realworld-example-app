<%--
Descripcion : JSP de la pantalla de Gestión de Expedientes de Vencimientos
Programador : EVERIS
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


<html>

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

<script type="text/javascript">  

 
	
	<%--Funcionalidad al cancelar un alta--%>
	function cancelarFormulario() {
		
		var form = document.forms['formGestionExped'];
		form.action = 'inicioBusquedaExpVen.do';
		form.submit();
	}
  </script>
</head>

<map:body transition="auto" style="version1.0" >
	
		

		<div id="CCOL"><label id="TC"><bean:message
			key="rescate.gestionexpedientes.label.titulo.principal" /></label> <BR>
		<BR>
		</div> 
		<html:form action="gestionExpedientesVen">
		<input type="hidden"
			name="anio" id="AnioHidden" />
		</html:form>
		
		<ifRAME height="89%;" id="gestionExpedientes"  src="/WSS372VENCIMIENTOSMANUALES/gestionExpedientesVen.do?parametro=inicio" scrolling="yes" style="overflow: hidden"
				frameborder="0">
 	</ifRAME>
		
		
		<DIV class="D MInf"><span id="BOTONES1">
		<map:contextualButton name="Aceptar" title="Aceptar"
			onclick="document.frames.frames[0].enviarFormulario();"><bean:message key="rescate.jsp.aceptar"/></map:contextualButton> <map:contextualButton
			name="Cancelar" title="Cancelar" onclick="cancelarFormulario();"><bean:message key="rescate.jsp.cancelar"/></map:contextualButton>
		</span></DIV>
		
</map:body>
</html>

