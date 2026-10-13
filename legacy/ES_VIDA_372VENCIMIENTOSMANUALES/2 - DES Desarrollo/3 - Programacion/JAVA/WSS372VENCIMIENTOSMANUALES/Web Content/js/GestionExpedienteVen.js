/* MODIFICACION : MU-2016-006673
FECHA : MARZO 2016
DESCRIPCION: Se permite modificar y guardar en BBDD el kdomiclio del beneficiario
AUTOR : RAROALE */

/*MODIFICACION : MU-2016-006664
FECHA : MARZO 2016
DESCRIPCION: Se permite modificar y guardar en BBDD los importes de Coaseguros
AUTOR : RAROALE */



// R&V Junio 2017 - CU011 - everis(RGL) - INI
function anadirCuadroCoaseguro(){
    var form= document.forms['formGestionExped'];

    var errors = validateForm(form);
    if(errors.length > 0) {
        return;
    }
    pasarDatosDisabled();
    document.forms[0].action = 'cargarCuadroCoasegurosVen.do';
    document.forms[0].submit();
}
// R&V Junio 2017 - CU011 - everis(RGL) - FIN







/**
* Con esta funcion queremos delimitar el numero de caracteres que podemos.
* meter en el campo de observaciones.
* @author EVERIS
* @param caracter
*/

   function controlCaracteres (caracter) {
	
	var numero = new String(caracter);

   if(numero.length > 255){
		   ctInfo('Ha superado el límite de caracteres permitido');

	document.getElementById('Observaciones').value = caracter.substring(0,255);
		 }   
   }
   
 /**
* Damos valora las pestañas
* @author EVERIS
* @param pestana
*/  
   function valorPestana (pestana) {
   		if(pestana == 0) {
   			document.forms[0].elements['pestanaJSP'].value = '0';
   		} else if(pestana == 1) {
   			document.forms[0].elements['pestanaJSP'].value = '1';
   		} else if(pestana == 2) {
   			document.forms[0].elements['pestanaJSP'].value = '2';
   		} else if(pestana == 3) {
   			document.forms[0].elements['pestanaJSP'].value = '3';
        // R&V Junio 2017 - CU011 - everis(RGL) - INI
        } else if(pestana == 4) {
   			document.forms[0].elements['pestanaJSP'].value = '4';
   		}
        // R&V Junio 2017 - CU011 - everis(RGL) - FIN
   }
   
   
/**
* Calculo para que si tiene más de dosdecimales lo recorte y solo muestredos decimales
* @author EVERIS
* @param valor
* @param decimales
*/ 
   	function precisionDecimales (valor,decimales) {
   		var valorCalculado = new Number (valor);
   		valorCalculado = valorCalculado.toFixed(decimales);
   		/**
   		if (valor.indexOf('.') != -1 && valor.length > valor.indexOf('.') + 1 + decimales) {
	   		   		
	   		var valorCalculado;
	   		var valorDecimal = valor.substring(valor.indexOf('.')+1,valor.indexOf('.') + 1 + decimales);
	  
	   		valorCalculado = valor.substring(0,valor.indexOf('.')+1) + valorDecimal;   		
	   	
   		}else {
   			valorCalculado = valor;
   		}**/
   		return valorCalculado;
   	}
   	  
     
