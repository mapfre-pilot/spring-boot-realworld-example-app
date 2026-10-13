/* MODIFICACION : MU-2016-006673
FECHA : MARZO 2016
DESCRIPCION: Se permite modificar y guardar en BBDD el kdomiclio del beneficiario
AUTOR : RAROALE */

/*MODIFICACION : MU-2016-006664
FECHA : MARZO 2016
DESCRIPCION: Se permite modificar y guardar en BBDD los importes de Coaseguros
AUTOR : RAROALE */

// R&V CA Fase II CU011-COASEGURO - INI
// Se habilita o deshabilita el resto de campos que no son importe y porcentaje
// en funcion del estado del radio button Valores Manuales
function controlCamposCoa2(numCoa,deshabilitado){
    var automatico = document.getElementById('valoresManuales2').checked;
    var deshabilitadoFinal = true;
    if ( (! deshabilitado) && (! automatico) ) {
        deshabilitadoFinal = false;
    }
    document.getElementById('Coasegur'+numCoa+'_3').disabled = deshabilitadoFinal;
    document.getElementById('Coasegur'+numCoa+'_4').disabled = deshabilitadoFinal;
    document.getElementById('Coasegur'+numCoa+'_5').disabled = deshabilitadoFinal;
    document.getElementById('Coasegur'+numCoa+'_6').disabled = deshabilitadoFinal;
    document.getElementById('Coasegur'+numCoa+'_7').disabled = deshabilitadoFinal;
    document.getElementById('Coasegur'+numCoa+'_8').disabled = deshabilitadoFinal;
}

// funcion que es invocada por el evento onclick de los radio VALORES MANUALES
function clickEnValoresManuales(opcion){
    if (opcion=='S'){
        controlCamposCoa();
    } else{
        if (opcion=='N'){
            controlCamposCoa();
        } else {
            // opcion no reconocida
            return;
        }
    }
}
// R&V CA Fase II CU011-COASEGURO - FIN

