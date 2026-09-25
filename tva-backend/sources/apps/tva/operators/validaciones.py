"""Validaciones de entrada — equivalentes de las reglas ``TVA_*_Validacion``.

Cada función devuelve una lista de avisos (vacía = válido).
"""

import datetime
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
    modo_norm = str(modo).upper() if modo is not None else ""
    if modo in (None, ""):
        errores.append("El campo indFunctionMode no puede ser nulo")
    elif modo_norm not in MODOS_FUNCIONAMIENTO:
        errores.append("Valor de indFunctionMode no permitido")

    if modo_norm == "VA" and body.get("proposalId") in (None, ""):
        errores.append("El campo proposalId no puede ser nulo si indFunctionMode es VA")

    tomadores = body.get("policyHolders") or []
    if len(tomadores) > 2:
        errores.append("No se admiten más de dos tomadores")

    investments = body.get("investment") or []
    if modo_norm == "VA" and not investments:
        errores.append("En Venta Asesorada es obligatorio informar al menos un seguro de ahorro")

    canal = str(body.get("distributionChannel") or "")
    for i, opt in enumerate(investments, start=1):
        errores.extend(validar_investment_option(opt, f"investment[{i}]- ", canal, codigos_productos))
    return errores


# --- Validaciones de secciones (§12.4.4) — textos exactos Appian -------------
#
# Cada función devuelve ``list[str]`` con los mensajes tal y como los emite la
# regla ``TVA_*_Validacion`` correspondiente.


def _vacio(v) -> bool:
    return v is None or (isinstance(v, str) and not v.strip())


def errores_datos_personales(dp: dict, medios: list | None = None) -> list[str]:
    """``TVA_CapturaTomador_DatosPersonales_Validacion`` (§12.4.4)."""
    dp = dp or {}
    errores: list[str] = []
    if _vacio(dp.get("documentId")):
        errores.append("El documento identificativo no puede ser nulo")
    if _vacio(dp.get("nombre")):
        errores.append("El nombre es obligatorio")
    if _vacio(dp.get("primerApellido")):
        errores.append("El primer apellido es obligatorio")
    if _vacio(dp.get("fechaNacimiento")):
        errores.append("La fecha de nacimiento es obligatoria")
    if _vacio(dp.get("sexo")):
        errores.append("El sexo es obligatorio")
    if _vacio(dp.get("nacionalidad")):
        errores.append("La nacionalidad es obligatoria")
    if _vacio(dp.get("paisNacimiento")):
        errores.append("El país de nacimiento es obligatorio")
    if _vacio(dp.get("actividad")) or _vacio(dp.get("sector")) or _vacio(dp.get("profesion")):
        errores.append("Los campos Actividad, Sector y Profesión son obligatorios")
    if medios is not None:
        errores += errores_medios_contacto(medios)
    return errores


def errores_medios_contacto(medios: list) -> list[str]:
    """``TVA_MediosContacto_Validacion`` (§12.4.4)."""
    medios = medios or []
    errores: list[str] = []
    tipos_telefono = ("MOVIL", "FIJO", "OTRO")
    moviles = [m for m in medios if str(m.get("tipo") or "").upper() == "MOVIL"]
    emails = [m for m in medios if str(m.get("tipo") or "").upper() == "EMAIL"]
    if not moviles:
        errores.append("El móvil es obligatorio")
    if not emails or _vacio((emails[0] or {}).get("contactMethodValue") or emails[0].get("valor")):
        errores.append("El correo electrónico es obligatorio")
    for m in medios:
        tipo = str(m.get("tipo") or "").upper()
        if _vacio(m.get("tipo")):
            errores.append("El campo tipo de medio de contacto es obligatorio")
        elif tipo in tipos_telefono and _vacio(m.get("prefijo")):
            errores.append("El campo Prefijo es obligatorio")
        if _vacio(m.get("contactMethodValue")) and _vacio(m.get("numero")) and _vacio(m.get("valor")):
            errores.append("El campo contactMethodValue es obligatorio")
    return errores


def errores_domicilio_habitual(dom: dict) -> list[str]:
    """``TVA_CapturaTomador_DomicilioHabitual_Validacion`` (§12.4.4)."""
    dom = dom or {}
    errores: list[str] = []
    if _vacio(dom.get("tipoVia")):
        errores.append("El tipo de vía es obligatorio")
    if _vacio(dom.get("nombreVia")):
        errores.append("El nombre de la vía es obligatorio")
    if _vacio(dom.get("numero")):
        errores.append("El número es obligatorio")
    if _vacio(dom.get("codigoPostal")):
        errores.append("El código postal es obligatorio")
    if _vacio(dom.get("localidad")):
        errores.append("La localidad es obligatoria")
    if _vacio(dom.get("provincia")):
        errores.append("La provincia es obligatoria")
    if _vacio(dom.get("pais")):
        errores.append("El país es obligatorio")
    return errores


