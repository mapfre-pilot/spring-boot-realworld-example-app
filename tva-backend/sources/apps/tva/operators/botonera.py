"""Botonera data-driven — port de ``TVA_Botonera`` (§12.4.3).

Calcula la lista de botones ``{id, label, visible, disabled, confirm?}`` que
acompaña a cada respuesta de acción/sesión.
"""

from apps.tva.models import Modalidad, Pantalla, Parametro, Sesion

from .sesion_modelo import (
    CAJA_DATOS_DEL_SEGURO,
    CAJA_DATOS_PRODUCTORES,
    CAJA_TOMADOR1,
    CAJA_TOMADOR2,
    caja_valida,
)

ROLE_ADMIN_PORTAL = "TVA_ADMIN_PORTAL"

_CONFIRM_CANCELAR = {
    "header": "Cancelar",
    "message": "Va a cancelar el proceso de captura. ¿Está seguro?",
    "ok": "Sí",
    "cancel": "No",
}
_CONFIRM_DOC = {
    "header": "Documentación precontractual",
    "message": "Se va a enviar un correo al cliente con la información precontractual.\n"
    "Si continúa ya no podrá modificar los datos de la solicitud.",
    "ok": "Continuar",
    "cancel": "Volver",
}


def _boton(id: str, label: str, visible: bool = True, disabled: bool = False, confirm: dict | None = None) -> dict:
    b = {"id": id, "label": label, "visible": visible, "disabled": disabled}
    if confirm:
        b["confirm"] = confirm
    return b


def _flag_bool(clave: str) -> bool:
    try:
        return bool(Parametro.get(clave, 0))
    except Exception:
        return False


def _test_conveniencia_valido(estado: dict) -> bool:
    for t in (estado or {}).get("tomadores", []):
        tc = (t.get("perfilCliente") or {}).get("testConveniencia") or {}
        if tc.get("estado") != "FIRMADO":
            return False
    return True


def _seguro_y_productores_validos(estado: dict) -> bool:
    return caja_valida(estado, CAJA_DATOS_PRODUCTORES) and caja_valida(estado, CAJA_DATOS_DEL_SEGURO)


def _hay_avisos_error(estado: dict) -> bool:
    return any(a.get("tipo") == "ERROR" for a in (estado or {}).get("avisos", []))


def botones_para(sesion: Sesion, roles: list[str] | None = None) -> list[dict]:
    """Devuelve la botonera para la pantalla/modo actual de la sesión."""
    roles = roles or []
    estado = sesion.estado or {}
    p = Pantalla(sesion.pantalla_actual)
    es_admin = ROLE_ADMIN_PORTAL in roles
    solicitud = p == Pantalla.CAPTURA_DATOS_SOLICITUD
    tomador = p in (Pantalla.CAPTURA_TOMADOR1, Pantalla.CAPTURA_TOMADOR2)
    r2c_captura = p == Pantalla.R2C_CAPTURA
    r2c_precios = p == Pantalla.R2C_PRECIOS
    resumen = p == Pantalla.RESUMEN_CONTRATACION
    via = sesion.modalidad == Modalidad.VENTA_INFORMADA
    va = sesion.modalidad == Modalidad.VENTA_ASESORADA
    r2c = sesion.modalidad == Modalidad.RENTAS

    base_validos = _seguro_y_productores_validos(estado)
    flag_tc = _flag_bool("TVA_FLAG_TEST_CONVENIENCIA_OBLIGATORIO")
    flag_docs = _flag_bool("TVA_FLAG_DOCUMENTOS_PRECONTRACTUALES_OBLIGATORIOS")
    tc_ok = _test_conveniencia_valido(estado) if flag_tc else True
    docs = estado.get("documentosPrecontractuales") or []
    docs_enviados = bool(docs) and all(d.get("enviado") for d in docs)

    caja_tomador_ok = caja_valida(estado, CAJA_TOMADOR1 if p == Pantalla.CAPTURA_TOMADOR1 else CAJA_TOMADOR2) and tc_ok

    botones = [
        _boton("cancelar", "Cancelar", visible=solicitud or tomador or r2c_captura or r2c_precios or resumen, confirm=_CONFIRM_CANCELAR),
        _boton("administracion", "Administración", visible=es_admin and p != Pantalla.ADMINISTRACION),
        _boton("atras", "Atrás", visible=r2c_precios),
        _boton(
            "recalcular",
            "Recalcular",
            visible=r2c_precios,
            disabled=not bool((estado.get("rentas") or {}).get("recalcular")),
        ),
        _boton("guardar-y-volver", "Guardar y volver", visible=solicitud and va, disabled=not base_validos),
        _boton(
            "doc-precontractual",
            "Doc. Precontractual",
            visible=solicitud and via,
            disabled=not (base_validos and tc_ok and not docs_enviados),
            confirm=_CONFIRM_DOC,
        ),
        _boton(
            "contratar",
            "Contratar",
            visible=(solicitud and (via or r2c)) or r2c_precios,
            disabled=not (
                base_validos
                and tc_ok
                and (not via or (docs_enviados and not _hay_avisos_error(estado)))
                and (not r2c or not flag_docs or docs_enviados)
            ),
        ),
        _boton("continuar", "Continuar", visible=tomador, disabled=not caja_tomador_ok),
        _boton("siguiente", "Siguiente", visible=r2c_captura, disabled=len(estado.get("tomadores") or []) < 2),
        _boton("firmar", "Firmar", visible=False),
    ]
    return botones
