"""Acciones de rentas R2C — PM TVA R2C Captura / Precios-Recalcular / Precios-Contratar
y la selección de opción (``TVA_OpcionImporteRenta`` / ``TVA_R2C_SeccionPrecios``)."""

import logging

from apps.tva.models import Pantalla, Sesion
from apps.tva.schemas.errors import AvisosClase, aviso
from apps.tva.services.connectors.apilife import ApiLifeError, get_apilife_client

from ._comun import add_aviso, guardar_y_trazar, resultado
from .secciones import producto_sesion

logger = logging.getLogger(__name__)

MSG_SELECCIONE_SIMULACION = "Seleccione una simulación"
MSG_RECALCULE = "Debe recalcular antes de contratar"

# Opciones de capital decreciente del taller (Appian DEV: 50% y 100%).
_DEATH_CAPITAL_POR_DEFECTO = [{"deathCapitalPremiumPerc": 50.0}, {"deathCapitalPremiumPerc": 100.0}]


def _rentas(sesion: Sesion) -> dict:
    return dict((sesion.estado or {}).get("rentas") or {})


def _guardar_rentas(sesion: Sesion, rentas: dict) -> None:
    sesion.estado = {**(sesion.estado or {}), "rentas": rentas}


def _opciones_capital(sesion: Sesion) -> list[dict]:
    producto = producto_sesion(sesion.estado or {})
    return list(producto.get("deathCapitalOptions") or _DEATH_CAPITAL_POR_DEFECTO)


def _simulaciones(sesion: Sesion, rentas: dict) -> list[dict]:
    """Llama a individualAnnuitySimulation una vez por opción de capital."""
    cliente = get_apilife_client()
    estado = sesion.estado or {}
    base = {
        "importeTotalPrima": rentas.get("importeTotalPrima"),
        "periodicidadRenta": rentas.get("periodicidadRenta"),
        "tomadores": estado.get("tomadores"),
        "codigoProducto": estado.get("codigoProducto"),
        "companyId": estado.get("companyId"),
        "distributionChannel": estado.get("distributionChannel"),
        "nuuma": (estado.get("perfilUsuario") or {}).get("nuuma"),
    }
    if rentas.get("rentaObjetivo") is not None:
        base["incomeAmn"] = rentas.get("rentaObjetivo")
    simulaciones = []
    for opt in rentas.get("deathCapitalOptions") or _DEATH_CAPITAL_POR_DEFECTO:
        simulaciones.append(cliente.annuity_simulation({**base, "deathCapitalPremiumPerc": opt.get("deathCapitalPremiumPerc")}))
    return simulaciones


def simular(sesion: Sesion) -> bool:
    """R2C_CAPTURA → R2C_PRECIOS: simula todas las opciones de capital.

    Devuelve True si la simulación fue posible (y guarda ``rentas.simulaciones``).
    """
    rentas = _rentas(sesion)
    if not rentas.get("deathCapitalOptions"):
        rentas["deathCapitalOptions"] = _opciones_capital(sesion)
    try:
        simulaciones = _simulaciones(sesion, rentas)
    except ApiLifeError as exc:
        a = add_aviso(sesion, AvisosClase.ANNUITY_SIMULATION, "TVA_ERROR_SERVICIO_EXTERNO", str(exc), tipo="ERROR")
        guardar_y_trazar(sesion, "R2C_SIMULAR", [a])
        return False
    rentas["simulaciones"] = simulaciones
    rentas["idxSimulacionSeleccionada"] = None
    rentas["rentaObjetivo"] = None
    rentas["recalcular"] = False
    _guardar_rentas(sesion, rentas)
    return True


def actualizar(sesion: Sesion, datos: dict) -> dict:
    """actualizar-rentas — selección de opción (idx) o renta objetivo.

    Seleccionar ``idxSimulacionSeleccionada`` fija la renta objetivo al
    ``incomeAmn`` de esa simulación y desmarca recalcular; informar
    ``rentaObjetivo`` lo marca para recalcular (Appian TVA_R2C_SeccionPrecios).
    """
    if sesion.pantalla_actual != Pantalla.R2C_PRECIOS.value:
        a = add_aviso(sesion, AvisosClase.GENERAL, "TVA_ERROR_ACCION_INVALIDA", "actualizar-rentas solo en precios", tipo="ERROR")
        guardar_y_trazar(sesion, "ACTUALIZAR_RENTAS", [a])
        return resultado(sesion)
    datos = datos or {}
    rentas = _rentas(sesion)
    simulaciones = rentas.get("simulaciones") or []
    if "idxSimulacionSeleccionada" in datos and datos.get("idxSimulacionSeleccionada") is not None:
        idx = int(datos["idxSimulacionSeleccionada"])
        rentas["idxSimulacionSeleccionada"] = idx
        if 0 <= idx < len(simulaciones):
            rentas["rentaObjetivo"] = (simulaciones[idx].get("projectData") or {}).get("incomeAmn")
        rentas["recalcular"] = False
    elif datos.get("rentaObjetivo") is not None:
        rentas["rentaObjetivo"] = datos.get("rentaObjetivo")
        rentas["recalcular"] = True
    _guardar_rentas(sesion, rentas)
    guardar_y_trazar(sesion, "ACTUALIZAR_RENTAS", datos=datos)
    return resultado(sesion)


