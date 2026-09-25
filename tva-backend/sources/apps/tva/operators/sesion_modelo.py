"""Modelo de sesión TVA — estructura ``TVA_Sesion`` del volcado Appian (§12.3).

Helpers para construir el ``estado`` JSON de una sesión nueva y para
manipular el árbol cajas/secciones con validez (base de la botonera).
"""

from __future__ import annotations

# Ids de caja — cons!TVA_CAJA_INDEX_*
CAJA_DATOS_PRODUCTORES = "DATOS_PRODUCTORES"
CAJA_DATOS_DEL_SEGURO = "DATOS_DEL_SEGURO"
CAJA_TOMADOR1 = "CAPTURA_DATOS_TOMADOR1"
CAJA_REP_LEGAL_TOMADOR1 = "CAPTURA_DATOS_REP_LEGAL_TOMADOR1"
CAJA_TOMADOR2 = "CAPTURA_DATOS_TOMADOR2"
CAJA_REP_LEGAL_TOMADOR2 = "CAPTURA_DATOS_REP_LEGAL_TOMADOR2"
CAJA_DOMICILIACIONES_T1 = "DOMICILIACIONES_TOMADOR1"
CAJA_DOMICILIACIONES_T2 = "DOMICILIACIONES_TOMADOR2"
CAJA_DOCUMENTACION_PRECONTRACTUAL = "DOCUMENTACION_PRECONTRACTUAL"
CAJA_REQUISITOS_CONTRATACION = "REQUISITOS_CONTRATACION"
CAJA_RESUMEN_RENTAS = "RESUMEN_CONTRATACION_RENTAS"
CAJA_SELECCION_TIPO_FIRMA = "SELECCION_TIPO_FIRMA"
CAJA_DATOS_FIRMA = "DATOS_FIRMA"
CAJA_RESULTADO_FIRMA = "RESULTADO_FIRMA"
CAJA_R2C_CAPTURA = "R2C_CAPTURA"
CAJA_R2C_TOMADORES = "R2C_CAJA_TOMADORES"
CAJA_R2C_PRECIOS = "R2C_CAJA_PRECIOS"


def seccion(id: str, titulo: str = "") -> dict:
    return {"id": id, "titulo": titulo or id, "datosValidos": False, "plegada": False}


def caja(id: str, titulo: str, secciones: list[dict]) -> dict:
    return {"id": id, "titulo": titulo, "plegada": False, "secciones": secciones}


def tomador_vacio() -> dict:
    """``TVA_Tomador`` vacío (§12.3) — estructura por defecto de un tomador."""
    return {
        "datosPersonales": {
            "documentId": None,
            "nombre": None,
            "primerApellido": None,
            "segundoApellido": None,
            "fechaNacimiento": None,
            "sexo": None,
            "nacionalidad": None,
            "paisNacimiento": None,
            "actividad": None,
            "sector": None,
            "profesion": None,
            "responsabilidadPublica": False,
            "residenciaHabitualEspanya": True,
        },
        "domicilioHabitual": {
            "tipoVia": None,
            "nombreVia": None,
            "numero": None,
            "complementoDireccion": None,
            "codigoPostal": None,
            "localidad": None,
            "provincia": None,
            "pais": "ES",
        },
        "mediosContacto": [],
        "fatcaCrs": {"residenteFiscalOtroPais": False},
        "legalRepresentative": None,
        "perfilCliente": {},
        "datosGestionParticipante": {
            "consentimientoProteccionDatos": False,
            "documentoIdDigitalizado": False,
            "testConvenienciaVigente": False,
            "enviadosDocumentosPrecontractuales": False,
        },
        "domiciliaciones": {},
    }


def cajas_iniciales(modalidad: str | None = None) -> list[dict]:
    """Cajas iniciales de la sesión (todas las secciones datosValidos=false)."""
    secciones_tomador = [
        seccion("datosPersonales", "Datos personales"),
        seccion("domicilioHabitual", "Domicilio habitual"),
        seccion("mediosContacto", "Medios de contacto"),
    ]
    return [
        caja(CAJA_DATOS_PRODUCTORES, "Datos de los productores", [seccion("productores", "Productores")]),
        caja(
            CAJA_DATOS_DEL_SEGURO,
            "Datos del seguro",
            [
                seccion("operacion", "Datos de la operación"),
                seccion("opcionesInversion", "Opciones de inversión"),
                seccion("garantias", "Garantías"),
                seccion("domiciliaciones", "Domiciliaciones"),
            ],
        ),
        caja(CAJA_TOMADOR1, "Tomador 1", list(secciones_tomador)),
        caja(CAJA_TOMADOR2, "Tomador 2", list(secciones_tomador)),
    ] + ([caja(CAJA_R2C_CAPTURA, "Datos de la renta", [seccion("captura", "Captura")])] if modalidad == "R2C" else [])


def nueva_sesion_estado(
    clave_sesion: str,
    modo_funcionamiento: str,
    *,
    codigo_producto: str | None = None,
    company_id: str | None = None,
    distribution_channel: str | None = None,
    nuuma: str | None = None,
    perfil_usuario: dict | None = None,
    tomadores: list | None = None,
    propuesta: dict | None = None,
    investment_option: dict | None = None,
    perfil_clientes_ok: bool = True,
) -> dict:
    """Construye el ``estado`` JSON con la estructura ``TVA_Sesion`` (§12.3)."""
    perfil = dict(perfil_usuario or {})
    perfil.setdefault("nuuma", nuuma or "")
    return {
        "claveSesion": clave_sesion,
        "modoFuncionamiento": modo_funcionamiento,
        "codigoProducto": codigo_producto,
        "companyId": company_id,
        "distributionChannel": distribution_channel,
        "perfilUsuario": perfil,
        "tomadores": tomadores if tomadores is not None else [tomador_vacio()],
        "ventaInformada": {"opcionesInversion": [], "cestaLibre": [], "preferencias": {}},
        "datosOperacion": {},
        "garantias": [],
        "comisiones": {},
        "beneficiarios": {},
        "cajas": cajas_iniciales(modo_funcionamiento),
        "avisos": [],
        "documentosPrecontractuales": [],
        "idPantallaActual": None,
        "idPantallaAnterior": None,
        "responseProposal": propuesta or {},
        "investmentOption": investment_option,
        "perfilClientesOK": perfil_clientes_ok,
    }


def buscar_caja(estado: dict, caja_id: str) -> dict | None:
    for c in (estado or {}).get("cajas", []):
        if c.get("id") == caja_id:
            return c
    return None


def set_seccion_valida(estado: dict, caja_id: str, seccion_id: str, valida: bool) -> dict:
    """Marca una sección como válida/inválida (inmutable: devuelve estado nuevo)."""
    nuevo = dict(estado or {})
    cajas = [dict(c) for c in nuevo.get("cajas", [])]
    for c in cajas:
        if c.get("id") == caja_id:
            c["secciones"] = [{**s, "datosValidos": valida} if s.get("id") == seccion_id else s for s in c.get("secciones", [])]
    nuevo["cajas"] = cajas
    return nuevo


def caja_valida(estado: dict, caja_id: str) -> bool:
    """True si todas las secciones de la caja tienen datosValidos."""
    c = buscar_caja(estado, caja_id)
    if not c:
        return False
    return all(s.get("datosValidos") for s in c.get("secciones", []))
