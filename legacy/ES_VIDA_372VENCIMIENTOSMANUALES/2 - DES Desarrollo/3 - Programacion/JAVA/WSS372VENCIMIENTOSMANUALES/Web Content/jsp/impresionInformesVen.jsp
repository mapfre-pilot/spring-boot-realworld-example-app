<!-- MODIFICACIÓN : MU-2015-035084
FECHA : 08/09/2015
DESCRIPCION: Añadimos nuevos criterios a los informes Resumento por Modalidad (tipo 08) 
AUTOR : INDRA -->

<!-- MODIFICACIÓN : MU-2015-0007509
FECHA : 08/05/2015
DESCRIPCION: Añadimos Informe Pagos por Modalidad.
AUTOR : OJUSTES -->

<!-- MODIFICACIÓN : MU-2015-0007512
FECHA : 08/05/2015
DESCRIPCION: Añadimos Informe Resumen por póliza.
AUTOR : OJUSTES -->

<%--
Descripcion : JSP para la impresión de informes de Vencimientos
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
	import="com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J005ImpresionInformesVenActionForm"%>
	<%@ page
	import="com.mapfre.mavisa.wss372vencimientosmanuales.utils.Msg"%>

<!--Desde aqui nos traemos el valor de tipOperacion una vezque se carge el action-->
<%	final J372J005ImpresionInformesVenActionForm formImpresionInformes = (J372J005ImpresionInformesVenActionForm)request.getAttribute("formImpresionInformes");
		
	final String tipOperacion = formImpresionInformes.getTipOperacion();
	final List vectorMensajes = formImpresionInformes.getVectorMensajes();
				%>

<head>

<title><bean:message key="rescate.jsp.impresion"/></title>

<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta name="GENERATOR" content="Rational Software Architect">

	<link rel="stylesheet" type="text/css" href="<bean:write name="HTTP_PATH"/>/css/contenedor.css">
	<link rel="stylesheet" type="text/css" href="<bean:write name="HTTP_PATH"/>/css/agrupacion.css"/>
	<link rel="stylesheet" type="text/css" href="<bean:write name="HTTP_PATH"/>/css/estilomapfre.css"/>
	<link rel="stylesheet" type="text/css" href="<bean:write name="HTTP_PATH"/>/css/comun.css"/>
	<link rel="stylesheet" type="text/css" href="<bean:write name="HTTP_PATH"/>/css/contenedor.css">

	<script src="<bean:write name="HTTP_PATH"/>/js/t07953.js"></script>
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

	<%--Declaracion de variables para darlas las reglas/ validaciones iniciales--%>
	var ruleAnioExped; 
    var ruleAnioDesde;
	var ruleAnioHasta;
	var ruleExpedDesde;
    var ruleExpedHasta;
    var ruleFecEmision;
	var ruleFecEmiDesde;
	var ruleFecEmiHasta;
	var ruleFecPagDesde;
	var ruleFecPagHasta;
		
	function imprimirFormulario(){

 		validarCampos();

		var form = document.forms['formImpresionInformes'];
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
   		<%-- Si hay mensajes se muestran
   	  Pasamos las reglas de validación de los elementos a unas variables globales para su reutilización.--%>	
    ruleAnioExped = document.getElementById('AnioExped').validationRules;
    ruleAnioDesde = document.getElementById('AnioDesde').validationRules;
	ruleAnioHasta = document.getElementById('AnioHasta').validationRules;
	ruleExpedDesde = document.getElementById('ExpedDesde').validationRules;
    ruleExpedHasta = document.getElementById('ExpedHasta').validationRules;
    ruleFecCalculo = document.getElementById('fecCalculo').validationRules;
    ruleFecEmision = document.getElementById('fecEmision').validationRules;
	ruleFecEmiDesde = document.getElementById('fecEmiDesde').validationRules;
	ruleFecEmiHasta = document.getElementById('fecEmiHasta').validationRules;
	ruleFecPagDesde = document.getElementById('fecPagDesde').validationRules;
	ruleFecPagHasta = document.getElementById('fecPagHasta').validationRules;
   		
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
   
	   if('<%=tipOperacion%>'=='IM' && (document.getElementById("tipo").value == '01'|| document.getElementById("tipo").value == '02'
	   									|| document.getElementById("tipo").value == '03')){
		
		<%--abre la ventana de pdf--%>
		
		url="lanzarImpresionDirecta.do";
		abrirVentanaImpresion(url);	
		}
		
		<%-- Carga inicial de la pagina.--%>
   		if ('<%=tipOperacion%>'=='INICIO') {
   			  		
   			limpiarCampos();
   		
   		}
   		
   		comboEmiFiniPrincipal();
	}