/**
* Al introducir el importe principal habilitamos algunos campos de complementario
* @author EVERIS
*/     	
   		function modificacionComplementario2 () {
   			
			var importePri = parseFloat(cambiarPuntoComa(document.getElementById('ImportePri').value));
			
			if (isNaN(importePri) || importePri == 0) 
			{
				document.getElementById('ImporteComp').disabled = 'disabled';
				document.getElementById('fecPagoComp_day').disabled = 'disabled';
				document.getElementById('fecPagoComp_month').disabled = 'disabled';
				document.getElementById('fecPagoComp_year').disabled = 'disabled';
				document.getElementById('fecPagoComp_trigger').className = "Oculto";
				document.getElementById('fecEmisionComp_day').disabled = 'disabled';
				document.getElementById('fecEmisionComp_month').disabled = 'disabled';
				document.getElementById('fecEmisionComp_year').disabled = 'disabled';
				document.getElementById('fecEmisionComp_trigger').className = "Oculto";
				
				document.getElementById('RtoIntegroComp').disabled = 'disabled';
				
				document.getElementById('RedPrimasComp').disabled = 'disabled';
				
				document.getElementById('RedTransitComp').disabled = 'disabled';
				
				document.getElementById('PorcentajeComp').disabled = 'disabled';
				
				document.getElementById('fecPagoIRPFComp_day').disabled = 'disabled';
				document.getElementById('fecPagoIRPFComp_month').disabled = 'disabled';
				document.getElementById('fecPagoIRPFComp_year').disabled = 'disabled';
				document.getElementById('fecPagoIRPFComp_trigger').className = "Oculto";
				
				document.getElementById('LiquidoComp').disabled = 'disabled';	
				
				document.getElementById('tipImpuestoComp').disabled = 'disabled';
				
				document.getElementById('RetencionComp').disabled = 'disabled';
			
			   
			} else {
				document.getElementById('ImporteComp').disabled = '';	
				document.getElementById('fecPagoComp').disabled = '';
				document.getElementById('fecPagoComp_day').disabled = '';
				document.getElementById('fecPagoComp_month').disabled = '';
				document.getElementById('fecPagoComp_year').disabled = '';
				document.getElementById('fecPagoComp_trigger').className = "Inline";
				document.getElementById('fecEmisionComp_day').disabled = '';
				document.getElementById('fecEmisionComp_month').disabled = '';
				document.getElementById('fecEmisionComp_year').disabled = '';
				document.getElementById('fecEmisionComp_trigger').className = "Inline";
				document.getElementById('tipImpuestoComp').disabled = '';
			
				document.getElementById('RtoIntegroComp').disabled = '';
				document.getElementById('RedPrimasComp').disabled = '';
				document.getElementById('RedTransitComp').disabled = '';
				document.getElementById('PorcentajeComp').disabled = '';
				document.getElementById('fecPagoIRPFComp_day').disabled = '';
				document.getElementById('fecPagoIRPFComp_month').disabled = '';
				document.getElementById('fecPagoIRPFComp_year').disabled = false;
				document.getElementById('fecPagoIRPFComp_trigger').className = "Inline";
				document.getElementById('LiquidoComp').disabled = false;
				document.getElementById('RetencionComp').disabled = false;
	    	}
	    	
    	}
/**
* Funcionalidad del complementario primero para su habilitacion o deshabilitacion.	
* @author EVERIS
*/     	
   function modificacionComplementario1 () {
			
			var impCapital = parseFloat(cambiarPuntoComa(document.getElementById('ImpCapital').value));
			
			if (isNaN(impCapital) || impCapital == 0) 
			{
			
				document.getElementById('ImportePri').disabled = 'disabled';
				document.getElementById('fecPagoPri_day').disabled = 'disabled';
				document.getElementById('fecPagoPri_month').disabled = 'disabled';
				document.getElementById('fecPagoPri_year').disabled = 'disabled';
				document.getElementById('fecPagoPri_trigger').className = "Oculto";
				document.getElementById('fecEmisionPri_day').disabled = 'disabled';
				document.getElementById('fecEmisionPri_month').disabled = 'disabled';
				document.getElementById('fecEmisionPri_year').disabled = 'disabled';
				document.getElementById('fecEmisionPri_trigger').className = "Oculto";
				document.getElementById('RtoIntegroPri').disabled = 'disabled';
				document.getElementById('RedPrimasPri').disabled = 'disabled';
				document.getElementById('RedTransitPri').disabled = 'disabled';
				document.getElementById('PorcentajePri').disabled = 'disabled';
				document.getElementById('fecPagoIRPFPri_day').disabled = 'disabled';
				document.getElementById('fecPagoIRPFPri_month').disabled = 'disabled';
				document.getElementById('fecPagoIRPFPri_year').disabled = 'disabled';
				document.getElementById('fecPagoIRPFPri_trigger').className = "Oculto";
				document.getElementById('LiquidoPri').disabled = 'disabled';	
				document.getElementById('tipImpuestoPri').disabled = 'disabled';
				document.getElementById('RetencionPri').disabled = 'disabled';
			
			   
			} else {
			
				document.getElementById('ImportePri').disabled = '';	
				document.getElementById('fecPagoPri').disabled = '';
				document.getElementById('fecPagoPri_day').disabled = '';
				document.getElementById('fecPagoPri_month').disabled = '';
				document.getElementById('fecPagoPri_year').disabled = '';
				document.getElementById('fecPagoPri_trigger').className = "Inline";
				document.getElementById('fecEmisionPri_day').disabled = '';
				document.getElementById('fecEmisionPri_month').disabled = '';
				document.getElementById('fecEmisionPri_year').disabled = '';
				document.getElementById('fecEmisionPri_trigger').className = "Inline";
				document.getElementById('tipImpuestoPri').disabled = '';
				document.getElementById('RtoIntegroPri').disabled = '';
				document.getElementById('RedPrimasPri').disabled = '';
				document.getElementById('RedTransitPri').disabled = '';
				document.getElementById('PorcentajePri').disabled = '';
				document.getElementById('fecPagoIRPFPri_day').disabled = '';
				document.getElementById('fecPagoIRPFPri_month').disabled = '';
				document.getElementById('fecPagoIRPFPri_year').disabled = false;
				document.getElementById('fecPagoIRPFPri_trigger').className = "Inline";
				document.getElementById('LiquidoPri').disabled = false;
				document.getElementById('RetencionPri').disabled = false;
				
	    	}
	    	 
	    	
    	}
   	
