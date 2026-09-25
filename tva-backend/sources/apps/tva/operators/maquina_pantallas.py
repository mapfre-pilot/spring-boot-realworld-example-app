"""Máquina de pantallas — transiciones inferidas de las reglas SAIL
``TVA_*_siguientePantalla`` y ``TVA_Principal.sail`` del volcado Appian.

Tabla de transiciones (acción ``siguiente`` por modalidad):

| Modalidad | Secuencia de pantallas |
|---|---|
| VA  | SEGUROS_AHORRO → CAPTURA_DATOS_SOLICITUD → CAPTURA_TOMADOR1 → CAPTURA_TOMADOR2 → RESUMEN_CONTRATACION → RESULTADO_FIRMA → FIN |
| VIA | SELECCION_PRODUCTO_AHORRO → MODALIDAD_CAMPANIA* → CAPTURA_DATOS_SOLICITUD → CAPTURA_TOMADOR1 → RESUMEN_CONTRATACION → RESULTADO_FIRMA → FIN |
| R2C | R2C_CAPTURA → R2C_PRECIOS → RESUMEN_CONTRATACION → RESULTADO_FIRMA → FIN |

\\* MODALIDAD_CAMPANIA se salta automáticamente cuando la modalidad no está
en campaña (cons!TVA_VAL_MENSAJE_CAMPANIA en Appian bloqueaba el paso).

Reglas especiales del inicio (`TVA InicioTarificadorVidaAhorro`):
- aplicación cerrada (cons!TVA_APLICACION_CERRADA) → SISTEMA_CERRADO
- usuario sin perfil/funcionalidades → SIN_PERFIL
- propuesta rechazada con avisos → SOLO_AVISOS
- `TVA_propuestaProductosAhorro_siguientePantalla`: VA sin propuesta →
  SEGUROS_AHORRO; VIA sin investmentOption → SELECCION_PRODUCTO_AHORRO,
  con insuranceOfferInd → MODALIDAD_CAMPANIA, con perfil OK →
  CAPTURA_DATOS_SOLICITUD, si no → CAPTURA_TOMADOR1; VIR → CAPTURA_DATOS_SOLICITUD.
"""

import logging
from enum import StrEnum

from apps.tva.models import Modalidad, Pantalla, Sesion

logger = logging.getLogger(__name__)


class Accion(StrEnum):
    SIGUIENTE = "siguiente"
    ANTERIOR = "anterior"
    SELECCIONAR_MODALIDAD = "seleccionar-modalidad"
    GUARDAR_SOLICITUD = "guardar-solicitud"
    CONTINUAR_TOMADOR = "continuar-tomador"
    RECALCULAR_RENTAS = "recalcular-rentas"
    CONTRATAR_RENTAS = "contratar-rentas"
    FIRMAR = "firmar"
    VALIDAR_REINVERSION = "validar-reinversion"
    VERIFICAR_PRODUCTORES = "verificar-productores"
    IMPORTE_MAXIMO = "importe-maximo"
    CANCELAR = "cancelar"
    ADMINISTRACION = "administracion"
    VOLVER_ADMINISTRACION = "volver-administracion"
    DOC_PRECONTRACTUAL = "doc-precontractual"
    CONTRATAR = "contratar"


ACCIONES_VALIDAS = [a.value for a in Accion]

# Secuencia lineal por modalidad (según reglas siguientePantalla).
SECUENCIAS: dict[str, list[Pantalla]] = {
    Modalidad.VENTA_ASESORADA: [
        Pantalla.SEGUROS_AHORRO,
        Pantalla.CAPTURA_DATOS_SOLICITUD,
        Pantalla.CAPTURA_TOMADOR1,
        Pantalla.CAPTURA_TOMADOR2,
        Pantalla.RESUMEN_CONTRATACION,
        Pantalla.RESULTADO_FIRMA,
        Pantalla.FIN,
    ],
    Modalidad.VENTA_INFORMADA: [
        Pantalla.SELECCION_PRODUCTO_AHORRO,
        Pantalla.MODALIDAD_CAMPANIA,
        Pantalla.CAPTURA_DATOS_SOLICITUD,
        Pantalla.CAPTURA_TOMADOR1,
        Pantalla.RESUMEN_CONTRATACION,
        Pantalla.RESULTADO_FIRMA,
        Pantalla.FIN,
    ],
    Modalidad.RENTAS: [
        Pantalla.R2C_CAPTURA,
        Pantalla.R2C_PRECIOS,
        Pantalla.RESUMEN_CONTRATACION,
        Pantalla.RESULTADO_FIRMA,
        Pantalla.FIN,
    ],
}

# Pantallas de entrada por modalidad (inicio de la Web API / inicio PM)
PANTALLA_INICIO = {
    Modalidad.VENTA_ASESORADA: Pantalla.SEGUROS_AHORRO,
    Modalidad.VENTA_INFORMADA: Pantalla.SELECCION_PRODUCTO_AHORRO,
    Modalidad.RENTAS: Pantalla.R2C_CAPTURA,
}


# Transiciones de la acción 'anterior' (inverso de la secuencia)
def _en_campania(sesion: Sesion) -> bool:
    return bool((sesion.estado or {}).get("modalidadCampania"))


