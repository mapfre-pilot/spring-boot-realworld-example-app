<%-- MODIFICACION : MU-2016-006673
FECHA : MARZO 2016
DESCRIPCION: Se permite modificar y guardar en BBDD el kdomiclio del beneficiario
AUTOR : RAROALE --%>

<!-- MODIFICACION : MU-2016-006664
FECHA : MARZO 2016
DESCRIPCION: Se permite modificar y guardar en BBDD los importes de Coaseguros
AUTOR : RAROALE -->

<%--
Descripcion : JSP de busqueda de Expedientes Listado en Vencimiento
Programador : EVERIS
Fecha : 06/2011
 Version : 1.0
--%>

<%@page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%-- *** Librerías *** --%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/maptags.tld" prefix="map"%>
<%@ taglib uri="/WEB-INF/struts-nested.tld" prefix="nested"%>

<%@page import="java.util.List"%>
<html>

<%@ page
	import="com.mapfre.mavisa.wss372vencimientosmanuales.forms.J372J001BusquedaExpVenActionForm"%>
<%@ page import="com.mapfre.mavisa.wss372vencimientosmanuales.utils.Msg"%>

<% 	
	final String BusquedaExp = "formBusquedaExp";
	final J372J001BusquedaExpVenActionForm formBusquedaExp = (J372J001BusquedaExpVenActionForm) 
				request.getAttribute(BusquedaExp);

	final List vectorMensajes = formBusquedaExp.getVectorMensajes();
%>
<head>

<!-- *** Estilos *** -->
<LINK rel="stylesheet" type="text/css"
	href="<bean:write name="HTTP_PATH"/>/css/estilomapfre.css">
<LINK rel="stylesheet" type="text/css"
	href="<bean:write name="HTTP_PATH"/>/css/comun.css">
<LINK rel="stylesheet" type="text/css"
	href="<bean:write name="HTTP_PATH"/>/css/agrupacion.css">
<LINK rel="stylesheet" type="text/css"
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

<!-- *** JSs *** -->
<SCRIPT language="JavaScript1.2"
	src="<bean:write name="HTTP_PATH"/>/js/menu.js" type="text/javascript"></SCRIPT>
<SCRIPT language="JavaScript1.2"
	src="<bean:write name="HTTP_PATH"/>/js/comun.js" type="text/javascript"></SCRIPT>
<SCRIPT language="JavaScript1.2"
	src="<bean:write name="HTTP_PATH"/>/js/generales.js"
	type="text/javascript"></SCRIPT>
<SCRIPT language="JavaScript1.2"
	src="<bean:write name="HTTP_PATH"/>/js/validaciones.js"
	type="text/javascript"></SCRIPT>
<SCRIPT language="JavaScript1.2"
	src="<bean:write name="HTTP_PATH"/>/js/customtag-validations.js"
	type="text/javascript"></SCRIPT>
<SCRIPT language="JavaScript1.2"
	src="<bean:write name="HTTP_PATH"/>/js/mensajeespera.js"
	type="text/javascript"></SCRIPT>
<SCRIPT language="JavaScript1.2"
	src="<bean:write name="HTTP_PATH"/>/js/customtag.js"
	type="text/javascript"></SCRIPT>

<SCRIPT src="<bean:write name="HTTP_PATH"/>/js/t07906.js" type="text/javascript"></SCRIPT>


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
	
	var ruta = '<%=request.getContextPath()%>';	
	
	
	function selecionExp () {
	   
		
	   var selectedRow = getSelectedRows('tablaVen');
	   parent.pasarValores(selectedRow);
	   
	   }
		
	</script>

</head>

