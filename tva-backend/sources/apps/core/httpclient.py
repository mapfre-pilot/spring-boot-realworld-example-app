"""HTTP client stub replacing ``arch-ram-lib-django-httpclient``.

Responsabilidad: cliente HTTP corporativo con timeouts, reintentos y
autenticación (básica o bearer) con credenciales solo por entorno.

Swap: sustituir ``BaseHttpClient`` por la clase base de la librería
corporativa manteniendo la misma interfaz ``get/post/put``.
"""

import logging
from typing import Any

import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

logger = logging.getLogger(__name__)


class BaseHttpClient:
    """Cliente HTTP con requests.Session, timeout, reintentos y auth."""

    def __init__(
        self,
        base_url: str,
        timeout: int = 30,
        retries: int = 3,
        username: str = "",
        password: str = "",
        bearer_token: str = "",
    ) -> None:
        self.base_url = base_url.rstrip("/")
        self.timeout = timeout
        self.session = requests.Session()
        retry = Retry(total=retries, backoff_factor=0.5, status_forcelist=(500, 502, 503, 504))
        self.session.mount("https://", HTTPAdapter(max_retries=retry))
        self.session.mount("http://", HTTPAdapter(max_retries=retry))
        if bearer_token:
            self.session.headers["Authorization"] = f"Bearer {bearer_token}"
        elif username:
            self.session.auth = (username, password)

    def _url(self, path: str) -> str:
        return f"{self.base_url}/{path.lstrip('/')}"

    def get(self, path: str, **kwargs: Any) -> requests.Response:
        kwargs.setdefault("timeout", self.timeout)
        response = self.session.get(self._url(path), **kwargs)
        response.raise_for_status()
        return response

    def post(self, path: str, **kwargs: Any) -> requests.Response:
        kwargs.setdefault("timeout", self.timeout)
        response = self.session.post(self._url(path), **kwargs)
        response.raise_for_status()
        return response

    def put(self, path: str, **kwargs: Any) -> requests.Response:
        kwargs.setdefault("timeout", self.timeout)
        response = self.session.put(self._url(path), **kwargs)
        response.raise_for_status()
        return response
