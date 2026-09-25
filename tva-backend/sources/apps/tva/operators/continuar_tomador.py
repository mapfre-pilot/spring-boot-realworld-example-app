"""Acción continuar-tomador — PM TVA CapturaTomador1/2-Continuar.

Re-valida todas las secciones de las cajas del tomador (y su representante
legal si lo hay), fija su validez y navega con ``siguiente_pantalla``.
En VIA añade el aviso INFO del importe máximo anual (PM Importe máximo).
"""

import logging

from apps.tva.models import Modalidad, Sesion
from apps.tva.schemas.errors import AvisosClase, aviso

from ._comun import guardar_y_trazar, resultado
from .maquina_pantallas import siguiente_pantalla
from .secciones import revalidar_caja
from .sesion_modelo import CAJA_REP_LEGAL_TOMADOR1, CAJA_REP_LEGAL_TOMADOR2, CAJA_TOMADOR1, CAJA_TOMADOR2, buscar_caja

logger = logging.getLogger(__name__)

MSG_IMPORTE_MAXIMO = "El importe máximo anual que el cliente puede contratar para la agrupación fiscal es de 7.500 €"


def ejecutar(sesion: Sesion, datos: dict) -> dict:
    """Re-valida las secciones del tomador capturado y avanza si todo es válido."""
    caja = CAJA_TOMADOR1 if sesion.pantalla_actual == "CAPTURA_TOMADOR1" else CAJA_TOMADOR2
    errores = revalidar_caja(sesion, caja)

    rep = CAJA_REP_LEGAL_TOMADOR1 if caja == CAJA_TOMADOR1 else CAJA_REP_LEGAL_TOMADOR2
    if buscar_caja(sesion.estado, rep):
        errores += revalidar_caja(sesion, rep)

    estado = dict(sesion.estado or {})
    if errores:
        sesion.estado = estado
        guardar_y_trazar(sesion, "CONTINUAR_TOMADOR", estado.get("avisos"))
        return resultado(sesion, estado.get("avisos"))

    avisos = [a for a in estado.get("avisos", []) if a.get("tipo") != "ERROR"]
    if sesion.modalidad == Modalidad.VENTA_INFORMADA:
        avisos = [a for a in avisos if a.get("texto") != MSG_IMPORTE_MAXIMO]
        avisos.append({**aviso(AvisosClase.GENERAL, "TVA_INFO_IMPORTE_MAXIMO", MSG_IMPORTE_MAXIMO, tipo="INFO"), "seccion": ""})
    estado["avisos"] = avisos
    sesion.estado = estado
    sesion.pantalla_actual = siguiente_pantalla(sesion).value
    guardar_y_trazar(sesion, "CONTINUAR_TOMADOR", datos=datos)
    return resultado(sesion)
