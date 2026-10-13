/*MODIFICACION : MU-2016-006664
FECHA : MARZO 2016
DESCRIPCION: Se permite modificar y guardar en BBDD los importes de Coaseguros
AUTOR : RAROALE */

// INICIO MODIFICACION EVERIS
/**
* Calcuo de los porcentajes
* uno para cada uno de los coaseguradores
* Atributo tipoCalculo: I calculo por importe, P calculo por porcentaje
* @author EVERIS
*/
// MU-2016-006664 - RAROALE - INI
   		function calculoCodImportes(tipoCalculo) {
	    var condicionCalculo = document.getElementById('valoresManuales2').checked; // R&V CA Fase II CU011-COASEGURO
	    if (condicionCalculo) { // R&V Correccion 03/08/2017-1-3
   			calculoPorImportes(1, tipoCalculo);
   			calculoPorImportes(2, tipoCalculo);
   			calculoPorImportes(3, tipoCalculo);
   			calculoPorImportes(4, tipoCalculo);
   			calculoPorImportes(5, tipoCalculo);
   			calculoPorImportes(6, tipoCalculo);
   			ajusteImportesCoa('NINGUNA');// R&V Ajuste centimos 22/09/2017
   			limpiaCoase();
   		} // R&V Correccion 03/08/2017-1-3
   		}
   		function calculoPorImportesOnchange(coa, tipoCalculo) {
	    var condicionCalculo = false; // R&V Correccion 03/08/2017-1-3
	    if (condicionCalculo) { // R&V Correccion 03/08/2017-1-3
                if (tipoCalculo == 'P') {
                    var Importe = document.getElementById('Porcentaje'+coa).value;
                    if (!isNaN(Importe) ||  Importe == '0,00') {
                        calculoPorImportes(coa, tipoCalculo)
                    }
                } else {
                    var Importe = document.getElementById('Coasegur'+coa+'_2').value;
                    if (!isNaN(Importe) ||  Importe == '0,00'){
                        calculoPorImportes(coa, tipoCalculo)
                    }
                }
		    } // R&V Correccion 03/08/2017-1-3
   		}
// MU-2016-006664 - RAROALE - FIN
 /**
* Calcuo del porcentaje
* uno para cada uno de los coaseguradores
* Atributo:
* 		coa: indica el CoAseguro que estamos tratando
* 		tipoCalculo: I calculo por importe, P calculo por porcentaje
* @author EVERIS
*/  		
   		//MU-2016-006664 - RAROALE - INI  
   		function calculoPorImportes(coa, tipoCalculo) {
   		// MU-2016-006664 - RAROALE - FIN  

	    var condicionCalculo = document.getElementById('valoresManuales2').checked; // R&V CA Fase II CU011-COASEGURO
	    if (condicionCalculo) { // R&V Correccion 03/08/2017-1-3

   			var Importe;
   			// MU-2016-006664 - RAROALE - INI  
   			var Porcentaje;
   			// MU-2016-006664 - RAROALE - FIN
   			var ImporteCap = parseFloat(cambiarPuntoComa(document.getElementById('ImpCapital').value));
   			var ImportePri = parseFloat(cambiarPuntoComa(document.getElementById('ImportePri').value));
   			var ImporteComp = parseFloat(cambiarPuntoComa(document.getElementById('ImporteComp').value));
   			
   			var RtoIntegro;
   			var RtoIntegroCap = parseFloat(cambiarPuntoComa(document.getElementById('RtoIntegroCap').value));
   			var RtoIntegroPri = parseFloat(cambiarPuntoComa(document.getElementById('RtoIntegroPri').value));
   			var RtoIntegroComp = parseFloat(cambiarPuntoComa(document.getElementById('RtoIntegroComp').value));
   		
   			var RedPrimasCap = parseFloat(cambiarPuntoComa(document.getElementById('RedPrimasCap').value));
   			var RedPrimasPri = parseFloat(cambiarPuntoComa(document.getElementById('RedPrimasPri').value));
   			var RedPrimasComp = parseFloat(cambiarPuntoComa(document.getElementById('RedPrimasComp').value));
   		
   			var RedTransit;
   			var RedTransitCap = parseFloat(cambiarPuntoComa(document.getElementById('RedTransitCap').value));
   			var RedTransitPri = parseFloat(cambiarPuntoComa(document.getElementById('RedTransitPri').value));
   			var RedTransitComp = parseFloat(cambiarPuntoComa(document.getElementById('RedTransitComp').value));
   			
   			var RtoNeto;
   			var RtoNetoCap = parseFloat(cambiarPuntoComa(document.getElementById('RtoNetoCap').value));
   			var RtoNetoPri = parseFloat(cambiarPuntoComa(document.getElementById('RtoNetoPri').value));
   			var RtoNetoComp = parseFloat(cambiarPuntoComa(document.getElementById('RtoNetoComp').value));
   			
   			var Retencion;
   			var RetencionCap = parseFloat(cambiarPuntoComa(document.getElementById('RetencionCap').value));
   			var RetencionPri = parseFloat(cambiarPuntoComa(document.getElementById('RetencionPri').value));
   			var RetencionComp = parseFloat(cambiarPuntoComa(document.getElementById('RetencionComp').value));
   			
   			var Compensa;
   			var CompensaPri = parseFloat(cambiarPuntoComa(document.getElementById('CompensaCap').value));

   			//var Porcentaje1 = parseFloat(cambiarPuntoComa(document.getElementById('Porcentaje'+coa).value));// R&V - Marzo 2018 - Linea original
            // R&V - Marzo 2018 - INI
            if (tipoCalculo=='I'){
                var Porcentaje1=porcentPreciso(coa);
            } else {
                var Porcentaje1 = parseFloat(cambiarPuntoComa(document.getElementById('Porcentaje'+coa).value));
            }
            // R&V - Marzo 2018 - FIN

   			// MU-2016-006664 - RAROALE - INI
   			var Importe1 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur'+coa+'_2').value));
   			// MU-2016-006664 - 06-05-2016 - RAROALE - INI
   		   	var BeneficiosPri = parseFloat(cambiarPuntoComa(document.getElementById('BeneficiosPri').value));
   			if (!isNaN(ImportePri) && !isNaN(ImporteComp) && !isNaN(ImporteCap) && !isNaN(BeneficiosPri)) {
   			// MU-2016-006664 - 06-05-2016 - RAROALE - FIN
	   			if (tipoCalculo == 'I') {
                    // R&V 48-1-362-372-CU011-CP043 INI
                    var esCoaMapfre = 'C0511'==document.getElementById('Coaseguradora'+coa).value.toUpperCase();
                    // R&V 48-1-362-372-CU011-CP043 FIN
	   				// MU-2016-006664 - 06-05-2016 - RAROALE - INI
	   				var importeTotal = ImporteCap + BeneficiosPri;
	   				// MU-2016-006664 - 06-05-2016 - RAROALE - FIN
   					if (!document.getElementById('ImportePri').disabled) {
   						importeTotal = importeTotal + ImportePri;
   						if (!document.getElementById('ImporteComp').disabled) {
   							importeTotal = importeTotal + ImporteComp;
   						}
   					} 
	   				if ((importeTotal) == 0) {
	   					Porcentaje1 = '0.00';
		   				document.getElementById('Porcentaje'+coa).value = '0,00';
	   				} else {
		   				if(!isNaN(Importe1) && !esCoaMapfre){ // R&V 48-1-362-372-CU011-CP043 se añade && !esCoaMapfre
		   					Porcentaje = (Importe1 * 100) / (importeTotal);
				   			var strPorcentaje = new String(Porcentaje);
				   			strPorcentaje = precisionDecimales(strPorcentaje, 2);
				   			if (strPorcentaje != '0') {
				   				// Porcentaje1 = strPorcentaje; // R&V - Marzo 2018 - Linea original, se quita para no reescribir con 2 dec.
				   				document.getElementById('Porcentaje'+coa).value = strPorcentaje.replace('.',',');
				   			} else {   
				   				Porcentaje1 = '0.00';
				   				document.getElementById('Porcentaje'+coa).value = '0,00';
				   			}
		   				}
                        // R&V 48-1-362/372-CU011-CP043 INI
                        else { // es coaseguradora Mapfre (C0511) o Importe1 es NaN
                            if (esCoaMapfre) {
                                var porcentajeMapfre = 100.0;
                                for (var i=1;i<=6;i++) {
                                    var strAux=document.getElementById('Porcentaje'+i.toString()).value;
                                    if ( strAux != '' && i.toString()!=coa) {
                                        porcentajeMapfre -= parseFloat(cambiarPuntoComa(strAux));
                                    }
                                }
                                Porcentaje1 = porcentajeMapfre; //R&V 48-1-362/372-CU011-CP043-(1)
                                var strPorcentajeMapfre= new String(porcentajeMapfre);
                                strPorcentajeMapfre = precisionDecimales(strPorcentajeMapfre,2).replace('.',',');
                                document.getElementById('Porcentaje'+coa).value = strPorcentajeMapfre;
                            }
                        }
                        // R&V 48-1-362/372-CU011-CP043 FIN

	   				}
	   			} else {
	   				if(!isNaN(Porcentaje1 )){
	   					// MU-2016-006664 - 06-05-2016 - RAROALE - INI
	   					var importeTotal = ImporteCap + BeneficiosPri;
	   					// MU-2016-006664 - 06-05-2016 - RAROALE - FIN
	   					if (!document.getElementById('ImportePri').disabled) {
	   						importeTotal = importeTotal + ImportePri;
	   						if (!document.getElementById('ImporteComp').disabled) {
	   							importeTotal = importeTotal + ImporteComp;
	   						}
	   					} 
						Importe = (importeTotal) * (Porcentaje1 / 100);
			   			var strImporte = new String(Importe);
			   			strImporte = precisionDecimales(strImporte, 2);
			   			if (strImporte != '0') {
			   			   document.getElementById('Coasegur'+coa+'_2').value = strImporte.replace('.',',');
			   			} else {   
			   				document.getElementById('Coasegur'+coa+'_2').value = '0,00';
			   			}
			   		// MU-2016-006664 - RAROALE - INI
					} else {
						document.getElementById('Coasegur'+coa+'_2').value = '0,00';
					}
	   				// MU-2016-006664 - RAROALE - FIN
	   			}
   			}
			if(!isNaN(Porcentaje1 )){	   			
	   			RtoIntegro = (RtoIntegroPri + RtoIntegroComp + RtoIntegroCap) * (Porcentaje1 / 100);
	   			var strRtoIntegro = new String(RtoIntegro);
	   			strRtoIntegro = precisionDecimales(strRtoIntegro, 2);
	   			if (strRtoIntegro != '0') {
	   			   document.getElementById('Coasegur'+coa+'_3').value = strRtoIntegro.replace('.',',');
	   			} else {
	   			   document.getElementById('Coasegur'+coa+'_3').value = '0,00';
	   			}
	   			   
	   			RedPrimas = (RedPrimasPri + RedPrimasComp + RedPrimasCap) * (Porcentaje1 / 100);
	   			var strRedPrimas = new String(RedPrimas);
	   			strRedPrimas = precisionDecimales(strRedPrimas, 2);
	   			if (strRedPrimas != '0') {
	   			   document.getElementById('Coasegur'+coa+'_4').value = strRedPrimas.replace('.',',');
	   			} else {
	   			    document.getElementById('Coasegur'+coa+'_4').value = '0,00';
	   			}      
	   			
	   			RedTransit = (RedTransitPri + RedTransitComp + RedTransitCap) * (Porcentaje1 / 100);
	   			var strRedTransit = new String(RedTransit);
	   			strRedTransit = precisionDecimales(strRedTransit, 2);
	   			if (strRedTransit != '0') {
	   				document.getElementById('Coasegur'+coa+'_5').value = strRedTransit.replace('.',',');
	   		 	} else {
	   		 		document.getElementById('Coasegur'+coa+'_5').value = '0,00';
	   		 	}
	   			
	   			RtoNeto = (RtoNetoPri + RtoNetoComp + RtoNetoCap) * (Porcentaje1 / 100);
	   			var strRtoNeto = new String(RtoNeto);
	   			strRtoNeto = precisionDecimales(strRtoNeto, 2);
	   			if (strRtoNeto != '0') {
	   				document.getElementById('Coasegur'+coa+'_6').value = strRtoNeto.replace('.',','); 
	   			} else {
	   				document.getElementById('Coasegur'+coa+'_6').value = '0,00';
	   			}
	   				
	   			Retencion = (RetencionPri + RetencionComp + RetencionCap) * (Porcentaje1 / 100);
	   			var strRetencion = new String(Retencion);
	   			strRetencion = precisionDecimales(strRetencion, 2);
	   			if (strRetencion != '0') {
	   				document.getElementById('Coasegur'+coa+'_7').value = strRetencion.replace('.',',');
	   			} else {
	   				document.getElementById('Coasegur'+coa+'_7').value = '0,00';
	   			}	

	   			Compensa = (CompensaPri) * (Porcentaje1 / 100);
	   			var strCompensa = new String(Compensa);
	   			strCompensa = precisionDecimales(strCompensa, 2);
	   			if (strCompensa != '0') {
	   				document.getElementById('Coasegur'+coa+'_8').value = strCompensa.replace('.',',');  
	   			} else {
	   				document.getElementById('Coasegur'+coa+'_8').value = '0,00';
	   			} 			
	   			
	   		}
			// MU-2016-006664 - RAROALE - FIN
   		} // R&V Correccion 03/08/2017-1-3
   		}
   		
