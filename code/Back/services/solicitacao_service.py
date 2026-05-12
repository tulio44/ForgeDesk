from datetime import datetime, date

from models.solicitacao import Solicitacao
from schemas.solicitacao import validar_status


def criar_solicitacao(db, data):
    # Parse and validate types
    cliente_id = int(data["cliente_id"])
    titulo = data["titulo"]
    descricao = data["descricao"]
    tipo_servico = data["tipo_servico"]
    
    orcamento = data.get("orcamento")
    if orcamento is not None:
        orcamento = float(orcamento)
    
    prazo = data.get("prazo")
    if prazo:
        prazo = date.fromisoformat(prazo)
    
    referencia = data.get("referencia")

    solicitacao = Solicitacao(
        cliente_id=cliente_id,
        titulo=titulo,
        descricao=descricao,
        tipo_servico=tipo_servico,
        orcamento=orcamento,
        prazo=prazo,
        referencia=referencia,
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

    if "prestador_id" in data:
        prestador_id = data["prestador_id"]
        if prestador_id is not None:
            try:
                solicitacao.prestador_id = int(prestador_id)
            except (ValueError, TypeError):
                return None, "prestador_id deve ser um inteiro ou null."
        else:
            solicitacao.prestador_id = None

    solicitacao.atualizado_em = datetime.utcnow()

    db.commit()
    db.refresh(solicitacao)

    return solicitacao, None


def atualizar_solicitacao(db, solicitacao_id, data):
    solicitacao = buscar_solicitacao_por_id(db, solicitacao_id)

    if not solicitacao:
        return None

    # Parse types
    parsed_data = {}
    for campo in data:
        if campo == "orcamento" and data[campo] is not None:
            parsed_data[campo] = float(data[campo])
        elif campo == "prazo":
            if data[campo]:
                parsed_data[campo] = date.fromisoformat(data[campo])
            else:
                parsed_data[campo] = None
        else:
            parsed_data[campo] = data[campo]

    campos_editaveis = [
        "titulo",
        "descricao",
        "tipo_servico",
        "orcamento",
        "prazo",
        "referencia"
    ]

    for campo in campos_editaveis:
        if campo in parsed_data:
            setattr(solicitacao, campo, parsed_data[campo])

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