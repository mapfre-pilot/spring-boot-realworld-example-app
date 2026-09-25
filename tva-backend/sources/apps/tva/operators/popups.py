"""Pop-ups Appian del panel de requisitos del tomador (RGPD, DNI, test conveniencia)."""

import logging
from datetime import date, datetime

from django.conf import settings

from apps.tva.models import Sesion
from apps.tva.schemas.errors import AvisosClase
from apps.tva.services.connectors.appian_embed import POPUPS, AppianEmbedError, get_appian_embed_client

from ._comun import add_aviso, guardar_y_trazar, resultado

logger = logging.getLogger(__name__)

_ETIQUETA = {"rgpd": "Consentimiento RGPD", "dni": "Digitalizar NIF/NIE", "test-conveniencia": "Realizar test de conveniencia"}


def _tipo_documento(doc: str) -> str:
    d = doc.strip().upper()
    return "NIE" if d[:1] in ("X", "Y", "Z") else "NIF"


def _username_appian(perfil: dict, sub: str) -> str:
    """Username Appian: perfil.username si es email, si no nuuma/sub@mapfre.net."""
    username = str(perfil.get("username") or "")
    if "@" not in username:
        username = f"{perfil.get('nuuma') or sub}@mapfre.net"
    if not username.lower().endswith("@mapfre.net"):
        username = f"{username.split('@')[0]}@mapfre.net"
    return username


def _contacto(tomador: dict) -> tuple[str, str, str]:
    """email, telefono (sin prefijo) y telefono con prefijo de mediosContacto."""
    medios = tomador.get("mediosContacto") or []
    email = next((str(m.get("contactMethodValue") or "") for m in medios if m.get("tipo") == "EMAIL"), "")
    tel = next((m for m in medios if m.get("tipo") != "EMAIL"), {})
    numero = str(tel.get("numero") or "")
    completo = f"{tel.get('prefijo') or ''}{numero}" if numero else ""
    return email, numero, completo


def construir_body(sesion: Sesion, popup: str, idx_tomador: int, user) -> dict:
    """Body JSON de la Web API Appian a partir del estado de la sesión."""
    if popup not in POPUPS:
        raise ValueError(f"Pop-up desconocido: {popup}")
    estado = sesion.estado or {}
    tomadores = estado.get("tomadores") or []
    if idx_tomador >= len(tomadores):
        raise ValueError(f"Tomador {idx_tomador + 1} no existe en la sesión")
    t = tomadores[idx_tomador]
    dp = t.get("datosPersonales") or {}
    for campo in ("nombre", "primerApellido", "fechaNacimiento", "documentId"):
        if not dp.get(campo):
            raise ValueError(f"Faltan datos del tomador: {campo}")
    perfil = estado.get("perfilUsuario") or {}
    sub = getattr(user, "sub", "") or ""
    username = _username_appian(perfil, sub)
    doc = str(dp.get("documentId")).upper()
    email, telefono, tel_completo = _contacto(t)
    client_id = str((t.get("datosGestionParticipante") or {}).get("datosRIC", {}).get("clientId") or "")
    avisos_email = settings.APPIAN_EMBED_EMAIL_AVISOS or f"{sub}@mapfre.com"

    if popup == "rgpd":
        return {
            "usuarioAppian": username,
            "codCia": "90",
            "codigoRamo": estado.get("codigoRamo") or "700",
            "proceso": "RGPD-CLI" if client_id and client_id != "0" else "RGPD-POT",
            "aplicacion": "TVA",
            "entidad": "0003",
            "clienteID": client_id or "",
            "nuuma": perfil.get("nuuma") or "",
            "idioma": "es_ES",
            "nombre": dp.get("nombre"),
            "apellidoUno": dp.get("primerApellido"),
            "apellidoDos": dp.get("segundoApellido") or "",
            "documentoIdentidad": doc,
            "tipoDocumento": _tipo_documento(doc),
            "email": email,
            "telefono": telefono,
            "codigoClausula": "FAC-POT",
            "codConsentimiento": "ES",
            "nivel": "1",
            "txttEntidad": "00",
        }
    if popup == "dni":
        return {
            "usuarioAppian": username,
            "solicitante": "TVA",
            "numeroDNINIE": doc,
            "entidad": "0003",
            "aplicativo": "TVA",
            "referencia": f"{doc}-{datetime.now():%Y%m%d%H%M%S}",
            "datos": "",
            "emailCliente": email,
            "telefonoCliente": telefono,
            "esCliente": "true" if client_id else "false",
            "idRic": client_id or "",
            "nombre": dp.get("nombre"),
            "apellidos": f"{dp.get('primerApellido') or ''} {dp.get('segundoApellido') or ''}".strip(),
            "emailOK": avisos_email,
            "emailKO": avisos_email,
            "emailWarning": avisos_email,
            "tipoEnvio": "EMAIL",
        }
    return {
        "username": username,
        "NIF": doc,
        "nombre": dp.get("nombre"),
        "apellido1": dp.get("primerApellido"),
        "apellido2": dp.get("segundoApellido") or "",
        "email": email,
        "telefono": tel_completo,
        "tipoPersona": "F",
        "tipoTest": "TC",
        "aplicacion": "VIDA",
    }