// MU-2016-006664 - RAROALE - INI
// habilira o o deshabilita los campos de importe y porcentaje de coaseguros segun sitiene codigo de coaseguro
	function controlCamposCoa() {
   		try {
   			var ImpCapital = parseFloat(cambiarPuntoComa(document.getElementById('ImpCapital').value));
   			var ImportePri = parseFloat(cambiarPuntoComa(document.getElementById('ImportePri').value));
   			var ImporteComp = parseFloat(cambiarPuntoComa(document.getElementById('ImporteComp').value));
   			var ImporteTotal = ImportePri + ImporteComp + ImpCapital; 
   		
	   		if (trim(document.getElementById('Coaseguradora1').value) == '') {
	   			document.getElementById('Porcentaje1').disabled = true;
	   			document.getElementById('Coasegur1_2').disabled = true;
	   			controlCamposCoa2('1',true); // R&V CA Fase II CU011-COASEGURO
	   		} else {
	   			if (ImporteTotal > 0 || ImporteTotal < 0) {
	   				document.getElementById('Porcentaje1').disabled = false;
	   				document.getElementById('Coasegur1_2').disabled = false;
	   				controlCamposCoa2('1',false); // R&V CA Fase II CU011-COASEGURO
	   			} else {
	   				document.getElementById('Porcentaje1').disabled = true;
		   			document.getElementById('Coasegur1_2').disabled = true;
		   			controlCamposCoa2('1',true); // R&V CA Fase II CU011-COASEGURO
	   			}
	   		}
	   		
	   		if (trim(document.getElementById('Coaseguradora2').value) == '') {
	   			document.getElementById('Porcentaje2').disabled = true;
	   			document.getElementById('Coasegur2_2').disabled = true;
	   			controlCamposCoa2('2',true); // R&V CA Fase II CU011-COASEGURO
	   		} else {
	   			if (ImporteTotal > 0 || ImporteTotal < 0) {
	   				document.getElementById('Porcentaje2').disabled = false;
	   				document.getElementById('Coasegur2_2').disabled = false;
	   				controlCamposCoa2('2',false); // R&V CA Fase II CU011-COASEGURO
	   			} else {
	   				document.getElementById('Porcentaje2').disabled = true;
		   			document.getElementById('Coasegur2_2').disabled = true;
		   			controlCamposCoa2('2',true); // R&V CA Fase II CU011-COASEGURO
	   			}
	   		}
	   		
	   		if (trim(document.getElementById('Coaseguradora3').value) == '') {
	   			document.getElementById('Porcentaje3').disabled = true;
	   			document.getElementById('Coasegur3_2').disabled = true;
	   			controlCamposCoa2('3',true); // R&V CA Fase II CU011-COASEGURO
	   		} else {
	   			if (ImporteTotal > 0 || ImporteTotal < 0) {
	   				document.getElementById('Porcentaje3').disabled = false;
	   				document.getElementById('Coasegur3_2').disabled = false;
	   				controlCamposCoa2('3',false); // R&V CA Fase II CU011-COASEGURO
	   			} else {
	   				document.getElementById('Porcentaje3').disabled = true;
		   			document.getElementById('Coasegur3_2').disabled = true;
		   			controlCamposCoa2('3',true); // R&V CA Fase II CU011-COASEGURO
	   			}
	   		}
	   		
	   		if (trim(document.getElementById('Coaseguradora4').value) == '') {
	   			document.getElementById('Porcentaje4').disabled = true;
	   			document.getElementById('Coasegur4_2').disabled = true;
	   			controlCamposCoa2('4',true); // R&V CA Fase II CU011-COASEGURO
	   		} else {
	   			if (ImporteTotal > 0 || ImporteTotal < 0) {
	   				document.getElementById('Porcentaje4').disabled = false;
	   				document.getElementById('Coasegur4_2').disabled = false;
	   				controlCamposCoa2('4',false); // R&V CA Fase II CU011-COASEGURO
	   			} else {
	   				document.getElementById('Porcentaje4').disabled = true;
		   			document.getElementById('Coasegur4_2').disabled = true;
		   			controlCamposCoa2('4',true); // R&V CA Fase II CU011-COASEGURO
	   			}
	   		}
	   		if (trim(document.getElementById('Coaseguradora5').value) == '') {
	   			document.getElementById('Porcentaje5').disabled = true;
	   			document.getElementById('Coasegur5_2').disabled = true;
	   			controlCamposCoa2('5',true); // R&V CA Fase II CU011-COASEGURO
	   		} else {
	   			if (ImporteTotal > 0 || ImporteTotal < 0) {
	   				document.getElementById('Porcentaje5').disabled = false;
	   				document.getElementById('Coasegur5_2').disabled = false;
	   				controlCamposCoa2('5',false); // R&V CA Fase II CU011-COASEGURO
	   			} else {
	   				document.getElementById('Porcentaje5').disabled = true;
		   			document.getElementById('Coasegur5_2').disabled = true;
		   			controlCamposCoa2('5',true); // R&V CA Fase II CU011-COASEGURO
	   			}
	   		}
	   		if (trim(document.getElementById('Coaseguradora6').value) == '') {
	   			document.getElementById('Porcentaje6').disabled = true;
	   			document.getElementById('Coasegur6_2').disabled = true;
	   			controlCamposCoa2('6',true); // R&V CA Fase II CU011-COASEGURO
	   		} else {
	   			if (ImporteTotal > 0 || ImporteTotal < 0) {
	   				document.getElementById('Porcentaje6').disabled = false;
	   				document.getElementById('Coasegur6_2').disabled = false;
	   				controlCamposCoa2('6',false); // R&V CA Fase II CU011-COASEGURO
	   			} else {
	   				document.getElementById('Porcentaje6').disabled = true;
		   			document.getElementById('Coasegur6_2').disabled = true;
		   			controlCamposCoa2('6',true); // R&V CA Fase II CU011-COASEGURO
	   			}
	   		}
   		}catch(e){	}
	}