<%--Funcion donde ledamos funcionalidad al combo segun se
 seleccione un valor u otro se esconderán o mostraran los campos.--%>
 
function comboEmiFiniPrincipal()
{    
	
	
	if (document.getElementById("tipo").value == '')
   {   
   		
   		document.getElementById("tituloEtiqueta").style.display="none";
   		document.getElementById("capaAnioExped").style.display="none";
    	document.getElementById("capaAnioDesde").style.display="none";
		document.getElementById("capaAnioHasta").style.display="none";
		document.getElementById("capaExpedDesde").style.display="none";
		document.getElementById("capaExpedHasta").style.display="none";
		document.getElementById("capafecEmision").style.display="none";
		document.getElementById("capafecEmiDesde").style.display="none";
		document.getElementById("capafecEmiHasta").style.display="none";
		document.getElementById("capafecPagDesde").style.display="none";
		document.getElementById("capafecPagHasta").style.display="none";
     
   	} else if (document.getElementById("tipo").value == '01'){   
   		
   		document.getElementById("tituloEtiqueta").style.display="";
   		document.getElementById("capaAnioExped").style.display="";
    	document.getElementById("capaAnioDesde").style.display="none";
		document.getElementById("capaAnioHasta").style.display="none";
		document.getElementById("capaExpedDesde").style.display="";
		document.getElementById("capaExpedHasta").style.display="";
		document.getElementById("capafecEmision").style.display="";
		document.getElementById("capafecCalculo").style.display="none";
		document.getElementById("capafecEmiDesde").style.display="none";
		document.getElementById("capafecEmiHasta").style.display="none";
		document.getElementById("capafecPagDesde").style.display="none";
		document.getElementById("capafecPagHasta").style.display="none";
     
   	} else if (document.getElementById("tipo").value == '02') { 
  		
  		document.getElementById("tituloEtiqueta").style.display="";
   		document.getElementById("capaAnioExped").style.display="";
    	document.getElementById("capaAnioDesde").style.display="none";
		document.getElementById("capaAnioHasta").style.display="none";
		document.getElementById("capaExpedDesde").style.display="";
		document.getElementById("capaExpedHasta").style.display="";
		document.getElementById("capafecEmision").style.display="";
		document.getElementById("capafecCalculo").style.display="none";
		document.getElementById("capafecEmiDesde").style.display="none";
		document.getElementById("capafecEmiHasta").style.display="none";
		document.getElementById("capafecPagDesde").style.display="none";
		document.getElementById("capafecPagHasta").style.display="none";
		
	} else if (document.getElementById("tipo").value == '03') { 
	
		document.getElementById("tituloEtiqueta").style.display="";
   		document.getElementById("capaAnioExped").style.display="";
    	document.getElementById("capaAnioDesde").style.display="none";
		document.getElementById("capaAnioHasta").style.display="none";
		document.getElementById("capaExpedDesde").style.display="";
		document.getElementById("capaExpedHasta").style.display="";
		document.getElementById("capafecEmision").style.display="";
		document.getElementById("capafecCalculo").style.display="none";
		document.getElementById("capafecEmiDesde").style.display="none";
		document.getElementById("capafecEmiHasta").style.display="none";
		document.getElementById("capafecPagDesde").style.display="none";
		document.getElementById("capafecPagHasta").style.display="none";
	} else if (document.getElementById("tipo").value == '04') { 

   		document.getElementById("tituloEtiqueta").style.display="";
    	document.getElementById("capaAnioExped").style.display="none";
    	document.getElementById("capaAnioDesde").style.display="none";
		document.getElementById("capaAnioHasta").style.display="none";
		document.getElementById("capaExpedDesde").style.display="none";
		document.getElementById("capaExpedHasta").style.display="none";
		document.getElementById("capafecEmision").style.display="none";
		document.getElementById("capafecCalculo").style.display="none";
		document.getElementById("capafecEmiDesde").style.display="";
		document.getElementById("capafecEmiHasta").style.display="";
		document.getElementById("capafecPagDesde").style.display="none";
		document.getElementById("capafecPagHasta").style.display="none";
		
	} else if (document.getElementById("tipo").value == '05') { 
  	
  		document.getElementById("tituloEtiqueta").style.display="";
    	document.getElementById("capaAnioExped").style.display="none";
    	document.getElementById("capaAnioDesde").style.display="none";
		document.getElementById("capaAnioHasta").style.display="none";
		document.getElementById("capaExpedDesde").style.display="none";
		document.getElementById("capaExpedHasta").style.display="none";
		document.getElementById("capafecCalculo").style.display="none";
		document.getElementById("capafecEmision").style.display="none";
		document.getElementById("capafecEmiDesde").style.display="none";
		document.getElementById("capafecEmiHasta").style.display="none";
		document.getElementById("capafecPagDesde").style.display="";
		document.getElementById("capafecPagHasta").style.display="";
		
		
	} else if (document.getElementById("tipo").value == '06') { 
  		
  		document.getElementById("tituloEtiqueta").style.display="";
    	document.getElementById("capaAnioExped").style.display="none";
    	document.getElementById("capaAnioDesde").style.display="none";
		document.getElementById("capaAnioHasta").style.display="none";
		document.getElementById("capaExpedDesde").style.display="none";
		document.getElementById("capaExpedHasta").style.display="none";
		document.getElementById("capafecCalculo").style.display="none";
		document.getElementById("capafecEmision").style.display="none";
		document.getElementById("capafecEmiDesde").style.display="none";
		document.getElementById("capafecEmiHasta").style.display="none";
		document.getElementById("capafecPagDesde").style.display="";
		document.getElementById("capafecPagHasta").style.display="";	
   	
   	} else if (document.getElementById("tipo").value == '07') {
  		
  		document.getElementById("tituloEtiqueta").style.display="";
    	document.getElementById("capaAnioExped").style.display="none";
    	document.getElementById("capaAnioDesde").style.display="none";
		document.getElementById("capaAnioHasta").style.display="none";
		document.getElementById("capaExpedDesde").style.display="none";
		document.getElementById("capaExpedHasta").style.display="none";
		document.getElementById("capafecEmision").style.display="none";
		document.getElementById("capafecCalculo").style.display="none";
		document.getElementById("capafecEmiDesde").style.display="none";
		document.getElementById("capafecEmiHasta").style.display="none";
		document.getElementById("capafecPagDesde").style.display="";
		document.getElementById("capafecPagHasta").style.display="";
		
	} else if (document.getElementById("tipo").value == '08') { 
		/*OJS  MU-2015-035084*/
  		document.getElementById("tituloEtiqueta").style.display="";
    	//document.getElementById("capaAnioExped").style.display="";
    	document.getElementById("capaAnioExped").style.display="none";
    	//document.getElementById("capaAnioDesde").style.display="none";
		//document.getElementById("capaAnioHasta").style.display="none";
		document.getElementById("capaAnioDesde").style.display="";
		document.getElementById("capaAnioHasta").style.display="";
		/*FIN  -  OJS  MU-2015-035084*/
		document.getElementById("capaExpedDesde").style.display="";
		document.getElementById("capaExpedHasta").style.display="";
		document.getElementById("capafecEmision").style.display="none";
		document.getElementById("capafecCalculo").style.display="";
		document.getElementById("capafecEmiDesde").style.display="none";
		document.getElementById("capafecEmiHasta").style.display="none";
		document.getElementById("capafecPagDesde").style.display="none";
		document.getElementById("capafecPagHasta").style.display="none";
   	
   	}
   	/*OJS  MU-2015-007512*/
   	else if (document.getElementById("tipo").value == '09') { 
  		
  		document.getElementById("tituloEtiqueta").style.display="";
    	document.getElementById("capaAnioExped").style.display="none";
    	document.getElementById("capaAnioDesde").style.display="";
		document.getElementById("capaAnioHasta").style.display="";
		document.getElementById("capaExpedDesde").style.display="";
		document.getElementById("capaExpedHasta").style.display="";
		document.getElementById("capafecEmision").style.display="none";
		document.getElementById("capafecCalculo").style.display="";
		document.getElementById("capafecEmiDesde").style.display="none";
		document.getElementById("capafecEmiHasta").style.display="none";
		document.getElementById("capafecPagDesde").style.display="none";
		document.getElementById("capafecPagHasta").style.display="none";
   	
   	}
   	/*Fin OJS  MU-2015-007512*/ 
   	/*OJS  MU-2015-007509*/
   	else if (document.getElementById("tipo").value == '10') { 
  		
   		document.getElementById("tituloEtiqueta").style.display="";
    	document.getElementById("capaAnioExped").style.display="none";
    	document.getElementById("capaAnioDesde").style.display="none";
		document.getElementById("capaAnioHasta").style.display="none";
		document.getElementById("capaExpedDesde").style.display="none";
		document.getElementById("capaExpedHasta").style.display="none";
		document.getElementById("capafecCalculo").style.display="none";
		document.getElementById("capafecEmision").style.display="none";
		document.getElementById("capafecEmiDesde").style.display="none";
		document.getElementById("capafecEmiHasta").style.display="none";
		document.getElementById("capafecPagDesde").style.display="";
		document.getElementById("capafecPagHasta").style.display="";
   	
   	}
   	/*Fin OJS  MU-2015-007509*/ 
   	else{
  		
   		document.getElementById("tituloEtiqueta").style.display="none";
   		document.getElementById("capaAnioExped").style.display="none";
    	document.getElementById("capaAnioDesde").style.display="none";
		document.getElementById("capaAnioHasta").style.display="none";
		document.getElementById("capaExpedDesde").style.display="none";
		document.getElementById("capaExpedHasta").style.display="none";
		document.getElementById("capafecEmision").style.display="none";
		document.getElementById("capafecEmiDesde").style.display="none";
		document.getElementById("capafecEmiHasta").style.display="none";
		document.getElementById("capafecPagDesde").style.display="none";
		document.getElementById("capafecPagHasta").style.display="none";
   	}
  return true; 
  }

