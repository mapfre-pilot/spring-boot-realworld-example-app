<%--
Descripcion : JSP de gestion de variables Vencimiento
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
<map:alertSupport />
<%@page import="java.util.List"%>
<html>

	<%@ page
	import="com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J004GestionVariablesVenActionForm"%>
	<%@ page
	import="com.mapfre.mavisa.wss372vencimientosmanuales.utils.Msg"%>

<!--Desde aqui nos traemos el valor de tipOperacion una vezque se carge el action-->
<%	final J372J004GestionVariablesVenActionForm formGestionVar = 
		(J372J004GestionVariablesVenActionForm)request.getAttribute("formGestionVariables");
	final List vectorMensajes = formGestionVar.getVectorMensajes();
%>

<head>
<title><bean:message key="rescate.jsp.guardar"/></title>
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
	
    <%-- CargaInicial() se llama al realizar una carga de la pagina, teniendo en cuenta dos variable tipOperacion
 para conocer su estado y tener un comportamiento inicial u otro.--%>
   
   function cargaInicial() {
   		<%-- Si hay mensajes se muestran --%>
   		
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
    
    
	function guardarFormulario(){
	
		var form= document.forms[0];
		var errors = validateForm(form);
				
		if(errors.length > 0) {
			return;
		}
		<% if (formGestionVar!=null) { %>
		
		if('<%=formGestionVar.getTipOperacion()%>'=='BA'){
			document.forms[0].elements['tipOperacion'].value ='BA';
		}else {
			document.forms[0].elements['tipOperacion'].value ='SA';
		
		}	
		<% } %>
		document.forms[0].submit();	
	}

	</script>
</head>

<map:body transition="auto" style="version1.0" onLoad="cargaInicial();">
	<html:form action="gestionVariablesVen"  >
<div id="Contenido">

<div id="CCOL">

 <label id="TC"><bean:message key="rescate.gestionvariables.label.titulo.principal"/></label>

</div>

<map:group-box layout="line" titleKey="rescate.gestionvariables.label.titulo.auxiliar" width="100%">
	<DIV>
			<span class="W15 D"><bean:message key="rescate.gestionvariables.label.anio"/>:</span>
	 		<bean:define id="litAnio" type="String"><bean:message key="rescate.gestionvariables.label.anio"/></bean:define>
	 		<map:text size="6" id="Año" maxlength="4" tabindex="10" property="anio">
	 		<map:validation rule="required">
	 		 <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion--%>
			  	<bean:message key="rescate.error.obligatorio" arg0="<%=litAnio%>"/>
	 		</map:validation>
	 		<map:validation rule="integer">
			  	<bean:message key="rescate.error.numerico" arg0="<%=litAnio%>"/>
	 		</map:validation>	
	 		<map:validation rule = "intRange(0,9999)">
			  	<bean:message key="rescate.error.rango" arg0="<%=litAnio%>"/>
	 		</map:validation></map:text>	

	</DIV>
	<br>
	<DIV>
		<span class="W15 D"><bean:message key="rescate.gestionvariables.label.expediente"/>:</span>
	 		<bean:define id="litExpediente" type="String"><bean:message key="rescate.gestionvariables.label.expediente"/></bean:define>
	 		<map:text size="6" id="Expediente" maxlength="5" tabindex="10" property="expediente">
	 		 <map:validation rule="required">
	 		 <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
			  	<bean:message key="rescate.error.obligatorio" arg0="<%=litExpediente%>"/>
	 		</map:validation>
	 		 <map:validation rule="integer">
			  	<bean:message key="rescate.error.numerico" arg0="<%=litExpediente%>"/>
	 		</map:validation></map:text>					
	</DIV>	
	
</map:group-box>
</div>
	<DIV id="BA" class="MInf">
		<div class ="W100 I" id="botones1">
		<span class="W100 D">
		<input type="hidden" name="tipOperacion"/>
		<map:button name="Guardar" title="Guardar" onclick="guardarFormulario();"><bean:message key="rescate.jsp.guardar"/></map:button>			
		</span>
		</div>	
	</DIV>
	
</html:form>
</map:body>
</html>	

