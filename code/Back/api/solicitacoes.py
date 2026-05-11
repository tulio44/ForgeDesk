from flask import Blueprint, jsonify, request

from database.database import get_db
from schemas.solicitacao import (
    validar_solicitacao_create,
    solicitacao_to_dict
)
from services.solicitacao_service import (
    criar_solicitacao,
    listar_solicitacoes,
    buscar_solicitacao_por_id,
    atualizar_status,
    atualizar_solicitacao,
    deletar_solicitacao
)

solicitacoes_bp = Blueprint("solicitacoes", __name__, url_prefix="/solicitacoes")


@solicitacoes_bp.post("")
def criar():
    data = request.get_json() or {}

    valido, erro = validar_solicitacao_create(data)
    if not valido:
        return jsonify({"erro": erro}), 400

    db = get_db()

    try:
        solicitacao = criar_solicitacao(db, data)
        return jsonify(solicitacao_to_dict(solicitacao)), 201
    finally:
        db.close()


@solicitacoes_bp.get("")
def listar():
    db = get_db()

    try:
        solicitacoes = listar_solicitacoes(db)
        return jsonify([solicitacao_to_dict(item) for item in solicitacoes]), 200
    finally:
        db.close()


@solicitacoes_bp.get("/<int:solicitacao_id>")
def buscar_por_id(solicitacao_id):
    db = get_db()

    try:
        solicitacao = buscar_solicitacao_por_id(db, solicitacao_id)

        if not solicitacao:
            return jsonify({"erro": "Solicitação não encontrada."}), 404

        return jsonify(solicitacao_to_dict(solicitacao)), 200
    finally:
        db.close()


@solicitacoes_bp.patch("/<int:solicitacao_id>/status")
def alterar_status(solicitacao_id):
    data = request.get_json() or {}

    db = get_db()

    try:
        solicitacao, erro = atualizar_status(db, solicitacao_id, data)

        if erro:
            return jsonify({"erro": erro}), 400

        return jsonify(solicitacao_to_dict(solicitacao)), 200
    finally:
        db.close()


@solicitacoes_bp.put("/<int:solicitacao_id>")
def atualizar(solicitacao_id):
    data = request.get_json() or {}

    db = get_db()

    try:
        solicitacao = atualizar_solicitacao(db, solicitacao_id, data)

        if not solicitacao:
            return jsonify({"erro": "Solicitação não encontrada."}), 404

        return jsonify(solicitacao_to_dict(solicitacao)), 200
    finally:
        db.close()


@solicitacoes_bp.delete("/<int:solicitacao_id>")
def deletar(solicitacao_id):
    db = get_db()

    try:
        sucesso = deletar_solicitacao(db, solicitacao_id)

        if not sucesso:
            return jsonify({"erro": "Solicitação não encontrada."}), 404

        return "", 204
    finally:
        db.close()