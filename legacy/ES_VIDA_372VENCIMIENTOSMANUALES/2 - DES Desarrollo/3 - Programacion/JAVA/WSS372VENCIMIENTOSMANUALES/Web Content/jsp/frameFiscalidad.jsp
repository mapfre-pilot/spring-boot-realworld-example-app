<%--
Descripcion : JSP para datos de fiscalidad en Vencimiento
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

	
<% 
	final String nifPersona = request.getParameter("nifCifPri");
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
<script src="<html:rewrite page="/js/GenericoVen.js"/>"
	language="JavaScript" type="text/JavaScript"></script>
	
<script type="text/javascript">



<%-- Modificamos los elementos del proyecto de fiscalidad, 
cambiando el boton de Aceptar por el de Seleccionar.--%>
function consultaFiscales() {

	document.frames.frames[0].document.getElementById('btnAceptar').disabled=false
	document.frames.frames[0].document.getElementById('btnAceptar').value = "Seleccionar";
	document.frames.frames[0].document.getElementById('btnAceptar').onclick = modiFormulario;

}

<%-- Abrimos el popup de personas--%>
function abrirPopupPersonas1() {
		
		var stTipoPer;
		var stCcompania = 0;
		var stNombrePersona = document.frames.frames[0].document.getElementById('objPersonaVO.stNombrePersona').value;
		var stApellido1 = document.frames.frames[0].document.getElementById('objPersonaVO.stApellido1').value;
		var stApellido2 = document.frames.frames[0].document.getElementById('objPersonaVO.stApellido2').value;
		var stCodDocumentoPersona = document.frames.frames[0].document.getElementById('objPersonaVO.stCodDocumentoPersona').value;
		var blBuscarPorCodigo = trim(stCodDocumentoPersona) != "";
		var blBuscarPorNombre = trim(stNombrePersona) != "" || trim(stApellido1) != "" || trim(stApellido2);
		var stCodTipoDocumentoPersona = '';
		
		if(fEsNumerico(stCodDocumentoPersona.substring(0,1))){
			stTipoPer= 'F';
			stCodTipoDocumentoPersona = '2';
		}else{
			if(!fEsNumerico(stCodDocumentoPersona.substring(8,9))){
				stTipoPer= 'F';
				stCodTipoDocumentoPersona = '2';
			}else{
				stTipoPer= 'J';
				stCodTipoDocumentoPersona = '5';
			}
		}
	
		if (blBuscarPorCodigo) {
			<%-- búsqueda por código--%>
			stCodDocumentoPersona =  stCodDocumentoPersona + calcularLetraNIF(stCodDocumentoPersona);
				url= "/WSS620PERSONAS3/Personas.do?stOperativa=MANTENIMIENTO&stProcedencia=RENTAS&stTipoPer="+stTipoPer+"&stPantallaModal=S&stTipoDoc="+stCodTipoDocumentoPersona+"&stNif="+stCodDocumentoPersona+"&stNombre=&stApell1=&stApell2=&stCompania="+stCcompania;			
				
		} else {
			if (blBuscarPorNombre){
				url= "/WSS620PERSONAS3/Personas.do?stOperativa=MANTENIMIENTO&stProcedencia=RENTAS&stTipoPer="+stTipoPer+"&stPantallaModal=S&stTipoDoc=&stNif=&stNombre="+stNombrePersona+""+"&stApell1="+stApellido1+"&stApell2="+stApellido2+"&stCompania="+stCcompania;					
			}else{
				url= "/WSS620PERSONAS3/Inicio.do?stPantallaModal=S&stTipoDoc=&stNif=&stNombre=&stApell1=&stApell2=&stCompania="+stCcompania+"&stProcedencia=RENTAS";
			}
		}	
		
		var objeto = new Object();
		objeto.ventana =  window;
		objeto.nombre = "ventanaEmergente";
				
		abrirVentana(String(url),objeto,"dialogwidth=750px;dialogheight=600px;dialogLeft=80px;dialogTop=30px;help=no;status=no");
}

