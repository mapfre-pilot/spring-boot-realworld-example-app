/*ALTA : MU-2016-006664
FECHA : MARZO 2016
DESCRIPCION: Se permite modificar y guardar en BBDD los importes de Coaseguros
AUTOR : RAROALE*/

var catCodNumerico = new Array("0","1","2","3","4","5","6","7","8","9");
var catImporte = new Array("0","1","2","3","4","5","6","7","8","9",",","-");


var stDf = "document.forms[0]";
var estado=false;
var  codTec;  
var cnt = 1;

// funcion encargada de navegar correctamente cundo tenemos una tabla con paginas
// dir: el punto do de destino
function goToPageTabl(dir, filt) {	
	df = document.forms[0];
 
	var strPuntero = document.location.toString();		
	if(strPuntero.lastIndexOf("/jsp/")>=0){//Cuando paginamos con los custom-tags, arquitectura deja el puntero en la página que nos sirve. En ese caso hay que resituar bien el puntero
		pagListadoOperacio = "/WSS750MOVILIZACIONES/" + dir;
	}else{
		pagListadoOperacio = dir;
	}
 	// Para el tema de refrescos de caché del navegador
 	tStamp = Math.ceil( Math.random() * 10000 ).toString();
 	
 	 if(filt==null || trim(filt)==""){
		df.action= pagListadoOperacio+".do?timeStamp=" + tStamp;
		df.submit();	
 	}else{
		df.action= pagListadoOperacio+".do?"+filt+"&timeStamp=" + tStamp;
		submiteForm(df);
	}
}

function replaceChars(txtEn, cAnt, cNue) {
 temp = "" + txtEn;
 while (temp.indexOf(cAnt)>-1) {
  pos		= temp.indexOf(cAnt);
  temp	= "" + (temp.substring(0, pos) + cNue + 
  temp.substring((pos + cAnt.length), temp.length));
 }
 return temp;
}
function comprobarNifCif(campo,blnSDni)
{
 resul = "ERR";
 campo.value =(campo.value.toUpperCase());
 campo.value= trim(campo.value);
//CESION-DERECHOS
 campo.value= quitarCerosIzq(trim(campo.value));
//CESION-DERECHOS-END
	if(campo.value.charAt(0)=="K")
	{
		var b = getTipoDocumento(campo);
		
		if(b=="documento_nif_menor")
		{
			nifmenor=campo.value.substring(1,campo.value.length);
			
			if (esUnDNI(nifmenor)){
 				resul="DNI";
			}
		}
	}
	else
	{
		if (vNIE(campo)){
			resul="NIE";
		}		
		if (esUnDNI(campo.value)){
 		  completarCerosIzq(campo.value,'10',campo);
		  resul="DNI";
		}else{
		  if (!blnSDni)
  		  {
  			if (esCIF(campo))//if(esUnCIF(campo))
			{
				 completarBlancosDcha(this.value,'10',campo);
				 resul="CIF";
			}else{
			}
  	   	  } 
	    }
	}
 return resul;
}

function esUnDNI(dni) //Valida para numeros de Documentos con 9 digitos
{
 l_txtRef = 'TRWAGMYFPDXBNJZSQVHLCKE';
 l_resDNI = /^(\d{1,8})([A-Z])$/i.test(dni);
 if(l_resDNI) 
 {
  l_CCI = RegExp.$2.toUpperCase();
  l_CCC = l_txtRef.charAt((/(\d*)$/.exec(RegExp.$1)[0])%23);
  l_resDNI = (l_CCI == l_CCC);
 }
 return l_resDNI;
}
	
function esUnCIF(campo){ 	//Comprueba si el valor introducido es un CIF valido de 9 digitos
	/*USAMOS LA FUNCIÓN DE ARQUITECTURA */
 	var valido = false;
 	if (campo != undefined){
		var valorCompleto = campo.value;
	 		
	 	if (campo.value.length > 9){
	 		campo.value = campo.value.substr(1,10);
	 	}
	 	try{
	 		valido = vCIF(campo);	 	
	 	}catch(e){
	 	}
	 	campo.value = valorCompleto;  	
 	}

 	return valido;
}

