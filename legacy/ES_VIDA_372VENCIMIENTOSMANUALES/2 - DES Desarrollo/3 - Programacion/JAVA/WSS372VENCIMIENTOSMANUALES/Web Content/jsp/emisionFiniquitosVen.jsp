<%--
Descripcion : JSP emisión de finiquitos en Rescates
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
<html>

	<%@ page
	import="com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J002EmisionFiniquitosVenActionForm"%>
	<%@ page
	import="com.mapfre.mavisa.wss372vencimientosmanuales.utils.Msg"%>

<!--Desde aqui nos traemos el valor de tipOperacion una vez que se carge el action-->

<%	final J372J002EmisionFiniquitosVenActionForm formEmisionFiniquitos = (J372J002EmisionFiniquitosVenActionForm)request.getAttribute("formEmisionFiniquitos");
				
	final String tipOperacion = formEmisionFiniquitos.getTipOperacion();
	final List vectorMensajes = formEmisionFiniquitos.getVectorMensajes();
				%>
<head>

<title><bean:message key="rescate.jsp.finiquito"/></title>
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

	<script src="<bean:write name="HTTP_PATH"/>/js/t00830.js"></script><%--Idiomas--%>
	<script src="<bean:write name="HTTP_PATH"/>/js/t00013.js"></script>
	<script src="<bean:write name="HTTP_PATH"/>/js/t07952.js"></script>
	<script src="<bean:write name="HTTP_PATH"/>/js/t07954.js"></script>
	<script src="<%=request.getContextPath()%>/js/psurtsub.js"
	language="JavaScript" type="text/JavaScript"></script>
	<script src="<bean:write name="HTTP_PATH"/>/js/comun.js"        language="JavaScript" type="text/JavaScript"></script>
	<script src="<bean:write name="HTTP_PATH"/>/js/generales.js"    language="JavaScript" type="text/JavaScript"></script>
	<script src="<bean:write name="HTTP_PATH"/>/js/validaciones.js" language="JavaScript" type="text/JavaScript"></script>
	<script src="<bean:write name="HTTP_PATH"/>/js/customtag.js" language="JavaScript" type="text/JavaScript"></script>
	<script src="<bean:write name="HTTP_PATH"/>/js/customtag-validations.js" language="JavaScript" type="text/JavaScript"></script>
<script src="<html:rewrite page="/js/GenericoVen.js"/>"
	language="JavaScript" type="text/JavaScript"></script>
	<script type="text/javascript">
	function enviarFormulario(){

		var form = document.forms['formEmisionFiniquitos'];
		var errors = validateForm(form);		
		if(errors.length > 0) {
			return;
		}
		document.forms[0].elements['tipOperacion'].value ='BU';
		document.forms[0].submit();		
	}
	
	
   <%-- CargaInicial() se llama al realizar una carga de la pagina, teniendo en cuenta dos variable tipOperacion
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
		
		 if('<%=tipOperacion%>'=='IM'){
	<%--abre la ventana de pdf--%>
		url="lanzarImpresionDirecta.do";
		abrirVentanaImpresion(url);	
		}
		<%-- Carga inicial de la pagina.--%>
   		if ('<%=tipOperacion%>'=='INICIO') {
   				
   			<%--llamamosa la funcion para cuando se inicie se carge la fecha--%>
		   FechaEmision();
   		
   		}
		
	}	
	<%--creamos una funcion para que carge la fecha del día--%>
	function FechaEmision(){

		    var fechaActual = new Date();
			document.getElementById('fecEfectEmision_year').value = fechaActual.getFullYear();
			document.getElementById('fecEfectEmision_day').value = PonerCerosFecha(fechaActual.getDate());
			document.getElementById('fecEfectEmision_month').value = PonerCerosFecha(fechaActual.getMonth()+1);
			<%--Una vez puestala fecha del día para que se pase a cobol correctamente nos creamos la funcion
			 crearFecha que nos cogerá todos los valores que haya en 
			la fecha y la pasa a nuestra variable fecEfectoEmision--%>
			document.getElementById('fecEfectEmision').value = crearFecha('fecEfectEmision');
	}
	
	 
	
	</script>
</head>

<map:body transition="auto" style="version1.0" onLoad="cargaInicial();">

<html:form action="emisionFiniquitosVen">

<div id="Contenido">
<div id="CCOL">

 <label id="TC"><bean:message key="rescate.emisionFiniquitos.label.titulo.principal"/></label>

</div>

