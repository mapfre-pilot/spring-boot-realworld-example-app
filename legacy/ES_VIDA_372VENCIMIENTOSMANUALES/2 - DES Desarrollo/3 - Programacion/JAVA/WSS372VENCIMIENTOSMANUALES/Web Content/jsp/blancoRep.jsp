<%--
Descripcion : JSP plantilla en Blanco
Programador : EVERIS
Fecha : 06/2011
 Version : 1.0
--%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta http-equiv="refresh" content="2">
<title></title>
</head>
<script type="text/javascript">

<%-- Funcion Carga Inicial para la consulta de datos fiscales --%>
function cargarInicial() {
<%-- Para consulta de fiscalidad --%>
	try {
			parent.consultaFiscales();

	} catch (error) {
	}
}
</script>
<%-- Carga inicial --%>
<body onload="cargarInicial();">

</body>
</html>