/**
* Tomamos como referrencia el numero 2 por el valor del elemento en la lista en vez de el nº12 que es lo q tiene
* @author EVERIS
*/   	
	//MU-2016-006664 - RAROALE - INI
   	function cambiosTipImpuesto(tipo) {
	//MU-2016-006664 - RAROALE - FIN
   		
   		var tipImpuesto = document.getElementById('tipImpuestoCap').selectedIndex;
   		
   		document.getElementById('RedPrimasCap').disabled = '';
   		document.getElementById('RedTransitCap').disabled = '';
   	
   		//document.getElementById('CompensaCap').value = '0,00';
   		// document.getElementById('CompensaCap').disabled = true; // R&V IN002
   		
		/*
		* Tipo de impuesto MOBILIARIO
		*/
		
   		if (tipImpuesto == '2') {
			
   			//document.getElementById('CompensaCap').disabled = ''; // R&V IN002
   			document.getElementById('RedPrimasCap').value = '0,00';
   			document.getElementById('RedPrimasCap').disabled = true;
   		
   		} 
   		
   		if (tipImpuesto != '2') {
   			document.getElementById('CompensaCap').value = '0,00';
   		}
   		
   		/*
		* Tipo de impuesto SOCIEDADES
		*/
		
   		if (tipImpuesto == '3') {
   			document.getElementById('RedPrimasCap').value = '0,00';
   			document.getElementById('RedPrimasCap').disabled = true;
   		
   		} 
   		
   		/*
		* Tipo de impuesto TRABAJO
		*/
		
   		if (tipImpuesto == '1') {
   			document.getElementById('RedTransitCap').value = '0,00';
   			document.getElementById('RedTransitCap').disabled = true;
   		
   		} 
		//MU-2016-006664 - RAROALE - INI
   		calculoRtoNeto('Cap', tipo);
   		calculoLiquido(tipo);
   		calculoRetencion('Cap', tipo);
   		//MU-2016-006664 - RAROALE - FIN
   	}
   	
/**
* Cambio de tipo de impuesto complementario
* @author EVERIS
*/    	

   	function cambiosTipImpuestoComp() {
   		
   		var tipImpuestoComp = document.getElementById('tipImpuestoComp').selectedIndex;
   		
   		document.getElementById('RedPrimasComp').disabled = '';
   		document.getElementById('RedTransitComp').disabled = '';
   		
		/*
		* Tipo de impuesto MOBILIARIO
		*/
		
   		if (tipImpuestoComp == '2') {
			document.getElementById('RedPrimasComp').value = '0,00';
   			document.getElementById('RedPrimasComp').disabled = true;
   		
   		}
   		
   		/*
		* Tipo de impuesto SOCIEDADES
		*/
		
   		if (tipImpuestoComp == '3') {
   			document.getElementById('RedPrimasComp').value = '0,00';
   			document.getElementById('RedPrimasComp').disabled = true;
   		}
   		
   		/*
		* Tipo de impuesto TRABAJO
		*/
		
   		if (tipImpuestoComp == '1') {
   			document.getElementById('RedTransitComp').value = '0,00';
   			document.getElementById('RedTransitComp').disabled = true;
   		
   		} 
   		
   		calculoRtoNeto('Comp');
   		calculoRetencion('Comp');
   		calculoLiquido();
 
   	}
   	