def lanzar_popup(sesion: Sesion, popup: str, idx_tomador: int, user) -> dict:
    """Llama a la Web API Appian y devuelve ``taskId``/``taskUrl``."""
    body = construir_body(sesion, popup, idx_tomador, user)
    res = get_appian_embed_client().lanzar(popup, body)
    guardar_y_trazar(sesion, f"POPUP_{popup.upper().replace('-', '_')}_LANZAR", datos={"taskId": res["taskId"], "idxTomador": idx_tomador})
    return {
        "popup": popup,
        "idxTomador": idx_tomador,
        "taskId": res["taskId"],
        "taskUrl": res["taskUrl"],
        "modo": settings.APPIAN_EMBED_MODE,
    }


def evaluar_respuesta(popup: str, respuesta: dict | None) -> tuple[str, dict | None]:
    """Deriva el resultado real del pop-up a partir de la respuesta CMP.

    Devuelve ``(resultado_final, respuesta)`` con resultado_final en
    ``{"SUBMIT", "DISMISS", "ERROR"}``. La respuesta de Appian es one-shot, así
    que el caller debe persistirla (``respuestasComponentes``).
    """
    if popup in ("rgpd", "dni"):
        if respuesta is None or respuesta.get("error") is True:
            return "ERROR", respuesta
        accion = respuesta.get("accion")
        if accion == "cancelado":
            return "DISMISS", respuesta
        if (popup == "rgpd" and accion == "enviado") or (popup == "dni" and accion in ("digitalizacion", "movilidad")):
            return "SUBMIT", respuesta
        return "ERROR", respuesta
    # test-conveniencia: puede no existir respuesta CMP almacenada
    if respuesta is None:
        return "SUBMIT", respuesta
    if respuesta.get("error") is True:
        return "ERROR", respuesta
    if respuesta.get("accion") == "cancelado":
        return "DISMISS", respuesta
    return "SUBMIT", respuesta


def completar_popup(
    sesion: Sesion,
    popup: str,
    idx_tomador: int,
    task_id: str,
    resultado_pop: str,
    roles: list[str] | None = None,
    user=None,
) -> dict:
    """Aplica el resultado del pop-up a la sesión.

    Si el frontend reporta SUBMIT no se confía en el evento: se consulta la Web
    API "CMP Devolver Respuesta Componente" (one-shot) y se deriva el resultado
    real con :func:`evaluar_respuesta`.
    """
    if popup not in POPUPS:
        raise ValueError(f"Pop-up desconocido: {popup}")
    estado = sesion.estado or {}
    tomadores = estado.get("tomadores") or []
    if idx_tomador >= len(tomadores):
        raise ValueError(f"Tomador {idx_tomador + 1} no existe en la sesión")
    res = resultado_pop.upper()
    respuesta: dict | None = None
    error_comprobacion = False
    if res == "SUBMIT":
        perfil = estado.get("perfilUsuario") or {}
        usuario_appian = _username_appian(perfil, getattr(user, "sub", "") or "")
        try:
            respuesta = get_appian_embed_client().respuesta(usuario_appian, task_id)
        except AppianEmbedError:
            logger.warning("No se pudo comprobar la respuesta del pop-up %s (%s)", popup, task_id)
            respuesta = None
            error_comprobacion = True
        res, respuesta = evaluar_respuesta(popup, respuesta)
        if error_comprobacion:
            res = "ERROR"
    if res == "SUBMIT":
        t = dict(tomadores[idx_tomador])
        gestion = {**(t.get("datosGestionParticipante") or {})}
        if popup == "rgpd":
            gestion["consentimientoProteccionDatos"] = True
        elif popup == "dni":
            gestion["documentoIdDigitalizado"] = True
        else:
            gestion["testConvenienciaVigente"] = True
            perfil = {**(t.get("perfilCliente") or {})}
            perfil["testConveniencia"] = {"estado": "FIRMADO", "fecha": date.today().isoformat()}
            t["perfilCliente"] = perfil
        t["datosGestionParticipante"] = gestion
        tomadores = [dict(x) for x in tomadores]
        tomadores[idx_tomador] = t
        sesion.estado = {**estado, "tomadores": tomadores}
    elif res == "ERROR":
        mensaje = (
            f"No se ha podido comprobar el resultado de {_ETIQUETA[popup]}"
            if error_comprobacion
            else f"No se ha podido completar {_ETIQUETA[popup]}"
        )
        add_aviso(
            sesion,
            AvisosClase.GENERAL,
            f"TVA_ERROR_POPUP_{popup.upper().replace('-', '_')}",
            mensaje,
            tipo="ERROR",
        )
    # Persistir la respuesta one-shot recuperada de Appian (aunque sea None).
    if resultado_pop.upper() == "SUBMIT":
        estado = sesion.estado or {}
        tomadores = estado.get("tomadores") or []
        t = dict(tomadores[idx_tomador])
        gestion = {**(t.get("datosGestionParticipante") or {})}
        respuestas = {**(gestion.get("respuestasComponentes") or {})}
        respuestas[popup] = {"taskId": task_id, "resultado": res, "respuesta": respuesta}
        gestion["respuestasComponentes"] = respuestas
        t["datosGestionParticipante"] = gestion
        tomadores = [dict(x) for x in tomadores]
        tomadores[idx_tomador] = t
        sesion.estado = {**estado, "tomadores": tomadores}
    guardar_y_trazar(
        sesion,
        f"POPUP_{popup.upper().replace('-', '_')}_{res}",
        datos={"taskId": task_id, "idxTomador": idx_tomador, "resultado": res, "respuesta": respuesta},
    )
    return resultado(sesion, roles=roles)
