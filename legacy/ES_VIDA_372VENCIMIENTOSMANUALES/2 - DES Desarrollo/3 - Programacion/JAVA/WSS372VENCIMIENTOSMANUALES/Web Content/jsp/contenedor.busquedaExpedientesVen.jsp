<%--
Descripcion : JSP de la pantalla de Gestión de Expedientes de Vencimientos FOXPRO
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

<%@page import="java.util.List"%>

<map:alertSupport />


<html>


	<%@ page
	import="com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J001BusquedaExpVenActionForm"%>
	<%@ page
	import="com.mapfre.mavisa.wss372vencimientosmanuales.utils.Msg"%>

<%	
	final String BusquedaExp = "formBusquedaExp";
	final J372J001BusquedaExpVenActionForm formBusquedaExp = (J372J001BusquedaExpVenActionForm) 
							request.getAttribute(BusquedaExp);
				
	final List vectorMensajes = formBusquedaExp.getVectorMensajes();
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
		
		document.getElementById('Anio').value = '';
		rdAnioExpFormulario();
		
	}
	
	

<%--Accion botonbuscar--%>	
function enviarFormulario(){
		
		var form = document.forms[0];
		var errors = validateForm(form);		
		if(errors.length > 0) {
			return;
		}
			
		form.action = 'busquedaExpFormVen.do';
		form.submit();
	}
	
	<%--Accion Alta--%>	
function altaFormulario(){
		
		var form = document.forms[0];
				
		form.action = 'inicioGestionExpedVen.do';
		form.submit();
	}
	
		
	
		
	
<%--OCULTA/MUESTRA LA CAPA año, expediente, poliza, nif/cif, cuando  selecciones radiobutton--%>
	
function rdAnioExpFormulario(){   
     document.getElementById('Poliza').value = '';
     document.getElementById('Subpoliza').value = '';
     document.getElementById('Certificado').value = '';
      document.getElementById('NifCif').value = '';
     
     
     
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
     document.getElementById('Anio').value = '';
     document.getElementById('Expediente').value = '';
     document.getElementById('NifCif').value = '';

     
     
     
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
    	document.getElementById('Anio').value = '';
     document.getElementById('Expediente').value = '';
     document.getElementById('Poliza').value = '';
     document.getElementById('Subpoliza').value = '';
     document.getElementById('Certificado').value = '';
    

      
     
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
  
  function pasarValores(Row){
  	 
  	 document.getElementById('Anio').value = Row;
  	 if (Row == '') {
		ctError('Debe elegirse algún expediente','Aceptar');
		} else { 	
		var form = document.forms[0];
    	 form.action = '/WSS372VENCIMIENTOSMANUALES/inicioModificarExpVen.do';
	 	form.submit();
		}	
     	
	
  
  }	
		
	

	</script>

</head>

<map:body transition="auto" style="version1.0" onLoad="cargaInicial();" scroll="yes">

<nested:root name="formBusquedaExp">

	
		
		<div id="CCOL"><label id="TC"><bean:message
			key="rescate.BusquedaExp.label.titulo.principal" /></label></div>
			
			<html:form action="busquedaExpFormVen">

		<div id="Contenido" class="W100" style="height:25%">
		
		<br>
		
		<map:group-box height="50%"> 
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
			</span></DIV>
			<br>
			<DIV id="datosAnioExp"><span><bean:message
				key="rescate.BusquedaExp.label.anio" />:&nbsp;</span> 
				<bean:define id="litAnio" type="String"><bean:message key="rescate.BusquedaExp.label.anio"/></bean:define>
				<map:text size="6" name="formBusquedaExp" id="Anio" maxlength="4" tabindex="10"
				property="anioSel">
	 		 <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
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
				tabindex="15" property="expedienteSel">
				<%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
	 		 	<map:validation rule="integer">
			  	<bean:message key="rescate.error.numerico" arg0="<%=litExpediente%>"/>
	 		</map:validation>
				</map:text></DIV> 
			<DIV id="datosPoliza" style="display:none">
				<span><bean:message
				key="rescate.BusquedaExp.label.poliza" />:&nbsp;</span> 
				<bean:define id="litPoliza" type="String"><bean:message key="rescate.BusquedaExp.label.poliza"/></bean:define>
				<map:text size="11"	name="formBusquedaExp" id="Poliza" maxlength="10" tabindex="20"
				property="polizaSel">
				 <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
	 		 	<map:validation rule="integer">
			  	<bean:message key="rescate.error.numerico" arg0="<%=litPoliza%>"/>
	 			</map:validation>
				</map:text>
				
				 <span><bean:message key="rescate.BusquedaExp.label.subPoliza" />:&nbsp; </span> 
				 <bean:define id="litSubPoliza" type="String"> <bean:message key="rescate.BusquedaExp.label.subPoliza"/> </bean:define>
				 <map:text size="4"	name="formBusquedaExp" id="SubPoliza" maxlength="4" tabindex="20"
					property="subpolizaSel">
				 <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
	 		 		<map:validation rule="integer">
			  		<bean:message key="rescate.error.numerico" arg0="<%=litSubPoliza%>"/>
	 				</map:validation>
				 </map:text>
				 
				 <span><bean:message key="rescate.BusquedaExp.label.certificado" /> :&nbsp;</span> 
				 <bean:define id="litCertificado" type="String"> <bean:message key="rescate.gestionexpedientes.label.certificado"/> </bean:define>
				 <map:text size="6"	name="formBusquedaExp" id="Certificado" maxlength="6" tabindex="20"
					property="certificadoSel"> 
				 <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
	 		 		<map:validation rule="integer">
			  		<bean:message key="rescate.error.numerico" arg0="<%=litCertificado%>"/>
	 				</map:validation>
				 </map:text>
				 
				 <span class="W50 I"> <bean:message key="rescate.gestionexpedientes.label.tipSituacion" />: 
						<map:radio id="TipSituacion1" name="formBusquedaExp"
							property="tipSituacion" value="VI">
							<bean:message
								key="rescate.gestionexpedientes.label.tipSituacion.opcion1" />

						</map:radio>
						
						 <map:radio id="TipSituacion2" name="formBusquedaExp"
							property="tipSituacion" value="AN" >
							<bean:message
								key="rescate.gestionexpedientes.label.tipSituacion.opcion2" />

						</map:radio> 
				</span>
				
				</DIV>

			<DIV id="datosnifCif" style="display:none"><span><bean:message
				key="rescate.BusquedaExp.label.nifCif" />:&nbsp;</span> <map:text size="11"
				name="formBusquedaExp" id="NifCif" maxlength="10" tabindex="25"
				property="nifCif">
			</map:text>
			</DIV>

			<br>
		</map:group-box> 
		</div>
		<br>
		<br>
		
		
		<div class="W100 I"><span class="W100 D"> <span>   <map:button name="Alta" title="Alta"
			onclick="altaFormulario();" accesskey="a" style="version1.0"><bean:message key="rescate.jsp.alta"/></map:button> </span><span> <map:button name="Buscar" title="Buscar"
			onclick="enviarFormulario();" accesskey="b" style="version1.0"><bean:message key="rescate.jsp.buscar"/></map:button> </span></span></div>
			
			
		
	</html:form>
	
	<nested:equal property="mostrarResultado" value="true">	
	
	<ifRAME style="height: 89%;" id="Listado" src="/WSS372VENCIMIENTOSMANUALES/listadoBusquedaExpVen.do"  scrolling="auto" frameborder="0" name="Listado">
 	</ifRAME>

 		
 	</nested:equal>	

		

			
 </nested:root>		
</map:body>
</html>