/**
* Cambio de tipo de impuesto complementario
* @author EVERIS
*/    	

   	function cambiosTipImpuestoPri() {
   		
   		var tipImpuesto = document.getElementById('tipImpuestoPri').selectedIndex;
   		
   		document.getElementById('RedPrimasPri').disabled = '';
   		document.getElementById('RedTransitPri').disabled = '';
   		
		/*
		* Tipo de impuesto MOBILIARIO
		*/
		
   		if (tipImpuesto == '2') {
			document.getElementById('RedPrimasPri').value = '0,00';
   			document.getElementById('RedPrimasPri').disabled = true;
   		
   		}
   		
   		/*
		* Tipo de impuesto SOCIEDADES
		*/
		
   		if (tipImpuesto == '3') {
   			document.getElementById('RedPrimasPri').value = '0,00';
   			document.getElementById('RedPrimasPri').disabled = true;
   		}
   		
   		/*
		* Tipo de impuesto TRABAJO
		*/
		
   		if (tipImpuesto == '1') {
   			document.getElementById('RedTransitPri').value = '0,00';
   			document.getElementById('RedTransitPri').disabled = true;
   		
   		} 
   		
   		calculoRtoNeto('Pri');
   		calculoRetencion('Pri');
   		calculoLiquido();
 
   	}   	   	
 	
/**
* Modificar botones formulario
* @author EVERIS
*/ 
   	function modiFormulario(){
		var capaBoton = parent.document.getElementById("BOTONES1");
		
		habilitacionInicialCampos();
		modificacionComplementario1();
		modificacionComplementario2();
		
		
		capaBoton.style.display = "block";
		
		parent.document.getElementById('Modificar').disabled = 'true';
		parent.document.getElementById('Alta').disabled = 'true';
		parent.document.getElementById('Buscar').disabled = 'true';
		
		document.forms[0].elements['tipOperacion'].value = 'MO';
		
		
	}

/**
* Alta formulario
* @author EVERIS
*/ 
    function altaFormulario(){
    
 
		var capaBoton = parent.document.getElementById("BOTONES1");
		
		habilitacionInicialCampos();
		limpiarCamposGene();
		limpiarCamposBene();
		modificacionComplementario1();
		modificacionComplementario2(); 
		capaBoton.style.display = "block";
		
		parent.document.getElementById('Modificar').disabled = 'true';
		parent.document.getElementById('Alta').disabled = 'true';
		parent.document.getElementById('Buscar').disabled = 'true';
		
		document.forms[0].elements['tipOperacion'].value = 'AL';
		
	
	}
/**
* Consulta Cartera
* @author EVERIS
*/
	function consultaCartera(){
	
	
		
		var form= document.forms['formGestionExped'];
		var errors = validateForm(form);		
		if(errors.length > 0) {
			return;
		}
		pasarDatosDisabled();
		
		document.forms[0].action = 'consultaCarteraVen.do';	
		document.forms[0].submit();
	}
	
/**
* Eliminacion de formulario
* @author EVERIS
*/	
		function elimFormulario(){
		var valorMarcado = true;
		
		valorMarcado = ctConfirm("¿Esta seguro de eliminar el expediente?", "Cancelar", "Aceptar");
		
		var form= document.forms['formGestionExped'];
		var errors = validateForm(form);		
		if(errors.length > 0) {
			return;
		}
		
		if (!valorMarcado) {
			document.forms[0].elements['tipOperacion'].value = 'AN';
			document.forms[0].submit();	
		} else {
			habilitacionInicial();
			habilitacionInicialCampos();
		}
		
	}
/** 
* Funcionalidad para pasar la fecha al formato correcto
* @author EVERIS
* @param posicionFecha
* @param fecha
*/ 

