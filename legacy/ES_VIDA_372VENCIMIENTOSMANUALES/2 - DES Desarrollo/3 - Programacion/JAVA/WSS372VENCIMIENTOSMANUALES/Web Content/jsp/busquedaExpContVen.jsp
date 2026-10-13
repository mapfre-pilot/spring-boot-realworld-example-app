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
<%@ taglib uri="/WEB-INF/struts-nested.tld" prefix="nested"%>
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

<LINK rel="stylesheet" type="text/css"
	href="<bean:write name="HTTP_PATH"/>/css/datosgenerales.css">
<LINK rel="stylesheet" type="text/css"
	href="<bean:write name="HTTP_PATH"/>/css/pestanias.css">
<LINK rel="stylesheet" type="text/css"
	href="<bean:write name="HTTP_PATH"/>/css/listado.css">
<LINK rel="stylesheet" type="text/css"
	href="<bean:write name="HTTP_PATH"/>/css/adaptadormv.css">
<LINK rel="stylesheet" type="text/css"
	href="<bean:write name="HTTP_PATH"/>/css/listadoinformacional.css">

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
<script type="text/javascript">

<%-- CargaInicial() se llama al realizar una carga de la pagina, teniendo en cuenta dos variable y tipOperacion
   para conocer su estado y tener un comportamiento inicial u otro.--%>
   
   function cargaInicial() {
   		
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
	   }		
			
		<!-- Validaciones de campos: de modalidad cogemos una propiedad y cuando demos alboton alta esta propiedad cambiará de valor, de esta forma haremos la validaciones a nuestro parecer-->		
	<%--una vez recogido todos los valores en la variable busqueda la vamos pasando a gestion expediente--%>	
	var busqueda;
			
	function pasarValores(busqueda){
		
		this.busqueda = busqueda;
			
		document.getElementById('Seleccionar').disabled = false;
		document.getElementById('Seleccionar').className = "contextualButton";
		
	}
	<%--Cuando se seleccione una fila de la lista se pasan los valores a gestion expediente--%>
	function selecFormulario() {

			window.dialogArguments.ventana.pasarValoresGestExp(busqueda);
			window.close();
	}
	
	
	</script>
</head>

<map:body transition="auto" style="version1.0" onLoad="cargaInicial();">
	<html:form action="busquedaExpFormVen">

		<div id="Contenido">
		<div id="CCOL"><iframe height="65%" frameborder="0"
			scrolling="no" id="MarcoListado" name="MarcoListado"
			src="<%=request.getContextPath()%>/listadoBusquedaExpVen.do"></iframe>
		</div>
		<DIV id="BA" class="MInf">
		<div><span class="W50 I"> <input type="hidden"
			name="operacion" /> <map:contextualButton name="Volver"
			title="Volver" onclick="window.close();">Volver</map:contextualButton>
		</span> <span class="W50 D"> <map:contextualButton name="Seleccionar"
			title="Seleccionar" disabled="true" onclick="selecFormulario();">Seleccionar</map:contextualButton>
		</span></div>
		</DIV>
		</div>
	</html:form>
</map:body>
</html>