<%-- Recuperamos los datos de la persona--%>

function recibirPersona(objPersona){

	document.frames.frames[0].document.getElementById('objPersonaVO.stCodPersona').value = objPersona.stKpersona;
	if (objPersona.stNif!='') { 
		document.frames.frames[0].document.getElementById('objPersonaVO.stCodDocumentoPersona').value = objPersona.stNif;
	}
	if (objPersona.stTipoDoc == '5'){
		document.frames.frames[0].document.getElementById('objPersonaVO.stNombrePersona').value = objPersona.stRazonSocial;
	}else{
		document.frames.frames[0].document.getElementById('objPersonaVO.stNombrePersona').value = objPersona.stNombre;
		document.frames.frames[0].document.getElementById('objPersonaVO.stApellido1').value = objPersona.stApell1;
		document.frames.frames[0].document.getElementById('objPersonaVO.stApellido2').value = objPersona.stApell2;
	}
	
	<%-- Enviamos la información de la persona a la pantalla de Gestión de Expedientes.--%>
	window.dialogArguments.ventana.recibirPersona(objPersona);
}

<%--Calcular domicilio al recibirlo--%>
function recibirDomicilio(objDomicilio){
	  
		window.dialogArguments.ventana.recibirDomicilio(objDomicilio);
	}


<%-- Objeto con información fiscal--%>

function datosFiscalesBean() {
	
	
	var stCodSituacionFamiliar ="";
	var stCodNifConyuge ="";
	var stCodGradoDisc ="";
	var stImpAnualAlim ="";
	var stImpPensionCom ="";
	var stPrestViv ="";	
}

<%-- Al pulsar SELECCIONAR recuperamos los datos fiscales,y creamos un objeto para recuperar sus valorees en Gestión de Expedientes.	--%>

function modiFormulario() {

	datosFiscalesBean = new datosFiscalesBean();
	
	datosFiscalesBean.stCodSituacionFamiliar = document.frames.frames[0].document.getElementById('objDatosFiscalesVO.stCodSituacionFamiliar').value;
	datosFiscalesBean.stCodGradoDisc = document.frames.frames[0].document.getElementById('objDatosFiscalesVO.stCodGradoDisc').value;
	datosFiscalesBean.stCodNifConyuge = document.frames.frames[0].document.getElementById('objDatosFiscalesVO.stCodNifConyuge').value;
	datosFiscalesBean.stImpAnualAlim = document.frames.frames[0].document.getElementById('objDatosFiscalesVO.stImpAnualAlim').value;
	datosFiscalesBean.stImpPensionCom = document.frames.frames[0].document.getElementById('objDatosFiscalesVO.stImpPensionCom').value;
	datosFiscalesBean.stPrestViv = document.frames.frames[0].document.getElementById('objDatosFiscalesVO.stPrestViv').value;
	
	
	window.dialogArguments.ventana.pasarDatosFiscales(datosFiscalesBean);
	window.close();
	

}

<%-- En la carga inicial recuperamos los datos de la persona, y cambiamos la función onclick del botón busqueda de personas.--%>
function inicio() {

document.frames.frames[0].document.getElementById('imgBuscarPersona').onclick = abrirPopupPersonas1;
document.frames.frames[0].document.getElementById('objPersonaVO.stCodDocumentoPersona').value = <%=nifPersona%>;
	
}
</script>
</head>


<body onload="inicio();"> 
  <IFRAME id="frameFiscalidad" src="/wss160fiscalidad/consultarPersonasTemp.do"width="100%" height="100%" scrolling="no" frameborder="0" >
  </IFRAME>
    <IFRAME id="frameFiscalidad1" src="/WSS372VENCIMIENTOSMANUALES/jsp/blancoRep.jsp" width="1" height="1" scrolling="no" frameborder="0">
  </IFRAME>
 
</body>
</html>