function pasarFecha(posicionFecha, fecha){

	if (fecha.length == 10) {
		document.getElementById(posicionFecha+'_day').value = fecha.substring(0,2);
		document.getElementById(posicionFecha+'_month').value = fecha.substring(3,5);
		document.getElementById(posicionFecha+'_year').value = fecha.substring(6);
	} else if (fecha.length == 8) {
		document.getElementById(posicionFecha+'_day').value = fecha.substring(6,8);
		document.getElementById(posicionFecha+'_month').value = fecha.substring(4,6);
		document.getElementById(posicionFecha+'_year').value = fecha.substring(0,4);
	
	} else {
		limpiarFechas(posicionFecha);
	}
}

/* 
* Abrimos la ventana de busqueda expediente desde el boton buscar de gestion expediente 
* @author EVERIS
*/

	function buscarExpediente() {

		var objeto = new Object();
		objeto.ventana = window;
		objeto.nombre = "ventanaEmergente1";

		abrirVentana(String('inicioBusquedaExpVen.do'),objeto,"dialogwidth=750px;dialogheight=600px;dialogLeft=80px;dialogTop=30px;help=no;status=no");


	}
	
/** 
* funcion para pasar los valores de la lista de busqueda expediente a gestion de expediente, 
* se divide en dos funciones para que pase a calidad en código
* @author EVERIS
* @param busqueda
*/	

function pasarValoresGestExp(busqueda){

    document.getElementById('Anio').value = busqueda.anio;
    document.getElementById('Expediente').value = busqueda.expediente;
    document.getElementById('Poliza1').value = busqueda.ramo;
    document.getElementById('Poliza2').value = busqueda.anioPoliza;
    document.getElementById('Poliza3').value = busqueda.numPoliza;
    document.getElementById('SubPoliza').value = busqueda.subPoliza;
   
    document.getElementById('Certificado').value = busqueda.certificado;
    document.getElementById('Modalidad').value = busqueda.modalidad;
    document.getElementById('CanalCamp').value = busqueda.canalCamp;
    document.getElementById('Entidad').value = busqueda.entidad;
    document.getElementById('Duracion').value = busqueda.duracion;
    document.getElementById('regionalPol').value = busqueda.regional;
    
    document.getElementById('regionalEnv').value = busqueda.lugarEnvio;
    document.getElementById('Oficina').value = busqueda.oficina;
    document.getElementById('Pendiente').value = busqueda.pendiente;
    
    document.getElementById('tipSituacion').value = busqueda.situacion;
    
    alert("El valor del checkd es -->" + busqueda.situacion);
    if (busqueda.situacion == 'VI'){
		
		document.getElementById('TipSituacion1').checked = 'checked';
		document.getElementById('TipSituacion2').checked = '';
		 
	} else if (busqueda.situacion == 'AN'){
	
		document.getElementById('TipSituacion1').checked = '';
		document.getElementById('TipSituacion2').checked = 'checked';
	}
     
    if (busqueda.tipoPers1 == 'F') {
			
		document.getElementById("TipPersona1Pri").checked = 'checked';
		document.getElementById("TipPersona2Pri").checked = '';
			
	} else if (busqueda.tipoPers1 == 'J') {
	
		document.getElementById("TipPersona1Pri").checked = '';
		document.getElementById("TipPersona2Pri").checked = 'checked';
	}
    	
     if (busqueda.residente1 == '1') {
			
		document.getElementById("Residente1Pri").checked = 'checked';
		document.getElementById("Residente2Pri").checked = '';
			
	} else if (busqueda.residente1 == '2') {
	
		document.getElementById("Residente1Pri").checked = '';
		document.getElementById("Residente2Pri").checked = 'checked';
	}

    //R&V - CU009 - INI
	 if (busqueda.eximido == 'S'){

    		document.getElementById("eximido1").checked = '';
    		document.getElementById("eximido2").checked = 'checked';

     } else {

    		document.getElementById("eximido1").checked = 'checked';
            document.getElementById("eximido2").checked = '';
     }
    //R&V - CU009 - FIN

     document.getElementById('NIFCIFPri').value = busqueda.nif1;
     document.getElementById('kpersonaPri').value = busqueda.persona1;
     
     // MU-2016-006673 - RAROALE - INI
     document.getElementById('kdomicilioPri').value = busqueda.domicilio1;
     document.getElementById('fmodificacion').value = busqueda.fmodificacion;
     // MU-2016-006673 - RAROALE - FIN
     
     //pasamos valores a la siguiente funcion     
     segPasarValoresGestExp(busqueda);
 
     }
 /**
* funcion para pasar los valores de la lista de busqueda expediente a gestion de expediente.
* @author EVERIS
* @param busqueda
*/    
  