<%--Funcion para validar los caampos delformularion segun el select puesto--%>
 function validarCampos(){ 
 	 
 	if(document.getElementById("tipo").value == '01'){
	 
	 iniciarReglasValidacion();	 
	  document.getElementById('AnioDesde').validationRules ='';
	  document.getElementById('AnioHasta').validationRules ='';
	  document.getElementById('fecCalculo').validationRules ='';
	  document.getElementById('fecEmiDesde').validationRules ='';
	  document.getElementById('fecEmiHasta').validationRules ='';
	  document.getElementById('fecPagDesde').validationRules ='';
	  document.getElementById('fecPagHasta').validationRules ='';
	         
    }else if(document.getElementById("tipo").value == '02'){ 
 
    	iniciarReglasValidacion();
		  document.getElementById('AnioDesde').validationRules ='';
		  document.getElementById('AnioHasta').validationRules ='';
		  document.getElementById('fecCalculo').validationRules ='';
		  document.getElementById('fecEmiDesde').validationRules ='';
		  document.getElementById('fecEmiHasta').validationRules ='';
		  document.getElementById('fecPagDesde').validationRules ='';
		  document.getElementById('fecPagHasta').validationRules ='';
	 }else if(document.getElementById("tipo").value == '03'){ 
 
    	iniciarReglasValidacion();
		  document.getElementById('AnioDesde').validationRules ='';
		  document.getElementById('AnioHasta').validationRules ='';
		  document.getElementById('fecCalculo').validationRules ='';
		  document.getElementById('fecEmiDesde').validationRules ='';
		  document.getElementById('fecEmiHasta').validationRules ='';
		  document.getElementById('fecPagDesde').validationRules ='';
		  document.getElementById('fecPagHasta').validationRules ='';
    }else if(document.getElementById("tipo").value == '04'){
    
   		 iniciarReglasValidacion();
	        document.getElementById('AnioExped').validationRules ='';
	    	document.getElementById('AnioDesde').validationRules ='';
			document.getElementById('AnioHasta').validationRules ='';
			document.getElementById('ExpedDesde').validationRules ='';
			document.getElementById('ExpedHasta').validationRules ='';
			document.getElementById('fecCalculo').validationRules ='';
			document.getElementById('fecEmision').validationRules ='';
			document.getElementById('fecPagDesde').validationRules ='';
			document.getElementById('fecPagHasta').validationRules ='';
	}else if(document.getElementById("tipo").value == '05'){
	
		iniciarReglasValidacion();
			document.getElementById('AnioExped').validationRules ='';
	    	document.getElementById('AnioDesde').validationRules ='';
			document.getElementById('AnioHasta').validationRules ='';
			document.getElementById('ExpedDesde').validationRules ='';
			document.getElementById('ExpedHasta').validationRules ='';
			document.getElementById('fecCalculo').validationRules ='';
			document.getElementById('fecEmision').validationRules ='';
			document.getElementById('fecEmiDesde').validationRules ='';
			document.getElementById('fecEmiHasta').validationRules ='';
	}else if(document.getElementById("tipo").value == '06'){
	
		iniciarReglasValidacion();
			document.getElementById('AnioExped').validationRules ='';
	    	document.getElementById('AnioDesde').validationRules ='';
			document.getElementById('AnioHasta').validationRules ='';
			document.getElementById('ExpedDesde').validationRules ='';
			document.getElementById('ExpedHasta').validationRules ='';
			document.getElementById('fecCalculo').validationRules ='';
			document.getElementById('fecEmision').validationRules ='';
			document.getElementById('fecEmiDesde').validationRules ='';
			document.getElementById('fecEmiHasta').validationRules ='';
		}
		else if(document.getElementById("tipo").value == '07'){
	
		iniciarReglasValidacion();
			document.getElementById('AnioExped').validationRules ='';
	    	document.getElementById('AnioDesde').validationRules ='';
			document.getElementById('AnioHasta').validationRules ='';
			document.getElementById('ExpedDesde').validationRules ='';
			document.getElementById('ExpedHasta').validationRules ='';
			document.getElementById('fecCalculo').validationRules ='';
			document.getElementById('fecEmision').validationRules ='';
			document.getElementById('fecEmiDesde').validationRules ='';
			document.getElementById('fecEmiHasta').validationRules ='';
			}
			
			else if(document.getElementById("tipo").value == '08'){
	
			iniciarReglasValidacion();
			/*OJS  MU-2015-035084*/
			//document.getElementById('AnioDesde').validationRules ='';
			//document.getElementById('AnioHasta').validationRules ='';
			document.getElementById('AnioExped').validationRules ='';
			/*FIN  -  OJS  MU-2015-035084*/
			document.getElementById('fecEmision').validationRules ='';
			document.getElementById('fecEmiDesde').validationRules ='';
			document.getElementById('fecEmiHasta').validationRules ='';
			document.getElementById('fecPagDesde').validationRules ='';
			document.getElementById('fecPagHasta').validationRules ='';
			}
			/*OJS  MU-2015-007512*/
			else if(document.getElementById("tipo").value == '09'){
				
				iniciarReglasValidacion();
				document.getElementById('AnioExped').validationRules ='';
				document.getElementById('fecEmision').validationRules ='';
				//document.getElementById('fecCalculo').validationRules ='';
				document.getElementById('fecEmiDesde').validationRules ='';
				document.getElementById('fecEmiHasta').validationRules ='';
				document.getElementById('fecPagDesde').validationRules ='';
				document.getElementById('fecPagHasta').validationRules ='';
			}
			/*Fin OJS  MU-2015-007512*/
			/*OJS  MU-2015-07509*/
			else if(document.getElementById("tipo").value == '10'){
				
				iniciarReglasValidacion();
				document.getElementById('AnioExped').validationRules ='';
		    	document.getElementById('AnioDesde').validationRules ='';
				document.getElementById('AnioHasta').validationRules ='';
				document.getElementById('ExpedDesde').validationRules ='';
				document.getElementById('ExpedHasta').validationRules ='';
				document.getElementById('fecCalculo').validationRules ='';
				document.getElementById('fecEmision').validationRules ='';
				document.getElementById('fecEmiDesde').validationRules ='';
				document.getElementById('fecEmiHasta').validationRules ='';
			}
			/*Fin OJS  MU-2015-007509*/
			else{
		
		document.getElementById("tipo").value == '';
		iniciarReglasValidacion();
		} 
		
  }
  
   function limpiarCampos(){
   		
   			document.getElementById('AnioExped').value='';
	    	document.getElementById('AnioDesde').value='';
			document.getElementById('AnioHasta').value='';
			document.getElementById('ExpedDesde').value='';
			document.getElementById('ExpedHasta').value='';
			limpiarFechas('fecEmision')
			limpiarFechas('fecCalculo')
			limpiarFechas('fecEmiDesde')
			limpiarFechas('fecEmiHasta')
			limpiarFechas('fecPagDesde')
			limpiarFechas('fecPagHasta')
   }
  
  
  <%--funcion para iniciar las reglas de la validacion, asi una vez q se seleccione un valor del select 
   cargara todo las reglas y no perderá ninguna segun se vaya seleccionando una despues de otra--%>
  function iniciarReglasValidacion() {
  
	  	document.getElementById('AnioExped').validationRules = ruleAnioExped;
	  	document.getElementById('AnioDesde').validationRules = ruleAnioDesde;
		document.getElementById('AnioHasta').validationRules = ruleAnioHasta;
		document.getElementById('ExpedDesde').validationRules = ruleExpedDesde;
		document.getElementById('ExpedHasta').validationRules = ruleExpedHasta;
		document.getElementById('fecEmision').validationRules = ruleFecEmision;
		document.getElementById('fecEmiDesde').validationRules = ruleFecEmiDesde;
		document.getElementById('fecEmiHasta').validationRules = ruleFecEmiHasta;
		document.getElementById('fecPagDesde').validationRules = ruleFecPagDesde;
		document.getElementById('fecPagHasta').validationRules = ruleFecPagHasta;
  }
	</script>
