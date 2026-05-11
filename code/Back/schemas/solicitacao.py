STATUS_VALIDOS = [
    "PENDENTE",
    "ACEITA",
    "EM_ANDAMENTO",
    "CONCLUIDA",
    "CANCELADA",
    "RECUSADA"
]


def validar_solicitacao_create(data):
    campos_obrigatorios = [
        "cliente_id",
        "titulo",
        "descricao",
        "tipo_servico"
    ]

    for campo in campos_obrigatorios:
        if campo not in data or data[campo] in [None, ""]:
            return False, f"O campo '{campo}' é obrigatório."

    return True, None


def validar_status(status):
    if status not in STATUS_VALIDOS:
        return False, f"Status inválido. Use um destes: {', '.join(STATUS_VALIDOS)}"

    return True, None


def solicitacao_to_dict(solicitacao):
    return {
        "id": solicitacao.id,
        "cliente_id": solicitacao.cliente_id,
        "prestador_id": solicitacao.prestador_id,
        "titulo": solicitacao.titulo,
        "descricao": solicitacao.descricao,
        "tipo_servico": solicitacao.tipo_servico,
        "orcamento": solicitacao.orcamento,
        "prazo": solicitacao.prazo.isoformat() if solicitacao.prazo else None,
        "referencia": solicitacao.referencia,
        "status": solicitacao.status,
        "criado_em": solicitacao.criado_em.isoformat() if solicitacao.criado_em else None,
        "atualizado_em": solicitacao.atualizado_em.isoformat() if solicitacao.atualizado_em else None
    }