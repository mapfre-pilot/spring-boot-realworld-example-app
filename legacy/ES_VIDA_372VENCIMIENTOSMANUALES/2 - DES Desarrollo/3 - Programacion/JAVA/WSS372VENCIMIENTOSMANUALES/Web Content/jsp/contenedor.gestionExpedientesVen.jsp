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
		
		<ifRAME height="89%;" id="gestionExpedientes"  src="/WSS372VENCIMIENTOSMANUALES/modificarExpVen.do"  scrolling="yes" style="overflow: hidden"
				frameborder="0">
 	</ifRAME>
		
		
		<DIV class="D MInf"><span id="BOTONES1">
		<map:contextualButton name="Aceptar" title="Aceptar"
			onclick="document.frames.frames[0].enviarFormulario();" accesskey="a"><bean:message key="rescate.jsp.aceptar"/></map:contextualButton> <map:contextualButton
			name="Cancelar" title="Cancelar" onclick="cancelarFormulario();" accesskey="c"><bean:message key="rescate.jsp.cancelar"/></map:contextualButton>
		</span></DIV>

	<script type="text/javascript">
		function controlarAceptar() {
		    var iframe = document.getElementById("gestionExpedientes");
		    if (!iframe) {
		        setTimeout(controlarAceptar, 300);
		        return;
		    }
		
		    var iframeDoc = null;
		    try {
		        if (iframe.contentWindow && iframe.contentWindow.document) {
		            iframeDoc = iframe.contentWindow.document;
		        }
		    } catch (e) {
		        setTimeout(controlarAceptar, 300);
		        return;
		    }
		
		    if (!iframeDoc) {
		        setTimeout(controlarAceptar, 300);
		        return;
		    }
		
		    var anioInput = iframeDoc.getElementById("Anio");
		    if (!anioInput) {
		        setTimeout(controlarAceptar, 300);
		        return;
		    }
		
		    var btns = document.getElementsByName("Aceptar");
		    if (!btns || btns.length === 0) {
		        return;
		    }
		    var btnAceptar = btns[0];
		
		    var anio = (anioInput.value || "").replace(/^\s+|\s+$/g, "");
		    if (anio === "1950") {
		        btnAceptar.disabled = true;
		        btnAceptar.onclick = function(ev) {
		            ev = ev || window.event;
		            if (ev.preventDefault) ev.preventDefault();
		            ev.returnValue = false;
		            return false;
		        };
		        // Marcador visual sencillo (opcional y ASCII safe)
		        // btnAceptar.title = (btnAceptar.title || "") + " (deshabilitado por anio 1950)";
		    }
		}
		
		if (window.addEventListener) {
		    window.addEventListener("load", controlarAceptar, false);
		} else if (window.attachEvent) {
		    window.attachEvent("onload", controlarAceptar);
		} else {
		    window.onload = controlarAceptar;
		}
	</script>
	
</map:body>
</html>