//Valida si un número de documento es válido (comprueba si es CIF o NIF valido)
function esDocumentoValido(campo){ 
 if(campo!=null)
  valor = campo.value;
  if (fEsCIF(campo)){//Para cif de 10.
	return true;
  }else{ 
   if(valor.charAt(0)=="X"||valor.charAt(0)=="Y"||valor.charAt(0)=="Z"||valor.charAt(0)=="M"||valor.charAt(0)=="K"||valor.charAt(0)=="L"){
	valor = trim(valor);
	campo.value = trim(campo.value);
   }
   if(vNIE(campo)){ //Para NIE
	 return true;
	}
	//documento_nif_menor
	if(valor.charAt(0)=="K") {
		b = getTipoDocumento(campo);
			
		if(b=="documento_nif_menor"){
			nifmenor=valor.substring(1,valor.length);
			if (esUnDNI(nifmenor)){
 				return true;
			}
		}
	} else {
		//documento_nie ó documento_nif_residente
		if(valor.charAt(0)=="X" || valor.charAt(0)=="L") {
			b = getTipoDocumento(campo);
			if(b!="")
				return true;
		}
	}
	/*Fin AGP*/
	
   if(esDNI(valor)){ //Para dni de 10.
	 return true;
	}
  }
 return false;
}

//Valida para numeros de Documentos con 10 digitos
function esDNI(dniValor){ 
 
 if(dniValor.substring(0,1).toUpperCase()=="X" || dniValor.substring(0,1).toUpperCase()=="Y"  || dniValor.substring(0,1).toUpperCase()=="Z"|| dniValor.substring(0,1).toUpperCase()=="M"){
  dniValor = dniValor.substring(1,dniValor.length);
 }
 dni = dniValor;
 l_txtRef = 'TRWAGMYFPDXBNJZSQVHLCKE';
 l_resul = /^([X]\d{7}|[X]\d{8}|\d{1,9})([A-Z])$/i.test(dni);
 if(l_resul)
 {
 l_CCI = RegExp.$2.toUpperCase();
 l_CCC = l_txtRef.charAt((/(\d*)$/.exec(RegExp.$1)[0])%23);
 l_resul = (l_CCI == l_CCC);
 }
 return l_resul;
}

//Comprueba si el valor introducido es un CIF valido de 10 digitos(el último un blanco)
function fEsCIF(campo){ 
 //LLAMAMOS A LA FUNCIÓN DE ARQUITECTURA
 var valorCompleto = campo.value;
 var valido = false;
 if (campo.value.length > 9){
 	campo.value = campo.value.substr(1,10);
 }
 try{
 	valido = vCIF(campo);
 }catch(e){}
 
 campo.value = valorCompleto; 
 
 return valido;
}
//FIN VALIDACIONES DE LOS DNI's y CIF's 
function rellenaCeros(cad,lgth) {
 str = '' + cad;
 while (str.length < lgth)
   str = '0' + str;
 return str;
}

function completarCerosIzq(valor,long,campo) {
 if(valor!=null && trim(valor)!=""){
  vForm = rellenaCeros(trim(valor),long);
  if(campo!=null)
	campo.value = vForm;
  }
}

function quitarCerosIzq(cad) {
 i = 0;
 while (cad.charAt(i) == '0') {
  i++;
 }
 return cad.substring(i);
}

function completarBlancosDcha(valor,long,campo){
 blanco =" ";
 if(valor!=null){
  stri = valor.length;
  if (trim(valor) != ""){
   if (valor.length != long){
    for (stri ; stri < long; stri++){
	 valor =  valor + blanco;}
	}
  }
  else{
   valor = "";
  }
  campo.value = valor;
 }
}

function ponerMayusculas(campo){
 if(campo!=null){
  return trim(campo.value.toUpperCase());
 }
 return "";
}

function trim(cad) { 
 if(cad) {
  cad = (cad.replace(/^\s+/,'')).replace(/\s+$/,'');
 }
 return(cad);
}

