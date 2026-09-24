"""Dispatcher de acciones de sesión → operadores."""

import logging

from apps.tva.models import Sesion
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
from ._comun import guardar_y_trazar, resultado
from .maquina_pantallas import ACCIONES_VALIDAS, Accion, siguiente

logger = logging.getLogger(__name__)


class AccionInvalida(Exception):
    pass


def ejecutar_accion(sesion: Sesion, accion: str, datos: dict) -> dict:
    """Ejecuta la acción sobre la sesión y devuelve la respuesta estándar."""
    if accion not in ACCIONES_VALIDAS:
        raise AccionInvalida(accion)

    if accion in (Accion.SIGUIENTE, Accion.ANTERIOR):
        if datos:
            sesion.estado = {**(sesion.estado or {}), **datos}
        sesion.pantalla_actual = siguiente(sesion, accion).value
        guardar_y_trazar(sesion, accion.upper(), datos=datos)
        return resultado(sesion)

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
        Accion.ANTERIOR: None,
    }
    a = Accion(accion)
    if a in (Accion.RECALCULAR_RENTAS, Accion.CONTRATAR_RENTAS) and sesion.modalidad != "R2C":
        sesion.estado = {
            **(sesion.estado or {}),
            "avisos": [
                aviso(AvisosClase.GENERAL, "TVA_ERROR_ACCION_INVALIDA", f"Acción {accion} no válida en modalidad {sesion.modalidad}")
            ],
        }
        guardar_y_trazar(sesion, accion.upper())
        return resultado(sesion)
    return dispatch[a](sesion, datos)
