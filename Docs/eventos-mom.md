# Documentação de Eventos — ForgeDesk

Este documento descreve os eventos publicados pelo backend do ForgeDesk na Sprint 2, usando RabbitMQ como Middleware Orientado a Mensagens.

## Fila

- Broker: RabbitMQ
- Exchange: exchange padrão do RabbitMQ (`""`)
- Fila: `forgedesk_eventos`
- Formato do payload: JSON
- Produtor: backend Flask (`code/Back`)
- Consumidor: `code/Back/consumers/consumer_solicitacoes.py`

## Eventos

| Evento | Produtor | Consumidor | Fila/Exchange | Momento em que ocorre |
| --- | --- | --- | --- | --- |
| `solicitacao.criada` | Backend Flask | `consumer_solicitacoes.py` | Fila `forgedesk_eventos`, exchange padrão | Após uma solicitação ser criada e persistida no banco |
| `solicitacao.status_atualizado` | Backend Flask | `consumer_solicitacoes.py` | Fila `forgedesk_eventos`, exchange padrão | Após o status de uma solicitação ser atualizado e persistido no banco |

## Payload: solicitacao.criada

```json
{
  "evento": "solicitacao.criada",
  "solicitacao_id": 1,
  "cliente_id": 1,
  "prestador_id": null,
  "titulo": "Capa para PDF de RPG independente",
  "tipo_servico": "Design",
  "status": "PENDENTE"
}
```

## Payload: solicitacao.status_atualizado

```json
{
  "evento": "solicitacao.status_atualizado",
  "solicitacao_id": 1,
  "cliente_id": 1,
  "prestador_id": 2,
  "status_anterior": "PENDENTE",
  "status_atual": "ACEITA"
}
```
