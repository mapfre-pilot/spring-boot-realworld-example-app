"""Acción ``validar-seccion`` — valida una sección de una caja (§12.4.4).

Equivalente al PM ``TVA ValidarSeccion``: escribe ``datos`` en la sesión bajo
el path de la sección, ejecuta el validador de la sección con los textos
exactos de Appian, marca ``secciones[j].datosValidos`` y sustituye los avisos
de nivel SECCION de esa sección (avisos con ``seccion: "<caja>/<seccion>"``).
"""

import logging

from apps.tva.models import Sesion

from ._comun import guardar_y_trazar, resultado
from .sesion_modelo import (
    CAJA_R2C_CAPTURA,
    tomador_vacio,
    CAJA_DATOS_DEL_SEGURO,
    CAJA_DATOS_PRODUCTORES,
    CAJA_DOMICILIACIONES_T1,
    CAJA_DOMICILIACIONES_T2,
    CAJA_TOMADOR1,
    CAJA_TOMADOR2,
    buscar_caja,
    set_seccion_valida,
)
from .validaciones import (
    avisos_seccion,
    errores_beneficiarios,
    errores_datos_operacion,
    errores_datos_personales,
    errores_direccion_correspondencia,
    errores_domiciliaciones,
    errores_domicilio_habitual,
    errores_medios_contacto,
    errores_notas,
    errores_opciones_inversion,
    errores_participante,
    errores_productores,
    errores_rentas_captura,
)

logger = logging.getLogger(__name__)

SECCIONES_TOMADOR = ("datosPersonales", "domicilioHabitual", "mediosContacto", "fatcaCrs", "legalRepresentative")


def producto_sesion(estado: dict) -> dict:
    """Producto seleccionado (del catálogo guardado en ``estado.productos``)."""
    codigo = (estado or {}).get("codigoProducto")
    for p in (estado or {}).get("productos") or []:
        if str(p.get("commercialProductCode") or p.get("code")) == str(codigo):
            return p
    return (estado or {}).get("productoSeleccionado") or {}


def _indice_tomador(caja_id: str) -> int | None:
    if caja_id in (CAJA_TOMADOR1, CAJA_DOMICILIACIONES_T1):
        return 0
    if caja_id in (CAJA_TOMADOR2, CAJA_DOMICILIACIONES_T2):
        return 1
    return None


def escribir_seccion(estado: dict, caja_id: str, seccion_id: str, datos: dict) -> dict:
    """Escribe ``datos`` en la sesión bajo el path de la sección."""
    nuevo = dict(estado or {})
    if caja_id == CAJA_R2C_CAPTURA:
        datos = datos or {}
        if "rentas" in datos:
            nuevo["rentas"] = {**(nuevo.get("rentas") or {}), **datos["rentas"]}
        if "tomadores" in datos:
            tomadores = [dict(t) for t in nuevo.get("tomadores") or []]
            while len(tomadores) < 2:
                tomadores.append(tomador_vacio())
            for i, td in enumerate(datos["tomadores"][:2]):
                dp = {**(tomadores[i].get("datosPersonales") or {}), **td}
                tomadores[i]["datosPersonales"] = dp
            nuevo["tomadores"] = tomadores
        return nuevo
    idx = _indice_tomador(caja_id)
    if idx is not None:
        tomadores = [dict(t) for t in nuevo.get("tomadores") or []]
        while len(tomadores) <= idx:
            tomadores.append(tomador_vacio())
        if caja_id in (CAJA_DOMICILIACIONES_T1, CAJA_DOMICILIACIONES_T2):
            tomadores[idx]["domiciliaciones"] = datos
        else:
            tomadores[idx][seccion_id] = datos
        nuevo["tomadores"] = tomadores
        return nuevo

    if caja_id == CAJA_DATOS_PRODUCTORES:
        nuevo["datosProductores"] = datos
        nuevo["comisiones"] = {**(nuevo.get("comisiones") or {}), **{k: v for k, v in (datos or {}).items() if k.startswith("comision")}}
        return nuevo

    if caja_id == CAJA_DATOS_DEL_SEGURO:
        if seccion_id == "operacion":
            nuevo["datosOperacion"] = datos
        elif seccion_id == "opcionesInversion":
            via = dict(nuevo.get("ventaInformada") or {})
            via["opcionesInversion"] = datos
            nuevo["ventaInformada"] = via
        elif seccion_id == "garantias":
            nuevo["garantias"] = datos
        elif seccion_id == "domiciliaciones":
            nuevo["domiciliaciones"] = datos
        elif seccion_id in ("datosContacto", "asegurado", "beneficiarios", "notas"):
            nuevo[seccion_id] = datos
        else:
            nuevo[seccion_id] = datos
        return nuevo

    nuevo[seccion_id] = datos
    return nuevo