function goToPage(pag,filt){
 df = document.forms[0];
 // Para el tema de refrescos de caché del navegador
 tStamp = Math.ceil( Math.random() * 10000 ).toString();
 if(filt==null || trim(filt)==""){
		df.action= pag+".do?timeStamp=" + tStamp;
		df.submit();	
 }else{
		df.action= pag+".do?"+filt+"&timeStamp=" + tStamp;
		submiteForm(df);
	}
}

// Similar a la anterior pero especificando por parámetro
// la página donde se quiere realizar la carga del action
// (útil cuando se ejecuta desde un iFrame y se quiere cargar
// la página destino en el padre, es decir, fuera del iFrame)
function goToPageFromIframe (pag,filt,objetivo){
 	// Para el tema de refrescos de caché del navegador
 	df = document.forms[0];
 	tStamp = Math.ceil( Math.random() * 10000 ).toString();
	if(filt==null || trim(filt)==""){
		df.action= pag+".do?timeStamp=" + tStamp;
		df.target=objetivo;
		df.submit();	
	}else{
		df.action= pag+".do?"+filt+"&timeStamp=" + tStamp;
		df.action = URLEncode(df.action);
		df.target=objetivo;
		df.submit();
	}
}

function submiteForm(oForm){

	oForm.action = URLEncode(oForm.action);
	oForm.submit();
}

function maximaLongitud(texto,mlong) { 
 tecla, in_val, out_val; 

 if (texto.value.length > mlong) { 
    in_val = texto.value; 
    out_val = in_value.substring(0,mlong); 
    texto.value = out_val; 
    return false; 
  } 
  return true; 
} 

function getCampoValue(form,nCampo){
 
 dfe=document.forms[form].elements;
 if(nCampo!=null && form!=null){
  if(form !=null && form=="")
   form=0;
   stEnc = false;
   campo = dfe[nCampo];
   stEle = campo.tagName;
	
   if(stEle!=null && stEle.toUpperCase()=="SELECT")
   {
	//tamanoCombo = campo.options.length;
    vCampo = campo[campo.selectedIndex].value;
   }else{
	vCampo = dfe[nCampo].value;
   }
   if(vCampo !=null){
	return vCampo;
	}	
  }
  return "";
}

function URLEncode(ptext){

 url = '';
 if (ptext != null) {
  ptextOld = null;
  posini = -1;
  posfin = -1;
  encoded = '';
  arg = null;
  valarg = null;
  pos = ptext.indexOf('?');
  if (pos == -1) {
	// No hay parametros
	return ptext; 
  }
  narg = 0;
  encoded = '';
  ptextOld = ptext.substring(0, pos+1);
  ptext = ptext.substring(pos+1, ptext.length);
  while ( (posini = ptext.indexOf('=')) >= 0 ) {// Codificamos los argumentos
   posfin = ptext.indexOf('&');
   if (posfin == -1) {
	posfin = ptext.length;
   }
   arg 	= ptext.substring(0, posini+1);// Nombre y Valor del argumento
   valarg 	= ptext.substring(posini+1, posfin);
   if (narg >0) {
	arg = '&' + arg;
   }
   encoded = URLEncodeString(valarg);// Codificacmos el valor del argumento
   if (posfin == -1) {// No hay mas argumentos
    ptext = '';
   }else{
	ptext = ptext.substring(posfin+1, ptext.length);
   }
   url += (arg + encoded);
   narg += 1;
  }
  url = ptextOld + url;
 }
 return url;
}

function URLEncodeString(valarg){
 if (valarg == null)
  return valarg;
  SAFEC = "0123456789" + // Numeric
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ" +	// Alphabetic
	"abcdefghijklmnopqrstuvwxyz" +
	"-_.!~*'()"; // RFC2396 Mark characters
   HEX = "0123456789ABCDEF";
   encoded = '';
  for (i = 0; i < valarg.length; i++ ) {
	ch = valarg.charAt(i);
	if (ch == " ") {
	 encoded += "+"; // x-www-urlencoded, rather than %20
	} else if (SAFEC.indexOf(ch) != -1) {
	  encoded += ch;
	} else {
	  charCode = ch.charCodeAt(0);
	  if (charCode > 255) {
	  encoded += "+";
	} else {
	  encoded += "%";
	  encoded += HEX.charAt((charCode >> 4) & 0xF);
	  encoded += HEX.charAt(charCode & 0xF);
	}
   }
  } 
  return encoded;
}

