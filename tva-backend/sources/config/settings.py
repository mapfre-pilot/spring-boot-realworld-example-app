import json
import os
from pathlib import Path


def evaluate_bool(varname: str) -> bool:
    """
    Evaluates whether the value of an environment variable is considered truthy.

    The function interprets common false-like values such as:
    "", "0", "false", "no", "off", "none", "[]", "()" (case-insensitive, stripped).

    Additionally, if the value is numeric, it is considered falsy if equal to zero.

    Args:
        varname (str): The name of the environment variable.

    Returns:
        bool: True if the variable is considered truthy, False otherwise.
    """
    value = os.environ.get(varname, "False").strip().lower()
    if value in {"", "0", "false", "f", "no", "n", "off", "none", "[]", "()"}:
        return False
    try:
        return float(value) != 0
    except ValueError:
        return True


def evaluate_dict(varname: str) -> dict:
    """
    Evaluates a dictionary from a string environment variable.

    The function attempts to parse the value of the environment variable as JSON.
    If parsing fails, it returns an empty dictionary.

    Args:
        varname (str): The name of the environment variable.
    Returns:
        dict: The parsed dictionary, or an empty dictionary if parsing fails.
    """
    value = os.environ.get(varname, "{}").strip()
    try:
        return json.loads(value)
    except json.JSONDecodeError:
        return {}


# GENERAL CONFIGURATION
# -------------------------------------------------------------
# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

# NAMING CONFIGURATION
# -------------------------------------------------------------
ENVIRONMENT = os.environ.get("ENVIRONMENT")
SERVICE_NAME = os.environ.get("SERVICE_NAME", "esp-appianesad-tva")
APPLICATION_NAME = os.environ.get("APPLICATION_NAME", "tva")

LOCAL_ENVIRONMENT = (ENVIRONMENT or "local").lower() == "local"

# SECURITY CONFIGURATION
# -------------------------------------------------------------
SECRET_KEY = os.environ.get("SECRET_KEY", "INSECURE")

DEBUG = evaluate_bool("DEBUG")

ALLOWED_HOSTS = os.environ.get("ALLOWED_HOSTS", "*").split(",")

# APPLICATION CONFIGURATION
# -------------------------------------------------------------
DJANGO_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
]

THIRD_PARTY_APPS = [
    # API
    "rest_framework",
    # Code First
    "drf_spectacular",
    "drf_spectacular_sidecar",
    "corsheaders",
]

LOCAL_APPS = [
    "apps.core",
    "apps.tva",
]

INSTALLED_APPS = DJANGO_APPS + THIRD_PARTY_APPS + LOCAL_APPS
if DEBUG:
    INSTALLED_APPS += ["django_extensions"]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "corsheaders.middleware.CorsMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
    # Stub de arch-ram-lib-django-observability: request-id + claveSesion
    "apps.core.observability.ObservabilityMiddleware",
]

ROOT_URLCONF = "config.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "config.wsgi.application"

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

# SECURITY AUTHENTICATION CONFIG
# -------------------------------------------------------------
# Stub de arch-ram-lib-django-auth (apps/core/auth.py):
#   - ENVIRONMENT=local     → simplejwt HS256 con SECRET_KEY (crear_token_local)
#   - resto de entornos     → RS256 contra el JWKS OIDC configurado abajo.
if LOCAL_ENVIRONMENT:
    _AUTH_CLASSES = ("apps.core.auth.LocalJWTAuthentication",)
else:
    _AUTH_CLASSES = ("apps.core.auth.OIDCJWTAuthentication",)

REST_FRAMEWORK = {
    "DEFAULT_SCHEMA_CLASS": "drf_spectacular.openapi.AutoSchema",
    "DEFAULT_RENDERER_CLASSES": ("rest_framework.renderers.JSONRenderer",),
    "DEFAULT_PERMISSION_CLASSES": ("rest_framework.permissions.IsAuthenticated",),
    "DEFAULT_AUTHENTICATION_CLASSES": _AUTH_CLASSES,
    "EXCEPTION_HANDLER": "rest_framework.views.exception_handler",
}

# JWT local (ENVIRONMENT=local)
SIMPLE_JWT = {
    "ALGORITHM": "HS256",
    "SIGNING_KEY": SECRET_KEY,
    "USER_ID_CLAIM": "sub",
}

# JWT OIDC (resto de entornos): token RS256 verificado contra el JWKS del IdP.
OAUTH_JWKS_URI = os.environ.get("OAUTH_JWKS_URI", "")
OAUTH_AUDIENCE = os.environ.get("OAUTH_AUDIENCE", "")
OAUTH_ISSUER = os.environ.get("OAUTH_ISSUER", "")
OAUTH_JWKS_CACHE_TTL = int(os.environ.get("OAUTH_JWKS_CACHE_TTL", "3600"))

# DATABASE CONFIGURATION
# -------------------------------------------------------------
# PostgreSQL en cualquier entorno con DB_HOST; sin DB_HOST se usa un sqlite
# local para poder arrancar/tests sin infraestructura.
if os.environ.get("DB_HOST"):
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.postgresql",
            "NAME": os.environ.get("DB_NAME", "tva"),
            "USER": os.environ.get("DB_USER", "tva"),
            "PASSWORD": os.environ.get("DB_PASSWORD", ""),
            "HOST": os.environ.get("DB_HOST", "localhost"),
            "PORT": os.environ.get("DB_PORT", "5432"),
        }
    }