// MU-2016-006664 - RAROALE - FIN

/**
* Al inicio se deshabilita Modificar y Anular
* @author EVERIS
*/    
   function desHabilitacionInicial() {

   		parent.document.getElementById('Modificar').disabled = 'true';
   }
 /**
* Habilita los botones de Alta y Buscar
* @author EVERIS
*/  
   function habilitacionInicial() {
   		
   		parent.document.getElementById('Alta').disabled = '';
		parent.document.getElementById('Buscar').disabled = '';
   
   }
/**
* Habilita todos los botones
* @author EVERIS
*/  

   function habilitacionTotal() {
   		
   		parent.document.getElementById('Modificar').disabled = '';
		parent.document.getElementById('Alta').disabled = '';
		parent.document.getElementById('Buscar').disabled = '';
   
   }
/**
* Deshabilita todos los botones
* @author EVERIS
*/ 
   function desHabilitacionTotal() {
   		
   		parent.document.getElementById('Modificar').disabled = 'true';
		parent.document.getElementById('Alta').disabled = 'true';
		parent.document.getElementById('Buscar').disabled = 'true';
   }
 /**
* Se le envia un parametro de tipo fecha y deshabilita todos los elementos.
* @author EVERIS
*/   
   function desHabilitarFechas(nameFecha) {
   		document.getElementById(nameFecha+'_day').disabled = true;
		document.getElementById(nameFecha+'_month').disabled = true;
		document.getElementById(nameFecha+'_year').disabled = true;
		document.getElementById(nameFecha+'_trigger').className = "Oculto";
   }
/**
* Se le envia un parametro de tipo fecha y habilita todos los elementos.
* @author EVERIS
*/ 
   function habilitarFechas(nameFecha) {
   		document.getElementById(nameFecha+'_day').disabled = '';
		document.getElementById(nameFecha+'_month').disabled = '';
		document.getElementById(nameFecha+'_year').disabled = '';
		document.getElementById(nameFecha+'_trigger').className = "Inline";
   }
