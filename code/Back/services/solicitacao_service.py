from datetime import datetime

from models.solicitacao import Solicitacao
from schemas.solicitacao import validar_status


def criar_solicitacao(db, data):
    solicitacao = Solicitacao(
        cliente_id=data["cliente_id"],
        titulo=data["titulo"],
        descricao=data["descricao"],
        tipo_servico=data["tipo_servico"],
        orcamento=data.get("orcamento"),
        prazo=data.get("prazo"),
        referencia=data.get("referencia"),
        status="PENDENTE"
    )

    db.add(solicitacao)
    db.commit()
    db.refresh(solicitacao)

    return solicitacao


def listar_solicitacoes(db):
    return db.query(Solicitacao).order_by(Solicitacao.id).all()


def buscar_solicitacao_por_id(db, solicitacao_id):
    return db.query(Solicitacao).filter(Solicitacao.id == solicitacao_id).first()


def atualizar_status(db, solicitacao_id, data):
    solicitacao = buscar_solicitacao_por_id(db, solicitacao_id)

    if not solicitacao:
        return None, "Solicitação não encontrada."

    novo_status = data.get("status")

    valido, erro = validar_status(novo_status)
    if not valido:
        return None, erro

    solicitacao.status = novo_status

    if data.get("prestador_id") is not None:
        solicitacao.prestador_id = data.get("prestador_id")

    solicitacao.atualizado_em = datetime.utcnow()

    db.commit()
    db.refresh(solicitacao)

    return solicitacao, None


def atualizar_solicitacao(db, solicitacao_id, data):
    solicitacao = buscar_solicitacao_por_id(db, solicitacao_id)

    if not solicitacao:
        return None

    campos_editaveis = [
        "titulo",
        "descricao",
        "tipo_servico",
        "orcamento",
        "prazo",
        "referencia"
    ]

    for campo in campos_editaveis:
        if campo in data:
            setattr(solicitacao, campo, data[campo])

    solicitacao.atualizado_em = datetime.utcnow()

    db.commit()
    db.refresh(solicitacao)

    return solicitacao


def deletar_solicitacao(db, solicitacao_id):
    solicitacao = buscar_solicitacao_por_id(db, solicitacao_id)

    if not solicitacao:
        return False

    db.delete(solicitacao)
    db.commit()

    return True