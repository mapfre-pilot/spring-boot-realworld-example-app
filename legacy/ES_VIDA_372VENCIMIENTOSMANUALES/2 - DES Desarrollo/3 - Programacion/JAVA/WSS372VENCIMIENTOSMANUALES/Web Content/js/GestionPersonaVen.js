/* MODIFICACION : MU-2016-006673
FECHA : MARZO 2016
DESCRIPCION: Recuperación del identificador del domicilio
AUTOR : RAROALE */

/* MODIFICACION : MU-2015-064406
FECHA : NOVIEMBRE 2015
DESCRIPCION: Error al recuperar el domicilio de prestaciones
AUTOR : RAROALE */

   // Variable global para identificar el tipo de beneficiario 
		var TIPOBENEFICARIO; 
 /**   
* Abrimos el popup de personas
* @author EVERIS
*/
	function abrirPopupPersonas() {
		var form= document.forms['formGestionExped'];
		var errors = validateForm(form);	
		var url;	
		if(errors.length > 0) {
			return;
		}
		

		var stCodDocumentoPersona = document.getElementById('NIFCIFPri').value;
	
		url="/WSS372VENCIMIENTOSMANUALES/obtenerDatosFiscalidad.do?nifCifPri='" + stCodDocumentoPersona + "'";
		
		var objeto = new Object();
		objeto.ventana = window;
		objeto.nombre = "ventanaEmergente";
		//objeto.tipo = tipo;
				
		abrirVentana(String(url),objeto,"dialogwidth=750px;dialogheight=600px;dialogLeft=80px;dialogTop=30px;help=no;status=no");
		
	}
 /**   
* Calcular domicilio al recibirlo
* @author EVERIS
* param objDomicilio
*/
	function recibirDomicilio(objDomicilio){
	// MU-2015-064406 - RAROALE - INI
	//if (objDomicilio.stTipoDomicilio == 'P' || objDomicilio.stTipoDomicilio == 'R'){
	// MU-2015-064406 - RAROALE - FIN

	// R&V CU001 INI
	if (objDomicilio.stTipoDomicilio != ''){ // R&V Recibimos cualquier tipo de domicilio seleccionado
	// R&V CU001 FIN


		if ( objDomicilio.stNombreVia != null && objDomicilio.stNumVia != null ) {
			document.getElementById('DomicilioPri').value = objDomicilio.stNombreVia + ', ' + objDomicilio.stNumVia;
            // R&V CU004 INI
            document.getElementById('TipoDomicilioPri').value = objDomicilio.stTipoDomicilio;
            // R&V CU004 FIN
		}
	
		// MU-2016-006673 - RAROALE - INI
		if (objDomicilio.stKdomicilio != null && objDomicilio.stCodPostal != null) {
			document.getElementById('kdomicilioPri').value = objDomicilio.stKdomicilio;
		}
		// MU-2016-006673 - RAROALE - FIN
		if (objDomicilio.stCodPostal != null) {
		
			document.getElementById('CodPostalPri').value = objDomicilio.stCodPostal;
		}
		if (objDomicilio.stPoblacion != null){
			document.getElementById('LocalidadPri').value = objDomicilio.stPoblacion;
		}
		// t01162 y t01164 son las tablas de Provincia y Pais para que se muestren por pantalla la descripción del codigo nos creamos una 
		//funcion obtenerDescripcionPorCodigo para sacar la descripción de los codigos de provincia y ciudad, y aqui mostramos por pantalla la descripción
		//es1 son es:idioma y 1:valor
		
		if (objDomicilio.stProvincia != null){
		
		    if ( t01162esl != null && objDomicilio.stProvincia != null ) {
		
				var tLen = t01162esl.length;
				
				for (var i = 0;i < tLen;i++){
				
					if ( objDomicilio.stProvincia != null && ( objDomicilio.stProvincia == ( t01162esl[i].value ) ) ) {
					
						 document.getElementById('ProvinciaPri').value = t01162esl[i].text;
					
					}
				} 		
			}
		}


		if (objDomicilio.stPais != null){
		
			if ( t01164esl != null && objDomicilio.stPais != null ) { 
		
				var tLen = t01164esl.length;
				
				for (var i = 0;i < tLen;i++){
				
					if(objDomicilio.stPais != null && (objDomicilio.stPais == (t01164esl[i].value))){
					
						 document.getElementById('PaisPri').value = t01164esl[i].text;
					
					}
				} 
			} 			
		}

        // R&V - Julio 2017 - Validación Código Postal Extranjero - everis(RGL) - INI
        if (objDomicilio.stCodPostalExt != null && objDomicilio.stCodPostalExt != '' ) {  // R&V IN008 añado --> && objDomicilio.stCodPostalExt != ''
            document.getElementById('CodPostalPri').value = objDomicilio.stCodPostalExt;
            document.getElementById('ProvinciaPri').value = "99";
        }
        // R&V - Julio 2017 - Validación Código Postal Extranjero - everis(RGL) - FIN

	}
		
		modificacionComplementario1();
		modificacionComplementario2();	
	}
