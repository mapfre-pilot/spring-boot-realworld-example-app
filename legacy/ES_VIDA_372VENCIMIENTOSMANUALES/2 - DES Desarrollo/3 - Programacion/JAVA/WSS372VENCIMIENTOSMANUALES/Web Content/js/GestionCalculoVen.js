/* MODIFICACION : MU-2016-006664
FECHA : MARZO 2016
DESCRIPCION: Se permite modificar y guardar en BBDD los importes de Coaseguros
AUTOR : RAROALE*/

/**
* Funcion para calcular el campo duracion segun tenga valor fecEfecto y fecVencimiento,
* se sumaran los años o se restan.
* @author EVERIS
*/

   function calcularDuracion() {  
      var valorFecVencimiento = isValorFecha('fecVencimiento');   
      var valorFecEfecto = isValorFecha('fecEfect'); 
      
      if ( valorFecEfecto && valorFecVencimiento ) {  
	  	
		   // Pasamos el valor a tipo float
	   		var valueAnioEfec = parseFloat(document.getElementById('fecEfect_year').value);
	   		// Pasamos el valor a tipo float.
	   		var valueAnioVenc = parseFloat(document.getElementById('fecVencimiento_year').value);
	   		
	   		// Comprueba que tengamos años validos valido
	   		if ( !isNaN ( valueAnioEfec ) && !isNaN ( valueAnioVenc ) ) { 
	   			
	   			var valueDuracion = valueAnioVenc - valueAnioEfec;
	   			
	   			if (valueDuracion >= 0){
	   				
	   				document.getElementById('Duracion').value = valueDuracion;
	   				
	   			}
	   		}	
	 	}  else if (!valorFecEfecto){
			 
				document.getElementById('fecEfect_month').value = document.getElementById('fecVencimiento_month').value;
			  	document.getElementById('fecEfect_day').value = document.getElementById('fecVencimiento_day').value;
			  	document.getElementById('fecEfect_year').value = document.getElementById('fecVencimiento_year').value;
			}
   	}
   	
/**
* Funcion para calcular la fecha de vencimiento segun la fecha efecto y la duracion.
* @author EVERIS
*/   	
	
	function calcularFecVencimiento() {
 
 	    var valorFecEfecto = isValorFecha('fecEfect'); 
	    var valorFecVencimiento = isValorFecha('fecVencimiento');    
	    var valueAnioEfec = parseFloat(document.getElementById('fecEfect_year').value);
	    var duracion = parseFloat(document.getElementById('Duracion').value);
	    
	    	if ( duracion != "" && valorFecEfecto ) { 
			 	
				document.getElementById('fecVencimiento_year').value = duracion + valueAnioEfec;
				
				if (!valorFecVencimiento) {
				  	document.getElementById('fecVencimiento_month').value = document.getElementById('fecEfect_month').value;
				  	document.getElementById('fecVencimiento_day').value = document.getElementById('fecEfect_day').value;
				  	 
				}
				 
			 }
 
   	}
   
   
   
/**
* Calcula el valor pendiente
* @author EVERIS
*/  
	// MU-2016-006664 - RAROALE - INI
   	function calculoPendiente(tipo) {
   	// MU-2016-006664 - RAROALE - FIN	
	    var condicionCalculo = document.getElementById('valoresManuales2').checked; // R&V CA Fase II CU011-COASEGURO
	    condicionCalculo = true; // R&V Correccion Automatismo 21/09/2017
	    if (condicionCalculo) { // R&V Correccion 03/08/2017-1-3

            var valorPendiente = "0.00";
            var valorCapital = 0;
            var valorPri = 0;
            var valorComp = 0;

            // Pasamos el valor a tipo float
            var importeCap = parseFloat(cambiarPuntoComa(document.getElementById('ImpCapital').value));

            // Comprueba que tenga un valor valido
            if (isNaN(importeCap)) {
                importeCap = 0;

            }

            // Pasamos el valor a tipo float
            var importePri = parseFloat(cambiarPuntoComa(document.getElementById('ImportePri').value));

            // Comprueba que tenga un valor valido
            if (isNaN(importePri)) {
                importePri = 0;

            }

            // Pasamos el valor a tipo float
            var importeComp = parseFloat(cambiarPuntoComa(document.getElementById('ImporteComp').value));

            // Comprueba que tenga un valor valido
            if (isNaN(importeComp)) {
                importeComp = 0;
            }

            //Pasamos el valor a tipo float
            var beneficiosPri = parseFloat(cambiarPuntoComa(document.getElementById('BeneficiosPri').value));

            // Comprueba que tenga un valor valido
            if (isNaN(beneficiosPri)) {
                beneficiosPri = 0;
            }

            // Comprobamos si los campos fecha tienen información
            var valorPagoPri = isValorFecha('fecPagoPri');
            var valorPagoComp = isValorFecha('fecPagoComp');
            var valorPagoCap = isValorFecha('fecPagoCapital');

            // Verificamos si la fecha de pago Capital esta informada
            if (!valorPagoCap) {

                valorCapital = importeCap + beneficiosPri;
            }

            // Verificamos si la fecha de pago Primer Complementario esta informada
            if (!valorPagoPri) {

                valorPri = importePri;
            }

            // Verificamos si la fecha de pago Segundo Complementario esta informada
            if (!valorPagoComp) {

                valorComp = importeComp;
            }

            // Sumamos todos los campos
            valorPendiente = valorCapital + valorPri +valorComp;



            // Damos formato al valor con solo dos decimales
            var strValorPendiente = new String(valorPendiente);

            strValorPendiente = precisionDecimales(strValorPendiente, 2);

            document.getElementById('Pendiente').value = strValorPendiente.replace('.',',');


            sumaTotal();
            //MU-2016-006664 - RAROALE - INI
            if (tipo!='P') { tipo = 'I';} // R&V - Marzo 2018 - Si no se informa tipo a 'P' se fuerza a 'I'
            if (tipo == 'I') {
                calculoCodImportes('I');
            } else {
                calculoCodImportes('P');
            }
            //MU-2016-006664 - RAROALE - FIN
            limpiaCoase();
   	    } // R&V Correccion 03/08/2017-1-3
   	}
   	
