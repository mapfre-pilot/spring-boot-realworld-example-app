"""Helpers de autorización por roles (claims JWT → TokenUser.roles)."""

from apps.tva.models import Sesion

ROLE_USUARIO = "TVA_USUARIO"
ROLE_ADMIN_PORTAL = "TVA_ADMIN_PORTAL"
ROLE_DEBUG = "TVA_DEBUG"


def es_admin(user) -> bool:
    return bool(getattr(user, "roles", []) and ROLE_ADMIN_PORTAL in user.roles)


def puede_ver_sesion(user, sesion: Sesion) -> bool:
    """El dueño de la sesión o un admin del portal."""
    return es_admin(user) or sesion.usuario == getattr(user, "sub", "")