</head>

<map:body transition="auto" style="version1.0" onLoad="cargaInicial();">

<html:form action="impresionInformesVen">

<div id="Contenido">
<div id="CCOL">

<label id="TC"><bean:message key="rescate.impresionInformes.label.titulo.principal"/></label>

</div>

<map:group-box height="150" layout="line" titleKey="rescate.impresionInformes.label.titulo.auxiliar" width="100%">
	<br>

	<DIV>
			<span class="W15 I"><bean:message key="rescate.impresionInformes.label.impresionInformes" />:</span>
			<bean:define id="litImpresionInformes" type="String"><bean:message key="rescate.impresionInformes.label.impresionInformes"/></bean:define>
			<map:select showcode="false" property="tipo" tabindex="5" onchange="comboEmiFiniPrincipal();limpiarCampos();">
			  <map:defaultOption><bean:message key="rescate.desplegable.default"/></map:defaultOption>
			   <map:optionsJs tablename="t07953" lang="es" type="l"
								orderby="value" dir="asc" />
			  <map:validation rule="required">
			  <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
			  	<bean:message key="rescate.error.obligatorio" arg0="<%=litImpresionInformes%>"/>
			  </map:validation>			  
			</map:select>
	</DIV>
	
	<DIV id="tituloEtiqueta" style="display:none">
	<span class="W15 I H20"><bean:message key="rescate.impresionInformes.label.tituloAux2"/>:</span>
	</DIV>
	
	<DIV id="capaAnioExped" style="display:none">
		<span class="W15 I"><bean:message key="rescate.impresionInformes.label.anioExped"/>:</span>
		<bean:define id="litAnioExped" type="String"><bean:message key="rescate.impresionInformes.label.anioExped"/></bean:define>
		<map:text title="AnioExped" size="6" name="formImpresionInformes" id="AnioExped" maxlength="4" tabindex="10" property="anioExped">
		<map:validation rule="required">
			  <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
			  	<bean:message key="rescate.error.obligatorio" arg0="<%=litAnioExped%>"/>
			  </map:validation>	  	
	 		 <map:validation rule="integer">
			  	<bean:message key="rescate.error.numerico" arg0="<%=litAnioExped%>"/>
	 		</map:validation>	
	 		<map:validation rule = "intRange(0,9999)">
			  	<bean:message key="rescate.error.rango" arg0="<%=litAnioExped%>"/>
	 		</map:validation>
	 		</map:text>
	</DIV>

	<DIV id="capaAnioDesde" style="display:none">
		<span class="W15 I"><bean:message key="rescate.impresionInformes.label.anioDesde"/>:</span>
		<bean:define id="litAnioDesde" type="String"><bean:message key="rescate.impresionInformes.label.anioDesde"/></bean:define>
		<map:text title="AnioDesde" size="6" name="formImpresionInformes" id="AnioDesde" maxlength="4" tabindex="10" property="anioDesde">
		<%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
	 		  <map:validation rule="required">
			  <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
			  	<bean:message key="rescate.error.obligatorio" arg0="<%=litAnioDesde%>"/>
			  </map:validation>			  	
	 		 <map:validation rule="integer">
			  	<bean:message key="rescate.error.numerico" arg0="<%=litAnioDesde%>"/>
	 		</map:validation>	
	 		<map:validation rule = "intRange(0,9999)">
			  	<bean:message key="rescate.error.rango" arg0="<%=litAnioDesde%>"/>
	 		</map:validation>
	 		</map:text>
	</DIV>
	<DIV id="capaAnioHasta" style="display:none">
		<span class="W15 I"><bean:message key="rescate.impresionInformes.label.anioHasta"/>:</span>
	    <bean:define id="litAnioHasta" type="String"><bean:message key="rescate.impresionInformes.label.anioHasta"/></bean:define>
		<map:text title="AnioHasta" size="6" name="formImpresionInformes" id="AnioHasta" maxlength="4" tabindex="15" property="anioHasta">
		<%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
	 		  <map:validation rule="required">
			  <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
			  	<bean:message key="rescate.error.obligatorio" arg0="<%=litAnioHasta%>"/>
			  </map:validation>			  
	 		 <map:validation rule="integer">
			  	<bean:message key="rescate.error.numerico" arg0="<%=litAnioHasta%>"/>
	 		</map:validation>	
	 		<map:validation rule = "intRange(0,9999)">
			  	<bean:message key="rescate.error.rango" arg0="<%=litAnioHasta%>"/>
	 		</map:validation></map:text>
	</DIV>
	<DIV id="capaExpedDesde" style="display:none">
		<span class="W15 I"><bean:message key="rescate.impresionInformes.label.expedDesde"/>:</span>
	 	<bean:define id="litExpedDesde" type="String"><bean:message key="rescate.impresionInformes.label.expedDesde"/></bean:define>
	 	<map:text size="6" name="formImpresionInformes" id="ExpedDesde" maxlength="5" tabindex="20" property="expedDesde">					
		 <map:validation rule="required">
			  <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
			  	<bean:message key="rescate.error.obligatorio" arg0="<%=litExpedDesde%>"/>
			  </map:validation>	
			  </map:text>		  
	</DIV>
	<DIV id="capaExpedHasta" style="display:none">
		<span class="W15 I"><bean:message key="rescate.impresionInformes.label.expedHasta"/>:</span>
	 	<bean:define id="litExpedHasta" type="String"><bean:message key="rescate.impresionInformes.label.expedHasta"/></bean:define>
	 	<map:text size="6" name="formImpresionInformes" id="ExpedHasta" maxlength="5" tabindex="25" property="expedHasta">					
		<map:validation rule="required">
			  <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
			  	<bean:message key="rescate.error.obligatorio" arg0="<%=litExpedHasta%>"/>
			  </map:validation>	
			  </map:text>		
	</DIV>
	<DIV id="capafecEmision" style="display:none">
		<span class="W15 I"><bean:message key="rescate.impresionInformes.label.fecEmision"/>:</span>
		<bean:define id="litFecEfectEmision" type="String"><bean:message key="rescate.impresionInformes.label.fecEmision"/></bean:define>
		<map:date  name="fecEmision" srcName="formImpresionInformes" srcProperty="fecEmision" srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" calendar="true" tabindex="30">
		</map:date>		    
    </DIV>
    <DIV id="capafecCalculo" style="display:none">
		<span class="W15 I"><bean:message key="rescate.impresionInformes.label.fecCalculo"/>:</span>
		<bean:define id="litFecEfectCalculo" type="String"><bean:message key="rescate.impresionInformes.label.fecCalculo"/></bean:define>
		<map:date  name="fecCalculo" srcName="formImpresionInformes" srcProperty="fecCalculo" srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" calendar="true" tabindex="30">
		<map:validation rule="required">
			  <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion--%>
			  	<bean:message key="rescate.error.obligatorio" arg0="<%=litFecEfectCalculo%>"/>
			 </map:validation>
		</map:date>		    
    </DIV>
	<DIV id="capafecEmiDesde" style="display:none">
		<span class="W15 I"><bean:message key="rescate.impresionInformes.label.fecEmiDesde"/>:</span>
		<bean:define id="litFecEmiDesde" type="String"><bean:message key="rescate.impresionInformes.label.fecEmiDesde"/></bean:define>
		<map:date  name="fecEmiDesde" srcName="formImpresionInformes" srcProperty="fecEmiDesde" srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" calendar="true" tabindex="30">
		<map:validation rule="required">
			  <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
			  	<bean:message key="rescate.error.obligatorio" arg0="<%=litFecEmiDesde%>"/>
			 </map:validation>
		</map:date>		    
    </DIV>

	<DIV id="capafecEmiHasta" style="display:none">
		<span class="W15 I"><bean:message key="rescate.impresionInformes.label.fecEmiHasta"/>:</span>
		<bean:define id="litFecEmiHasta" type="String"><bean:message key="rescate.impresionInformes.label.fecEmiHasta"/></bean:define>
		<map:date  name="fecEmiHasta" srcName="formImpresionInformes" srcProperty="fecEmiHasta" srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" calendar="true" tabindex="30">
		<map:validation rule="required">
			  <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
			  	<bean:message key="rescate.error.obligatorio" arg0="<%=litFecEmiHasta%>"/>
		</map:validation>
		</map:date>		    
    </DIV>

	<DIV id="capafecPagDesde" style="display:none">
		<span class="W15 I"><bean:message key="rescate.impresionInformes.label.fecPagDesde"/>:</span>
		<bean:define id="litFecPagDesde" type="String"><bean:message key="rescate.impresionInformes.label.fecPagDesde"/></bean:define>
		<map:date  name="fecPagDesde" srcName="formImpresionInformes" srcProperty="fecPagDesde" srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" calendar="true" tabindex="30">
		<map:validation rule="required">
			  <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
			  	<bean:message key="rescate.error.obligatorio" arg0="<%=litFecPagDesde%>"/>
		</map:validation>
		</map:date>		    
    </DIV>
 
	<DIV id="capafecPagHasta" style="display:none">
		<span class="W15 I"><bean:message key="rescate.impresionInformes.label.fecPagHasta"/>:</span>
		<bean:define id="litFecPagHasta" type="String"><bean:message key="rescate.impresionInformes.label.fecPagHasta"/></bean:define>
		<map:date  name="fecPagHasta" srcName="formImpresionInformes" srcProperty="fecPagHasta" srcFormat="yyyyMMdd" targetFormat="yyyyMMdd" separator="true" calendar="true" tabindex="30">
		<map:validation rule="required">
			  <%-- Obtenemos el literal del campo para mapearlo al mensaje de error.para validacion --%>
			  	<bean:message key="rescate.error.obligatorio" arg0="<%=litFecPagHasta%>"/>
		</map:validation>
		</map:date>		    
    </DIV>
</map:group-box>
<!--String correcto = "false";-->
</div>
	<DIV id="BA" class="MInf">
		<div class ="W100 I" id="botones1">
		<span class="W100 D">
		<input type="hidden" name="tipOperacion"/>		
		<map:button name="Imprimir" title="Imprimir" onclick="imprimirFormulario();"><bean:message key="rescate.jsp.imprimir"/></map:button>			
		</span>
		</div>	
	</DIV>

</html:form>
</map:body>
</html>