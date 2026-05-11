CREATE TABLE IF NOT EXISTS solicitacoes (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    prestador_id INTEGER NULL,

    titulo VARCHAR(120) NOT NULL,
    descricao TEXT NOT NULL,
    tipo_servico VARCHAR(80) NOT NULL,

    orcamento FLOAT NULL,
    prazo DATE NULL,
    referencia TEXT NULL,

    status VARCHAR(30) NOT NULL DEFAULT 'PENDENTE',

    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);