<map:body transition="auto" style="version1.0" onLoad="cargaInicial();">
<div id="Contenido" class="W100" style="height:25%">
	<html:form action="listadoBusquedaExpVen">
		<div class="H90">
		<div NOWRAP class="W98">
		<div NOWRAP id="TD"><bean:message
			key="rescate.BusquedaExp.label.titulo.tabla" /></div>

		<map:table tablename="tablaVen"
			dataProvider="com.mapfre.mavisa.wss372vencimientosmanuales.actions.J372J002BusquedaExpVenDataProvider"
			pagesInBlock="2" pagesize="10" width="100%">
			<script type="text/javascript">
					carga();
			</script>
			<map:selectColumn width="5%" type="single" name="formBusquedaExp" property="selectedRow" >

				<map:columnHeader></map:columnHeader>
				<map:columnId>
					<bean:write name="row" property="expediente"/>&<bean:write name="row" property="anio"/>
				</map:columnId>
			</map:selectColumn>

			<map:column width="10%">
				<map:columnHeader align="center">
					<bean:message key="rescate.BusquedaExp.label.anio" />

				</map:columnHeader>
				<map:columnContent>
					<bean:write name="row" property="anio" />
					<html:hidden name="row" property="anio" />

				</map:columnContent>
			</map:column>

			<map:column width="10%">
				<map:columnHeader align="center">
					<bean:message key="rescate.BusquedaExp.label.expediente" />
				</map:columnHeader>
				<map:columnContent>
					<bean:write name="row" property="expediente" />
					<html:hidden name="row" property="expediente" />
				</map:columnContent>
			</map:column>

			<map:column width="10%">
				<map:columnHeader align="center">
					<bean:message key="rescate.BusquedaExp.label.ramo" />
				</map:columnHeader>
				<map:columnContent>
					<bean:write name="row" property="ramo" />
					<html:hidden name="row" property="ramo" />
				</map:columnContent>
			</map:column>

			<map:column width="12%">
				<map:columnHeader align="center">
					<bean:message key="rescate.BusquedaExp.label.anioPoliza" />
				</map:columnHeader>
				<map:columnContent>
					<bean:write name="row" property="anioPoliza" />
					<html:hidden name="row" property="anioPoliza" />
				</map:columnContent>
			</map:column>

			<map:column width="10%">
				<map:columnHeader align="center">
					<bean:message key="rescate.BusquedaExp.label.numPoliza" />
				</map:columnHeader>
				<map:columnContent>
					<bean:write name="row" property="numPoliza" />
					<html:hidden name="row" property="numPoliza" />
				</map:columnContent>
			</map:column>
			<map:column width="10%">
				<map:columnHeader align="center">
					<bean:message key="rescate.BusquedaExp.label.subPoliza" />
				</map:columnHeader>
				<map:columnContent>
					<bean:write name="row" property="subPoliza" />
					<html:hidden name="row" property="subPoliza" />
				</map:columnContent>
			</map:column>
			<map:column width="10%">
				<map:columnHeader align="center">
					<bean:message key="rescate.BusquedaExp.label.certificado" />
				</map:columnHeader>
				<map:columnContent>
					<bean:write name="row" property="certificado" />
					<html:hidden name="row" property="certificado" />
				</map:columnContent>
			</map:column>
			<map:column width="10%">
				<map:columnHeader align="center">
					<bean:message key="rescate.BusquedaExp.label.situacion" />
				</map:columnHeader>
				<map:columnContent>
					<bean:write name="row" property="desSituacion" />
					<html:hidden name="row" property="situacion" />
				</map:columnContent>
			</map:column>
			<map:column width="20%">
				<map:columnHeader align="center">
					<bean:message key="rescate.BusquedaExp.label.nifCifBeneficiario" />
				</map:columnHeader>
				<map:columnContent>
					<bean:write name="row" property="nif1" />
					<html:hidden name="row" property="nif1" />

					<html:hidden name="row" property="modalidad" />
					<html:hidden name="row" property="canalCamp" />
					<html:hidden name="row" property="entidad" />
					<html:hidden name="row" property="duracion" />
					<html:hidden name="row" property="regional" />
					<html:hidden name="row" property="lugarEnvio" />
					<html:hidden name="row" property="oficina" />
					<html:hidden name="row" property="pendiente" />
					<html:hidden name="row" property="tipoPers1" />
					<html:hidden name="row" property="residente1" />
					<html:hidden name="row" property="persona1" />
					<%-- MU-2016-006673 - RAROALE - INI--%>
					<html:hidden name="row" property="domicilio1"/>
					<html:hidden name="row" property="fmodificacion"/>
					<%-- MU-2016-006673 - RAROALE - FIN--%>
					<html:hidden name="row" property="fecPagComp" />
					<html:hidden name="row" property="fecPagComp2" />
					<html:hidden name="row" property="fecPagoCapital" />
					<html:hidden name="row" property="fecEmision" />
					<html:hidden name="row" property="fecEfecto" />
					<html:hidden name="row" property="impRtorintegrcap" />
					<html:hidden name="row" property="impRedPriCap" />
					<html:hidden name="row" property="impRedTranCap" />
					<html:hidden name="row" property="impCompensatoria" />
					<html:hidden name="row" property="impRtonetoCap" />
					<html:hidden name="row" property="porretCap" />
					<html:hidden name="row" property="impretCap" />
					<html:hidden name="row" property="impliqCap" />
					<html:hidden name="row" property="fecImpreCap" />
					<html:hidden name="row" property="fecPagret" />
					<html:hidden name="row" property="impAnticipo" />
					<html:hidden name="row" property="impInteresPendiente" />
					<html:hidden name="row" property="fecVencimientoCap" />
					<html:hidden name="row" property="tipImpuestoCap" />
					<html:hidden name="row" property="impCapital" />
					<html:hidden name="row" property="impBeneficios" />
					<html:hidden name="row" property="impRtointComp" />
					<html:hidden name="row" property="impRedpriComp" />
					<html:hidden name="row" property="impRedTranComp" />
					<html:hidden name="row" property="irTonetComp" />
					<html:hidden name="row" property="porretComp" />
					<html:hidden name="row" property="iretComp" />
					<html:hidden name="row" property="iliqComp" />
					<html:hidden name="row" property="fecImpreComp" />
					<html:hidden name="row" property="fecPagretCom" />
					<html:hidden name="row" property="tipImpuestComp" />
					<html:hidden name="row" property="impComp" />
					<html:hidden name="row" property="fecCemiComp" />
					<html:hidden name="row" property="impRtointComp2" />
					<html:hidden name="row" property="impRedpriComp2" />
					<html:hidden name="row" property="impRedTranComp2" />
					<html:hidden name="row" property="irTonetComp2" />
					<html:hidden name="row" property="porretComp2" />
					<html:hidden name="row" property="iretComp2" />
					<html:hidden name="row" property="iliqComp2" />
					<html:hidden name="row" property="fecImpreComp2" />
					<html:hidden name="row" property="fecPagretCom2" />
					<html:hidden name="row" property="tipImpuestComp2" />
					<html:hidden name="row" property="impComp2" />
					<html:hidden name="row" property="fecCemiComp2" />
					<html:hidden name="row" property="codCoA1" />
					<html:hidden name="row" property="porCoA1" />
					<html:hidden name="row" property="codCoA2" />
					<html:hidden name="row" property="porCoA2" />
					<html:hidden name="row" property="codCoA3" />
					<html:hidden name="row" property="porCoA3" />
					<html:hidden name="row" property="codCoA4" />
					<html:hidden name="row" property="porCoA4" />
					<html:hidden name="row" property="codCoA5" />
					<html:hidden name="row" property="porCoA5" />
					<html:hidden name="row" property="codCoA6" />
					<html:hidden name="row" property="porCoA6" />
					<!--MU-2016-006664 - RAROALE - INI-->
					<html:hidden name="row" property="impCoA1"/>
					<html:hidden name="row" property="impCoA2"/>
					<html:hidden name="row" property="impCoA3"/>
					<html:hidden name="row" property="impCoA4"/>
					<html:hidden name="row" property="impCoA5"/>
					<html:hidden name="row" property="impCoA6"/>
					<!--MU-2016-006664 - RAROALE - FIN-->
					<html:hidden name="row" property="fecBDGICap" />
					<html:hidden name="row" property="fecBDGIComp1" />
					<html:hidden name="row" property="fecBDGIComp2" />  
					<html:hidden name="row" property="pagotot" />
					<html:hidden name="row" property="cartera" />
					<html:hidden name="row" property="reaseguro" />
					<html:hidden name="row" property="usuarioC" />
					<html:hidden name="row" property="observacionesG" />
					<html:hidden name="row" property="eximido" /> <!-- R&V - CU009 -->

				</map:columnContent>
			</map:column>

			<map:tableNavigation position="bottom" summary="false" />

		</map:table> <html:hidden property="selectedRow" />
		</div>
		</div>

		<%
			final J372J001BusquedaExpVenActionForm formulario = (J372J001BusquedaExpVenActionForm) request
					.getSession().getAttribute(BusquedaExp);
			final J372J001BusquedaExpVenActionForm formRequest = (J372J001BusquedaExpVenActionForm) request
					.getAttribute(BusquedaExp);
			formRequest.setVectorMensajes(formulario.getVectorMensajes());
			request.setAttribute(BusquedaExp, formRequest);
		%>
	</html:form>
	</div>
	<DIV id="BA" class="MInf">
		<div><span class="W50 I"> <input type="hidden"
			name="operacion" /> </span> <span class="W50 D"> <map:contextualButton name="Seleccionar"
			title="Seleccionar" onclick="selecionExp();" accesskey="s"><bean:message
						key="rescate.jsp.seleccionar" /></map:contextualButton>
		</span></div>
		</DIV>
</map:body>
</html>