function URLDecodeString(encoded )
{
  ptext = '';
 if (encoded != null) {
   encOld = null;
   pos = encoded.indexOf('?');
  encOld = encoded.substring(0, pos+1);
  encoded = encoded.substring(pos+1, encoded.length);
   HEXC = "0123456789ABCDEFabcdef"; 
   i = 0;
  while (i < encoded.length) {
    ch = encoded.charAt(i);
   if (ch == "+") {
    ptext += " ";
    i++;
   } else if (ch == "%") {
   if (i < (encoded.length-2)&& HEXC.indexOf(encoded.charAt(i+1)) != -1 && HEXC.indexOf(encoded.charAt(i+2)) != -1 ) {
    ptext += unescape( encoded.substr(i,3) );
    i += 3;
   } else {
    ptext += "%[ERROR]";
    i++;
   }
  } else {
  ptext += ch;
  i++;
  }
 } // while
 ptext = encOld + ptext;
 }
 return ptext;
}

function encode(car)
{
 res = "&#";
 decimalCode = car.charCodeAt(0);
 res = res + decimalCode + ";";
 return res;
}

function encodeString(str)
{
 result = "";
 stri = 0;
 car = "";
 for (stri = 0; stri < str.length; stri++){
  car = str.charAt(stri);
  if (car == "="){
   car= encode(car);
  }else if (car == "<"){
   car= encode(car);
  }else if (car == ">"){
   car = encode(car);
  }else if (car == "|"){
   car = "/";
  }else if (car == " "){
	car = " ";
  }else if (car == "\r"){
   car = "";
  }else if (car == "\n"){
   car = "\n";
  }else if (car == "\""){
   car = "\'";
  }else if (car == "\'"){
   car = "\'";
  }else if(car == "€"){
   car = "&#80;";
  }	else if (car.charCodeAt(0) < 40 || car.charCodeAt(0) > 126){
	car = encode(car);
  }
  result = result + car;
 }
 return result;
}

//Formatea aaaammdd como dd/mm/aaaa
function formatearFecha(fecha){
 if(fecha!=null && fecha!=""){
  fechaAnyo = fecha.substring(0,4);
  fechaMes = fecha.substring(4,6);
  fechaDia = fecha.substring(6,8);
  fechaF = fechaDia.concat("/").concat(fechaMes).concat("/").concat(fechaAnyo);
  }else{
	return fecha;
  }
  return fechaF;
}

//Formatea dd/mm/aaaa como aaaammdd
function desformatearFecha(fecha){
 if(fecha!=null && fecha!=""){
  var arrayFecha = fecha.split("/");
  fechaDia = arrayFecha[0];
  fechaMes = arrayFecha[1];
  fechaAnyo = arrayFecha[2];
  fechaF = fechaAnyo.concat(fechaMes).concat(fechaDia);
  }else{
	return fecha;
  }
  return fechaF;
}

function getFechaActual(){
 diaAct= rellenaCeros(new Date().getDate(),'2');
 mesAct= rellenaCeros(new Date().getMonth() + 1,'2');
 anyoAct= rellenaCeros(new Date().getYear(),'4');	
 return anyoAct+mesAct+diaAct;
}

function moverFoco(elem, nomSig){
 if(elem!=null && nomSig!=null){
  nom = elem.name;
  valor = elem.value;
  if(valor.length==2){
	document.forms[0].elements[nomSig].focus();
  }	
 }
}

// Imagenes
function high(x){
 obj=x;
 highlighting=setInterval("highlightit(obj)",50);
}

function low(x){
 clearInterval(highlighting)
 if (x.style.MozOpacity)
  x.style.MozOpacity=0.5
 else if (x.filters)
  x.filters.alpha.opacity=50
}