/**   
* Se le envia un parametro fecha y limpia ese campo.
* @author EVERIS
* @param nameFecha
*/   

   function limpiarFechas(nameFecha) {
   				document.getElementById(nameFecha+'_day').value = 'dd';
				document.getElementById(nameFecha+'_month').value = 'mm';
				document.getElementById(nameFecha+'_year').value = 'yyyy';
				//Primero borramos visualmente y ahora borramos la lógica que no se ve
				document.getElementById(nameFecha).value = '';
				document.forms[0].elements[nameFecha].value = '';
   } 
 
 /**   
* Deshabilita todos los campos al inicio
* @author EVERIS
*/  
   function desHabilitacionInicialCampos() {

   		document.getElementById('Poliza1').disabled = 'true';
   		document.getElementById('Poliza2').disabled = 'true';
   		document.getElementById('Poliza3').disabled = 'true';
   		document.getElementById('SubPoliza').disabled = 'true';		
   		document.getElementById('Certificado').disabled = 'true';
   		document.getElementById('Modalidad').disabled = 'true';
   		desHabilitarFechas('fecEfect');
   		document.getElementById('Residente1Pri').disabled = 'disabled';
   		document.getElementById('Residente2Pri').disabled = 'disabled';
   		
   		document.getElementById('Entidad').disabled = 'disabled';
   		document.getElementById('CanalCamp').disabled = 'disabled';
   		document.getElementById('Tomador').disabled = 'true';
   		document.getElementById('regionalPol').disabled = 'true';
   		document.getElementById('regionalEnv').disabled = 'true';
   		document.getElementById('Oficina').disabled = 'true';
   		document.getElementById('Observaciones').disabled = 'true';
   		//En los css ya tenemos declarado el valor para ocultar campos por lo que llamamos a ellos directamente
		document.getElementById('imgConsulta').className = "Oculto";
   		document.getElementById('imgNifCifPri').className = "Oculto";
   		document.getElementById('NIFCIFPri').disabled = 'true';
   		
   		// Rescates
   		document.getElementById('ImpCapital').disabled = 'true';
   		document.getElementById('BeneficiosPri').disabled = 'true';
   		document.getElementById('ImpAnticipo').disabled = 'true';
   		
   		document.getElementById('ImpInteresPend').disabled = 'true';
   		desHabilitarFechas('fecPagoCapital');
   		desHabilitarFechas('fecVencimiento');
   		desHabilitarFechas('fecPagoPri');
   		
   		document.getElementById('tipImpuestoCap').disabled = 'true';
   		document.getElementById('RtoIntegroCap').disabled = 'true';
   		document.getElementById('RedPrimasCap').disabled = 'true';
   		document.getElementById('RedTransitCap').disabled = 'true';
   		document.getElementById('CompensaCap').disabled = 'true';
   		document.getElementById('PorcentajeCap').disabled = 'true';
   		document.getElementById('RtoNetoCap').disabled = 'true';
   		document.getElementById('RetencionCap').disabled = 'true';
   		desHabilitarFechas('fecPagoIRPFCap');
   		document.getElementById('LiquidoCap').disabled = 'true';
	    desHabilitarFechas('fecImpreCap');
   		document.getElementById('Duracion').disabled = 'true';
		//Pri
		document.getElementById('ImportePri').disabled = 'true';
		document.getElementById('tipImpuestoPri').disabled = 'true';
   		document.getElementById('RtoIntegroPri').disabled = 'true';
   		document.getElementById('RedPrimasPri').disabled = 'true';
   		document.getElementById('RedTransitPri').disabled = 'true';
   		document.getElementById('PorcentajePri').disabled = 'true';
   		document.getElementById('RtoNetoPri').disabled = 'true';
   		document.getElementById('RetencionPri').disabled = 'true';
   		desHabilitarFechas('fecPagoIRPFPri');
   		document.getElementById('LiquidoPri').disabled = 'true';
   		desHabilitarFechas('fecEmisionPri');
   		desHabilitarFechas('fecEmision');
   		desHabilitarFechas('fecPagoPri');
   		
   		//Comp.
		document.getElementById('ImporteComp').disabled = 'true';
		document.getElementById('tipImpuestoComp').disabled = 'true';
   		document.getElementById('RtoIntegroComp').disabled = 'true';
   		document.getElementById('RedPrimasComp').disabled = 'true';
   		document.getElementById('RedTransitComp').disabled = 'true';
   		document.getElementById('PorcentajeComp').disabled = 'true';
   		document.getElementById('RtoNetoComp').disabled = 'true';
   		document.getElementById('RetencionComp').disabled = 'true';
   		desHabilitarFechas('fecPagoIRPFComp');
   		document.getElementById('LiquidoComp').disabled = 'true';
   		desHabilitarFechas('fecEmisionComp');
   		desHabilitarFechas('fecPagoComp');
   		// Primer Beneficiario
   		document.getElementById('Coaseguradora1').disabled = 'true';
   		document.getElementById('Porcentaje1').disabled = 'true';
   		document.getElementById('Coaseguradora2').disabled = 'true';
   		document.getElementById('Porcentaje2').disabled = 'true';
   		document.getElementById('Coaseguradora3').disabled = 'true';
   		document.getElementById('Porcentaje3').disabled = 'true';
   		document.getElementById('Coaseguradora4').disabled = 'true';
   		document.getElementById('Porcentaje4').disabled = 'true';
   		document.getElementById('Coaseguradora5').disabled = 'true';
   		document.getElementById('Porcentaje5').disabled = 'true';
   		document.getElementById('Coaseguradora6').disabled = 'true';
   		document.getElementById('Porcentaje6').disabled = 'true';
   		document.getElementById('totPagMafre').disabled = 'true';
   		document.getElementById('CodCalcFisPri').disabled = 'true';
   		document.getElementById('CodCalFiscalCompPri').disabled = 'true';
   		document.getElementById('CodCalFiscalCompSeg').disabled = 'true';
   		// MU-2016-006664 - RAROALE - INI
   		document.getElementById('Coasegur1_2').disabled = 'true';
   		document.getElementById('Coasegur2_2').disabled = 'true';
   		document.getElementById('Coasegur3_2').disabled = 'true';
   		document.getElementById('Coasegur4_2').disabled = 'true';
   		document.getElementById('Coasegur5_2').disabled = 'true';
   		document.getElementById('Coasegur6_2').disabled = 'true';
   		// MU-2016-006664 - RAROALE - FIN
   		
   }
