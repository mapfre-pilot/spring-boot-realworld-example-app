"""Validaciones de entrada — equivalentes de las reglas ``TVA_*_Validacion``.

Cada función devuelve una lista de avisos (vacía = válido).
"""

import re

from apps.tva.models import Parametro
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


# --- Contrato real de la Web API de inicio (§12.4.1) -----------------------

MODOS_FUNCIONAMIENTO = ("VA", "VIA", "R2C")
OPERATION_TYPES = ("S", "AE")  # Suscripción / Aportación extraordinaria
CONTRIBUTION_FREQUENCIES = ("M", "T", "S", "A")


def _param_json_list(clave: str, default: list) -> list:
    try:
        valor = Parametro.get(clave, default)
    except Exception:
        return list(default)
    if isinstance(valor, list):
        return [str(v) for v in valor]
    return [str(valor)]


def nuuma_desde_username(username: str) -> str:
    """NUUMA = parte local del correo en mayúsculas (``TVA_WebApi_Inicio``)."""
    return (username or "").split("@")[0].upper()


def validar_investment_option(opt: dict, prefijo: str, canal: str, codigos_validos: list[str] | None = None) -> list[str]:
    """``TVA_ValidacionInvestmentOption`` — errores por opción (§12.4.1).

    ``prefijo`` es ``investment[i]- `` con índice 1-based.
    """
    errores: list[str] = []
    codigo = str(opt.get("commercialProductCode") or "").strip()
    if codigos_validos is not None and codigo not in codigos_validos:
        errores.append(f"{prefijo}commercialProductCode: El valor informado no es válido")
    elif not codigo:
        errores.append(f"{prefijo}commercialProductCode: El valor informado no es válido")

    if str(opt.get("operationTypeCode") or "") not in OPERATION_TYPES:
        errores.append(f"{prefijo}operationTypeCode: El valor informado no es válido")

    unica = opt.get("uniqueContributionAmn")
    periodica = opt.get("periodicContributionAmn")
    if unica is not None and float(unica) < 0:
        errores.append(f"{prefijo}uniqueContributionAmn: El valor no puede ser negativo")
    if periodica is not None and float(periodica) < 0:
        errores.append(f"{prefijo}periodicContributionAmn: El valor no puede ser negativo")
    if unica is None and periodica is None:
        errores.append(f"{prefijo}Los dos importes no pueden ser nulos a la vez")

    if periodica is not None and str(opt.get("contributionFrequencyCode") or "") not in CONTRIBUTION_FREQUENCIES:
        errores.append(f"{prefijo}contributionFrequencyCode: El valor informado no es válido")
    return errores


def validar_parametros_inicio_body(body: dict, codigos_productos: list[str] | None = None) -> list[str]:
    """``TVA_WebApi_Inicio_ObtenerMensajeError`` — textos exactos (§12.4.1)."""
    errores: list[str] = []
    if body is None:
        return ["Request inválida"]

    if body.get("companyId") in (None, ""):
        errores.append("El campo companyId no puede ser nulo")
    elif str(body["companyId"]) not in _param_json_list("TVA_CODIGOS_EMPRESA_ADMITIDOS", ["0511"]):
        errores.append("Valor de companyId no permitido")

    if body.get("distributionChannel") in (None, ""):
        errores.append("El campo distributionChannel no puede ser nulo")
    elif str(body["distributionChannel"]) not in _param_json_list("TVA_CODIGOS_DISTRIBUTION_CHANNEL_ADMITIDOS", ["500"]):
        errores.append("Valor de distributionChannel no permitido")

    username = body.get("username")
    if username in (None, ""):
        errores.append("El campo username no puede ser nulo")
    elif not re.search(r"@mapfre\.net$", str(username), re.IGNORECASE):
        errores.append("El nombre de usuario debe acabar en @mapfre.net")

    modo = body.get("indFunctionMode")
    if modo in (None, ""):
        errores.append("El campo indFunctionMode no puede ser nulo")
    elif str(modo) not in MODOS_FUNCIONAMIENTO:
        errores.append("Valor de indFunctionMode no permitido")

    if modo == "VA" and body.get("proposalId") in (None, ""):
        errores.append("El campo proposalId no puede ser nulo si indFunctionMode es VA")

    tomadores = body.get("policyHolders") or []
    if len(tomadores) > 2:
        errores.append("No se admiten más de dos tomadores")

    investments = body.get("investment") or []
    if modo == "VA" and not investments:
        errores.append("En Venta Asesorada es obligatorio informar al menos un seguro de ahorro")

    canal = str(body.get("distributionChannel") or "")
    for i, opt in enumerate(investments, start=1):
        errores.extend(validar_investment_option(opt, f"investment[{i}]- ", canal, codigos_productos))
    return errores
