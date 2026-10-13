/**
* Calcula la letra de nif
* @author EVERIS
* @param stDNI
*/ 
	function calcularLetraNIF(stDNI) {
		if (isNaN(stDNI) == false) {
			var cadena = "TRWAGMYFPDXBNJZSQVHLCKET";
			var posicion = stDNI % 23;
			var letra = cadena.substring(posicion,posicion+1);
			return letra;
		} else {
			return '';
		}
	}

/**
* Comprueba si un campo fecha tiene información devolviendo un true o un false
* @author EVERIS
* @param nameFecha
*/
 
    function isValorFecha(nameFecha) {
    
    	var valueReturn = false;
   		
   		var day = document.getElementById(nameFecha+'_day').value;
		var month =	document.getElementById(nameFecha+'_month').value;
		var year = document.getElementById(nameFecha+'_year').value;
		
		// Si todos los campos tienen los valores iniciales o en blanco consideramos que estan vacios.
		if ( ( day == 'dd' || day == '' ) && ( month == 'mm' || month == '' ) && ( year == 'yyyy' || year == '' ) ) { 
			valueReturn = false;
		} else {
			valueReturn = true;
		}
			
		return valueReturn;
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
				
				document.getElementById(nameFecha).value = '';
   }
/**
* Funcion para poner un cero a la izquierda en la fecha (dia y mes)si viene solo con un dígito 
* @author EVERIS
* @param obj
*/    
	 function PonerCerosFecha(obj){

	 var valor = new String(obj);

		 if (valor.length < 2){
		   obj = '0'+obj;
		 }
		 return obj;
	 } 
/**
* Funcion para cambiar puntos por comas 
* @author EVERIS
* @param valor
*/
	function cambiarPuntoComa(valor) {
	   	var valorCambiado = valor.replace(',','.');
   		return valorCambiado;
   	} 
   	
/**
* Funcion para mapear la fecha sinos viene con formato yyymmdd no pase a cobol nada
* @author EVERIS
* @param nameFecha
*/   	
   
      function crearFecha(nameFecha) {
   		
   		var valueFecha;
		
		valueFecha = document.getElementById(nameFecha+'_year').value + document.getElementById(nameFecha+'_month').value + document.getElementById(nameFecha+'_day').value;
		
		if ( valueFecha == 'yyyymmdd' ) { 
			valueFecha = '';
		}
		
		return valueFecha;
   }