function highlightit(cur2){
	if (cur2.style.MozOpacity<1)
		cur2.style.MozOpacity=parseFloat(cur2.style.MozOpacity)+0.1
	else if (cur2.filters&&cur2.filters.alpha.opacity<100)
		cur2.filters.alpha.opacity+=10
	else if (window.highlighting)
		clearInterval(highlighting)
		
	cur2.style.cursor="hand";	
}

function startWith(cadena,ini){ 
 start = true;
 i=0;
 while (start && i<ini.length)
 {
  if (ini.charAt(i) != cadena.charAt(i))
   start = false;
   else i++;
 }
  return start;
}

function truncar(texto,long){
 if(texto!=null && texto.length>long){
  tTru = texto.substring(0,long);
 }else if(texto!=null){
  tTru=texto;
 }
 return tTru;
}


function popup ( pagina )
{
 cnt++;
 wnd = open( pagina, "gl" + cnt, "directories=no,menubar=no,location=no,scrollbars=yes,status=no,toolbar=yes,fullscreen=no,resizable=yes, width=750, height=450, top=25, left=25");
}

function recorta(cad)
{
 max = 50; //Máximo permitido a visualizar en el resumen
 sal = cad;
 if (cad != null && cad != "")
  if (cad.length > max)
	sal = cad.substring (0, 50) + "...";
    return sal;
}

function pulsada(e,permitidos,campo,msj){
 estado = false;
 var x;
 if(document.all){    
  codTec = event.keyCode
  cadTecla = (String.fromCharCode(event.keyCode));
 }else if(document.layers){
   codTecla = e.which
   cadTecla = String.fromCharCode(e.which);
 }else if(document.getElementById){
   codTecla = (window.Event) ? e.which : e.keyCode;
   cadTecla=(String.fromCharCode(codTecla));
 }
 for(x in permitidos){
   if(cadTecla==permitidos[x]){
     estado=true;
    }
 }  
 if(!estado && msj!=null && msj!=""){
  ctError(msj,msjcerrar);
 }
 if(estado==false){
  if(document.all){
    event.returnValue = false;
  }else{
    return false;
  }
 }
}

/*Comprueba si la tecla pulsada es un caracter numérico, y si es así, no lo permite escribirlo*/
function comprobarTexto(e,noPermitidos,campo)
{
 estado = true;
 var x;
 if(document.all){    
  codTec = event.keyCode
  cadTecla = (String.fromCharCode(event.keyCode));
 }else if(document.layers){
   codTecla = e.which
   cadTecla = String.fromCharCode(e.which);
 }else if(document.getElementById){
   codTecla = (window.Event) ? e.which : e.keyCode;
   cadTecla=(String.fromCharCode(codTecla));
 }
 for(x in noPermitidos){
   if(cadTecla==noPermitidos[x]){
     estado=false;
    }
 }  
 
 if(estado==false){
  if(document.all){
    event.returnValue = false;
  }else{
    return false;
  }
 }
}


