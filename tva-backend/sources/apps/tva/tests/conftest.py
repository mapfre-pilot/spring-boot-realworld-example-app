import jwt
import pytest
from django.conf import settings
from django.utils import timezone
from datetime import timedelta


def make_token(sub: str = "tester", roles: list[str] | None = None) -> str:
    now = timezone.now()
    return jwt.encode(
        {
            "sub": sub,
            "roles": roles if roles is not None else ["TVA_USUARIO"],
            "iat": int(now.timestamp()),
            "exp": int((now + timedelta(hours=1)).timestamp()),
        },
        settings.SECRET_KEY,
        algorithm="HS256",
    )


@pytest.fixture
def auth_header() -> dict:
    return {"HTTP_AUTHORIZATION": f"Bearer {make_token()}"}


@pytest.fixture
def admin_header() -> dict:
    return {"HTTP_AUTHORIZATION": f"Bearer {make_token('admin', ['TVA_USUARIO', 'TVA_ADMIN_PORTAL'])}"}


@pytest.fixture
def api_client(db):
    from rest_framework.test import APIClient

    return APIClient()
