"""System checks TVA — configuración de conectores mock|real.

Si un ``*_MODE`` es ``real``, exige las variables mínimas del conector;
si el valor no es mock|real, error. Nunca imprime valores.
"""

from django.conf import settings
from django.core.checks import Error, Tags, register

_MODOS = ("mock", "real")

_REQUERIDAS = {
    "apilife": ("APILIFE_MODE", ("APILIFE_BASE_URL", "APILIFE_USERNAME", "APILIFE_PASSWORD")),
    "misv": ("MISV_MODE", ("MISV_BASE_URL", "MISV_USERNAME", "MISV_PASSWORD")),
    "perfil-usuario": ("PERFIL_USUARIO_MODE", ("SOA_BASE_URL", "SOA_USERNAME", "SOA_PASSWORD")),
    "ric": ("RIC_MODE", ("RIC_BASE_URL",)),
    "appian-embed": ("APPIAN_EMBED_MODE", ("APPIAN_EMBED_BASE_URL", "APPIAN_EMBED_API_KEY")),
}

_IDS = {"apilife": "tva.E001", "misv": "tva.E002", "perfil-usuario": "tva.E003", "ric": "tva.E004", "appian-embed": "tva.E005"}


@register(Tags.compatibility)
def chequeo_integraciones(app_configs=None, databases=None, **kwargs):
    errores = []
    for nombre, (var_mode, requeridas) in _REQUERIDAS.items():
        mode = getattr(settings, var_mode, "mock")
        check_id = _IDS[nombre]
        if mode not in _MODOS:
            errores.append(Error(f"{var_mode}={mode!r} inválido (esperado: mock|real)", id=f"{check_id}", obj="apps.tva"))
            continue
        if mode == "real":
            missing = [v for v in requeridas if not getattr(settings, v, "")]
            if missing:
                errores.append(
                    Error(
                        f"{nombre} en modo real sin configurar: {', '.join(missing)}",
                        id=check_id,
                        obj="apps.tva",
                    )
                )
    return errores