def errores_direccion_correspondencia(dir_: dict) -> list[str]:
    """``TVA_Address_Validacion`` — mismos campos capitalizados + tipo (§12.4.4)."""
    dir_ = dir_ or {}
    errores: list[str] = []
    if _vacio(dir_.get("tipoVia")):
        errores.append("El Tipo de Vía es obligatorio")
    if _vacio(dir_.get("nombreVia")):
        errores.append("El Nombre de la Vía es obligatorio")
    if _vacio(dir_.get("numero")):
        errores.append("El Número es obligatorio")
    if _vacio(dir_.get("codigoPostal")):
        errores.append("El Código Postal es obligatorio")
    if _vacio(dir_.get("localidad")):
        errores.append("La Localidad es obligatoria")
    if _vacio(dir_.get("provincia")):
        errores.append("La Provincia es obligatoria")
    if _vacio(dir_.get("pais")):
        errores.append("El País es obligatorio")
    if _vacio(dir_.get("tipoDireccion")):
        errores.append("El campo tipo de dirección es obligatorio")
    return errores


def _en_rango(valor, minimo: float, maximo: float) -> bool:
    try:
        return float(minimo) <= float(valor) <= float(maximo)
    except (TypeError, ValueError):
        return False


def errores_datos_operacion(op: dict, producto: dict | None = None) -> list[str]:
    """``TVA_DatosDeLaOperacion_Validacion`` (§12.4.4)."""
    op = op or {}
    producto = producto or {}
    errores: list[str] = []

    if _vacio(op.get("fechaEfecto")):
        errores.append("La fecha de efecto no puede ser nula")

    prima_unica = op.get("primaUnica")
    prima_periodica = op.get("aportacionPeriodica")
    if _vacio(prima_unica) and _vacio(prima_periodica):
        errores.append("Debe rellenar la prima única o la prima periódica")

    if not _vacio(prima_periodica):
        if _vacio(op.get("periodicidad")):
            errores.append("Debe seleccionar la periodicidad")
        dia_cobro = op.get("diaCobro")
        if not _vacio(dia_cobro) and not _en_rango(dia_cobro, 1, 31):
            errores.append("El valor debe estar en el rango 1 a 31")

    prima_min = producto.get("primaMinima", 600)
    prima_max = producto.get("primaMaxima", 1_000_000)
    for prima in (prima_unica, prima_periodica):
        if not _vacio(prima) and not _en_rango(prima, float(prima_min), float(prima_max)):
            errores.append(f"El importe de la prima debe estar entre {prima_min} y {prima_max}")
            break

    if op.get("revalorizacion") and _vacio(op.get("porcentajeCrecimiento")):
        errores.append("El tipo de revalorización no puede ser nulo")

    reinversion = op.get("reinversion") or {}
    if reinversion.get("activa"):
        if _vacio(reinversion.get("operacion")):
            errores.append("La operación de reinversión no puede ser nula")
        if _vacio(reinversion.get("poliza")):
            errores.append("La póliza de reinversión no puede ser nula")
        if _vacio(reinversion.get("tipo")):
            errores.append("El tipo de de reinversion no puede ser nulo")

    tipo_duracion = str(op.get("tipoDuracion") or "").upper()
    if _vacio(tipo_duracion):
        errores.append("El tipo de duración no puede ser nulo")
    elif tipo_duracion == "ANIOS":
        if _vacio(op.get("duracion")):
            errores.append("La duración no puede ser nula")
    elif tipo_duracion == "TABLA":
        if _vacio(op.get("tabla")):
            errores.append("La tabla no puede ser nula")
    elif tipo_duracion == "EDAD_VENCIMIENTO":
        if _vacio(op.get("edadVencimiento")):
            errores.append("La edad de vencimiento no puede ser nula")
    elif tipo_duracion == "FECHA_VENCIMIENTO":
        if _vacio(op.get("fechaVencimiento")):
            errores.append("La fecha de vencimiento no puede ser nula")
    elif tipo_duracion == "JUBILACION":
        pass

    fecha_minus = op.get("fechaAltaMinusvalia")
    if not _vacio(op.get("gradoMinusvalia")) and not _vacio(fecha_minus):
        try:
            if datetime.date.fromisoformat(str(fecha_minus)[:10]) > datetime.date.today():
                errores.append("La fecha de alta de la minusvalía no puede ser un valor futuro")
        except ValueError:
            pass
    return errores