function teclasNoPermitidos() {
 patron = /^[\\|\n|·|~|¬|`|´|¨|\'|\"|\r]$/;
 car = String.fromCharCode(event.keyCode);
 if (patron.test(car)) {
	event.returnValue = false;
	return false;
 }
 else {
	return true;
 }
}
function validaPermitidos(e,tipo,texto){
	var blnOk = false;
	var expNum;
	var cad;
	if(document.all){    
		cad = String.fromCharCode(event.keyCode);
 	}else if(document.layers){
		cad = String.fromCharCode(e.which);
	}else if(document.getElementById){
		cad = String.fromCharCode(window.Event?e.which:e.keyCode);
	}
	switch (tipo) {
		case "NUMERICO":
			expNum = /^[0-9]*$/;
			blnOk = expNum.test(cad);
			break;
		case "DECIMAL":
			expNum = /^[0-9,\,\.]*$/;
			blnOk = expNum.test(cad);
			if (blnOk){
				if (cad == "."){
					cad = ",";
				}
				if (cad == ","&& texto.indexOf(cad) > -1 ){
					blnOk = false;
				}
			}
			break;
		case "DECIMAL_NEGATIVO":
			expNum = /^[0-9,\,\.,-]*$/;
			blnOk = expNum.test(cad);
			if (blnOk){
				if (cad == "."){
					cad = ",";
				}
				if ((cad == "," || cad == "-" )&& texto.indexOf(cad) > -1 ){
					blnOk = false;
				}
			}
			break; 	}
	return blnOk;
}


function verificarPunto(elemento){
	if (elemento.value.indexOf(".") > -1){
		elemento.value = elemento.value.replace('.',',');
	}
}


/**
 *	Al seleccionar una fila de un listado se activa el boton en el padre y se guarda en el campo del formulario
 *  Al deseleccionar una fila de un listado se desactiva el boton en el padre
 *
 */

function openWindowModal(paginaDo,referencia,widthV,heightV){

	if(widthV==null)	
		widthV = "630";
	
	if(heightV==null)	 
		heightV="300";	 

	var props = "dialogHeight:"+heightV+"px;dialogWidth:"+widthV+"px;help:no;center:yes;resizable:no;status:no;scroll:no";	
	retorno = showModalDialog(URLEncode(paginaDo),referencia,props);

	return retorno;
}


function nuevoPopup(url, name, width, height)
{
	// posicion centrada en la pantalla
	var pos_x = (screen.width/2)-(width/2);
	var pos_y = (screen.height/2)-(height/2);

	// resto de parametros (se pueden parametrizar todos en esta funcion)
	var options = "fullscreen=no" +
				  ",toolbar=no" +
				  ",location=no" +
				  ",status=no" +
				  ",menubar=no" +
				  ",scrollbars=no" +
				  ",resizable=no";
	window.open(url, name, options);
}

function getURLparam(name){
	var url = window.location.href;
	var query_string = url.split("?");
	
	var params = query_string[1].split("&");
	
	var i = 0;
	while (i < params.length){
		var param_item = params[i].split("=");
		if (param_item[0] == name){
			return param_item[1];
		}
		i++;
	}
	
	return "";
}

function pierdeFocoNumerico(input){
	if(isNaN(input.value) || input.value.indexOf(".") >-1 || input.value.indexOf("-") >-1 ){
		input.value = "";
	}
}

function pierdeFocoDecimal(input){
	var valor = input.value;
	var valorPreparado = replaceChars(replaceChars(input.value,".",""),",",".");
	if(isNaN(valorPreparado)){
		input.value = "";
	}else{
		input.value = formato_numero(valorPreparado,2,",",".");
	}
}

function formato_numero(numero, decimales, separador_decimal, separador_miles){ 
    numero=parseFloat(numero);
    if(isNaN(numero)){
        return "";
    }

    if(decimales!==undefined){
        // Redondeamos
        numero=numero.toFixed(decimales);
    }

    // Convertimos el punto en separador_decimal
    numero=numero.toString().replace(".", separador_decimal!==undefined ? separador_decimal : ",");

    if(separador_miles){
        // Añadimos los separadores de miles
        var miles=new RegExp("(-?[0-9]+)([0-9]{3})");
        while(miles.test(numero)) {
            numero=numero.replace(miles, "$1" + separador_miles + "$2");
        }
    }

    return numero;
}

function validarImporteProv(elemento){
	var valor = formato_numero(elemento.value,2,".","");
	if (valor){
		var importe = parseFloat(valor);
		if(importe < 10000000000 && importe > 0){		
			pierdeFocoDecimal(elemento);
			return true;
		}else{
			elemento.value="";
			ctError('Dato introducido fuera de rango.', '');
			elemento.focus();
			return false;
		}
	}
	return false;
}

function validarImporte10(elemento){
	var valor = formato_numero(elemento.value,2,".", false);
	if (valor){
		var importe = parseFloat(valor);
		if(importe < 10000000000 && importe >= 0){		
			pierdeFocoDecimal(elemento);
			return true;
		}else{
			elemento.value="";
			ctError('Dato introducido fuera de rango.', '');
			elemento.focus();
			return false;
		}
	}
	return false;
}

function validarImporte9(elemento){
	var valor = formato_numero(elemento.value,2,".","");
	if (valor){
		var importe = parseFloat(valor);
		if(importe < 1000000000 && importe >= 0){		
			pierdeFocoDecimal(elemento);
			return true;
		}else{
			elemento.value="";
			ctError('Dato introducido fuera de rango.', '');
			elemento.focus();
			return false;
		}
	}
	return false;
}

function validarImporte10Dec2(elemento){
	var valor = formato_numero(elemento.value,2,".",""); 
	if (valor){ 
		var importe = replaceChars(elemento.value,".","")
		var importe = parseFloat(valor); 
		if(importe < 10000000000 && importe >= 0){		
			pierdeFocoDecimal(elemento); 
			return true; 
		}else{ 
			elemento.value=""; 
			ctError('Dato introducido fuera de rango.', ''); 
			elemento.focus(); 
			return false; 
		} 
	} 
	return false; 
} 

// Valida el formato del lunero
// elemento: elemento que contiene el numero
// dec: nuero de fecimales que tiene
// impSupe: improte superiro
function validarImporte2Dec(elemento, dec, impSupe, impInf){
	var valor = formato_numero(elemento.value,2,".",""); 
	if (valor){ 
		var importe = replaceChars(elemento.value,".","")
		importe = parseFloat(importe);
		if(importe < impSupe && importe > impInf){		
			if (pierdeFocoDecimalLog(elemento,dec)) {
				return true;
			} else {
				ctError('Dato introducido incorrecto.', ''); 
				elemento.focus();  
				return false;
			}
		}else{ 
			ctError('Dato introducido fuera de rango.', ''); 
			elemento.focus();  
			return false; 
		} 
	} else {
		elemento.value = "0,00";
	}
	return false; 
} 

function validarImporteDecRanInc(elemento, dec, impSupe, impInf){
	var valor = formato_numero(elemento.value,2,".",""); 
	if (valor){ 
		var importe = replaceChars(elemento.value,".","");
		importe = replaceChars(importe,",",".");
		importe = parseFloat(importe);
		if(importe <= impSupe && importe >= impInf){		
			if (pierdeFocoDecimalLog(elemento,dec)) {
				return true;
			} else {
				ctError('Dato introducido incorrecto.', ''); 
				elemento.focus();  
				return false;
			}
		}else{ 
			ctError('Dato introducido fuera de rango.', ''); 
			elemento.focus();  
			return false; 
		} 
	} else {
		elemento.value = "0,00";
	}
	return false; 
} 


function pierdeFocoDecimalLog(input, dec){
	var valor = input.value;
	var valorPreparado = replaceChars(replaceChars(input.value,".",""),",",".");
	if(isNaN(valorPreparado)){
		return false; 
	}else{
		input.value = formato_numero(valorPreparado,dec,",");
		if (dec > 3 ) {
			var elem = input.value.split(',');
			var entera = elem[0];
			var decimal = elem[1];
			decimal = replaceChars(decimal,".","");
			input.value = entera + ',' + decimal;
		} 
		return true;
	} 
} 

function validarImporte3(elemento){
	var valor = formato_numero(elemento.value,2,".","");
	if (valor){
		var importe = parseFloat(valor);
		if(importe < 1000 && importe >= 0){		
			pierdeFocoDecimal(elemento);
			return true;
		}else{
			elemento.value="";
			ctError('Dato introducido fuera de rango.', '');
			elemento.focus();
			return false;
		}
	}
	return false;
}


//Devuelve un parametro de la url actual
function getParam(sname)
{
  var params = location.search.substr(location.search.indexOf("?")+1);
  var sval = "";
  params = params.split("&");
    for (var i=0; i<params.length; i++)
       {
         temp = params[i].split("=");
         if ( [temp[0]] == sname ) { sval = temp[1]; }
       }
  return sval;
}

function getFechaActual(){
 diaAct= rellenaCeros(new Date().getDate(),'2');
 mesAct= rellenaCeros(new Date().getMonth() + 1,'2');
 anyoAct= rellenaCeros(new Date().getYear(),'4');	
 return anyoAct+mesAct+diaAct;
}