def errores_seccion(estado: dict, caja_id: str, seccion_id: str) -> list[str]:
    """Ejecuta el validador de la sección sobre los datos ya persistidos."""
    estado = estado or {}
    idx = _indice_tomador(caja_id)
    producto = producto_sesion(estado)
    op = estado.get("datosOperacion") or {}

    if idx is not None:
        tomadores = estado.get("tomadores") or []
        t = tomadores[idx] if len(tomadores) > idx else {}
        if caja_id in (CAJA_DOMICILIACIONES_T1, CAJA_DOMICILIACIONES_T2):
            return errores_domiciliaciones(t.get("domiciliaciones"))
        if seccion_id == "datosPersonales":
            return errores_datos_personales(t.get("datosPersonales"), t.get("mediosContacto"))
        if seccion_id == "domicilioHabitual":
            return errores_domicilio_habitual(t.get("domicilioHabitual"))
        if seccion_id == "mediosContacto":
            return errores_medios_contacto(t.get("mediosContacto"))
        if seccion_id == "legalRepresentative":
            rep = t.get("legalRepresentative")
            return [] if rep in (None, {}) else errores_participante(rep)
        if seccion_id == "fatcaCrs":
            return []
        return []

    if caja_id == CAJA_R2C_CAPTURA:
        return errores_rentas_captura(estado.get("rentas"), estado.get("tomadores"))

    if caja_id == CAJA_DATOS_PRODUCTORES:
        return errores_productores(estado.get("datosProductores"))

    if caja_id == CAJA_DATOS_DEL_SEGURO:
        if seccion_id == "operacion":
            return errores_datos_operacion(op, producto)
        if seccion_id == "opcionesInversion":
            return errores_opciones_inversion((estado.get("ventaInformada") or {}).get("opcionesInversion"), op, producto)
        if seccion_id == "garantias":
            garantias = estado.get("garantias") or []
            obligatorias_faltan = [g for g in garantias if g.get("obligatoria") and not g.get("seleccionada", True)]
            return ["Las garantías obligatorias deben permanecer seleccionadas"] if obligatorias_faltan else []
        if seccion_id == "domiciliaciones":
            return errores_domiciliaciones(estado.get("domiciliaciones"))
        if seccion_id == "datosContacto":
            return errores_direccion_correspondencia(estado.get("datosContacto"))
        if seccion_id == "asegurado":
            aseg = estado.get("asegurado") or {}
            return [] if aseg.get("esTomador", True) else errores_participante(aseg)
        if seccion_id == "beneficiarios":
            return errores_beneficiarios(estado.get("beneficiarios"))
        if seccion_id == "notas":
            return errores_notas(estado.get("notas"))
    return []


def _set_avisos_seccion(estado: dict, ref: str, errores: list[str]) -> dict:
    """Sustituye los avisos SECCION de ``ref`` por los nuevos errores."""
    nuevo = dict(estado or {})
    avisos = [a for a in nuevo.get("avisos") or [] if a.get("seccion") != ref]
    avisos += avisos_seccion(errores, seccion_ref=ref)
    nuevo["avisos"] = avisos
    return nuevo


def ejecutar(sesion: Sesion, datos: dict, roles: list[str] | None = None) -> dict:
    """``POST sesiones/<clave>/acciones/validar-seccion`` — payload {caja, seccion, datos}."""
    datos = datos or {}
    caja_id = datos.get("caja")
    seccion_id = datos.get("seccion")
    payload = datos.get("datos") or {}

    estado = escribir_seccion(sesion.estado or {}, caja_id, seccion_id, payload)
    sesion.estado = estado
    errores = errores_seccion(estado, caja_id, seccion_id)
    estado = set_seccion_valida(estado, caja_id, seccion_id, not errores)
    estado = _set_avisos_seccion(estado, f"{caja_id}/{seccion_id}", errores)
    sesion.estado = estado
    guardar_y_trazar(sesion, "VALIDAR_SECCION", datos={"caja": caja_id, "seccion": seccion_id})
    return resultado(sesion, roles=roles)


def revalidar_caja(sesion: Sesion, caja_id: str) -> list[str]:
    """Re-valida todas las secciones de una caja y fija su validez.

    Usado por ``continuar-tomador`` y ``guardar-solicitud``.
    """
    estado = dict(sesion.estado or {})
    c = buscar_caja(estado, caja_id)
    if not c:
        return []
    todos: list[str] = []
    for s in c.get("secciones") or []:
        sid = s.get("id")
        errores = errores_seccion(estado, caja_id, sid)
        estado = set_seccion_valida(estado, caja_id, sid, not errores)
        estado = _set_avisos_seccion(estado, f"{caja_id}/{sid}", errores)
        todos += errores
    sesion.estado = estado
    return todos