/**   
* Limpia todos los campos generales
* @author EVERIS
*/   

   function limpiarCamposGene() {
   	
   		document.getElementById('Anio').value = '';
   		document.getElementById('Expediente').value = '';
   		document.getElementById('Poliza1').value = '';
   		document.getElementById('Poliza2').value = '';
   		document.getElementById('Poliza3').value = '';
   		document.getElementById('SubPoliza').value = '';
   		document.getElementById('Certificado').value = '';
   		document.getElementById('Modalidad').value = '';
   		document.getElementById('Entidad').value = '';
   		document.getElementById('CanalCamp').value = '';
   		document.getElementById('Duracion').value = '';
   		limpiarFechas('fecEfect');
   		document.getElementById('regionalPol').value = '';
   		document.getElementById('regionalEnv').value = '';
   		document.getElementById('Tomador').value = '';
   		document.getElementById('Oficina').value = '';
   		document.getElementById('Observaciones').value = '';
   		document.getElementById('Pendiente').value = '0,00';
   		document.getElementById('NIFCIFPri').value = '';

   		//R&V - CU009 - INI
        document.getElementById('eximido1').checked= true;
        document.getElementById('eximido2').checked= false;
        //R&V - CU009 - FIN
 
   		// Vencimientos
   		document.getElementById('ImpCapital').value = '0,00';
   		document.getElementById('BeneficiosPri').value = '0,00';
   		document.getElementById('ImpAnticipo').value = '0,00';
   		document.getElementById('ImpInteresPend').value = '0,00';
   		document.getElementById('RtoIntegroCap').value = '0,00';
   		document.getElementById('RedPrimasCap').value = '0,00';
   		document.getElementById('RedTransitCap').value = '0,00';
   		document.getElementById('CompensaCap').value = '0,00';
   		document.getElementById('PorcentajeCap').value = '0,00';
   		document.getElementById('RtoNetoCap').value = '0,00';
   		document.getElementById('RetencionCap').value = '0,00';
   		document.getElementById('LiquidoCap').value = '0,00';
   		document.getElementById('Pendiente').value = '0,00';
   		limpiarFechas('fecPagoIRPFCap');
   		limpiarFechas('fecPagoCapital');
	    limpiarFechas('fecImpreCap');	    
   		limpiarFechas('fecEmision');	    
   		limpiarFechas('fecVencimiento');
   		
   		
   		
   		// Primer Complementario 
   		document.getElementById('ImportePri').value = '0,00';
   		document.getElementById('RtoIntegroPri').value = '0,00';
   		document.getElementById('RedPrimasPri').value = '0,00';
   		document.getElementById('RedTransitPri').value = '0,00';
   		document.getElementById('RtoNetoPri').value = '0,00';
   		document.getElementById('PorcentajePri').value = '0,00';
   		document.getElementById('RetencionPri').value = '0,00';
   		document.getElementById('LiquidoPri').value = '0,00';
   		limpiarFechas('fecPagoIRPFPri');
   		limpiarFechas('fecPagoPri');
	    limpiarFechas('fecEmisionPri');
	    limpiarFechas('fecImprePri');
	
	    
   		// Segundo Complementario
		document.getElementById('ImporteComp').value = '0,00';
   		document.getElementById('RtoIntegroComp').value = '0,00';
   		document.getElementById('RedPrimasComp').value = '0,00';
   		document.getElementById('RedTransitComp').value = '0,00';
   		document.getElementById('PorcentajeComp').value = '0,00';
   		document.getElementById('RtoNetoComp').value = '0,00';
   		document.getElementById('RetencionComp').value = '0,00';
   		document.getElementById('LiquidoComp').value = '0,00';
   		limpiarFechas('fecPagoIRPFComp');   		
   		limpiarFechas('fecEmisionComp');   		
   		limpiarFechas('fecPagoComp');
   		limpiarFechas('fecImpreComp');
  		
   		// Codigo de fiscalidad
   		document.getElementById('CodCalcFisPri').value = '';
   		document.getElementById('CodCalFiscalCompSeg').value = '';
   		document.getElementById('CodCalFiscalCompPri').value = '';

   	}
 /**   
* Limpia todos los campos beneficiarios
* @author EVERIS
*/   	
   	 function limpiarCamposBene() {

   		// Primer beneficiario
   		document.getElementById('NombrePri').value = '';
   		document.getElementById('kpersonaPri').value = '';
   		// MU-2016-006673 - RAROALE - INI
   		document.getElementById('kdomicilioPri').value = '';
   		document.getElementById('fmodificacion').value = '';
   		// MU-2016-006673 - RAROALE - FIN
   		document.getElementById('Apellido2Pri').value = '';
   		document.getElementById('Apellido1Pri').value = '';
   		document.getElementById('DomicilioPri').value = '';
   		document.getElementById('CodPostalPri').value = '';
   		document.getElementById('ProvinciaPri').value = '';
   		document.getElementById('LocalidadPri').value = '';
   		document.getElementById('PaisPri').value = '';
   		limpiarFechas('fecNacPri');
   		document.getElementById('NifRepLegalPri').value = '';
   		document.getElementById('DiscapacitadoPri').value = '';
   		document.getElementById('SitFamiliarPri').value = '';
   		document.getElementById('NifConyugePri').value = '';
   		document.getElementById('PenComPri').value = '';
   		document.getElementById('AnulAlimenHijosPri').value = '';		
   		document.getElementById('Coaseguradora1').value = '';
   		document.getElementById('Porcentaje1').value = '';
   		document.getElementById('Coaseguradora2').value = '';
   		document.getElementById('Porcentaje2').value = '';
   		document.getElementById('Coaseguradora3').value = '';
   		document.getElementById('Porcentaje3').value = '';
   		document.getElementById('Coaseguradora4').value = '';
   		document.getElementById('Porcentaje4').value = '';
   		document.getElementById('Coaseguradora5').value = '';
   		document.getElementById('Porcentaje5').value = '';
   		document.getElementById('Coaseguradora6').value = '';
   		document.getElementById('Porcentaje6').value = '';
   		document.getElementById('totPagMafre').checked = 'checked';
   		
   		//Aqui poner por defecto Sin Retencion en desplegable tipo impuesto.
   		document.getElementById('tipImpuestoCap').value ='34';
   		document.getElementById('tipImpuestoPri').value ='34';
   		document.getElementById('tipImpuestoComp').value ='34';
   		document.getElementById('RazonSocialPri').value ='';

	
   }
 /**   
* Habilita todos los campos.
* @author EVERIS
*/ 
   function habilitacionInicialCampos() {

   		document.getElementById('Poliza1').disabled = '';
   		document.getElementById('Poliza2').disabled = '';
   		document.getElementById('Poliza3').disabled = '';
   		document.getElementById('SubPoliza').disabled = '';
   		document.getElementById('Certificado').disabled = '';
   		document.getElementById('Modalidad').disabled = '';
   		document.getElementById('Entidad').disabled = '';
   		document.getElementById('CanalCamp').disabled = '';
   		document.getElementById('Duracion').disabled = '';
   		document.getElementById('Residente1Pri').disabled = '';
   		document.getElementById('Residente2Pri').disabled = '';
   		document.getElementById('regionalPol').disabled = '';
   		document.getElementById('regionalEnv').disabled = '';
   		document.getElementById('Tomador').disabled = '';
   		document.getElementById('Oficina').disabled = '';
   		document.getElementById('Observaciones').disabled = '';
   		document.getElementById('imgConsulta').className = "Inline";
   		document.getElementById('imgNifCifPri').className = "Inline";
   		document.getElementById('NIFCIFPri').disabled = '';
   		document.getElementById('BeneficiosPri').disabled = '';
   		
   		// Vencimientos
   		
   		document.getElementById('ImpCapital').disabled = '';
   		document.getElementById('ImpAnticipo').disabled = '';
   		document.getElementById('ImpInteresPend').disabled = '';
   		document.getElementById('Duracion').disabled = '';
   		habilitarFechas('fecPagoCapital');
   		habilitarFechas('fecVencimiento');
        habilitarFechas('fecPagoIRPFCap');
        habilitarFechas('fecEfect'); 
   		document.getElementById('tipImpuestoCap').disabled = ''; 
   		document.getElementById('RtoIntegroCap').disabled = '';
   		document.getElementById('RedPrimasCap').disabled = '';
   		document.getElementById('RedTransitCap').disabled = '';
   		document.getElementById('PorcentajeCap').disabled = '';
   		document.getElementById('RetencionCap').disabled = '';

   		document.getElementById('tipImpuestoComp').disabled ='';
   		habilitarFechas('fecEmision');
   		document.getElementById('LiquidoCap').disabled = '';
  		
   		// Primer Beneficiario
   		document.getElementById('Coaseguradora1').disabled = '';
   		document.getElementById('Porcentaje1').disabled = '';
   		document.getElementById('Coaseguradora2').disabled = '';
   		document.getElementById('Porcentaje2').disabled = '';
   		document.getElementById('Coaseguradora3').disabled = '';
   		document.getElementById('Porcentaje3').disabled = '';
   		document.getElementById('Coaseguradora4').disabled = '';
   		document.getElementById('Porcentaje4').disabled = '';
   		document.getElementById('Coaseguradora5').disabled = '';
   		document.getElementById('Porcentaje5').disabled = '';
   		document.getElementById('Coaseguradora6').disabled = '';
   		document.getElementById('Porcentaje6').disabled = '';
   		document.getElementById('totPagMafre').disabled = '';
   		// MU-2016-006664 - RAROALE - INI
   		document.getElementById('Coasegur1_2').disabled = '';
   		document.getElementById('Coasegur2_2').disabled = '';
   		document.getElementById('Coasegur3_2').disabled = '';
   		document.getElementById('Coasegur4_2').disabled = '';
   		document.getElementById('Coasegur5_2').disabled = '';
   		document.getElementById('Coasegur6_2').disabled = '';
   		// MU-2016-006664 - RAROALE - FIN
   		
   }

// R&V - Junio 2017 - CU011 - everis(RGL) - INI
function deshabilitarImportesDeCoaseguros( estado ){ // estado = [ true | false ]
    for (fila=3; fila<=8; fila++){
        for (columna=1; columna<=6; columna++){
            document.getElementById('Coasegur' + columna.toString() + '_' + fila.toString() ).disabled = estado;
        }
    }
}
// R&V - Junio 2017 - CU011 - everis(RGL) - FIN