function segPasarValoresGestExp(busqueda){   
	
	 //Para reemplazar los puntos por las comas, mejora comunicación con cobol.
     pasarFecha('fecPagoPri',busqueda.fecPagComp);
     pasarFecha('fecPagoComp',busqueda.fecPagComp2);  
	 pasarFecha('fecPagoCapital',busqueda.fecPagoCapital);
	 pasarFecha('fecEmision',busqueda.fecEmision);
	 pasarFecha('fecEfect',busqueda.fecEfecto);
	 
	 //IRPF CAPITAL
     document.getElementById('RtoIntegroCap').value = busqueda.impRtorintegrcap.toString().replace('.',',');
     document.getElementById('RedPrimasCap').value = busqueda.impRedPriCap.toString().replace('.',',');
     document.getElementById('RedTransitCap').value = busqueda.impRedTranCap.toString().replace('.',',');
     document.getElementById('CompensaCap').value = busqueda.impCompensatoria.toString().replace('.',',');
     document.getElementById('RtoNetoCap').value = busqueda.impRtonetoCap.toString().replace('.',',');
     document.getElementById('PorcentajeCap').value = busqueda.porretCap.toString().replace('.',',');
     document.getElementById('RetencionCap').value = busqueda.impretCap.toString().replace('.',',');   
     document.getElementById('LiquidoCap').value = busqueda.impliqCap.toString().replace('.',',');  
     pasarFecha('fecImpreCap',busqueda.fecImpreCap);    
     pasarFecha('fecPagoIRPFCap',busqueda.fecPagret);
     document.getElementById('ImpAnticipo').value = busqueda.impAnticipo.toString().replace('.',',');
   	 document.getElementById('ImpInteresPend').value = busqueda.impInteresPendiente.toString().replace('.',',');
   	 pasarFecha('fecVencimiento',busqueda.fecVencimientoCap); 
	 document.getElementById('tipImpuestoCap').value = busqueda.tipImpuestoCap;
	 document.getElementById('ImpCapital').value = busqueda.impCapital.toString().replace('.',',');
	 document.getElementById('BeneficiosPri').value = busqueda.impBeneficios.toString().replace('.',',');
     //Complementario1.
     document.getElementById('RtoIntegroPri').value = busqueda.impRtointComp.toString().replace('.',',');
     document.getElementById('RedPrimasPri').value = busqueda.impRedpriComp.toString().replace('.',',');
     document.getElementById('RedTransitPri').value = busqueda.impRedTranComp.toString().replace('.',',');
     document.getElementById('RtoNetoPri').value = busqueda.irTonetComp.toString().replace('.',',');
     document.getElementById('PorcentajePri').value = busqueda.porretComp.toString().replace('.',',');  
     document.getElementById('RetencionPri').value = busqueda.iretComp.toString().replace('.',',');   
     document.getElementById('LiquidoPri').value = busqueda.iliqComp.toString().replace('.',',');  
     pasarFecha('fecImprePri',busqueda.fecImpreComp);    
     pasarFecha('fecPagoIRPFPri',busqueda.fecPagretCom);
     document.getElementById('tipImpuestoPri').value = busqueda.tipImpuestComp;
	 document.getElementById('ImportePri').value = busqueda.impComp.toString().replace('.',',');
     pasarFecha('fecEmisionPri',busqueda.fecCemiComp);
     //Complementario2.
     document.getElementById('RtoIntegroComp').value = busqueda.impRtointComp2.toString().replace('.',',');
     document.getElementById('RedPrimasComp').value = busqueda.impRedpriComp2.toString().replace('.',',');
     document.getElementById('RedTransitComp').value = busqueda.impRedTranComp2.toString().replace('.',',');
     document.getElementById('RtoNetoComp').value = busqueda.irTonetComp2.toString().replace('.',',');
     document.getElementById('PorcentajeComp').value = busqueda.porretComp2.toString().replace('.',',');  
     document.getElementById('RetencionComp').value = busqueda.iretComp2.toString().replace('.',','); 
     document.getElementById('LiquidoComp').value = busqueda.iliqComp2.toString().replace('.',',');
     pasarFecha('fecImpreComp',busqueda.fecImpreComp2);
     pasarFecha('fecPagoIRPFComp',busqueda.fecPagretCom2);
     document.getElementById('tipImpuestoComp').value = busqueda.tipImpuestComp2;
     document.getElementById('ImporteComp').value = busqueda.impComp2.toString().replace('.',',');
	 pasarFecha('fecEmisionComp',busqueda.fecCemiComp2);
     document.getElementById('Coaseguradora1').value = busqueda.codCoA1.toString().replace('.',',');
     document.getElementById('Porcentaje1').value = busqueda.porCoA1.toString().replace('.',',');
     document.getElementById('Coaseguradora2').value = busqueda.codCoA2.toString().replace('.',',');
     document.getElementById('Porcentaje2').value = busqueda.porCoA2.toString().replace('.',',');
     document.getElementById('Coaseguradora3').value = busqueda.codCoA3.toString().replace('.',',');
     document.getElementById('Porcentaje3').value = busqueda.porCoA3.toString().replace('.',',');
     document.getElementById('Coaseguradora4').value = busqueda.codCoA4.toString().replace('.',',');
     document.getElementById('Porcentaje4').value = busqueda.porCoA4.toString().replace('.',',');
     document.getElementById('Coaseguradora5').value = busqueda.codCoA5.toString().replace('.',',');
     document.getElementById('Porcentaje5').value = busqueda.porCoA5.toString().replace('.',',');
     document.getElementById('Coaseguradora6').value = busqueda.codCoA6.toString().replace('.',',');
     document.getElementById('Porcentaje6').value = busqueda.porCoA6.toString().replace('.',',');
     //MU-2016-006664 - RAROALE - INI
     document.getElementById('Impcentaje1').value = busqueda.impCoA1.toString().replace('.',',');
     document.getElementById('Impcentaje2').value = busqueda.impCoA2.toString().replace('.',',');
     document.getElementById('Impcentaje3').value = busqueda.impCoA3.toString().replace('.',',');
     document.getElementById('Impcentaje4').value = busqueda.impCoA4.toString().replace('.',',');
     document.getElementById('Impcentaje5').value = busqueda.impCoA5.toString().replace('.',',');
     document.getElementById('Impcentaje6').value = busqueda.impCoA6.toString().replace('.',',');
     //MU-2016-006664 - RAROALE - FIN
     document.getElementById('CodCalFiscalCompPri').value = busqueda.codCalcFisComp.toString().replace('.',',');
     document.getElementById('CodCalFiscalCompSeg').value = busqueda.codCalFiscalComSeg.toString().replace('.',',');
     document.getElementById('CodCalcFisPri').value = busqueda.codCalcFisPri.toString().replace('.',',');    
     document.getElementById('Observaciones').value = busqueda.observacionesG; 
     
	 habilitacionTotal();
	 
	 
	 
	
	}  
