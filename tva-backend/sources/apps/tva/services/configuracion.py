"""Configuración de los conectores editable desde Administración.

Precedencia: valor guardado en ``tva_configuracion`` > variable de entorno
(``settings``). Los secretos se guardan cifrados con Fernet usando una clave
derivada de ``TVA_CONFIG_KEY`` (o ``SECRET_KEY`` si no está definida) y nunca
se devuelven por la API. Los valores se releen de BD cada ``TTL_SEGUNDOS``
para que un cambio llegue a todos los workers/réplicas sin reiniciar.
"""

import base64
import hashlib
import logging
import time
from dataclasses import dataclass

from cryptography.fernet import Fernet, InvalidToken
from django.conf import settings
from django.db import DatabaseError

from apps.tva.models import ConfiguracionIntegracion

logger = logging.getLogger(__name__)

TTL_SEGUNDOS = 30
MODOS = ("mock", "real")


@dataclass(frozen=True)
class Campo:
    nombre: str
    grupo: str
    etiqueta: str
    tipo: str = "texto"  # texto | modo | entero | secreto

    @property
    def secreto(self) -> bool:
        return self.tipo == "secreto"


GRUPOS = {
    "apilife": "API Life / APPINVE",
    "misv": "MISV (perfil inversor)",
    "ric": "RIC (clientes)",
    "perfil-usuario": "Perfil de usuario (SOA7)",
    "appian": "Appian Embedded",
}

CAMPOS: tuple[Campo, ...] = (
    Campo("APILIFE_MODE", "apilife", "Modo", "modo"),
    Campo("APILIFE_BASE_URL", "apilife", "URL base"),
    Campo("APILIFE_USERNAME", "apilife", "Usuario (APPSAVI)"),
    Campo("APILIFE_PASSWORD", "apilife", "Contraseña (APPSAVI)", "secreto"),
    Campo("APILIFE_APPINVE_USERNAME", "apilife", "Usuario APPINVE"),
    Campo("APILIFE_APPINVE_PASSWORD", "apilife", "Contraseña APPINVE", "secreto"),
    Campo("APILIFE_TIMEOUT", "apilife", "Timeout (s)", "entero"),
    Campo("APILIFE_ACCEPT_LANGUAGE", "apilife", "Accept-Language"),
    Campo("APILIFE_APPLICATION_ID", "apilife", "Application ID"),
    Campo("MISV_MODE", "misv", "Modo", "modo"),
    Campo("MISV_BASE_URL", "misv", "URL base"),
    Campo("MISV_USERNAME", "misv", "Usuario (APPCMPA)"),
    Campo("MISV_PASSWORD", "misv", "Contraseña (APPCMPA)", "secreto"),
    Campo("MISV_TIMEOUT", "misv", "Timeout (s)", "entero"),
    Campo("MISV_APLICACION", "misv", "Aplicación"),
    Campo("MISV_TIPO_PERSONA", "misv", "Tipo de persona"),
    Campo("RIC_MODE", "ric", "Modo", "modo"),
    Campo("RIC_BASE_URL", "ric", "URL base"),
    Campo("RIC_PATH", "ric", "Ruta"),
    Campo("RIC_USERNAME", "ric", "Usuario"),
    Campo("RIC_PASSWORD", "ric", "Contraseña", "secreto"),
    Campo("RIC_TIMEOUT", "ric", "Timeout (s)", "entero"),
    Campo("PERFIL_USUARIO_MODE", "perfil-usuario", "Modo", "modo"),
    Campo("SOA_BASE_URL", "perfil-usuario", "URL base SOA7"),
    Campo("SOA_USERNAME", "perfil-usuario", "Usuario (APPRIMO)"),
    Campo("SOA_PASSWORD", "perfil-usuario", "Contraseña (APPRIMO)", "secreto"),
    Campo("SOA_TIMEOUT", "perfil-usuario", "Timeout (s)", "entero"),
    Campo("APPIAN_EMBED_MODE", "appian", "Modo", "modo"),
    Campo("APPIAN_EMBED_BASE_URL", "appian", "URL base (/suite)"),
    Campo("APPIAN_EMBED_API_KEY", "appian", "API key", "secreto"),
    Campo("APPIAN_EMBED_TIMEOUT", "appian", "Timeout (s)", "entero"),
    Campo("APPIAN_EMBED_EMAIL_AVISOS", "appian", "Email de avisos"),
)

