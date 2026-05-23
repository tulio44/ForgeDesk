EVENTO_SOLICITACAO_CRIADA = "solicitacao.criada"
EVENTO_STATUS_ATUALIZADO = "solicitacao.status_atualizado"


def montar_evento_solicitacao_criada(solicitacao):
    return {
        "evento": EVENTO_SOLICITACAO_CRIADA,
        "solicitacao_id": solicitacao.id,
        "cliente_id": solicitacao.cliente_id,
        "prestador_id": solicitacao.prestador_id,
        "titulo": solicitacao.titulo,
        "tipo_servico": solicitacao.tipo_servico,
        "status": solicitacao.status,
    }


def montar_evento_status_atualizado(solicitacao, status_anterior=None):
    return {
        "evento": EVENTO_STATUS_ATUALIZADO,
        "solicitacao_id": solicitacao.id,
        "cliente_id": solicitacao.cliente_id,
        "prestador_id": solicitacao.prestador_id,
        "status_anterior": status_anterior,
        "status_atual": solicitacao.status,
    }
