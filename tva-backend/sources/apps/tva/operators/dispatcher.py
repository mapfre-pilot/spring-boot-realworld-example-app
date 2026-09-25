"""Dispatcher de acciones de sesión → operadores."""

import logging

from apps.tva.models import Pantalla, Sesion
from apps.tva.schemas.errors import AvisosClase, aviso

from . import (
    continuar_tomador,
    firmar,
    guardar_solicitud,
    importe_maximo,
    rentas,
    seleccionar_modalidad,
    validar_reinversion,
    verificar_productores,
)
from ._comun import add_aviso, guardar_y_trazar, resultado
from .maquina_pantallas import (
    ACCIONES_VALIDAS,
    Accion,
    pantalla_anterior,
    siguiente_pantalla,
    sincronizar_pantalla,
)

logger = logging.getLogger(__name__)


class AccionInvalida(Exception):
    pass


def _accion_cancelar(sesion: Sesion) -> dict:
    """Cancelar: pantalla FIN y avisos = []."""
    estado = dict(sesion.estado or {})
    estado["avisos"] = []
    sesion.estado = estado
    sesion.pantalla_actual = Pantalla.FIN.value
    sesion.abierta = False
    sincronizar_pantalla(sesion)
    guardar_y_trazar(sesion, "CANCELAR")
    return resultado(sesion)


def _accion_administracion(sesion: Sesion, roles: list[str]) -> dict:
    """Administración: guarda idPantallaAnterior y va a ADMINISTRACION."""
    if "TVA_ADMIN_PORTAL" not in roles:
        a = add_aviso(
            sesion,
            AvisosClase.GENERAL,
            "TVA_ERROR_ACCION_INVALIDA",
            "Usuario sin permisos de administración",
            tipo="ERROR",
        )
        guardar_y_trazar(sesion, "ADMINISTRACION", [a])
        return resultado(sesion, roles=roles)
    estado = dict(sesion.estado or {})
    estado["idPantallaAnterior"] = sesion.pantalla_actual
    sesion.estado = estado
    sesion.pantalla_actual = Pantalla.ADMINISTRACION.value
    sincronizar_pantalla(sesion)
    guardar_y_trazar(sesion, "ADMINISTRACION")
    return resultado(sesion, roles=roles)


def _accion_doc_precontractual(sesion: Sesion, datos: dict, roles: list[str]) -> dict:
    """Doc. Precontractual (VIA): envío mock de documentos al cliente."""
    estado = dict(sesion.estado or {})
    try:
        from apps.tva.services.connectors.apilife import get_apilife_client

        get_apilife_client().individual_documents(datos or {})
    except Exception as exc:
        logger.warning("Envío doc. precontractual falló: %s", exc)
        a = add_aviso(
            sesion,
            AvisosClase.GENERAL,
            "TVA_ERROR_DOC_PRECONTRACTUAL",
            "Error al enviar la documentación precontractual",
            tipo="ERROR",
        )
        guardar_y_trazar(sesion, "DOC_PRECONTRACTUAL", [a])
        return resultado(sesion, roles=roles)
    estado["documentosPrecontractuales"] = [{"tipo": "PRECONTRACTUAL", "enviado": True}]
    tomadores = estado.get("tomadores") or []
    if tomadores:
        t = dict(tomadores[0])
        t["datosGestionParticipante"] = {
            **(t.get("datosGestionParticipante") or {}),
            "enviadosDocumentosPrecontractuales": True,
        }
        tomadores[0] = t
        estado["tomadores"] = tomadores
    sesion.estado = estado
    guardar_y_trazar(sesion, "DOC_PRECONTRACTUAL")
    return resultado(sesion, roles=roles)


