"""Acción continuar-tomador — PM TVA CapturaTomador1/2-Continuar."""

import logging

from apps.tva.models import Sesion

from ._comun import guardar_y_trazar, resultado
from .maquina_pantallas import siguiente_pantalla
from .validaciones import validar_datos_personales, validar_domiciliacion, validar_domicilio

logger = logging.getLogger(__name__)


def ejecutar(sesion: Sesion, datos: dict) -> dict:
    """Valida los datos del tomador capturados y avanza a la siguiente captura."""
    avisos = []
    avisos += validar_datos_personales(datos.get("datosPersonales", datos))
    if "domicilio" in datos or "addressName" in datos or "direccion" in datos:
        avisos += validar_domicilio(datos.get("domicilio", datos))
    if "iban" in datos or "IBAN" in datos or "domiciliacion" in datos:
        avisos += validar_domiciliacion(datos.get("domiciliacion", datos))
    if avisos:
        sesion.estado = {**(sesion.estado or {}), "avisos": avisos}
        guardar_y_trazar(sesion, "CONTINUAR_TOMADOR", avisos)
        return resultado(sesion, avisos)

    estado = dict(sesion.estado or {})
    tomadores = estado.get("tomadores", [])
    tomadores.append(datos)
    estado["tomadores"] = tomadores
    estado["avisos"] = []
    sesion.estado = estado
    sesion.pantalla_actual = siguiente_pantalla(sesion).value
    guardar_y_trazar(sesion, "CONTINUAR_TOMADOR", datos=datos)
    return resultado(sesion)
