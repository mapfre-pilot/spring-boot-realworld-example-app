"""JWTAuthentication unificada: despacho por `alg` (HS256 local / RS256 OIDC)."""

from types import SimpleNamespace
from unittest.mock import MagicMock

import jwt
import pytest
from cryptography.hazmat.primitives.asymmetric import rsa
from django.test import override_settings
from rest_framework import exceptions

from apps.core import auth as auth_mod
from apps.core.auth import JWTAuthentication
from apps.tva.tests.conftest import make_token

BASE = "/api/tva/v1"


def _request(token: str):
    from rest_framework.test import APIRequestFactory

    return APIRequestFactory().get("/x", HTTP_AUTHORIZATION=f"Bearer {token}")


def _rs256_token(private_key, **claims) -> str:
    payload = {
        "iss": "https://login.microsoftonline.com/tenant/v2.0",
        "aud": "client-id",
        "exp": 9999999999,
        "iat": 1700000000,
        **claims,
    }
    return jwt.encode(payload, private_key, algorithm="RS256")


@pytest.fixture
def rsa_pair():
    return rsa.generate_private_key(public_exponent=65537, key_size=2048)


@pytest.fixture
def jwks_mock(monkeypatch, rsa_pair):
    """Devuelve la clave pública RSA del test como si viniera del JWKS."""
    client = MagicMock()
    client.get_signing_key_from_jwt.return_value = SimpleNamespace(key=rsa_pair.public_key())
    monkeypatch.setattr(auth_mod, "_jwks_client", client)
    yield
    monkeypatch.setattr(auth_mod, "_jwks_client", None)


def test_hs256_en_local_ok(api_client, auth_header):
    r = api_client.get(f"{BASE}/productos/", **auth_header)
    assert r.status_code == 200


def test_hs256_rechazado_fuera_de_local():
    with override_settings(LOCAL_ENVIRONMENT=False):
        with pytest.raises(exceptions.AuthenticationFailed):
            JWTAuthentication().authenticate(_request(make_token()))


def test_rs256_oidc_ok_aud_lista_preferred_username_y_default_roles(jwks_mock, rsa_pair):
    token = _rs256_token(
        rsa_pair,
        sub="opaque-sub",
        preferred_username="operador1@mapfre.net",
        aud="api://client-id",
    )
    with override_settings(
        OAUTH_AUDIENCE=["client-id", "api://client-id"],
        OAUTH_ISSUER="https://login.microsoftonline.com/tenant/v2.0",
        OAUTH_DEFAULT_ROLES=["TVA_USUARIO", "TVA_ADMIN_PORTAL"],
        OAUTH_JWKS_URI="https://jwks.test/keys",
    ):
        user, _ = JWTAuthentication().authenticate(_request(token))
    assert user.sub == "operador1@mapfre.net"
    assert user.roles == ["TVA_USUARIO", "TVA_ADMIN_PORTAL"]


def test_rs256_roles_del_claim_tienen_prioridad(jwks_mock, rsa_pair):
    token = _rs256_token(rsa_pair, sub="x", roles=["TVA_DEBUG"])
    with override_settings(
        OAUTH_AUDIENCE=["client-id"],
        OAUTH_ISSUER="https://login.microsoftonline.com/tenant/v2.0",
        OAUTH_DEFAULT_ROLES=["TVA_USUARIO"],
        OAUTH_JWKS_URI="https://jwks.test/keys",
    ):
        user, _ = JWTAuthentication().authenticate(_request(token))
    assert user.roles == ["TVA_DEBUG"]
    assert user.sub == "x"


def test_rs256_sub_fallback_upn_oid(jwks_mock, rsa_pair):
    token = _rs256_token(rsa_pair, upn="u@mapfre.net")
    with override_settings(
        OAUTH_AUDIENCE=["client-id"],
        OAUTH_ISSUER="https://login.microsoftonline.com/tenant/v2.0",
        OAUTH_JWKS_URI="https://jwks.test/keys",
    ):
        user, _ = JWTAuthentication().authenticate(_request(token))
    assert user.sub == "u@mapfre.net"


def test_alg_desconocido_401(api_client):
    token = jwt.encode({"sub": "x", "exp": 9999999999}, None, algorithm="none")
    r = api_client.get(f"{BASE}/productos/", HTTP_AUTHORIZATION=f"Bearer {token}")
    assert r.status_code in (401, 403)


def test_salud_informa_auth(api_client):
    r = api_client.get(f"{BASE}/salud/")
    assert r.status_code == 200
    assert r.json()["auth"] == {"local": True, "oidc": False}