def errores_opciones_inversion(opciones: list, op: dict | None = None, producto: dict | None = None) -> list[str]:
    """``TVA_OpcionesDeInversion_Validacion`` (§12.4.4)."""
    opciones = opciones or []
    op = op or {}
    producto = producto or {}
    errores: list[str] = []
    seleccionadas = [o for o in opciones if o.get("seleccionada", True)]
    if not seleccionadas:
        errores.append("Debe seleccionar la opción de inversión")
        return errores

    prima_unica_op = op.get("primaUnica")
    if not _vacio(prima_unica_op):
        suma = sum(float(o.get("primaUnica") or 0) for o in seleccionadas)
        if abs(suma - float(prima_unica_op)) > 0.01:
            errores.append("La suma de los importes de la prima única debe coincidir con el total de la operación")
    prima_periodica_op = op.get("aportacionPeriodica")
    if not _vacio(prima_periodica_op):
        suma = sum(float(o.get("primaPeriodica") or o.get("aportacionPeriodica") or 0) for o in seleccionadas)
        if abs(suma - float(prima_periodica_op)) > 0.01:
            errores.append("La suma de los importes de la prima periódica debe coincidir con el total de la operación")

    if producto.get("unitLinkedInd"):
        for o in seleccionadas:
            if _vacio(o.get("plazoObjetivo")):
                errores.append("El plazo objetivo no puede ser nulo")
                break
    return errores


def errores_domiciliaciones(dom: dict) -> list[str]:
    """``TVA_Domiciliaciones_Validacion`` (§12.4.4)."""
    dom = dom or {}
    errores: list[str] = []
    for campo, requerido, msg in (
        ("ibanRecibos", True, "El IBAN de pago de recibos no puede ser nulo"),
        ("ibanPrestaciones", bool(dom.get("requierePrestaciones")), "El IBAN de pago de prestaciones no puede ser nulo"),
    ):
        iban = dom.get(campo)
        if requerido and _vacio(iban):
            errores.append(msg)
        elif not _vacio(iban) and not iban_valido(str(iban)):
            errores.append("IBAN inválido")
    return errores


def iban_valido(iban: str) -> bool:
    """Comprobación mod-97 del IBAN (``CMP_validacionIBAN``)."""
    limpio = iban.replace(" ", "").upper()
    if len(limpio) < 15 or not limpio.isalnum():
        return False
    try:
        return int("".join(str(int(c, 36)) if c.isalpha() else c for c in limpio[4:] + limpio[:4])) % 97 == 1
    except ValueError:
        return False


def errores_participante(p: dict) -> list[str]:
    """``TVA_Participante_Validacion`` — asegurado / representante legal."""
    p = p or {}
    errores: list[str] = []
    if _vacio(p.get("nombre")):
        errores.append("El nombre es obligatorio")
    if _vacio(p.get("primerApellido")):
        errores.append("El primer apellido es obligatorio")
    if _vacio(p.get("sexo")):
        errores.append("El sexo es obligatorio")
    if _vacio(p.get("fechaNacimiento")):
        errores.append("La fecha de nacimiento es obligatoria")
    if _vacio(p.get("parentesco")):
        errores.append("El parentesco es obligatorio")
    return errores


def errores_beneficiarios(b: dict) -> list[str]:
    """``TVA_Beneficiarios_Validacion`` (§12.4.4)."""
    b = b or {}
    errores: list[str] = []
    tipo = str(b.get("tipo") or b.get("tipoBeneficiario") or "").upper()
    if tipo in ("TEXTO_LIBRE", "TEXTO", "LIBRE") and _vacio(b.get("textoLibre")):
        errores.append("Debe incluir en el texto libre el beneficiario")
    for part in b.get("participantes") or []:
        errores += errores_participante(part)
    return errores


def errores_notas(notas: list) -> list[str]:
    """``TVA_Notas_Validacion`` (§12.4.4)."""
    errores: list[str] = []
    for n in notas or []:
        if n.get("seleccionada") and _vacio(n.get("texto")):
            errores.append("Hay notas seleccionadas que deben llevar texto obligatoriamente")
            break
    return errores


def errores_productores(prod: dict) -> list[str]:
    """``TVA_Productores_Validacion``."""
    prod = prod or {}
    errores: list[str] = []
    if _vacio(prod.get("oficina")):
        errores.append("La oficina es obligatoria")
    if _vacio(prod.get("productor")):
        errores.append("El productor es obligatorio")
    maxima = prod.get("comisionMaxima")
    deseada = prod.get("comisionDeseada")
    if not _vacio(deseada) and not _vacio(maxima) and float(deseada) > float(maxima):
        errores.append("El porcentaje de comisión no puede superar el máximo")
    return errores


def avisos_seccion(errores: list[str], clase=AvisosClase.GENERAL, seccion_ref: str = "") -> list:
    """Envuelve los textos §12.4.4 en avisos tipo ERROR mostrarEn=SECCION."""
    return [{**aviso(clase, "TVA_ERROR_VALIDACION", e, tipo="ERROR", mostrar_en="SECCION"), "seccion": seccion_ref} for e in errores]


def test_conveniencia_valido(perfil: dict | None) -> bool:
    """``TVA_EsValidoTestConveniencia``: firma ``FI`` y fecha no caducada."""
    perfil = perfil or {}
    if str(perfil.get("testConvenienciaEstadoFirma") or "") != "FI":
        return False
    fecha = perfil.get("testConvenienciaFechaCaducidad")
    if not fecha:
        return False
    try:
        return datetime.date.fromisoformat(str(fecha)[:10]) >= datetime.date.today()
    except ValueError:
        return False