/**
* Calcula el valor neto
* @author EVERIS
*/   	
	//MU-2016-006664 - RAROALE - INI
   	function calculoRtoNeto(valor, tipo) {
	//MU-2016-006664 - RAROALE - FIN

	    var condicionCalculo = document.getElementById('valoresManuales2').checked; // R&V CA Fase II CU011-COASEGURO
	    condicionCalculo = true; // R&V Correccion Automatismo 21/09/2017
	    if (condicionCalculo) { // R&V Correccion 03/08/2017-1-3

            var rtoNeto;
            var rtoIntegro = parseFloat(cambiarPuntoComa(document.getElementById('RtoIntegro'+ valor).value));

            if (isNaN(rtoIntegro)) {
                rtoIntegro = 0;
            }

            var redPrimas = parseFloat(cambiarPuntoComa(document.getElementById('RedPrimas'+ valor).value));

            if (isNaN(redPrimas)) {
                redPrimas = 0;
            }

            var redTransit = parseFloat(cambiarPuntoComa(document.getElementById('RedTransit'+ valor).value));

            if (isNaN(redTransit)) {
                redTransit = 0;
            }

            rtoNeto = rtoIntegro - redPrimas - redTransit;
            //de dejamos solo dos decimales
            var strRtoNeto = new String(rtoNeto);

            strRtoNeto = precisionDecimales(strRtoNeto, 2);

            document.getElementById('RtoNeto'+ valor).value = strRtoNeto.replace('.',',');
            //MU-2016-006664 - RAROALE - INI
            if (tipo!='P') { tipo = 'I';} // R&V - Marzo 2018 - Si no se informa tipo a 'P' se fuerza a 'I'
            if (tipo == 'I') {
                calculoRetencion(valor, 'I');
            } else {
                calculoRetencion(valor, 'P');
            }
            //MU-2016-006664 - RAROALE - FIN

            sumaTotal();
            //MU-2016-006664 - RAROALE - INI
            if (tipo!='P') { tipo = 'I';} // R&V - Marzo 2018 - Si no se informa tipo a 'P' se fuerza a 'I'
            if (tipo == 'I') {
                calculoCodImportes('I');
            } else {
                calculoCodImportes('P');
            };
            //MU-2016-006664 - RAROALE - FIN
            limpiaCoase();
   		} // R&V Correccion 03/08/2017-1-3
   	}

   	
 /**
* Calcula el valor retencion
* @author EVERIS
* @param valor
*/  	
	//MU-2016-006664 - RAROALE - INI
  	function calculoRetencion(valor, tipo) {
	//MU-2016-006664 - RAROALE - FIN
	    var condicionCalculo = document.getElementById('valoresManuales2').checked; // R&V CA Fase II CU011-COASEGURO
	    condicionCalculo = true; // R&V Correccion Automatismo 21/09/2017
	    if (condicionCalculo) { // R&V Correccion 03/08/2017-1-3
            if (valor == 'Cap') var tipImpuesto = document.getElementById('tipImpuestoCap').selectedIndex;
            if (valor == 'Comp') var tipImpuesto = document.getElementById('tipImpuestoComp').selectedIndex;
            if (valor == 'Pri') var tipImpuesto = document.getElementById('tipImpuestoPri').selectedIndex;
            var codPostal = document.getElementById('CodPostalPri').value;
            codPostal = codPostal.substring(0,2);
            var retencion;
            if (tipImpuesto == '1') {
                if ( codPostal == '01' || codPostal == '20' || codPostal == '31' || codPostal == '48') {
                    var rtoNeto = parseFloat(cambiarPuntoComa(document.getElementById('RtoNeto'+ valor).value));
                } else {
                    var rtoNeto = parseFloat(cambiarPuntoComa(document.getElementById('RtoIntegro'+ valor).value));
                }
            } else {
                var rtoNeto = parseFloat(cambiarPuntoComa(document.getElementById('RtoNeto'+ valor).value));
            }

            if (isNaN(rtoNeto)) {
                rtoNeto = 0;
            }

            var porcentaje = parseFloat(cambiarPuntoComa(document.getElementById('Porcentaje'+ valor).value));
            if (isNaN(porcentaje)) {
                porcentaje = 0;
            }

            retencion = rtoNeto*porcentaje/100;
            //FER
            if (retencion<0){
                retencion = 0;
            }
            //de dejamos solo dos decimales
            var strRetencion = new String(retencion);

            strRetencion = precisionDecimales(strRetencion, 2);
            document.getElementById('Retencion'+ valor).value = strRetencion.replace('.',',');

            sumaTotal();
            //MU-2016-006664 - RAROALE - INI
            if (tipo!='P') { tipo = 'I';} // R&V - Marzo 2018 - Si no se informa tipo a 'P' se fuerza a 'I'
            if (tipo == 'I') {
                calculoCodImportes('I');
            } else {
                calculoCodImportes('P');
            }
            //MU-2016-006664 - RAROALE - FIN
            limpiaCoase();
  		}// R&V Correccion 03/08/2017-1-3
  	}
   
    	
  /**
* Calcula el valor liquido
* @author EVERIS
*/ 
   	//MU-2016-006664 - RAROALE - INI
   	function calculoLiquido(tipo) {
	//MU-2016-006664 - RAROALE - FIN
	    var condicionCalculo = document.getElementById('valoresManuales2').checked; // R&V CA Fase II CU011-COASEGURO
	    condicionCalculo = true; // R&V Correccion Automatismo 21/09/2017
	    if (condicionCalculo) { // R&V Correccion 03/08/2017-1-3

            var valorLiquidoPri;
            var valorLiquidoCap;
            var valorLiquidoComp;

                var importePri = parseFloat(cambiarPuntoComa(document.getElementById('ImportePri').value));

                if (isNaN(importePri)) {
                    importePri = 0;
                }

                var importeCap = parseFloat(cambiarPuntoComa(document.getElementById('ImpCapital').value));

                if (isNaN(importeCap)) {
                    importeCap = 0;
                }

                var beneficiosPri = parseFloat(cambiarPuntoComa(document.getElementById('BeneficiosPri').value));

                if (isNaN(beneficiosPri)) {
                    beneficiosPri = 0;
                }

                var impAnticipo = parseFloat(cambiarPuntoComa(document.getElementById('ImpAnticipo').value));

                if (isNaN(impAnticipo)) {
                    impAnticipo = 0;
                }

                var impInteresPend = parseFloat(cambiarPuntoComa(document.getElementById('ImpInteresPend').value));

                if (isNaN(impInteresPend)) {
                    impInteresPend = 0;
                }

                var retencionPri = parseFloat(cambiarPuntoComa(document.getElementById('RetencionPri').value));

                if (isNaN(retencionPri)) {
                    retencionPri = 0;
                }

                var retencionCap = parseFloat(cambiarPuntoComa(document.getElementById('RetencionCap').value));

                if (isNaN(retencionCap)) {
                    retencionCap = 0;
                }

                var retencionComp = parseFloat(cambiarPuntoComa(document.getElementById('RetencionComp').value));

                if (isNaN(retencionComp)) {
                    retencionComp = 0;
                }

                var importeComp = parseFloat(cambiarPuntoComa(document.getElementById('ImporteComp').value));

                if (isNaN(importeComp)) {
                    importeComp = 0;
                }

                valorLiquidoPri = importePri - retencionPri;
                valorLiquidoCap = importeCap + beneficiosPri - retencionCap - impAnticipo - impInteresPend;
                valorLiquidoComp = importeComp - retencionComp;

                //de dejamos solo dos decimales
                var strLiquidoPri = new String(valorLiquidoPri);
                var strLiquidoCap = new String(valorLiquidoCap);
                var strLiquidoComp = new String(valorLiquidoComp);

                strLiquidoPri = precisionDecimales(strLiquidoPri, 2);
                strLiquidoCap = precisionDecimales(strLiquidoCap, 2);
                strLiquidoComp = precisionDecimales(strLiquidoComp, 2);

                document.getElementById('LiquidoPri').value = strLiquidoPri.replace('.',',');
                document.getElementById('LiquidoCap').value = strLiquidoCap.replace('.',',');
                document.getElementById('LiquidoComp').value = strLiquidoComp.replace('.',',');

                sumaTotal();
                //MU-2016-006664 - RAROALE - INI
                if (tipo!='P') { tipo = 'I';} // R&V - Marzo 2018 - Si no se informa tipo a 'P' se fuerza a 'I'
                if (tipo == 'I') {
                    calculoCodImportes('I');
                } else {
                    calculoCodImportes('P');
                }
                //MU-2016-006664 - RAROALE - FIN
                limpiaCoase();
   			} // R&V Correccion 03/08/2017-1-3
   		}
   		