else:
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.sqlite3",
            "NAME": os.environ.get("DB_SQLITE_PATH", str(BASE_DIR / "db.sqlite3")),
        }
    }

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# CACHE
# -------------------------------------------------------------
# Redis si REDIS_HOST está definido (stub de arch-ram-lib-django-rediscache);
# si no, caché local en memoria.
if os.environ.get("REDIS_HOST"):
    CACHES = {
        "default": {
            "BACKEND": "django_redis.cache.RedisCache",
            "LOCATION": f"redis://{os.environ.get('REDIS_HOST')}:{os.environ.get('REDIS_PORT', '6379')}/{os.environ.get('REDIS_DB', '0')}",
            "OPTIONS": {"CLIENT_CLASS": "django_redis.client.DefaultClient"},
            "TIMEOUT": int(os.environ.get("CACHE_DEFAULT_TIMEOUT", "300")),
        }
    }
else:
    CACHES = {
        "default": {
            "BACKEND": "django.core.cache.backends.locmem.LocMemCache",
            "LOCATION": "tva-local",
            "TIMEOUT": int(os.environ.get("CACHE_DEFAULT_TIMEOUT", "300")),
        }
    }
CACHE_DEFAULT_TIMEOUT = int(os.environ.get("CACHE_DEFAULT_TIMEOUT", "300"))
CACHE_OAUTH_TTL = int(os.environ.get("CACHE_OAUTH_TTL", "3600"))

# CELERY
# -------------------------------------------------------------
CELERY_BROKER_URL = os.environ.get(
    "CELERY_BROKER_URL", f"redis://{os.environ.get('REDIS_HOST', 'localhost')}:{os.environ.get('REDIS_PORT', '6379')}/1"
)
CELERY_RESULT_BACKEND = os.environ.get("CELERY_RESULT_BACKEND", CELERY_BROKER_URL)
CELERY_TASK_ALWAYS_EAGER = evaluate_bool("CELERY_TASK_ALWAYS_EAGER")

# TVA — conectores externos (valores solo por entorno, ver .env.sample)
# -------------------------------------------------------------
APILIFE_MODE = os.environ.get("APILIFE_MODE", "mock")  # mock | real
APILIFE_BASE_URL = os.environ.get("APILIFE_BASE_URL", "")
APILIFE_USERNAME = os.environ.get("APILIFE_USERNAME", "")
APILIFE_PASSWORD = os.environ.get("APILIFE_PASSWORD", "")
APILIFE_TIMEOUT = int(os.environ.get("APILIFE_TIMEOUT", "30"))
MISV_BASE_URL = os.environ.get("MISV_BASE_URL", "")
MISV_MODE = os.environ.get("MISV_MODE", "mock")
RIC_BASE_URL = os.environ.get("RIC_BASE_URL", "")
RIC_MODE = os.environ.get("RIC_MODE", "mock")
PERFIL_USUARIO_BASE_URL = os.environ.get("PERFIL_USUARIO_BASE_URL", "")
PERFIL_USUARIO_MODE = os.environ.get("PERFIL_USUARIO_MODE", "mock")
ALERTAS_EMAIL_TO = os.environ.get("ALERTAS_EMAIL_TO", "")
ALERTAS_EMAIL_FROM = os.environ.get("ALERTAS_EMAIL_FROM", "noReply@tva.local")

# INTERNATIONALIZATION CONFIGURATION
# -------------------------------------------------------------
LANGUAGE_CODE = "en-us"
TIME_ZONE = "UTC"
USE_I18N = True
USE_TZ = True

# MEDIA & STATIC CONFIGURATION
# -------------------------------------------------------------
STATIC_URL = "static/"
STATIC_ROOT = os.path.join(BASE_DIR, STATIC_URL)
MEDIA_URL = "media/"
MEDIA_ROOT = os.path.join(BASE_DIR, "media")

# CODE FIRST
# -------------------------------------------------------------
SPECTACULAR_SETTINGS = {
    "TITLE": "TVA — Tarificador Vida Ahorro",
    "DESCRIPTION": "API del tarificador de productos Vida Ahorro (migración de la aplicación Appian TVA).",
    "VERSION": "1.0.0",
    "SWAGGER_UI_DIST": "SIDECAR",
    "SWAGGER_UI_FAVICON_HREF": "SIDECAR",
    "REDOC_DIST": "SIDECAR",
}

# LOGGING
# -------------------------------------------------------------
LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        # Stub de arch-ram-lib-django-observability: formato JSON con request-id
        "json": {"()": "apps.core.observability.JsonFormatter"},
        "verbose": {"format": "[%(asctime)s] [%(name)s] [%(levelname)s] %(message)s"},
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "formatter": "json",
        },
        "null": {"class": "logging.NullHandler"},
    },
    "loggers": {
        "": {
            "handlers": ["console"],
            "level": os.getenv("LOGGER_LEVEL", "DEBUG" if DEBUG else "INFO"),
            "propagate": False,
        },
        "django": {
            "handlers": ["console" if DEBUG else "null"],
            "level": os.getenv("LOGGER_LEVEL", "DEBUG" if DEBUG else "INFO"),
        },
        "django.server": {
            "handlers": ["console" if DEBUG else "null"],
            "level": os.getenv("LOGGER_LEVEL", "DEBUG" if DEBUG else "INFO"),
            "propagate": False,
        },
        "django.db.backends": {
            "handlers": ["console" if DEBUG else "null"],
            "level": os.getenv("LOGGER_LEVEL", "DEBUG" if DEBUG else "INFO"),
            "propagate": False,
        },
        "django.utils.autoreload": {
            "handlers": ["console" if DEBUG else "null"],
            "level": os.getenv("LOGGER_LEVEL", "DEBUG" if DEBUG else "INFO"),
            "propagate": False,
        },
    },
}

# CORS — orígenes permitidos para el frontend Angular (coma-separados).
CORS_ALLOWED_ORIGINS = [o.strip() for o in os.getenv("CORS_ALLOWED_ORIGINS", "http://localhost:4200").split(",") if o.strip()]