CAMPOS_POR_NOMBRE = {c.nombre: c for c in CAMPOS}

_cache: dict = {"expira": 0.0, "valores": {}}


class ConfiguracionError(ValueError):
    pass


def _fernet() -> Fernet:
    clave = settings.TVA_CONFIG_KEY or settings.SECRET_KEY
    return Fernet(base64.urlsafe_b64encode(hashlib.sha256(clave.encode()).digest()))


def _valores_bd() -> dict[str, str]:
    try:
        filas = list(ConfiguracionIntegracion.objects.all())
    except DatabaseError:
        logger.warning("tva_configuracion no disponible; se usan las variables de entorno")
        return {}
    valores: dict[str, str] = {}
    for fila in filas:
        if not fila.secreto:
            valores[fila.nombre] = fila.valor
            continue
        try:
            valores[fila.nombre] = _fernet().decrypt(fila.valor.encode()).decode()
        except InvalidToken:
            logger.error("No se puede descifrar %s: ¿ha cambiado SECRET_KEY/TVA_CONFIG_KEY?", fila.nombre)
    return valores


def _valores() -> dict[str, str]:
    ahora = time.monotonic()
    if ahora >= _cache["expira"]:
        _cache["valores"] = _valores_bd()
        _cache["expira"] = ahora + TTL_SEGUNDOS
    return _cache["valores"]


def invalidar() -> None:
    _cache["expira"] = 0.0


def obtener(nombre: str):
    """Valor efectivo de ``nombre`` (BD > entorno), tipado según el campo."""
    campo = CAMPOS_POR_NOMBRE[nombre]
    valor = _valores().get(nombre)
    if valor is None:
        return getattr(settings, nombre)
    return int(valor) if campo.tipo == "entero" else valor


def huella(grupo: str) -> tuple:
    """Valores efectivos de un grupo; cambia cuando hay que recrear el cliente."""
    return tuple(obtener(c.nombre) for c in CAMPOS if c.grupo == grupo)


def describir() -> list[dict]:
    """Campos para Administración; los secretos solo indican si están configurados."""
    guardados = _valores_bd()
    resultado = []
    for campo in CAMPOS:
        efectivo = guardados.get(campo.nombre, getattr(settings, campo.nombre))
        resultado.append(
            {
                "nombre": campo.nombre,
                "grupo": campo.grupo,
                "grupoEtiqueta": GRUPOS[campo.grupo],
                "etiqueta": campo.etiqueta,
                "tipo": campo.tipo,
                "valor": None if campo.secreto else str(efectivo),
                "configurado": efectivo not in ("", None),
                "origen": "bd" if campo.nombre in guardados else "entorno",
            }
        )
    return resultado


def _validar(campo: Campo, valor: str) -> str:
    valor = valor.strip()
    if campo.tipo == "modo" and valor not in MODOS:
        raise ConfiguracionError(f"{campo.nombre}: valor esperado mock|real")
    if campo.tipo == "entero" and not valor.isdigit():
        raise ConfiguracionError(f"{campo.nombre}: debe ser un número entero")
    return valor


def guardar(valores: dict[str, str], restablecer: list[str], usuario: str) -> None:
    """Guarda/restablece valores. Un secreto vacío se ignora (se conserva el actual)."""
    desconocidos = [n for n in [*valores, *restablecer] if n not in CAMPOS_POR_NOMBRE]
    if desconocidos:
        raise ConfiguracionError(f"Campos desconocidos: {', '.join(desconocidos)}")
    validados = {}
    for nombre, valor in valores.items():
        campo = CAMPOS_POR_NOMBRE[nombre]
        if campo.secreto and not str(valor or "").strip():
            continue
        validados[nombre] = _validar(campo, str(valor if valor is not None else ""))
    for nombre, valor in validados.items():
        campo = CAMPOS_POR_NOMBRE[nombre]
        ConfiguracionIntegracion.objects.update_or_create(
            nombre=nombre,
            defaults={
                "valor": _fernet().encrypt(valor.encode()).decode() if campo.secreto else valor,
                "secreto": campo.secreto,
                "actualizado_por": usuario,
            },
        )
    ConfiguracionIntegracion.objects.filter(nombre__in=restablecer).delete()
    invalidar()
    logger.info("Configuración actualizada por %s: %s", usuario, ", ".join([*validados, *restablecer]) or "-")
