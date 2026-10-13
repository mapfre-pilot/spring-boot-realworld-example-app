<%--
Descripcion : JSP carga de Ficheros en Vencimiento
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
<map:alertSupport />
<%@page import="java.util.List"%>
<%@page import="com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J010CargaFicheroVenActionForm"%>
<html>

<%@ page
	import="com.mapfre.mavisa.wss372vencimientosmanuales.utils.Msg"%>
	
<!--Desde aqui nos traemos el valor de tipOperacion una vezque se carge el action-->
<%	final J372J010CargaFicheroVenActionForm formCargaFichero = (J372J010CargaFicheroVenActionForm) 
						request.getAttribute("formCargaFichero");
		
	final List vectorMensajes = formCargaFichero.getVectorMensajes();
				%>
				

<head>

<title><bean:message key="rescate.jsp.carga"/></title>

<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta name="GENERATOR" content="Rational Software Architect">

	<link rel="stylesheet" type="text/css" href="<bean:write name="HTTP_PATH"/>/css/contenedor.css">
	<link rel="stylesheet" type="text/css" href="<bean:write name="HTTP_PATH"/>/css/agrupacion.css"/>
	<link rel="stylesheet" type="text/css" href="<bean:write name="HTTP_PATH"/>/css/estilomapfre.css"/>
	<link rel="stylesheet" type="text/css" href="<bean:write name="HTTP_PATH"/>/css/comun.css"/>
	<link rel="stylesheet" type="text/css" href="<bean:write name="HTTP_PATH"/>/css/contenedor.css">

	<script src="<bean:write name="HTTP_PATH"/>/js/t07952.js"></script>
	<script src="<bean:write name="HTTP_PATH"/>/js/t00830.js"></script><%--Idiomas--%>
	<script src="<bean:write name="HTTP_PATH"/>/js/t00013.js"></script>
	<script src="<bean:write name="HTTP_PATH"/>/js/comun.js"        language="JavaScript" type="text/JavaScript"></script>
	<script src="<bean:write name="HTTP_PATH"/>/js/generales.js"    language="JavaScript" type="text/JavaScript"></script>
	<script src="<bean:write name="HTTP_PATH"/>/js/validaciones.js" language="JavaScript" type="text/JavaScript"></script>
	<script src="<bean:write name="HTTP_PATH"/>/js/customtag.js" language="JavaScript" type="text/JavaScript"></script>
	<script src="<bean:write name="HTTP_PATH"/>/js/customtag-validations.js" language="JavaScript" type="text/JavaScript"></script>
	<script src="<html:rewrite page="/js/GenericoVen.js"/>"
	language="JavaScript" type="text/JavaScript"></script>
	<!--Desde aqui nos traemos el valor de tipOperacion una vez que se carge el action,-->
<script type="text/javascript">

<%-- CargaInicial() se llama al realizar una carga de la pagina, teniendo en cuenta dos variable tipOperacion.
  para conocer su estado y tener un comportamiento inicial u otro--%>
   
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
<%-- Funcion de submit de formulario	--%>
	function aceptarFormulario(){
	
		var form= document.forms['formCargaFichero'];
		
		var errors = validateForm(form);		
		if(errors.length > 0) {
			return;
		}
		document.forms[0].submit();		
	}


	</script>
</head>

<map:body transition="auto" style="version1.0" onLoad="cargaInicial();">

<html:form action="cargaFicheroVen">

<div id="Contenido">
<div id="CCOL">

<label id="TC"><bean:message key="rescate.cargaficheros.label.titulo.principal"/></label>

</div>

<map:group-box height="80" layout="line" titleKey="rescate.cargaficheros.label.titulo.auxiliar" width="100%">
	<br>

	<DIV>
			<span class="W10 I"><bean:message key="rescate.cargaficheros.label.cargaficheros" />:</span>
			<bean:define id="litCargaFichero" type="String"><bean:message key="rescate.cargaficheros.label.cargaficheros"/></bean:define>
			<map:select showcode="false" property="tipo" tabindex="5">
			  <map:defaultOption><bean:message key="rescate.desplegable.default"/></map:defaultOption>
			   <map:optionsJs tablename="t07952" lang="es" type="l"
								orderby="value" dir="asc" />
			  <map:validation rule="required">
			  <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion--%>
			  	<bean:message key="rescate.error.obligatorio" arg0="<%=litCargaFichero%>"/>
			  </map:validation>			  
			</map:select>
	</DIV>
	
	
</map:group-box>
<!--String correcto = "false";-->
</div>
	
	<DIV id="BA" class="MInf">
		<div class ="W100 I" id="botones1">
		<span class="W100 D">
		<input type="hidden" name="tipOperacion"/>	
		<map:button name="Aceptar" title="Aceptar" onclick="aceptarFormulario();"><bean:message key="rescate.jsp.aceptar"/></map:button>			
		</span>
		</div>	
	</DIV>

</html:form>
</map:body>
</html>