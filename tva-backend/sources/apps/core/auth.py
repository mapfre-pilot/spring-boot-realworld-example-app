"""Authentication stubs replacing ``arch-ram-lib-django-auth``.

Responsabilidad de la librería corporativa: autenticar peticiones con
JWT emitido por el IdP corporativo (OIDC) y exponer usuario + roles.

Implementación local:

- ``JWTAuthentication`` despacha por el ``alg`` del token:
  - ``HS256`` → firma local con ``SECRET_KEY``; solo permitido si
    ``settings.LOCAL_ENVIRONMENT`` (tokens de ``crear_token_local``).
  - ``RS256`` → JWKS del IdP OIDC (``OAUTH_JWKS_URI``,
    ``OAUTH_AUDIENCE`` — lista separada por comas —, ``OAUTH_ISSUER``).

Roles esperados en el claim ``roles`` (lista): ``TVA_USUARIO``,
``TVA_ADMIN_PORTAL``, ``TVA_DEBUG``. Si el token no trae roles se aplican
``OAUTH_DEFAULT_ROLES``.

El ``sub`` del usuario es ``preferred_username`` → ``upn`` → ``sub`` →
``oid`` (en EntraID ``sub`` es opaco; las sesiones se asocian por ese
valor, igual que hace el frontend).

Swap: sustituir esta clase por la autenticación de
``arch-ram-lib-django-auth`` manteniendo ``LOCAL_ENVIRONMENT`` para los
tokens locales de desarrollo.
"""

import logging
from dataclasses import dataclass, field

import jwt
from django.conf import settings
from jwt import PyJWKClient
from rest_framework import authentication, exceptions

logger = logging.getLogger(__name__)


@dataclass
class TokenUser:
    """Usuario mínimo derivado del JWT (no hay modelo de usuario propio)."""

    sub: str
    roles: list[str] = field(default_factory=list)
    claims: dict = field(default_factory=dict)

    @property
    def is_authenticated(self) -> bool:
        return True

    def has_role(self, role: str) -> bool:
        return role in self.roles


def _decode_hs256(token: str) -> dict:
    return jwt.decode(
        token,
        settings.SECRET_KEY,
        algorithms=["HS256"],
        options={"verify_aud": False},
    )


_jwks_client: PyJWKClient | None = None


def _decode_rs256(token: str) -> dict:
    global _jwks_client
    if _jwks_client is None:
        if not settings.OAUTH_JWKS_URI:
            raise exceptions.AuthenticationFailed("OAUTH_JWKS_URI no configurado")
        _jwks_client = PyJWKClient(
            settings.OAUTH_JWKS_URI,
            cache_keys=True,
            lifespan=settings.OAUTH_JWKS_CACHE_TTL,
        )
    signing_key = _jwks_client.get_signing_key_from_jwt(token)
    audience = settings.OAUTH_AUDIENCE or None
    return jwt.decode(
        token,
        signing_key.key,
        algorithms=["RS256"],
        audience=audience,
        issuer=settings.OAUTH_ISSUER or None,
        options={"verify_aud": bool(audience), "verify_iss": bool(settings.OAUTH_ISSUER)},
    )


def _sub_de(claims: dict) -> str:
    return str(
        claims.get("preferred_username")
        or claims.get("upn")
        or claims.get("sub")
        or claims.get("oid")
        or ""
    )


def _roles_de(claims: dict) -> list[str]:
    roles = claims.get("roles") or claims.get("role") or settings.OAUTH_DEFAULT_ROLES
    if isinstance(roles, str):
        roles = [roles]
    return list(roles)


class JWTAuthentication(authentication.BaseAuthentication):
    """Autenticación unificada: despacha por ``alg`` del JWT (HS256 local / RS256 OIDC)."""

    def authenticate(self, request):
        header = authentication.get_authorization_header(request).decode()
        if not header.startswith("Bearer "):
            return None
        token = header.removeprefix("Bearer ").strip()
        try:
            alg = (jwt.get_unverified_header(token).get("alg") or "").upper()
            if alg == "HS256":
                if not settings.LOCAL_ENVIRONMENT:
                    raise exceptions.AuthenticationFailed(
                        "Tokens HS256 locales solo en ENVIRONMENT=local"
                    )
                claims = _decode_hs256(token)
            elif alg == "RS256":
                claims = _decode_rs256(token)
            else:
                raise exceptions.AuthenticationFailed(f"Algoritmo JWT no soportado: {alg or 'desconocido'}")
        except exceptions.AuthenticationFailed:
            raise
        except Exception as exc:
            logger.warning("JWT inválido: %s", exc)
            raise exceptions.AuthenticationFailed("Token inválido o expirado") from exc
        user = TokenUser(sub=_sub_de(claims), roles=_roles_de(claims), claims=claims)
        return (user, token)


# Alias finos por compatibilidad con imports existentes.
class LocalJWTAuthentication(JWTAuthentication):
    """HS256 con SECRET_KEY — solo para ENVIRONMENT=local."""


class OIDCJWTAuthentication(JWTAuthentication):
    """RS256 contra el JWKS OIDC corporativo."""