/**
* Mapea los campos ocultos, con dos variables diferente le decimos que pase 
* a hidden para que se pasen bien lo * valores a cobol y no se pierdan  
* @author everis
*/

   	 
   function pasarDatosDisabled() {
   		document.getElementById('AnioHidden').value = document.getElementById('Anio').value;
   		document.getElementById('ExpedienteHidden').value = document.getElementById('Expediente').value;
   		document.getElementById('PendienteHidden').value = document.getElementById('Pendiente').value;
   		document.getElementById('TomadorHidden').value = document.getElementById('Tomador').value;
   		//fecEfecto lo metemos aqui para que se envíe correctamente.
   		document.getElementById('fecEfect').value = crearFecha('fecEfect');
   		
   		document.getElementById('RtoNetoPriHidden').value = document.getElementById('RtoNetoPri').value;
   		document.getElementById('RtoNetoCompHidden').value = document.getElementById('RtoNetoComp').value;
   		document.getElementById('RtoNetoCapHidden').value = document.getElementById('RtoNetoCap').value;
   		document.getElementById('RetencionPriHidden').value = document.getElementById('RetencionPri').value;
   		document.getElementById('RetencionCompHidden').value = document.getElementById('RetencionComp').value;
   		document.getElementById('RetencionCapHidden').value = document.getElementById('RetencionCap').value;
   	
   		document.getElementById('fecPagoCapital').value = crearFecha('fecPagoCapital');
   		document.getElementById('fecPagoPri').value = crearFecha('fecPagoPri');
   		document.getElementById('fecPagoComp').value = crearFecha('fecPagoComp');
   		document.getElementById('fecImpreCap').value = crearFecha('fecImpreCap');
   		document.getElementById('fecImprePri').value = crearFecha('fecImprePri');
   		document.getElementById('fecImpreComp').value = crearFecha('fecImpreComp');
   		document.getElementById('fecEmisionPri').value = crearFecha('fecEmisionPri');
   		document.getElementById('fecEmisionComp').value = crearFecha('fecEmisionComp'); 
   		document.getElementById('fecEmision').value = crearFecha('fecEmision'); 
   		document.getElementById('fecVencimiento').value = crearFecha('fecVencimiento');		
   	
   		// Primer beneficiario
   		document.getElementById('RazonSocialPriHidden').value = document.getElementById('RazonSocialPri').value;
   		document.getElementById('NombrePriHidden').value = document.getElementById('NombrePri').value;
   		document.getElementById('Apellido2PriHidden').value = document.getElementById('Apellido2Pri').value;
   		document.getElementById('Apellido1PriHidden').value = document.getElementById('Apellido1Pri').value;
   		document.getElementById('DomicilioPriHidden').value = document.getElementById('DomicilioPri').value;
   		document.getElementById('CodPostalPriHidden').value = document.getElementById('CodPostalPri').value;
   		document.getElementById('ProvinciaPriHidden').value = document.getElementById('ProvinciaPri').value;
   		document.getElementById('LocalidadPriHidden').value = document.getElementById('LocalidadPri').value;
   		document.getElementById('PaisPriHidden').value = document.getElementById('PaisPri').value;
   		document.getElementById('NifRepLegalPriHidden').value = document.getElementById('NifRepLegalPri').value;
   	
   		document.getElementById('fecNacPri').value = crearFecha('fecNacPri');
   		
   		document.getElementById('DiscapacitadoPriHidden').value = document.getElementById('DiscapacitadoPri').value;
   		document.getElementById('SitFamiliarPriHidden').value = document.getElementById('SitFamiliarPri').value;
   		document.getElementById('NifConyugePriHidden').value = document.getElementById('NifConyugePri').value;
   		document.getElementById('PenCompPriHidden').value = document.getElementById('PenComPri').value;

   		
   		// RadioButton.
   		
   		
   		
   		if (document.getElementById('TipPersona1Pri').checked) {
   			document.getElementById('TipPersonaPriHidden').value = 'F'; 
   		} else if (document.getElementById('TipPersona2Pri').checked) {
   			document.getElementById('TipPersonaPriHidden').value = 'J'; 
   		}
   		
   }
   
    /**
* Funcion que recoge la informacion de los datos fiscales de la persona informada
* @author EVERIS
* @param datosFiscales
*/
 
   function ponerDatosFiscales() {
 			
 			if (document.getElementById('DiscapacitadoPri').value != null){
		
				if(t07503esl != null && document.getElementById('DiscapacitadoPri').value != null){
			
					var tLen = t07503esl.length;
					
					for (var i = 0;i < tLen;i++){
					
						if(document.getElementById('DiscapacitadoPri') != null &&
						 (document.getElementById('DiscapacitadoPri') == (t07503esl[i].value) ) ){
						
							 document.getElementById('DiscapacitadoPri').value = t07503esl[i].text;
							 
						
						}
					} 
				} 			
			}
			
			if (document.getElementById('SitFamiliarPri').value != null){
		
				if(t07505esl != null && document.getElementById('SitFamiliarPri').value != null) {
			
					var tLen = t07505esl.length;
					
					for (var i = 0;i < tLen;i++){
					
						if(document.getElementById('SitFamiliarPri').value != null && 
						
						(document.getElementById('SitFamiliarPri').value == (t07505esl[i].value) ) ) {
						
							 document.getElementById('SitFamiliarPri').value = t07505esl[i].text;
						
						}
					} 
				} 			
			}	
			
			if (document.getElementById('PrestViviendoPri') != null){
		
				if(document.getElementById('PrestViviendoPri') != '00') {
			
					document.getElementById('PrestViviendoPri').value = 'X';
					} 
				} 			
			}		
  		
   
   