def _accion_contratar(sesion: Sesion, datos: dict, roles: list[str]) -> dict:
    """Contratar (VIA): valida las condiciones de habilitado y va a RESUMEN."""
    from .botonera import (
        _flag_bool,
        _hay_avisos_error,
        _seguro_y_productores_validos,
        _test_conveniencia_valido,
    )

    estado = dict(sesion.estado or {})
    motivo = None
    if not _seguro_y_productores_validos(estado):
        motivo = "Los datos de productores y del seguro no son válidos"
    elif _flag_bool("TVA_FLAG_TEST_CONVENIENCIA_OBLIGATORIO") and not _test_conveniencia_valido(estado):
        motivo = "Es necesario que el cliente tenga realizado su test de conveniencia"
    elif _flag_bool("TVA_FLAG_DOCUMENTOS_PRECONTRACTUALES_OBLIGATORIOS") and not (estado.get("documentosPrecontractuales")):
        motivo = "Es obligatorio enviar la documentación precontractual"
    elif sesion.modalidad == "VIA" and not estado.get("documentosPrecontractuales"):
        motivo = "Es necesario enviar la documentación precontractual antes de contratar"
    elif _hay_avisos_error(estado):
        motivo = "Hay avisos de error pendientes"

    if motivo:
        a = add_aviso(sesion, AvisosClase.GENERAL, "TVA_ERROR_CONTRATAR", motivo, tipo="ERROR")
        guardar_y_trazar(sesion, "CONTRATAR", [a])
        return resultado(sesion, roles=roles)
    sesion.pantalla_actual = Pantalla.RESUMEN_CONTRATACION.value
    sincronizar_pantalla(sesion)
    guardar_y_trazar(sesion, "CONTRATAR", datos=datos)
    return resultado(sesion, roles=roles)


def ejecutar_accion(sesion: Sesion, accion: str, datos: dict, roles: list[str] | None = None) -> dict:
    """Ejecuta la acción sobre la sesión y devuelve la respuesta estándar."""
    roles = roles or []
    if accion not in ACCIONES_VALIDAS:
        raise AccionInvalida(accion)
    a = Accion(accion)

    if a == Accion.CANCELAR:
        return _accion_cancelar(sesion)
    if a == Accion.ADMINISTRACION:
        return _accion_administracion(sesion, roles)
    if a == Accion.VOLVER_ADMINISTRACION:
        sesion.pantalla_actual = (sesion.estado or {}).get("idPantallaAnterior") or Pantalla.FIN.value
        sincronizar_pantalla(sesion)
        guardar_y_trazar(sesion, "VOLVER_ADMINISTRACION")
        return resultado(sesion, roles=roles)
    if a == Accion.DOC_PRECONTRACTUAL:
        return _accion_doc_precontractual(sesion, datos, roles)
    if a == Accion.CONTRATAR:
        if sesion.modalidad == "R2C":
            return rentas.contratar(sesion, datos)
        return _accion_contratar(sesion, datos, roles)

    if a == Accion.SIGUIENTE:
        if datos:
            sesion.estado = {**(sesion.estado or {}), **datos}
        sesion.pantalla_actual = siguiente_pantalla(sesion).value
        sincronizar_pantalla(sesion)
        guardar_y_trazar(sesion, a.upper(), datos=datos)
        return resultado(sesion, roles=roles)

    if a == Accion.ANTERIOR:
        sesion.pantalla_actual = pantalla_anterior(sesion).value
        sincronizar_pantalla(sesion)
        guardar_y_trazar(sesion, a.upper(), datos=datos)
        return resultado(sesion, roles=roles)

    dispatch = {
        Accion.SELECCIONAR_MODALIDAD: seleccionar_modalidad.ejecutar,
        Accion.GUARDAR_SOLICITUD: guardar_solicitud.ejecutar,
        Accion.CONTINUAR_TOMADOR: continuar_tomador.ejecutar,
        Accion.RECALCULAR_RENTAS: rentas.recalcular,
        Accion.CONTRATAR_RENTAS: rentas.contratar,
        Accion.FIRMAR: firmar.ejecutar,
        Accion.VALIDAR_REINVERSION: validar_reinversion.ejecutar,
        Accion.VERIFICAR_PRODUCTORES: verificar_productores.ejecutar,
        Accion.IMPORTE_MAXIMO: importe_maximo.ejecutar,
    }
    if a in (Accion.RECALCULAR_RENTAS, Accion.CONTRATAR_RENTAS) and sesion.modalidad != "R2C":
        sesion.estado = {
            **(sesion.estado or {}),
            "avisos": [
                aviso(
                    AvisosClase.GENERAL,
                    "TVA_ERROR_ACCION_INVALIDA",
                    f"Acción {accion} no válida en modalidad {sesion.modalidad}",
                    tipo="ERROR",
                )
            ],
        }
        guardar_y_trazar(sesion, a.upper())
        return resultado(sesion, roles=roles)
    res = dispatch[a](sesion, datos)
    # los operadores devuelven el dict de resultado; añadir botones si falta
    if isinstance(res, dict) and "botones" not in res:
        res["botones"] = resultado(sesion, roles=roles)["botones"]
    return res