def siguiente(sesion: Sesion, accion: str = Accion.SIGUIENTE) -> Pantalla:
    """Calcula la siguiente pantalla para la sesión y la acción dadas.

    Solo cambia la pantalla; el resto del estado lo actualizan los
    operadores concretos.
    """
    secuencia = SECUENCIAS.get(sesion.modalidad, [])
    try:
        idx = secuencia.index(Pantalla(sesion.pantalla_actual))
    except ValueError:
        # Pantalla no está en la secuencia (SISTEMA_CERRADO, SOLO_AVISOS…)
        return Pantalla(sesion.pantalla_actual)

    if accion == Accion.ANTERIOR:
        nueva = secuencia[max(0, idx - 1)]
    else:
        nueva = secuencia[min(len(secuencia) - 1, idx + 1)]

    # VIA: saltar MODALIDAD_CAMPANIA si la modalidad no está en campaña
    if nueva == Pantalla.MODALIDAD_CAMPANIA and not _en_campania(sesion):
        nueva = secuencia[min(len(secuencia) - 1, idx + (2 if accion != Accion.ANTERIOR else 0))]
    if accion == Accion.ANTERIOR and Pantalla.MODALIDAD_CAMPANIA in secuencia and not _en_campania(sesion):
        if nueva == Pantalla.MODALIDAD_CAMPANIA:
            nueva = secuencia[max(0, idx - 2)]

    return nueva


def pantalla_inicio(modalidad: str, estado: dict | None = None) -> Pantalla:
    """Pantalla inicial de una sesión nueva según su modalidad y datos.

    Reproduce ``TVA_propuestaProductosAhorro_siguientePantalla``.
    """
    estado = estado or {}
    if modalidad == Modalidad.VENTA_ASESORADA:
        propuesta = estado.get("responseProposal") or {}
        applications = ((propuesta.get("contractingProposal") or {}).get("insurancesApplication")) or []
        if not applications:
            return Pantalla.SEGUROS_AHORRO
        if len(applications) == 1 and estado.get("perfilClientesOK"):
            return Pantalla.CAPTURA_DATOS_SOLICITUD if not applications[0].get("statusDesc") else Pantalla.SEGUROS_AHORRO
        return Pantalla.SEGUROS_AHORRO
    if modalidad == Modalidad.VENTA_INFORMADA:
        investment = estado.get("investmentOption")
        if investment is None:
            return Pantalla.SELECCION_PRODUCTO_AHORRO
        if investment.get("insuranceOfferInd"):
            return Pantalla.MODALIDAD_CAMPANIA
        return Pantalla.CAPTURA_DATOS_SOLICITUD if estado.get("perfilClientesOK") else Pantalla.CAPTURA_TOMADOR1
    if modalidad == Modalidad.RENTAS:
        return Pantalla.R2C_CAPTURA
    return Pantalla.SOLO_AVISOS


# --- Navegación data-driven (§12.4.2) ---------------------------------------


def siguiente_pantalla(sesion: Sesion) -> Pantalla:
    """Siguiente pantalla según datos de la sesión (§12.4.2).

    Reproduce ``TVA_propuestaProductosAhorro_siguientePantalla`` y las
    transiciones de los PM ``*-Continuar``.
    """
    estado = sesion.estado or {}
    actual = Pantalla(sesion.pantalla_actual)
    modalidad = sesion.modalidad
    tomadores = estado.get("tomadores") or []
    perfil_ok = bool(estado.get("perfilClientesOK"))

    if actual == Pantalla.SELECCION_PRODUCTO_AHORRO:
        investment = estado.get("investmentOption") or {}
        if investment.get("insuranceOfferInd"):
            return Pantalla.MODALIDAD_CAMPANIA
        return Pantalla.CAPTURA_DATOS_SOLICITUD if perfil_ok else Pantalla.CAPTURA_TOMADOR1

    if actual == Pantalla.MODALIDAD_CAMPANIA:
        return Pantalla.CAPTURA_DATOS_SOLICITUD if perfil_ok else Pantalla.CAPTURA_TOMADOR1

    if actual == Pantalla.SEGUROS_AHORRO:
        return Pantalla.CAPTURA_DATOS_SOLICITUD

    if actual == Pantalla.CAPTURA_TOMADOR1:
        return Pantalla.CAPTURA_TOMADOR2 if len(tomadores) >= 2 else Pantalla.CAPTURA_DATOS_SOLICITUD

    if actual == Pantalla.CAPTURA_TOMADOR2:
        return Pantalla.CAPTURA_DATOS_SOLICITUD

    if actual == Pantalla.CAPTURA_DATOS_SOLICITUD:
        return Pantalla.RESUMEN_CONTRATACION

    if actual == Pantalla.RESUMEN_CONTRATACION:
        return Pantalla.RESULTADO_FIRMA

    if actual == Pantalla.RESULTADO_FIRMA:
        return Pantalla.FIN

    if actual == Pantalla.R2C_CAPTURA:
        return Pantalla.R2C_PRECIOS

    if actual == Pantalla.R2C_PRECIOS:
        return Pantalla.RESUMEN_CONTRATACION

    return actual


def pantalla_anterior(sesion: Sesion) -> Pantalla:
    """Acción ``anterior``: R2C_PRECIOS → R2C_CAPTURA; ADMINISTRACION → previa."""
    estado = sesion.estado or {}
    actual = Pantalla(sesion.pantalla_actual)
    if actual == Pantalla.R2C_PRECIOS:
        return Pantalla.R2C_CAPTURA
    if actual == Pantalla.ADMINISTRACION:
        return Pantalla(estado.get("idPantallaAnterior") or actual)
    return actual


def sincronizar_pantalla(sesion: Sesion) -> None:
    """Mantiene ``estado.idPantallaActual`` en sync con ``sesion.pantalla_actual``."""
    estado = dict(sesion.estado or {})
    estado["idPantallaActual"] = sesion.pantalla_actual
    sesion.estado = estado