/**   
* Calculo del  beneficiario.
* @author EVERIS
* param objPersona
*/	
	function recibirPersona(objPersona){

    // R&V - Validacion NIF - INI
	if (objPersona.stRelacion=='RP' && objPersona.stNifRela!=''){
	    document.getElementById('NifRepLegalPri').value = objPersona.stNifRela;
	}
    // R&V - Validacion NIF - FIN

	var capaRSocial = document.getElementById("capaRazonSocialPri");
	var capaNombre = document.getElementById("capaCamposNombrePri");
	
	if ( objPersona.stTipoPer == 'F' ) { 
	
		document.getElementById('TipPersona1Pri').checked = 'checked';
		
		document.getElementById('tipPersonaPri').value = objPersona.stTipoPer;
	
		/**capaRSocial.style.visibility = 'hidden';	
		capaNombre.style.visibility = 'visible';**/
		
		
	
	}else {
	
		if (objPersona.stTipoPer == 'J') {
			document.getElementById('TipPersona2Pri' ).checked = 'checked';
			document.getElementById('tipPersonaPri' ).value = objPersona.stTipoPer;

			capaRSocial.style.visibility = 'visible';	
		    capaNombre.style.visibility = 'hidden';
		
		}
	}
	

	if (objPersona.stNif != '') { 		
		document.getElementById('NIFCIFPri').value = objPersona.stNif;
	}
	

	document.getElementById('kpersonaPri').value = objPersona.stKpersona;
	
	if ( objPersona.stTipoDoc == '5' ) { 
		document.getElementById('RazonSocialPri').value = objPersona.stRazonSocial;
	}else{
		
		document.getElementById('NombrePri').value = objPersona.stNombre;
		document.getElementById('Apellido1Pri').value = objPersona.stApell1;
		document.getElementById('Apellido2Pri').value = objPersona.stApell2;
		
		document.getElementById('kpersonaPri').value = objPersona.stKpersona;
		
		pasarFecha('fecNacPri',objPersona.stFecNac);		  
	}
	
	
	
	
	modificacionComplementario1();
	modificacionComplementario2();
	
	return;
	}

/**   
* Pasamos la informacion de los datos fiscales de la persona informada
* @author EVERIS
* param datosFiscales
*/	
 	function pasarDatosFiscales(datosFiscales) {
     	
     					
		/*if (TIPOBENEFICARIO == 'Pri') { */
			
			document.getElementById('NifConyugePri').value = datosFiscales.stCodNifConyuge;
			document.getElementById('AnulAlimenHijosPri').value = datosFiscales.stImpAnualAlim;
			document.getElementById('PenCompPri').value = datosFiscales.stImpPensionCom;
			
		
			
			if (datosFiscales.stCodGradoDisc != null) {
		
				if(t07503esl != null && datosFiscales.stCodGradoDisc != null){
			
					var tLen = t07503esl.length;
					
					for (var i = 0;i < tLen;i++) {
					
						if(datosFiscales.stCodGradoDisc != null && (datosFiscales.stCodGradoDisc == (t07503esl[i].value))){
						
							 document.getElementById('DiscapacitadoPri').value = t07503esl[i].text;
						
						}
					} 
				} 			
			}
			
			if (datosFiscales.stCodSituacionFamiliar != null) {
		
				if(t07505esl != null && datosFiscales.stCodSituacionFamiliar != null){
			
					var tLen = t07505esl.length;
					
					for (var i = 0;i < tLen;i++) {
					
						if(datosFiscales.stCodSituacionFamiliar != null && (datosFiscales.stCodSituacionFamiliar == (t07505esl[i].value))){
						
							 document.getElementById('SitFamiliarPri').value = t07505esl[i].text;
						
						}
					} 
				} 			
			}	
			
			if (datosFiscales.stPrestViv != null) {
		
				if(t01051esl != null && datosFiscales.stPrestViv != null){
			
					var tLen = t01051esl.length;
					
					for (var i = 0;i < tLen;i++) {
					
						if ( datosFiscales.stPrestViv != null && ( datosFiscales.stPrestViv == ( t01051esl[i].value ) ) ) {
						
							 document.getElementById('PrestViviendoPri').value = t01051esl[i].text;
						
						}
					} 
				} 			
			}	
			
  		/*}*/
   }
   
    