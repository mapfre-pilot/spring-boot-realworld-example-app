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
#   JWTAuthentication despacha por `alg`: HS256 solo en LOCAL_ENVIRONMENT
#   (crear_token_local), RS256 contra el JWKS OIDC configurado abajo.
_AUTH_CLASSES = ("apps.core.auth.JWTAuthentication",)

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
# Fuera de local, sin variables se usa la App Registration EntraID de TVA.
_ENTRAID_TENANT = "93ad25dd-8cdc-4066-9727-31a8a3024f80"
_ENTRAID_CLIENT_ID = "86cc156f-a83e-4c72-bd33-bcaca9ef9545"
_OAUTH_DEFAULTS = (
    {}
    if LOCAL_ENVIRONMENT
    else {
        "OAUTH_JWKS_URI": f"https://login.microsoftonline.com/{_ENTRAID_TENANT}/discovery/v2.0/keys",
        "OAUTH_AUDIENCE": f"{_ENTRAID_CLIENT_ID},api://{_ENTRAID_CLIENT_ID}",
        "OAUTH_ISSUER": f"https://login.microsoftonline.com/{_ENTRAID_TENANT}/v2.0",
        "OAUTH_DEFAULT_ROLES": "TVA_USUARIO",
    }
)
OAUTH_JWKS_URI = os.environ.get("OAUTH_JWKS_URI", _OAUTH_DEFAULTS.get("OAUTH_JWKS_URI", ""))
# Audiencias admitidas separadas por comas (EntraID emite aud=client_id en v2
# o aud=api://<client_id> en v1).
OAUTH_AUDIENCE = [s.strip() for s in os.environ.get("OAUTH_AUDIENCE", _OAUTH_DEFAULTS.get("OAUTH_AUDIENCE", "")).split(",") if s.strip()]
OAUTH_ISSUER = os.environ.get("OAUTH_ISSUER", _OAUTH_DEFAULTS.get("OAUTH_ISSUER", ""))
OAUTH_JWKS_CACHE_TTL = int(os.environ.get("OAUTH_JWKS_CACHE_TTL", "3600"))
# Roles aplicados cuando el token OIDC no trae claim `roles`.
OAUTH_DEFAULT_ROLES = [
    s.strip() for s in os.environ.get("OAUTH_DEFAULT_ROLES", _OAUTH_DEFAULTS.get("OAUTH_DEFAULT_ROLES", "")).split(",") if s.strip()
]

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
            "OPTIONS": {"timeout": 20},
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

# TVA — arranque: migraciones + parámetros al cargar el WSGI (apps/tva/bootstrap.py)
TVA_AUTO_MIGRATE = evaluate_bool("TVA_AUTO_MIGRATE")

# TVA — conectores externos. Valores por entorno (ver .env.sample); Administración
# → Configuración puede sobrescribirlos en BD (apps/tva/services/configuracion.py).
# Clave de cifrado de los secretos guardados en BD (por defecto deriva de SECRET_KEY).
TVA_CONFIG_KEY = os.environ.get("TVA_CONFIG_KEY", "")
# -------------------------------------------------------------
APILIFE_MODE = os.environ.get("APILIFE_MODE", "mock")  # mock | real
APILIFE_BASE_URL = os.environ.get("APILIFE_BASE_URL", "")
APILIFE_USERNAME = os.environ.get("APILIFE_USERNAME", "")
APILIFE_PASSWORD = os.environ.get("APILIFE_PASSWORD", "")
APILIFE_TIMEOUT = int(os.environ.get("APILIFE_TIMEOUT", "30"))
# Credenciales del connected system "TVA API Life APPINVE" (fallback a las principales)
APILIFE_APPINVE_USERNAME = os.environ.get("APILIFE_APPINVE_USERNAME", "")
APILIFE_APPINVE_PASSWORD = os.environ.get("APILIFE_APPINVE_PASSWORD", "")
# Cross-app: cons!CMP_VAL_TRADUCCION_ES / cons!TVA_ACRONIMO_APLICACION
APILIFE_ACCEPT_LANGUAGE = os.environ.get("APILIFE_ACCEPT_LANGUAGE", "es")
APILIFE_APPLICATION_ID = os.environ.get("APILIFE_APPLICATION_ID", "TVA")
MISV_BASE_URL = os.environ.get("MISV_BASE_URL", "")
MISV_MODE = os.environ.get("MISV_MODE", "mock")
MISV_USERNAME = os.environ.get("MISV_USERNAME", "")
MISV_PASSWORD = os.environ.get("MISV_PASSWORD", "")
MISV_TIMEOUT = int(os.environ.get("MISV_TIMEOUT", "20"))
# Cross-app: cons!VIDA_ACRONIMO_APLICACION / cons!VIDA_CODIGOS_TIPO_PERSONA_FISICA
MISV_APLICACION = os.environ.get("MISV_APLICACION", "VIDA")
MISV_TIPO_PERSONA = os.environ.get("MISV_TIPO_PERSONA", "F")
RIC_BASE_URL = os.environ.get("RIC_BASE_URL", "")
RIC_MODE = os.environ.get("RIC_MODE", "mock")
RIC_PATH = os.environ.get("RIC_PATH", "personas")
RIC_USERNAME = os.environ.get("RIC_USERNAME", "")
RIC_PASSWORD = os.environ.get("RIC_PASSWORD", "")
RIC_TIMEOUT = int(os.environ.get("RIC_TIMEOUT", "30"))
PERFIL_USUARIO_MODE = os.environ.get("PERFIL_USUARIO_MODE", "mock")
# SOAP TVA_WSDL_IGestionarPerfilUsuario hacia SOA7 (WSSE UsernameToken, usuario APPRIMO)
SOA_BASE_URL = os.environ.get("SOA_BASE_URL", "")
SOA_USERNAME = os.environ.get("SOA_USERNAME", "")
SOA_PASSWORD = os.environ.get("SOA_PASSWORD", "")
SOA_TIMEOUT = int(os.environ.get("SOA_TIMEOUT", "10"))
APPIAN_EMBED_BASE_URL = os.environ.get("APPIAN_EMBED_BASE_URL", "https://mapfrespain-test.appiancloud.com/suite")
APPIAN_EMBED_API_KEY = os.environ.get("APPIAN_EMBED_API_KEY", "")
APPIAN_EMBED_MODE = os.environ.get("APPIAN_EMBED_MODE", "mock")  # mock | real
APPIAN_EMBED_TIMEOUT = int(os.environ.get("APPIAN_EMBED_TIMEOUT", "30"))
APPIAN_EMBED_EMAIL_AVISOS = os.environ.get("APPIAN_EMBED_EMAIL_AVISOS", "")
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
            "level": "DEBUG" if os.getenv("SQL_DEBUG") == "True" else "WARNING",
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
# Regex de orígenes adicionales (por defecto, cualquier host https de la plataforma AWS MAPFRE).
CORS_ALLOWED_ORIGIN_REGEXES = [
    r.strip() for r in os.getenv("CORS_ALLOWED_ORIGIN_REGEXES", r"^https://[\w.-]+\.plataforma\.aws\.mapfre\.net$").split(",") if r.strip()
]