/**
* Limpieza de los campos coaseguradoras
* uno para cada uno de los coaseguradores
* @author EVERIS
*/
   		
   		function limpiaCoase() {
   		
   			var Coaseguradora1 = (document.getElementById('Coaseguradora1').value);
   			var Coaseguradora2 = (document.getElementById('Coaseguradora2').value);
   			var Coaseguradora3 = (document.getElementById('Coaseguradora3').value);
   			var Coaseguradora4 = (document.getElementById('Coaseguradora4').value);
   			var Coaseguradora5 = (document.getElementById('Coaseguradora5').value);
   			var Coaseguradora6 = (document.getElementById('Coaseguradora6').value);
   			
   			if (Coaseguradora1 == '') {
   				// MU-2016-006664 - RAROALE - INI
   				document.getElementById('Porcentaje1').value = '';
   				document.getElementById('Coasegur1_2').value = '';
   				document.getElementById('Coasegur1_3').value = '';
   				document.getElementById('Coasegur1_4').value = '';
   				document.getElementById('Coasegur1_5').value = '';
   				document.getElementById('Coasegur1_6').value = '';
   				document.getElementById('Coasegur1_7').value = '';
   				document.getElementById('Coasegur1_8').value = '';
   				// MU-2016-006664 - RAROALE - FIN
   			}
            // R&V Correccion 03/08/2017-1-3 INI
            else {
                if (document.getElementById('Porcentaje1').value != '') {
                    document.getElementById('Porcentaje1').value = precisionDecimales(parseFloat(document.getElementById('Porcentaje1').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur1_2').value != '') {
                    document.getElementById('Coasegur1_2').value = precisionDecimales(parseFloat(document.getElementById('Coasegur1_2').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur1_3').value != '') {
                    document.getElementById('Coasegur1_3').value = precisionDecimales(parseFloat(document.getElementById('Coasegur1_3').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur1_4').value != '') {
                    document.getElementById('Coasegur1_4').value = precisionDecimales(parseFloat(document.getElementById('Coasegur1_4').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur1_5').value != '') {
                    document.getElementById('Coasegur1_5').value = precisionDecimales(parseFloat(document.getElementById('Coasegur1_5').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur1_6').value != '') {
                    document.getElementById('Coasegur1_6').value = precisionDecimales(parseFloat(document.getElementById('Coasegur1_6').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur1_7').value != '') {
                    document.getElementById('Coasegur1_7').value = precisionDecimales(parseFloat(document.getElementById('Coasegur1_7').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur1_8').value != '') {
                    document.getElementById('Coasegur1_8').value = precisionDecimales(parseFloat(document.getElementById('Coasegur1_8').value.replace(',','.')),2).toString().replace('.',',');
                }
            }
            // R&V Correccion 03/08/2017-1-3 FIN

   			if (Coaseguradora2 == '') {
   				// MU-2016-006664 - RAROALE - INI
   				document.getElementById('Porcentaje2').value = '';
   				document.getElementById('Coasegur2_2').value = '';
   				document.getElementById('Coasegur2_3').value = '';
   				document.getElementById('Coasegur2_4').value = '';
   				document.getElementById('Coasegur2_5').value = '';
   				document.getElementById('Coasegur2_6').value = '';
   				document.getElementById('Coasegur2_7').value = '';
   				document.getElementById('Coasegur2_8').value = '';
   				// MU-2016-006664 - RAROALE - FIN
   			}
            // R&V Correccion 03/08/2017-1-3 INI
            else {
                if (document.getElementById('Porcentaje2').value != '') {
                    document.getElementById('Porcentaje2').value = precisionDecimales(parseFloat(document.getElementById('Porcentaje2').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur2_2').value != '') {
                    document.getElementById('Coasegur2_2').value = precisionDecimales(parseFloat(document.getElementById('Coasegur2_2').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur2_3').value != '') {
                    document.getElementById('Coasegur2_3').value = precisionDecimales(parseFloat(document.getElementById('Coasegur2_3').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur2_4').value != '') {
                    document.getElementById('Coasegur2_4').value = precisionDecimales(parseFloat(document.getElementById('Coasegur2_4').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur2_5').value != '') {
                    document.getElementById('Coasegur2_5').value = precisionDecimales(parseFloat(document.getElementById('Coasegur2_5').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur2_6').value != '') {
                    document.getElementById('Coasegur2_6').value = precisionDecimales(parseFloat(document.getElementById('Coasegur2_6').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur2_7').value != '') {
                    document.getElementById('Coasegur2_7').value = precisionDecimales(parseFloat(document.getElementById('Coasegur2_7').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur2_8').value != '') {
                    document.getElementById('Coasegur2_8').value = precisionDecimales(parseFloat(document.getElementById('Coasegur2_8').value.replace(',','.')),2).toString().replace('.',',');
                }
            }
            // R&V Correccion 03/08/2017-1-3 FIN

   			if (Coaseguradora3 == '') {
   				// MU-2016-006664 - RAROALE - INI
   				document.getElementById('Porcentaje3').value = '';
   				document.getElementById('Coasegur3_2').value = '';
   				document.getElementById('Coasegur3_3').value = '';
   				document.getElementById('Coasegur3_4').value = '';
   				document.getElementById('Coasegur3_5').value = '';
   				document.getElementById('Coasegur3_6').value = '';
   				document.getElementById('Coasegur3_7').value = '';
   				document.getElementById('Coasegur3_8').value = '';
   				// MU-2016-006664 - RAROALE - FIN
   			}
            // R&V Correccion 03/08/2017-1-3 INI
            else {
                if (document.getElementById('Porcentaje3').value != '') {
                    document.getElementById('Porcentaje3').value = precisionDecimales(parseFloat(document.getElementById('Porcentaje3').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur3_2').value != '') {
                    document.getElementById('Coasegur3_2').value = precisionDecimales(parseFloat(document.getElementById('Coasegur3_2').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur3_3').value != '') {
                    document.getElementById('Coasegur3_3').value = precisionDecimales(parseFloat(document.getElementById('Coasegur3_3').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur3_4').value != '') {
                    document.getElementById('Coasegur3_4').value = precisionDecimales(parseFloat(document.getElementById('Coasegur3_4').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur3_5').value != '') {
                    document.getElementById('Coasegur3_5').value = precisionDecimales(parseFloat(document.getElementById('Coasegur3_5').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur3_6').value != '') {
                    document.getElementById('Coasegur3_6').value = precisionDecimales(parseFloat(document.getElementById('Coasegur3_6').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur3_7').value != '') {
                    document.getElementById('Coasegur3_7').value = precisionDecimales(parseFloat(document.getElementById('Coasegur3_7').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur3_8').value != '') {
                    document.getElementById('Coasegur3_8').value = precisionDecimales(parseFloat(document.getElementById('Coasegur3_8').value.replace(',','.')),2).toString().replace('.',',');
                }
            }
            // R&V Correccion 03/08/2017-1-3 FIN

   			if (Coaseguradora4 == '') {
   				// MU-2016-006664 - RAROALE - INI
   				document.getElementById('Porcentaje4').value = '';
   				document.getElementById('Coasegur4_2').value = '';
   				document.getElementById('Coasegur4_3').value = '';
   				document.getElementById('Coasegur4_4').value = '';
   				document.getElementById('Coasegur4_5').value = '';
   				document.getElementById('Coasegur4_6').value = '';
   				document.getElementById('Coasegur4_7').value = '';
   				document.getElementById('Coasegur4_8').value = '';
   				// MU-2016-006664 - RAROALE - FIN
   			}
            // R&V Correccion 03/08/2017-1-3 INI
            else {
                if (document.getElementById('Porcentaje4').value != '') {
                    document.getElementById('Porcentaje4').value = precisionDecimales(parseFloat(document.getElementById('Porcentaje4').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur4_2').value != '') {
                    document.getElementById('Coasegur4_2').value = precisionDecimales(parseFloat(document.getElementById('Coasegur4_2').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur4_3').value != '') {
                    document.getElementById('Coasegur4_3').value = precisionDecimales(parseFloat(document.getElementById('Coasegur4_3').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur4_4').value != '') {
                    document.getElementById('Coasegur4_4').value = precisionDecimales(parseFloat(document.getElementById('Coasegur4_4').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur4_5').value != '') {
                    document.getElementById('Coasegur4_5').value = precisionDecimales(parseFloat(document.getElementById('Coasegur4_5').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur4_6').value != '') {
                    document.getElementById('Coasegur4_6').value = precisionDecimales(parseFloat(document.getElementById('Coasegur4_6').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur4_7').value != '') {
                    document.getElementById('Coasegur4_7').value = precisionDecimales(parseFloat(document.getElementById('Coasegur4_7').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur4_8').value != '') {
                    document.getElementById('Coasegur4_8').value = precisionDecimales(parseFloat(document.getElementById('Coasegur4_8').value.replace(',','.')),2).toString().replace('.',',');
                }
            }
            // R&V Correccion 03/08/2017-1-3 FIN

   			if (Coaseguradora5 == '') {
   				// MU-2016-006664 - RAROALE - INI
   				document.getElementById('Porcentaje5').value = '';
   				document.getElementById('Coasegur5_2').value = '';
   				document.getElementById('Coasegur5_3').value = '';
   				document.getElementById('Coasegur5_4').value = '';
   				document.getElementById('Coasegur5_5').value = '';
   				document.getElementById('Coasegur5_6').value = '';
   				document.getElementById('Coasegur5_7').value = '';
   				document.getElementById('Coasegur5_8').value = '';
   				// MU-2016-006664 - RAROALE - FIN
   			}
            // R&V Correccion 03/08/2017-1-3 INI
            else {
                if (document.getElementById('Porcentaje5').value != '') {
                    document.getElementById('Porcentaje5').value = precisionDecimales(parseFloat(document.getElementById('Porcentaje5').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur5_2').value != '') {
                    document.getElementById('Coasegur5_2').value = precisionDecimales(parseFloat(document.getElementById('Coasegur5_2').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur5_3').value != '') {
                    document.getElementById('Coasegur5_3').value = precisionDecimales(parseFloat(document.getElementById('Coasegur5_3').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur5_4').value != '') {
                    document.getElementById('Coasegur5_4').value = precisionDecimales(parseFloat(document.getElementById('Coasegur5_4').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur5_5').value != '') {
                    document.getElementById('Coasegur5_5').value = precisionDecimales(parseFloat(document.getElementById('Coasegur5_5').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur5_6').value != '') {
                    document.getElementById('Coasegur5_6').value = precisionDecimales(parseFloat(document.getElementById('Coasegur5_6').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur5_7').value != '') {
                    document.getElementById('Coasegur5_7').value = precisionDecimales(parseFloat(document.getElementById('Coasegur5_7').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur5_8').value != '') {
                    document.getElementById('Coasegur5_8').value = precisionDecimales(parseFloat(document.getElementById('Coasegur5_8').value.replace(',','.')),2).toString().replace('.',',');
                }
            }
            // R&V Correccion 03/08/2017-1-3 FIN

   			if (Coaseguradora6 == '') {
   				// MU-2016-006664 - RAROALE - INI
   				document.getElementById('Porcentaje6').value = '';
   				document.getElementById('Coasegur6_2').value = '';
   				document.getElementById('Coasegur6_3').value = '';
   				document.getElementById('Coasegur6_4').value = '';
   				document.getElementById('Coasegur6_5').value = '';
   				document.getElementById('Coasegur6_6').value = '';
   				document.getElementById('Coasegur6_7').value = '';
   				document.getElementById('Coasegur6_8').value = '';
   				// MU-2016-006664 - RAROALE - FIN
   			}
            // R&V Correccion 03/08/2017-1-3 INI
            else {
                if (document.getElementById('Porcentaje6').value != '') {
                    document.getElementById('Porcentaje6').value = precisionDecimales(parseFloat(document.getElementById('Porcentaje6').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur6_2').value != '') {
                    document.getElementById('Coasegur6_2').value = precisionDecimales(parseFloat(document.getElementById('Coasegur6_2').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur6_3').value != '') {
                    document.getElementById('Coasegur6_3').value = precisionDecimales(parseFloat(document.getElementById('Coasegur6_3').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur6_4').value != '') {
                    document.getElementById('Coasegur6_4').value = precisionDecimales(parseFloat(document.getElementById('Coasegur6_4').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur6_5').value != '') {
                    document.getElementById('Coasegur6_5').value = precisionDecimales(parseFloat(document.getElementById('Coasegur6_5').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur6_6').value != '') {
                    document.getElementById('Coasegur6_6').value = precisionDecimales(parseFloat(document.getElementById('Coasegur6_6').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur6_7').value != '') {
                    document.getElementById('Coasegur6_7').value = precisionDecimales(parseFloat(document.getElementById('Coasegur6_7').value.replace(',','.')),2).toString().replace('.',',');
                }
                if (document.getElementById('Coasegur6_8').value != '') {
                    document.getElementById('Coasegur6_8').value = precisionDecimales(parseFloat(document.getElementById('Coasegur6_8').value.replace(',','.')),2).toString().replace('.',',');
                }
            }
            // R&V Correccion 03/08/2017-1-3 FIN
   		}


//Inicio cambio Julio 2017
    /**
    * Suma de la fila correspondiente
    * @author EVERIS
    */
    function sumaTotalesCoa (totalFila, coa, coaAbridora) {
	    var condicionCalculo = document.getElementById('valoresManuales2').checked; // R&V CA Fase II CU011-COASEGURO
	    if (condicionCalculo) { // R&V Correccion 03/08/2017-1-3
            var Coasegur1 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur1_'+coa).value));
            if (isNaN(Coasegur1)) {
            Coasegur1 = 0;
            }

            var Coasegur2 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur2_'+coa).value));
            if (isNaN(Coasegur2)) {
            Coasegur2 = 0;
            }
            var Coasegur3 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur3_'+coa).value));
            if (isNaN(Coasegur3)) {
            Coasegur3 = 0;
            }
            var Coasegur4 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur4_'+coa).value));
            if (isNaN(Coasegur4)) {
            Coasegur4 = 0;
            }
            var Coasegur5 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur5_'+coa).value));
            if (isNaN(Coasegur5)) {
            Coasegur5 = 0;
            }
            var Coasegur6 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur6_'+coa).value));
            if (isNaN(Coasegur6)) {
            Coasegur6 = 0;
            }

            var sumaTotalFila = Coasegur1 + Coasegur2 + Coasegur3 + Coasegur4 + Coasegur5 + Coasegur6;
            var difRtoIntTotal = totalFila - sumaTotalFila;

            if (!isNaN(difRtoIntTotal ) && difRtoIntTotal != '') {
                var RtoIntCoaAbridora = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur'+coaAbridora+'_'+coa).value));
                // R&V Correccion 03/08/2017-1-3 INI
                if (isNaN(RtoIntCoaAbridora)){
                    RtoIntCoaAbridora= 0.0;
                }
                // R&V Correccion 03/08/2017-1-3 FIN
                var ajusteDifRtoInt = RtoIntCoaAbridora+difRtoIntTotal;
                var strAjusteRtoInt = new String(ajusteDifRtoInt);
                strAjusteRtoInt = precisionDecimales(strAjusteRtoInt, 2);
                document.getElementById('Coasegur'+coaAbridora+'_'+coa).value = strAjusteRtoInt.replace('.',',');
            }
        } // R&V Correccion 03/08/2017-1-3
    }

	/**
    * Ajuste de los importes de las coaseguradoras.
    * La suma total de las coaseguradoras sera igual al importePri.
    * La diferencia se pasa a la coaseguradora Mapfre C511 o C0511
    * @author EVERIS
    */
	function ajusteImportesCoa(numCoa) { // R&V Correccion Ajustes Coa CAC - Añadimos parametro numCoa (str)
      /* R&V Correccion Ajustes Coa CAC - El parámetro numCoa (string) se incorpora en los campos a
      la llamada sumTotal() en los siguientes id's:
            Porcentaje1, Porcentaje2, Porcentaje3, Porcentaje4, Porcentaje5, Porcentaje6,
            Coasegur1_2, Coasegur2_2, Coasegur3_2, Coasegur4_2, Coasegur5_2, Coasegur6_2.
      Con el fin de identificar en la llamada a ajusteImportesCoa() a la coaseguradora que hace la llamada
      y no reescribir campos si es C0511
      */
	    var condicionCalculo = document.getElementById('valoresManuales2').checked; // R&V CA Fase II CU011-COASEGURO
	    if (condicionCalculo) { // R&V Correccion 03/08/2017-1-3
            //Se ajusta tanto el importe como el resto de campos
            var Coaseguradora1 = (document.getElementById('Coaseguradora1').value.toUpperCase());
            var Coaseguradora2 = (document.getElementById('Coaseguradora2').value.toUpperCase());
            var Coaseguradora3 = (document.getElementById('Coaseguradora3').value.toUpperCase());
            var Coaseguradora4 = (document.getElementById('Coaseguradora4').value.toUpperCase());
            var Coaseguradora5 = (document.getElementById('Coaseguradora5').value.toUpperCase());
            var Coaseguradora6 = (document.getElementById('Coaseguradora6').value.toUpperCase());

            //Si hay diferencia de importe se la ajusto a la coaseguradora principal C0511
            var valorCoa = "0";
            if ((Coaseguradora1 != '') && (Coaseguradora1=='C0511' || Coaseguradora1=='C511')) {
                valorCoa = "1";
            } else if ((Coaseguradora2 != '') && (Coaseguradora2=='C0511' || Coaseguradora2=='C511')) {
                valorCoa = "2";
            } else if ((Coaseguradora3 != '') && (Coaseguradora3=='C0511' || Coaseguradora3=='C511')) {
                valorCoa = "3";
            } else if ((Coaseguradora4 != '') && (Coaseguradora4=='C0511' || Coaseguradora4=='C511')) {
                valorCoa = "4";
            } else if ((Coaseguradora5 != '') && (Coaseguradora5=='C0511' || Coaseguradora5=='C511')) {
                valorCoa = "5";
            } else if ((Coaseguradora6 != '') && (Coaseguradora6=='C0511' || Coaseguradora6=='C511')) {
                valorCoa = "6";
            }

            if (valorCoa != '0' && valorCoa!=numCoa) { // R&V Correccion Ajustes Coa CAC - Añadimos && valorCoa!=numCoa
                //Ajuste del importe
                //Sumo importe total
                var ImporteCapAj = parseFloat(cambiarPuntoComa(document.getElementById('ImpCapital').value));
                var BeneficiosPriAj = parseFloat(cambiarPuntoComa(document.getElementById('BeneficiosPri').value));
                // R&V IN026M - INI
                //var ImportePriAj = parseFloat(cambiarPuntoComa(document.getElementById('BeneficiosPri').value)); //R&V ERROR!!! No es 'BeneficiosPri'
                var ImportePriAj = parseFloat(cambiarPuntoComa(document.getElementById('ImportePri').value));
                // R&V IN026M - INI
                var ImporteCompAj = parseFloat(cambiarPuntoComa(document.getElementById('ImporteComp').value));
                if (isNaN(ImporteCapAj)) {
                        ImporteCapAj = 0;
                }
                if (isNaN(BeneficiosPriAj)) {
                        BeneficiosPriAj = 0;
                }
                if (isNaN(ImportePriAj)) {
                         ImportePriAj = 0;
                 }
                  if (isNaN(ImportePriAj)) {
                      ImporteCompAj = 0;
              }
               // var importeTotalAj = ImporteCapAj + BeneficiosPriAj+ImportePriAj;
                var importeTotalAj = ImporteCapAj + BeneficiosPriAj;
                    // MU-2016-006664 - 06-05-2016 - RAROALE - FIN
                    if (!document.getElementById('ImportePri').disabled) {
                        importeTotalAj = importeTotalAj + ImportePriAj;
                    if (!document.getElementById('ImporteComp').disabled) {
                        importeTotalAj = importeTotalAj + ImporteCompAj;
                    }
                }
                 if (isNaN(importeTotalAj)) {
                     importeTotalAj = 0;
                 }
                var strImporteTotal = new String(importeTotalAj);
                strImporteTotal = precisionDecimales(strImporteTotal, 2);
                document.getElementById('CoasegurTot_2').value = strImporteTotal.replace('.',',');

                //Ajusto el importe

                // R&V Correccion 03/08/2017-1-3 INI
                // 'CoasegurTot_2' ya tiene el importe correcto, no hay que corregir como en Rescates
                // R&V Correccion 03/08/2017-1-3 FIN

                var totalDos = document.getElementById('CoasegurTot_2').value;
                if ( totalDos !='' && totalDos!='0.00' && totalDos!='0,00') {
                    var ImporteTotalCoas = parseFloat(cambiarPuntoComa(document.getElementById('CoasegurTot_2').value));

                    // R&V Correccion 03/08/2017-1-3 INI
                    // ImporteTotalCoas tiene el importe correcto, no hay que corregir como en Rescates
                    // R&V Correccion 03/08/2017-1-3 FIN

                    sumaTotalesCoa(ImporteTotalCoas,2,valorCoa);
                }

                calculoPorImportes(valorCoa,'I'); // R&B Ajuste centimos 22/09/2017

                // R&B Ajuste centimos 22/09/2017 - INI
                //Ajuste del Rto. Integro
//                var totalTres = document.getElementById('CoasegurTot_3').value;
//                if (totalTres !='' && totalTres!='0.00' && totalTres!='0,00') {
//                    var RtoIntTotalCoas = parseFloat(cambiarPuntoComa(document.getElementById('CoasegurTot_3').value));
//                    sumaTotalesCoa(RtoIntTotalCoas,3,valorCoa);
//                }
                var total3 = parseFloat(cambiarPuntoComa(document.getElementById('RtoIntegroCap').value));
                if (isNaN(total3)) {
                    total3 = 0.0;
                }
                var total32 = parseFloat(cambiarPuntoComa(document.getElementById('RtoIntegroPri').value));
                if (!isNaN(total32)){
                    total3 += total32;
                }
                var total33 = parseFloat(cambiarPuntoComa(document.getElementById('RtoIntegroComp').value));
                if (!isNaN(total33)){
                    total3 += total33;
                }
                if (!isNaN(total3)) {
                    sumaTotalesCoa(total3,3,valorCoa);
                }

                //Ajuste de Red. Primas
//                var totalCuatro = document.getElementById('CoasegurTot_4').value;
//                if (totalCuatro !='' && totalCuatro!='0.00' && totalCuatro!='0,00') {
//                    var RedPrimasTotalCoas = parseFloat(cambiarPuntoComa(document.getElementById('CoasegurTot_4').value));
//                    sumaTotalesCoa(RedPrimasTotalCoas,4,valorCoa);
//                }
                var total4 = parseFloat(cambiarPuntoComa(document.getElementById('RedPrimasCap').value));
                if (isNaN(total4)) {
                    total4 = 0.0;
                }
                var total42 = parseFloat(cambiarPuntoComa(document.getElementById('RedPrimasPri').value));
                if (!isNaN(total42)){
                    total4 += total42;
                }
                var total43 = parseFloat(cambiarPuntoComa(document.getElementById('RedPrimasComp').value));
                if (!isNaN(total43)){
                    total4 += total43;
                }
                if (!isNaN(total4)) {
                    sumaTotalesCoa(total4,4,valorCoa);
                }

                //Ajuste de Red. Transitoria
//                var totalCinco = document.getElementById('CoasegurTot_5').value;
//                if (totalCinco !='' && totalCinco!='0.00' && totalCinco!='0,00') {
//                    var RedTransitTotalCoas = parseFloat(cambiarPuntoComa(document.getElementById('CoasegurTot_5').value));
//                     sumaTotalesCoa(RedTransitTotalCoas,5,valorCoa);
//                }
                var total5 = parseFloat(cambiarPuntoComa(document.getElementById('RedTransitCap').value));
                if (isNaN(total5)) {
                    total5 = 0.0;
                }
                var total52 = parseFloat(cambiarPuntoComa(document.getElementById('RedTransitPri').value));
                if (!isNaN(total52)){
                    total5 += total52;
                }
                var total53 = parseFloat(cambiarPuntoComa(document.getElementById('RedTransitComp').value));
                if (!isNaN(total53)){
                    total5 += total53;
                }
                if (!isNaN(total5)) {
                    sumaTotalesCoa(total5,5,valorCoa);
                }

                //Ajuste Rto. Neto
//                var totalSeis = document.getElementById('CoasegurTot_6').value;
//                if (totalSeis !='' && totalSeis!='0.00' && totalSeis!='0,00') {
//                    var RtoNetoTotalCoas = parseFloat(cambiarPuntoComa(document.getElementById('CoasegurTot_6').value));
//                    sumaTotalesCoa(RtoNetoTotalCoas,6,valorCoa);
//                }
                var total6 = parseFloat(cambiarPuntoComa(document.getElementById('RtoNetoCap').value));
                if (isNaN(total6)) {
                    total6 = 0.0;
                }
                var total62 = parseFloat(cambiarPuntoComa(document.getElementById('RtoNetoPri').value));
                if (!isNaN(total62)){
                    total6 += total62;
                }
                var total63 = parseFloat(cambiarPuntoComa(document.getElementById('RtoNetoComp').value));
                if (!isNaN(total63)){
                    total6 += total63;
                }
                if (!isNaN(total6)) {
                    sumaTotalesCoa(total6,6,valorCoa);
                }

                 //Ajuste Retencion
//                var totalSiete = document.getElementById('CoasegurTot_7').value;
//                if (totalSiete !='' && totalSiete!='0.00' && totalSiete!='0,00') {
//                    var RetencionTotalCoas = parseFloat(cambiarPuntoComa(document.getElementById('CoasegurTot_7').value));
//                    sumaTotalesCoa(RetencionTotalCoas,7,valorCoa);
//                }
                var total7 = parseFloat(cambiarPuntoComa(document.getElementById('RetencionCap').value));
                if (isNaN(total7)) {
                    total7 = 0.0;
                }
                var total72 = parseFloat(cambiarPuntoComa(document.getElementById('RetencionPri').value));
                if (!isNaN(total72)){
                    total7 += total72;
                }
                var total73 = parseFloat(cambiarPuntoComa(document.getElementById('RetencionComp').value));
                if (!isNaN(total73)){
                    total7 += total73;
                }
                if (!isNaN(total7)) {
                    sumaTotalesCoa(total7,7,valorCoa);
                }

                //Ajuste de Compen
//                var totalOcho = document.getElementById('CoasegurTot_8').value;
//                if (totalOcho !='' && totalOcho!='0.00' && totalOcho!='0,00') {
//                    var CompensaTotalCoas = parseFloat(cambiarPuntoComa(document.getElementById('CoasegurTot_8').value));
//                    sumaTotalesCoa(CompensaTotalCoas,8,valorCoa);
//                }
                var total8 = parseFloat(cambiarPuntoComa(document.getElementById('CompensaCap').value));
                if (!isNaN(total8)) {
                    sumaTotalesCoa(total8,8,valorCoa);
                }
                // R&B Ajuste centimos 22/09/2017 - FIN

                //Suma total de los porcentajes informados
                var totalPor = parseFloat(0,00);
                if ( Coaseguradora1 != '') {
                    var por1 = (document.getElementById('Porcentaje1').value);
                    if ( por1 !='' && por1!='0.00' && por1!='0,00') {
                       var porce1 = parseFloat(cambiarPuntoComa(document.getElementById('Porcentaje1').value));
                       totalPor = totalPor + porce1;
                    }
                }
                if (Coaseguradora2 != '') {
                    var por2 = (document.getElementById('Porcentaje2').value);
                    if ( por2 !='' && por2!='0.00' && por2!='0,00') {
                      var porce2 = parseFloat(cambiarPuntoComa(document.getElementById('Porcentaje2').value));
                      totalPor = totalPor + porce2;
                    }
                }
                if (Coaseguradora3 != '') {
                    var por3 = (document.getElementById('Porcentaje3').value);
                    if ( por3 !='' && por3!='0.00' && por3!='0,00') {
                      var porce3 = parseFloat(cambiarPuntoComa(document.getElementById('Porcentaje3').value));
                      totalPor = totalPor + porce3;
                    }
                }
                if (Coaseguradora4 != '') {
                    var por4 = (document.getElementById('Porcentaje4').value);
                    if ( por4 !='' && por4!='0.00' && por4!='0,00') {
                      var porce4 = parseFloat(cambiarPuntoComa(document.getElementById('Porcentaje4').value));
                      totalPor = totalPor + porce4;
                    }
                }
                if (Coaseguradora5 != '') {
                    var por5 = (document.getElementById('Porcentaje5').value);
                    if ( por5 !='' && por5!='0.00' && por5!='0,00') {
                      var porce5 = parseFloat(cambiarPuntoComa(document.getElementById('Porcentaje5').value));
                      totalPor = totalPor + porce5;
                    }
                }
                if (Coaseguradora6 != '') {
                    var por6 = (document.getElementById('Porcentaje6').value);
                    if ( por6 !='' && por6!='0.00' && por6!='0,00') {
                      var porce6 = parseFloat(cambiarPuntoComa(document.getElementById('Porcentaje6').value));
                      totalPor = totalPor + porce6;
                    }
                }
                var strPorceTotal = new String(totalPor);
                strPorceTotal = precisionDecimales(strPorceTotal, 2);
                document.getElementById('PorcentajeTot').value = strPorceTotal.replace('.',',');
                // R&V Correccion Ajustes Coa CAC - INI
                //calculoPorImportes(valorCoa,'I');
                // R&V Correccion Ajustes Coa CAC - INI
            }
          } // R&V Correccion 03/08/2017-1-3
    }
    //Fin cambio Julio 2017

/**
* Suma total de los campos coaseguradoras
* uno para cada uno de los coaseguradores
* @author EVERIS
*/   		
  function sumaTotal(numCoa) { //R&V Correccion Ajustes Coa CAC - Añadimos parametro numCoa (str)
    /* R&V Correccion Ajustes Coa CAC - El parámetro numCoa (string) se incorpora en los campos a
    la llamada sumTotal() en los siguientes id's:
          Porcentaje1, Porcentaje2, Porcentaje3, Porcentaje4, Porcentaje5, Porcentaje6,
          Coasegur1_2, Coasegur2_2, Coasegur3_2, Coasegur4_2, Coasegur5_2, Coasegur6_2.
    Con el fin de identificar en la llamada a ajusteImportesCoa() a la coaseguradora que hace la llamada
    y no reescribir campos si es C0511
    */

    var condicionCalculo = document.getElementById('valoresManuales2').checked; // R&V CA Fase II CU011-COASEGURO
    if (condicionCalculo) { // R&V Correccion 03/08/2017-1-3

        // MU-2016-006664 - RAROALE - INI
        var Importe1 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur1_2').value));
        if (isNaN(Importe1)) {
            Importe1 = 0;
        }
        var Importe2 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur2_2').value));
        if (isNaN(Importe2)) {
            Importe2 = 0;
        }
        var Importe3 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur3_2').value));
        if (isNaN(Importe3)) {
            Importe3 = 0;
        }
        var Importe4 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur4_2').value));
        if (isNaN(Importe4)) {
            Importe4 = 0;
        }
        var Importe5 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur5_2').value));
        if (isNaN(Importe5)) {
            Importe5 = 0;
        }
        var Importe6 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur6_2').value));
        if (isNaN(Importe6)) {
            Importe6 = 0;
        }

        // El porcentaje total se calcula usando los importes de prima, importe complementario e importes de Coaseguro
        var suma1 = Importe1 + Importe2 + Importe3 + Importe4 + Importe5 + Importe6;
        var ImporteCap = parseFloat(cambiarPuntoComa(document.getElementById('ImpCapital').value));
        var ImportePri = parseFloat(cambiarPuntoComa(document.getElementById('ImportePri').value));
        var ImporteComp = parseFloat(cambiarPuntoComa(document.getElementById('ImporteComp').value));
        // MU-2016-006664 - 06-05-2016 - RAROALE - INI
        var BeneficiosPri = parseFloat(cambiarPuntoComa(document.getElementById('BeneficiosPri').value));
        if (isNaN(BeneficiosPri)) {
            BeneficiosPri = 0;
        }
        var importeTotal = ImporteCap + BeneficiosPri;
        // MU-2016-006664 - 06-05-2016 - RAROALE - FIN
        if (!document.getElementById('ImportePri').disabled) {
            importeTotal = importeTotal + ImportePri;
            if (!document.getElementById('ImporteComp').disabled) {
                importeTotal = importeTotal + ImporteComp;
            }
        }
            //Inicio Julio 217
            var strImporteTotal = precisionDecimales(importeTotal, 2);
            // R&V Correccion 03/08/2017-1-3 INI
            // No queremos el total real sino el total de cada uno de los importes
            //document.getElementById('CoasegurTot_2').value = strImporteTotal;
            document.getElementById('CoasegurTot_2').value = precisionDecimales(suma1, 2).toString().replace('.',',');
            // R&V Correccion 03/08/2017-1-3 FIN
            //Fin Julio 2017


        var porcentTotal = (suma1 * 100) / importeTotal;

        if (isNaN(porcentTotal)) {
            porcentTotal = 0;
        }

        var strPorcent = new String(porcentTotal);
        strPorcent = precisionDecimales(strPorcent, 2);
        document.getElementById('PorcentajeTot').value = strPorcent.replace('.',',');

        if (suma1 == 0 ) {
            document.getElementById('PorcentajeTot').value = '';
            document.getElementById('CoasegurTot_2').value = '';
            document.getElementById('CoasegurTot_3').value = '';
            document.getElementById('CoasegurTot_4').value = '';
            document.getElementById('CoasegurTot_5').value = '';
            document.getElementById('CoasegurTot_6').value = '';
            document.getElementById('CoasegurTot_7').value = '';
            document.getElementById('CoasegurTot_8').value = '';
            //document.getElementById('totPagMafre1').checked = 'checked';
        } else {
            sumaCampoTotal(2);
            sumaCampoTotal(3);
            sumaCampoTotal(4);
            sumaCampoTotal(5);
            sumaCampoTotal(6);
            sumaCampoTotal(7);
            sumaCampoTotal(8);
            //document.getElementById('totPagMafre2').checked = 'checked';
        }
        // MU-2016-006664 - RAROALE - INI

        //ajusteImportesCoa(numCoa);//Julio 2017 // R&V Correccion Ajustes Coa CAC - reenviamos parametro numCoa (str)// R&V Correccion 03/08/2017-1-3
   	} // R&V Correccion 03/08/2017-1-3
  }
  
 /**
* Suma total de los campos coaseguradoras
* uno para cada uno de los coaseguradores
* @author EVERIS
*/   		
  function sumaCampoTotal(coa) {
   		
	    var condicionCalculo = document.getElementById('valoresManuales2').checked; // R&V CA Fase II CU011-COASEGURO
	    if (condicionCalculo) { // R&V Correccion 03/08/2017-1-3

   			
   			
   			var Coasegur1 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur1_'+coa).value));
   			if (isNaN(Coasegur1)) {
   			Coasegur1 = 0;  
   			}
   			
   			var Coasegur2 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur2_'+coa).value));
   			if (isNaN(Coasegur2)) {
   			Coasegur2 = 0;  
   			}
   			var Coasegur3 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur3_'+coa).value));
   			if (isNaN(Coasegur3)) {
   			Coasegur3 = 0;  
   			}
   			var Coasegur4 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur4_'+coa).value));
   			if (isNaN(Coasegur4)) {
   			Coasegur4 = 0;  
   			}
   			var Coasegur5 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur5_'+coa).value));
   			if (isNaN(Coasegur5)) {
   			Coasegur5 = 0;  
   			}
   			var Coasegur6 = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur6_'+coa).value));
   			if (isNaN(Coasegur6)) {
   			Coasegur6 = 0;  
   			}
   			
   			var suma2 = Coasegur1 + Coasegur2 + Coasegur3 + Coasegur4 + Coasegur5 + Coasegur6;
   			
   			var strPorcent2 = new String(suma2);
	   		strPorcent2 = precisionDecimales(strPorcent2, 2);
   			document.getElementById('CoasegurTot_'+coa).value = strPorcent2.replace('.',','); 
   			
   		/*	if (coa == '2'){
   				var ImporteCap = parseFloat(cambiarPuntoComa(document.getElementById('ImpCapital').value));
   				var ImportePri = parseFloat(cambiarPuntoComa(document.getElementById('ImportePri').value));
   				// MU-2016-006664 - RAROALE - INI
   	   			if (!isNaN(ImportePri) && !isNaN(ImporteComp)) {
		   	   		var Importe = (ImportePri + ImporteComp);
		   			var strImporte = precisionDecimales(Importe, 2);
		   			document.getElementById('CoasegurTot_'+coa).value = strImporte;
   	   			}
   	   			// MU-2016-006664 - RAROALE - FIN
   			}*/

            /*<<<<<<<<<<<<<<<<<<<<<<<<<<  R&V Correccion 03/08/2017-1-3 ANULACION INI <<<<<<<<<<<<<<
   			if (coa == '3'){
   				var ImporteCap = parseFloat(cambiarPuntoComa(document.getElementById('RtoIntegroCap').value));
   				var ImportePri = parseFloat(cambiarPuntoComa(document.getElementById('RtoIntegroPri').value));
   	   			var ImporteComp = parseFloat(cambiarPuntoComa(document.getElementById('RtoIntegroComp').value));
   	   		var Importe = (ImporteCap + ImportePri + ImporteComp);
	   	   		var strImporte = precisionDecimales(Importe, 2);
	   			document.getElementById('CoasegurTot_'+coa).value = strImporte;
   			}
   			
   			if (coa == '4'){
   				var ImporteCap = parseFloat(cambiarPuntoComa(document.getElementById('RedPrimasCap').value));
   				var ImportePri = parseFloat(cambiarPuntoComa(document.getElementById('RedPrimasPri').value));
   	   			var ImporteComp = parseFloat(cambiarPuntoComa(document.getElementById('RedPrimasComp').value));
   	   			var Importe = (ImporteCap + ImportePri + ImporteComp);
	   	   		var strImporte = precisionDecimales(Importe, 2);
	   			document.getElementById('CoasegurTot_'+coa).value = strImporte;
   			}
   			
   			if (coa == '5'){
   				var ImporteCap = parseFloat(cambiarPuntoComa(document.getElementById('RedTransitCap').value));
   				var ImportePri = parseFloat(cambiarPuntoComa(document.getElementById('RedTransitPri').value));
   	   			var ImporteComp = parseFloat(cambiarPuntoComa(document.getElementById('RedTransitComp').value));
   	   			var Importe = (ImporteCap + ImportePri + ImporteComp);
	   	   		var strImporte = precisionDecimales(Importe, 2);
	   			document.getElementById('CoasegurTot_'+coa).value = strImporte;
   			}
   			
   			if (coa == '6'){
   				var ImporteCap = parseFloat(cambiarPuntoComa(document.getElementById('RtoNetoCap').value));
   				var ImportePri = parseFloat(cambiarPuntoComa(document.getElementById('RtoNetoPri').value));
   	   			var ImporteComp = parseFloat(cambiarPuntoComa(document.getElementById('RtoNetoComp').value));
   	   			var Importe = (ImporteCap + ImportePri + ImporteComp);
	   			var strImporte = precisionDecimales(Importe, 2);
	   			document.getElementById('CoasegurTot_'+coa).value = strImporte;
   			}
   			
   			if (coa == '7'){
   				var ImporteCap = parseFloat(cambiarPuntoComa(document.getElementById('RetencionCap').value));
   				var ImportePri = parseFloat(cambiarPuntoComa(document.getElementById('RetencionPri').value));
   	   			var ImporteComp = parseFloat(cambiarPuntoComa(document.getElementById('RetencionComp').value));
   	   			var Importe = (ImporteCap + ImportePri + ImporteComp);
	   			var strImporte = precisionDecimales(Importe, 2);
	   			document.getElementById('CoasegurTot_'+coa).value = strImporte;
   			}
   			
   			
   			if (coa == '8'){
   				var ImportePri = parseFloat(cambiarPuntoComa(document.getElementById('CompensaCap').value));
	   	   		var Importe = (ImportePri);
	   			var strImporte = precisionDecimales(Importe, 2);
	   			document.getElementById('CoasegurTot_'+coa).value = strImporte;
   			}
            <<<<<<<<<<<<<<<<<<<<<<<<<<  R&V Correccion 03/08/2017-1-3 ANULACION FIN <<<<<<<<<<<<<< */
         } // R&V Correccion 03/08/2017-1-3
      }
   			
		// FIN MODIFICACION EVERIS

   // R&V Correccion 03/08/2017-1-3 INI
   function empiezaPor(prefijo, cadena){
   // Nos dice si 'cadena' empieza por 'prefijo'
        if (prefijo.length > cadena.length) {
            return false;
        } else {
            return prefijo == cadena.substring(0,prefijo.length);
        }
   }

   function terminaPor(sufijo, cadena){
   // Nos dice si 'cadena' termina en 'sufijo'
        if (sufijo.length > cadena.length){
            return false;
        } else {
            return sufijo == cadena.substring(cadena.length-sufijo.length, cadena.length);
        }
   }

   function pulsaEnter(ev, idCampo, coa){
   //Si pulsa enter en el campo, llamamos al recalculoCoaPorCambioDe()
        tecla = (document.all) ? ev.keyCode : ev.which;
        if (tecla==13){
            recalculoCoaPorCambioDe(idCampo, coa);
        }
   }

    function calculaTotales(){
        sumaCampoTotal('2');
        sumaCampoTotal('3');
        sumaCampoTotal('4');
        sumaCampoTotal('5');
        sumaCampoTotal('6');
        sumaCampoTotal('7');
        sumaCampoTotal('8');
    }

   function recalculoCoaPorCambioDe(idCampo,coa){

        if (empiezaPor('Coaseguradora',idCampo)) { // Cambio en coaseguradora
            if (document.getElementById(idCampo).value.toUpperCase() =='C0511') {
                ajusteImportesCoa('NULA'); // Llamamos al reajuste de valores hacia C0511 y con 'NULA' para forzar el reajuste
                limpiaCoase();
                calculaTotales();
                sumaTotal();
            }
            return;
        }

        if (empiezaPor('Porcentaje',idCampo)) { // Cambio en Porcentaje
            calculoPorImportes(coa, 'P'); //abro esta funcion ...
            ajusteImportesCoa(coa); // Llamamos al reajuste de valores hacia C0511
            limpiaCoase();
            calculaTotales();
            sumaTotal();
            // R&V CA Fase II CU011-COASEGURO - INI
            if (document.getElementById('valoresManuales1').checked) {
                sumaTotalFila('1');
            }
            // R&V CA Fase II CU011-COASEGURO - FIN
            return;
        }

        if (terminaPor('_2',idCampo)) { // Cambio en Importe
            calculoPorImportes(coa, 'I'); //abro esta funcion ...
            ajusteImportesCoa(coa); // Llamamos al reajuste de valores hacia C0511
            limpiaCoase();
            calculaTotales();
            sumaTotal();
            // R&V CA Fase II CU011-COASEGURO - INI
            if (document.getElementById('valoresManuales1').checked) {
                sumaTotalFila('2');
            }
            // R&V CA Fase II CU011-COASEGURO - FIN
            return;
        }

        if (idCampo == 'ImpCapital' || idCampo == 'BeneficiosPri' || idCampo == 'ImportePri' || idCampo == 'ImporteComp' ){
            calculoPorImportes('1','I'); calculoPorImportes('2','I'); calculoPorImportes('3','I'); // R&V - Marzo 2018 - Forzamos a 'I'
            calculoPorImportes('4','I'); calculoPorImportes('5','I'); calculoPorImportes('6','I'); // R&V - Marzo 2018 - Forzamos a 'I'
            //ajusteImportesCoa(coa); // Llamamos al reajuste de valores hacia C0511
            limpiaCoase();
            calculaTotales();
            sumaTotal();
            return;
        }

        if (idCampo == 'CompensaCap') {
            calculoPorImportes('1','I'); calculoPorImportes('2','I'); calculoPorImportes('3','I'); // R&V - Marzo 2018 - Forzamos a 'I'
            calculoPorImportes('4','I'); calculoPorImportes('5','I'); calculoPorImportes('6','I'); // R&V - Marzo 2018 - Forzamos a 'I'
            limpiaCoase();
            calculaTotales();
            sumaTotal();
            return;
        }
        // R&V CA Fase II CU011-COASEGURO - INI
        if (terminaPor('_3',idCampo) || terminaPor('_4',idCampo) || terminaPor('_5',idCampo) || terminaPor('_6',idCampo) || terminaPor('_7',idCampo) || terminaPor('_8',idCampo) ) {
            sumaTotalFila(idCampo.slice(-1)); // ultimo caracter del idCampo ('3'..'8')
            return;
        }
        // R&V CA Fase II CU011-COASEGURO - FIN
   }
   // R&V Correccion 03/08/2017-1-3 FIN

// R&V CA Fase II CU011-COASEGURO - INI
// R&V Esta funcion pone el total de la fila numFila ('1'..'8') en su total correspondiente.
// R&V La fila '1' corresponde a porcentaje, la '2' a importes y el resto al resto de coeficientes
function sumaTotalFila(numFila){
    var nombreCampo = '';
    var nombreCampoTotal = '';
    if (numFila=='1') { // porcentajes
        nombreCampo='Porcentaje$';
        nombreCampoTotal='PorcentajeTot';
    } else { // resto de valores, que coinciden con el prefijo de su id
        if (numFila=='2' || numFila=='3' || numFila=='4' || numFila=='5' || numFila=='6' || numFila=='7' || numFila=='8') {
            nombreCampo='Coasegur$_'+numFila;
            nombreCampoTotal='CoasegurTot_'+numFila;
        }
    }
    if (nombreCampo!=''){
        var totalAcumulado=0.0;
        for (var numColumna=1;numColumna<=6;numColumna++) {
            var tmpNombreCampo = nombreCampo.replace('$',numColumna.toString());
            var valorCampo = document.getElementById(tmpNombreCampo).value.replace(',','.');
            if ( ! isNaN(parseFloat(valorCampo))) {
                totalAcumulado += parseFloat(valorCampo);
            }
        }
        totalAcumulado =  totalAcumulado.toFixed(2);
        document.getElementById(nombreCampoTotal).value = totalAcumulado.toString() ;
    }
}
// R&V CA Fase II CU011-COASEGURO - FIN

// R&V - Marzo 2018 - INI
function porcentPreciso(c){

    var ImporteEnTabla = parseFloat(cambiarPuntoComa(document.getElementById('Coasegur'+c+'_2').value));
    var ImporteCapEnFormulario = parseFloat(cambiarPuntoComa(document.getElementById('ImpCapital').value));
    var BeneficiosPriEnFormulario = parseFloat(cambiarPuntoComa(document.getElementById('BeneficiosPri').value));
    var ImportePriEnFormulario = parseFloat(cambiarPuntoComa(document.getElementById('ImportePri').value));
    var ImporteCompEnFormulario = parseFloat(cambiarPuntoComa(document.getElementById('ImporteComp').value));

    if (isNaN(ImporteEnTabla)) {ImporteEnTabla = 0.0;}
    if (isNaN(ImporteCapEnFormulario)) {ImporteCapEnTabla = 0.0;}
    if (isNaN(BeneficiosPriEnFormulario)) {BeneficiosPriEnTabla = 0.0;}
    if (isNaN(ImportePriEnFormulario)) {ImportePriEnTabla = 0.0;}
    if (isNaN(ImporteCompEnFormulario)) {ImporteCompEnTabla = 0.0;}

    var denominador = ImporteCapEnFormulario + BeneficiosPriEnFormulario;
    if (!document.getElementById('ImportePri').disabled) {
        denominador += ImportePriEnFormulario;
        if (!document.getElementById('ImporteComp').disabled) {
            denominador += ImporteCompEnFormulario;
        }
    }

    if (denominador!=0.0) {
        var PorcentajePreciso = ImporteEnTabla * 100 / denominador;
    } else {
        var PorcentajePreciso = 0.0;
    }

    return PorcentajePreciso.toFixed(6);
}
// R&V - Marzo 2018 - FIN