<map:group-box layout="line" titleKey="rescate.emisionFiniquitos.label.titulo.auxiliar" width="100%">
	<DIV>
			<span class="W15 I"><bean:message key="rescate.emisionFiniquitos.label.emisionFiniqui" />:</span>
			<bean:define id="litEmisionFiniqui" type="String"><bean:message key="rescate.emisionFiniquitos.label.emisionFiniqui"/></bean:define>
			<map:select showcode="false" property="emisionFiniqui" tabindex="5">
			  <map:defaultOption><bean:message key="rescate.desplegable.default"/></map:defaultOption>
			  <map:optionsJs tablename="t07954" lang="es" type="l"
								orderby="value" dir="asc" />
			  <map:validation rule="required">
			  <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
			  	<bean:message key="rescate.error.obligatorio" arg0="<%=litEmisionFiniqui%>"/>
			  </map:validation>			  
			</map:select>
			
	</DIV>
	<br>		
		<DIV><span class="W15 I"><bean:message
				key="rescate.emisionFiniquitos.label.anio" />:&nbsp;</span> 
				<bean:define id="litAnio" type="String"><bean:message key="rescate.emisionFiniquitos.label.anio"/></bean:define>
				<map:text size="6" name="formEmisionFiniquitos" id="Anio" maxlength="4" tabindex="10" property="anio">
	 		 <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
	 		 	<map:validation rule="integer">
			  	<bean:message key="rescate.error.numerico" arg0="<%=litAnio%>"/>
	 		</map:validation>	
	 		<map:validation rule = "intRange(0,9999)">
			  	<bean:message key="rescate.error.rango" arg0="<%=litAnio%>"/>
	 		</map:validation>
	 		<map:validation rule="required">
			  <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
			  	<bean:message key="rescate.error.obligatorio" arg0="<%=litAnio%>"/>
			  </map:validation>	
			</map:text> 
	</DIV>
	<br>
	<DIV>
		<span class="W15 I"><bean:message key="rescate.emisionFiniquitos.label.expedDesde"/>:</span>
		<bean:define id="litExpedDesde" type="String"><bean:message key="rescate.emisionFiniquitos.label.expedDesde"/></bean:define>
	 	<map:text size="6" name="formEmisionFiniquitos" id="ExpedienteDesde" maxlength="5" tabindex="15" property="expedDesde">					
		<map:validation rule="required">
			  <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacionv --%>
			  	<bean:message key="rescate.error.obligatorio" arg0="<%=litExpedDesde%>"/>
			 </map:validation>	
			 <map:validation rule="integer">
			  	<bean:message key="rescate.error.numerico" arg0="<%=litExpedDesde%>"/>
	 		</map:validation>
		</map:text> 
	</DIV>
	<br>
	<DIV>
		<span class="W15 I"><bean:message key="rescate.emisionFiniquitos.label.expedHasta"/>:</span>
		<bean:define id="litExpedHasta" type="String"><bean:message key="rescate.emisionFiniquitos.label.expedHasta"/></bean:define>
	 	<map:text size="6" name="formEmisionFiniquitos" id="ExpedienteHasta" maxlength="5" tabindex="20" property="expedHasta">					
		<map:validation rule="required">
			  <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
			  	<bean:message key="rescate.error.obligatorio" arg0="<%=litExpedHasta%>"/>
			 </map:validation>	
			 <map:validation rule="integer">
			  	<bean:message key="rescate.error.numerico" arg0="<%=litExpedHasta%>"/>
	 		</map:validation>
		</map:text> 
	</DIV>
	<br>
	<DIV>
			<span class="W15 I"><bean:message key="rescate.emisionFiniquitos.label.regionalEnvio" />:</span>
			<map:select showcode="false" property="regionalEnvio" tabindex="30">
			  <map:defaultOption><bean:message key="rescate.desplegable.default"/></map:defaultOption>			  
			 <map:optionsJs tablename="t07956" lang="es" type="l"
								orderby="value" dir="asc" />
			</map:select>
			
	</DIV>
	<br>
	<DIV>
		<span class="W15 I"><bean:message key="rescate.emisionFiniquitos.label.fecEfectEmision"/>:</span>
		<bean:define id="litFecEfectEmision" type="String"><bean:message key="rescate.emisionFiniquitos.label.fecEfectEmision"/></bean:define>
		<map:date  name="fecEfectEmision" srcName="formEmisionFiniquitos" srcProperty="fecEfectEmision" srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" calendar="true">
		</map:date>
    </DIV>
</map:group-box>
</div>
	<DIV id="BA" class="MInf">
		<div class ="W100 I" id="botones1">
		<span class="W100 D">
		<input type="hidden" name="tipOperacion"/>	
		<map:button name="Emitir" title="Emitir" onclick="enviarFormulario();">Emitir</map:button>			
		</span>
		</div>	
	</DIV>

</html:form>
</map:body>
</html>