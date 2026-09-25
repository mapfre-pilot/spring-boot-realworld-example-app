"""Catálogo de avisos y errores.

Derivado de las constantes del volcado Appian:

- ``cons!TVA_AVISOS_CLASE_*`` (clase del aviso, entero).
- ``cons!TVA_VAL_MENSAJE_*`` / ``cons!TVA_LITERALES_*`` (mensajes).
"""

from enum import IntEnum


class AvisosClase(IntEnum):
    """Clases de aviso — cons!TVA_AVISOS_CLASE_*."""

    VERIFICAR_PRODUCTORES = 1
    TALLER = 2
    BUSQUEDA_RIC = 3
    SAVE_PROPOSAL = 4
    DISCREPANCIAS = 5
    INSURANCE_APPLICATION = 6
    GET_PROPOSAL = 7
    GENERAL = 8
    ANNUITY_SIMULATION = 9
    FIRMA = 10


class ErrorCodes:
    """Códigos de error funcionales expuestos por la API."""

    PARAMETROS_ENTRADA = "TVA_ERROR_PARAMETROS_ENTRADA"
    CLIENTE_NO_ENCONTRADO = "TVA_ERROR_CLIENTE_NO_ENCONTRADO"
    SIN_PERFIL = "TVA_ERROR_SIN_PERFIL"
    APLICACION_CERRADA = "TVA_ERROR_APLICACION_CERRADA"
    SESION_NO_ENCONTRADA = "TVA_ERROR_SESION_NO_ENCONTRADA"
    SESION_CERRADA = "TVA_ERROR_SESION_CERRADA"
    ESTADO_INVALIDO = "TVA_ERROR_ESTADO_INVALIDO"
    ACCION_INVALIDA = "TVA_ERROR_ACCION_INVALIDA"
    VALIDACION = "TVA_ERROR_VALIDACION"
    SERVICIO_EXTERNO = "TVA_ERROR_SERVICIO_EXTERNO"
    PROCESO_FIRMA = "TVA_ERROR_PROCESO_FIRMA"  # cons!TVA_VAL_MENSAJE_ERROR_PROCESO_FIRMA
    CLIENTE_SIN_CONVENIENCIA = "TVA_ERROR_CLIENTE_SIN_CONVENIENCIA"


# Mensajes copiados de cons!TVA_VAL_MENSAJE_* (textos públicos, sin datos sensibles)
MENSAJES = {
    "APLICACION_CERRADA": "Aplicación cerrada por mantenimiento",
    "CLIENTE_SIN_CONVENIENCIA": "Es necesario que el cliente tenga realizado su test de conveniencia y se encuentre en un perfil admitido.",
    "PROCESO_FIRMA": "Error en el proceso de envío a firma.",
    "MODO_CAMPANIA": 'Esta modalidad está en campaña. Debe acceder por "GESVIDA Campañas"',
    "NO_HAY_DATOS": "No hay datos para mostrar",
}


def aviso(clase: AvisosClase | int, codigo: str, mensaje: str, tipo: str = "INFO", mostrar_en: str = "CABECERA") -> dict:
    """Construye un aviso Appian ``{clase, tipo, texto, mostrarEn}``.

    Se conservan ``codigo`` y ``mensaje`` para compatibilidad con el
    contrato REST ya existente.
    """
    return {
        "clase": int(clase),
        "tipo": tipo,
        "texto": mensaje,
        "mostrarEn": mostrar_en,
        "codigo": codigo,
        "mensaje": mensaje,
    }


def error_response(codigo: str, mensaje: str, avisos: list | None = None) -> dict:
    """Sobre de error estándar de la API."""
    return {"error": {"codigo": codigo, "mensaje": mensaje}, "avisos": avisos or []}


def webapi_error_response(mensajes: list[str]) -> dict:
    """Sobre de error de la Web API de inicio (forma Appian ``errors[]``)."""
    from datetime import datetime, timezone

    return {
        "code": "02",
        "message": "Error en los datos proporcionados",
        "application": "TVA",
        "timestamp": datetime.now(tz=timezone.utc).isoformat(),
        "errors": [{"code": "02", "message": m} for m in mensajes],
    }
