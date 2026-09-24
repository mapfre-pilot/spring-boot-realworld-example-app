"""Validaciones de entrada — equivalentes de las reglas ``TVA_*_Validacion``.

Cada función devuelve una lista de avisos (vacía = válido).
"""

from apps.tva.schemas.errors import AvisosClase, aviso

LONGITUD_DOCUMENTO = 9


def validar_parametros_inicio(documento: str, canal: str) -> list:
    """``TVA_WebApi_Inicio_ObtenerMensajeError`` — parámetros del WebApi de inicio."""
    avisos = []
    if not documento or not documento.strip():
        avisos.append(aviso(AvisosClase.GENERAL, "TVA_ERROR_PARAMETROS_ENTRADA", "documentoCliente es obligatorio"))
    if not canal:
        avisos.append(aviso(AvisosClase.GENERAL, "TVA_ERROR_PARAMETROS_ENTRADA", "canal es obligatorio"))
    return avisos


def validar_datos_personales(datos: dict) -> list:
    """``TVA_CapturaTomador_DatosPersonales_Validacion``."""
    avisos = []
    if not datos.get("documento") and not datos.get("documentNumber"):
        avisos.append(aviso(AvisosClase.GENERAL, "TVA_ERROR_VALIDACION", "documento de identidad obligatorio"))
    if datos.get("birthDate") in (None, "") and datos.get("fechaNacimiento") in (None, ""):
        avisos.append(aviso(AvisosClase.GENERAL, "TVA_ERROR_VALIDACION", "fecha de nacimiento obligatoria"))
    return avisos


def validar_domicilio(datos: dict) -> list:
    """``TVA_CapturaTomador_DomicilioHabitual_Validacion`` / ``TVA_Address_Validacion``."""
    avisos = []
    if not (datos.get("addressName") or datos.get("direccion")):
        avisos.append(aviso(AvisosClase.GENERAL, "TVA_ERROR_VALIDACION", "dirección obligatoria"))
    if not (datos.get("postalCode") or datos.get("codigoPostal")):
        avisos.append(aviso(AvisosClase.GENERAL, "TVA_ERROR_VALIDACION", "código postal obligatorio"))
    return avisos


def validar_domiciliacion(datos: dict) -> list:
    """``TVA_Domiciliaciones_Validacion``."""
    avisos = []
    iban = datos.get("iban") or datos.get("IBAN") or ""
    if not iban:
        avisos.append(aviso(AvisosClase.GENERAL, "TVA_ERROR_VALIDACION", "IBAN obligatorio"))
    elif len(iban.replace(" ", "")) < 15:
        avisos.append(aviso(AvisosClase.GENERAL, "TVA_ERROR_VALIDACION", "IBAN con formato inválido"))
    return avisos


def validar_opciones_inversion(datos: dict) -> list:
    """``TVA_OpcionesDeInversion_Validacion`` / ``TVA_VIA_ValidacionInvestmentOption``."""
    avisos = []
    opciones = datos.get("investmentOptions") or datos.get("opcionesInversion") or []
    if not opciones:
        avisos.append(aviso(AvisosClase.GENERAL, "TVA_ERROR_VALIDACION", "al menos una opción de inversión"))
    return avisos


def validar_beneficiarios(datos: dict) -> list:
    """``TVA_Beneficiarios_Validacion``."""
    avisos = []
    beneficiarios = datos.get("beneficiarios") or []
    if beneficiarios:
        total = sum(float(b.get("porcentaje", 0) or 0) for b in beneficiarios)
        if abs(total - 100.0) > 0.01:
            avisos.append(aviso(AvisosClase.GENERAL, "TVA_ERROR_VALIDACION", "los porcentajes de beneficiarios deben sumar 100"))
    return avisos


def validar_datos_operacion(datos: dict) -> list:
    """``TVA_DatosDeLaOperacion_Validacion``."""
    avisos = []
    if not (datos.get("modalidad") or datos.get("productCode")):
        avisos.append(aviso(AvisosClase.GENERAL, "TVA_ERROR_VALIDACION", "modalidad/producto obligatorio"))
    return avisos
