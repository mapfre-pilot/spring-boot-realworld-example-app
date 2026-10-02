"""Cache stub replacing ``arch-ram-lib-django-rediscache``.

Responsabilidad: alias sobre la caché de Django (Redis en despliegue,
LocMem en local) y un decorador TTL para cachear resultados de
integraciones/catálogos.

Swap: sustituir ``cached``/``invalidate_prefix`` por los helpers de la
librería corporativa sin tocar a los consumidores.
"""

import functools
import hashlib
import json
from typing import Any, Callable

from django.core.cache import cache, caches


def get_cache(alias: str = "default"):
    """Devuelve el alias de caché de Django."""
    return caches[alias]


def cached(prefix: str, timeout: int | None = None) -> Callable:
    """Decorador TTL: cachea el resultado JSON-serializable de la función.

    La clave se deriva de ``prefix`` + argumentos (kwargs/args serializados).
    """

    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args: Any, **kwargs: Any) -> Any:
            raw = json.dumps({"a": args, "k": kwargs}, sort_keys=True, default=str)
            key = f"{prefix}:{hashlib.sha256(raw.encode()).hexdigest()[:32]}"
            hit = cache.get(key)
            if hit is not None:
                return hit
            value = func(*args, **kwargs)
            cache.set(key, value, timeout)
            return value

        return wrapper

    return decorator


def invalidate_prefix(prefix: str) -> int:
    """Invalida claves por prefijo (soportado por django-redis)."""
    deleted = cache.delete_pattern(f"{prefix}:*") if hasattr(cache, "delete_pattern") else 0
    return int(deleted or 0)
