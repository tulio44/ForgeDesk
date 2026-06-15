from flask import Blueprint, jsonify, request

from core.auth import autenticar_usuario, criar_token


auth_bp = Blueprint("auth", __name__, url_prefix="/auth")


@auth_bp.post("/login")
def login():
    data = request.get_json() or {}

    email = data.get("email")
    senha = data.get("senha")

    if not email or not senha:
        return jsonify({"erro": "E-mail e senha são obrigatórios."}), 400

    usuario = autenticar_usuario(email, senha)
    if not usuario:
        return jsonify({"erro": "Credenciais inválidas."}), 401

    return jsonify({
        "token": criar_token(usuario),
        "usuario": usuario
    }), 200
