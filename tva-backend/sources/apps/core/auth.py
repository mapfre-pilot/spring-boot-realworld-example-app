"""Authentication stubs replacing ``arch-ram-lib-django-auth``.

Responsabilidad de la librería corporativa: autenticar peticiones con
JWT emitido por el IdP corporativo (OIDC) y exponer usuario + roles.

Implementación local:

- ``ENVIRONMENT=local`` → ``LocalJWTAuthentication`` valida tokens HS256
  firmados con ``SECRET_KEY`` (se generan con ``manage.py crear_token_local``).
- Resto de entornos → ``OIDCJWTAuthentication`` valida tokens RS256
  contra el JWKS del IdP (``OAUTH_JWKS_URI``, ``OAUTH_AUDIENCE``,
  ``OAUTH_ISSUER``) usando PyJWT[crypto].

Roles esperados en el claim ``roles`` (lista): ``TVA_USUARIO``,
``TVA_ADMIN_PORTAL``, ``TVA_DEBUG``.

Swap: sustituir ambas clases por la clase de autenticación de
``arch-ram-lib-django-auth`` y eliminar ``LocalJWTAuthentication`` de
``REST_FRAMEWORK['DEFAULT_AUTHENTICATION_CLASSES']`` en settings.
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
        _jwks_client = PyJWKClient(settings.OAUTH_JWKS_URI, cache_keys=True)
    signing_key = _jwks_client.get_signing_key_from_jwt(token)
    return jwt.decode(
        token,
        signing_key.key,
        algorithms=["RS256"],
        audience=settings.OAUTH_AUDIENCE or None,
        issuer=settings.OAUTH_ISSUER or None,
        options={"verify_aud": bool(settings.OAUTH_AUDIENCE), "verify_iss": bool(settings.OAUTH_ISSUER)},
    )


class _BaseJWTAuthentication(authentication.BaseAuthentication):
    """Extrae y valida el bearer token, devolviendo un TokenUser."""

    def decode(self, token: str) -> dict:  # pragma: no cover - interface
        raise NotImplementedError

    def authenticate(self, request):
        header = authentication.get_authorization_header(request).decode()
        if not header.startswith("Bearer "):
            return None
        token = header.removeprefix("Bearer ").strip()
        try:
            claims = self.decode(token)
        except exceptions.AuthenticationFailed:
            raise
        except Exception as exc:
            logger.warning("JWT inválido: %s", exc)
            raise exceptions.AuthenticationFailed("Token inválido o expirado") from exc
        roles = claims.get("roles") or claims.get("role") or []
        if isinstance(roles, str):
            roles = [roles]
        user = TokenUser(sub=str(claims.get("sub") or claims.get("oid") or ""), roles=list(roles), claims=claims)
        return (user, token)


class LocalJWTAuthentication(_BaseJWTAuthentication):
    """HS256 con SECRET_KEY — solo para ENVIRONMENT=local."""

    def decode(self, token: str) -> dict:
        return _decode_hs256(token)


class OIDCJWTAuthentication(_BaseJWTAuthentication):
    """RS256 contra el JWKS OIDC corporativo."""

    def decode(self, token: str) -> dict:
        return _decode_rs256(token)