def recalcular(sesion: Sesion, datos: dict) -> dict:
    """Recalcula las simulaciones con la renta objetivo y fija la prima."""
    rentas = _rentas(sesion)
    idx = rentas.get("idxSimulacionSeleccionada")
    if idx is None or not rentas.get("recalcular"):
        a = add_aviso(sesion, AvisosClase.ANNUITY_SIMULATION, "TVA_ERROR_RECALCULAR", MSG_RECALCULE, tipo="ERROR")
        guardar_y_trazar(sesion, "R2C_RECALCULAR", [a], datos)
        return resultado(sesion)
    try:
        simulaciones = _simulaciones(sesion, rentas)
    except ApiLifeError as exc:
        a = add_aviso(sesion, AvisosClase.ANNUITY_SIMULATION, "TVA_ERROR_SERVICIO_EXTERNO", str(exc), tipo="ERROR")
        guardar_y_trazar(sesion, "R2C_RECALCULAR", [a], datos)
        return resultado(sesion)
    rentas["simulaciones"] = simulaciones
    if 0 <= idx < len(simulaciones):
        rentas["importeTotalPrima"] = (simulaciones[idx].get("projectData") or {}).get("premiumAmn")
    rentas["recalcular"] = False
    _guardar_rentas(sesion, rentas)
    guardar_y_trazar(sesion, "R2C_RECALCULAR", datos=datos)
    return resultado(sesion)


def contratar(sesion: Sesion, datos: dict) -> dict:
    """Contratar (R2C): individualAnnuityInsuranceApplication → RESUMEN."""
    rentas = _rentas(sesion)
    idx = rentas.get("idxSimulacionSeleccionada")
    avisos = []
    if idx is None:
        avisos.append(aviso(AvisosClase.ANNUITY_SIMULATION, "TVA_ERROR_SIN_SIMULACION", MSG_SELECCIONE_SIMULACION, tipo="ERROR"))
    elif rentas.get("recalcular"):
        avisos.append(aviso(AvisosClase.ANNUITY_SIMULATION, "TVA_ERROR_RECALCULAR", MSG_RECALCULE, tipo="ERROR"))
    if avisos:
        sesion.estado = {**(sesion.estado or {}), "avisos": [*((sesion.estado or {}).get("avisos") or []), *avisos]}
        guardar_y_trazar(sesion, "R2C_CONTRATAR", avisos, datos)
        return resultado(sesion)
    estado = sesion.estado or {}
    try:
        response = get_apilife_client().annuity_insurance_application(
            {
                "importeTotalPrima": rentas.get("importeTotalPrima"),
                "periodicidadRenta": rentas.get("periodicidadRenta"),
                "rentaObjetivo": rentas.get("rentaObjetivo"),
                "tomadores": estado.get("tomadores"),
                "codigoProducto": estado.get("codigoProducto"),
                "companyId": estado.get("companyId"),
                "distributionChannel": estado.get("distributionChannel"),
                "nuuma": (estado.get("perfilUsuario") or {}).get("nuuma"),
                "deathCapitalPremiumPerc": ((rentas.get("deathCapitalOptions") or [])[idx] or {}).get("deathCapitalPremiumPerc")
                if idx is not None and idx < len(rentas.get("deathCapitalOptions") or [])
                else None,
            }
        )
        sesion.estado = {**(sesion.estado or {}), "insuranceApplication": response, "avisos": []}
        sesion.pantalla_actual = Pantalla.RESUMEN_CONTRATACION.value
    except ApiLifeError as exc:
        avisos.append(aviso(AvisosClase.INSURANCE_APPLICATION, "TVA_ERROR_SERVICIO_EXTERNO", str(exc)))
        sesion.estado = {**(sesion.estado or {}), "avisos": avisos}
    guardar_y_trazar(sesion, "R2C_CONTRATAR", avisos, datos)
    return resultado(sesion, avisos or None)
