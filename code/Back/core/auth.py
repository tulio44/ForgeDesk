import base64
import hashlib
import hmac
import json
import os
import time


AUTH_SECRET = os.getenv("AUTH_SECRET", "forgedesk-dev-secret")
TOKEN_TTL_SECONDS = int(os.getenv("TOKEN_TTL_SECONDS", "86400"))

DEMO_USERS = {
    "cliente@forgedesk.com": {
        "id": 1,
        "nome": "Cliente Demo",
        "senha": "123456"
    }
}


def autenticar_usuario(email, senha):
    usuario = DEMO_USERS.get(email)

    if not usuario or usuario["senha"] != senha:
        return None

    return {
        "id": usuario["id"],
        "nome": usuario["nome"],
        "email": email
    }


def criar_token(usuario):
    header = {"alg": "HS256", "typ": "JWT"}
    payload = {
        "sub": usuario["id"],
        "nome": usuario["nome"],
        "email": usuario["email"],
        "exp": int(time.time()) + TOKEN_TTL_SECONDS
    }

    encoded_header = _base64url_encode(json.dumps(header).encode("utf-8"))
    encoded_payload = _base64url_encode(json.dumps(payload).encode("utf-8"))
    assinatura = _assinar(f"{encoded_header}.{encoded_payload}")

    return f"{encoded_header}.{encoded_payload}.{assinatura}"


def validar_token(token):
    try:
        encoded_header, encoded_payload, assinatura = token.split(".")
    except ValueError:
        return None

    conteudo_assinado = f"{encoded_header}.{encoded_payload}"
    assinatura_esperada = _assinar(conteudo_assinado)

    if not hmac.compare_digest(assinatura, assinatura_esperada):
        return None

    try:
        payload = json.loads(_base64url_decode(encoded_payload))
    except (ValueError, json.JSONDecodeError):
        return None

    if payload.get("exp", 0) < int(time.time()):
        return None

    return payload


def _assinar(valor):
    digest = hmac.new(
        AUTH_SECRET.encode("utf-8"),
        valor.encode("utf-8"),
        hashlib.sha256
    ).digest()

    return _base64url_encode(digest)


def _base64url_encode(valor):
    return base64.urlsafe_b64encode(valor).decode("utf-8").rstrip("=")


def _base64url_decode(valor):
    padding = "=" * (-len(valor) % 4)
    return base64.urlsafe_b64decode(valor + padding).decode("utf-8")
