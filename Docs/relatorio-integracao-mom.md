# Relatório de Integração MOM — ForgeDesk

## Escolha do RabbitMQ

O RabbitMQ foi escolhido por ser um broker de mensagens maduro, simples de executar com Docker e adequado para demonstrar Middleware Orientado a Mensagens na Sprint 2. A imagem `rabbitmq:3-management` também disponibiliza um painel web, permitindo visualizar filas, conexões e mensagens durante a execução.

## Funcionamento do produtor

O produtor foi implementado no backend Flask, dentro do fluxo já existente de solicitações. Após uma solicitação ser criada com sucesso, o backend publica o evento `solicitacao.criada`. Após uma atualização de status ser persistida, o backend publica o evento `solicitacao.status_atualizado`.

A conexão e publicação ficam centralizadas em `code/Back/messaging/rabbitmq.py`. O arquivo declara a fila `forgedesk_eventos` antes de publicar e envia o payload em JSON. Caso o RabbitMQ esteja temporariamente fora do ar, a falha é registrada no terminal, mas a API continua respondendo normalmente.

## Funcionamento do consumidor

O consumidor foi implementado em `code/Back/consumers/consumer_solicitacoes.py`. Ele conecta ao RabbitMQ, declara a mesma fila `forgedesk_eventos` e fica aguardando mensagens até interrupção manual com `CTRL+C`.

Cada mensagem recebida é convertida de JSON para dicionário Python e impressa no terminal com nome do evento, id da solicitação, status e payload completo.

## Fluxo assíncrono

O fluxo é assíncrono porque a API REST apenas publica uma mensagem no RabbitMQ após concluir a operação no banco. O processamento dessa mensagem acontece em outro processo, executado separadamente pelo consumidor. Não existe chamada REST direta entre produtor e consumidor.

## Comandos para rodar

Subir PostgreSQL e RabbitMQ:

```powershell
cd infra
docker compose up -d
```

Rodar o backend:

```powershell
cd code/Back
.\.venv\Scripts\Activate.ps1
python main.py
```

Rodar o consumidor em outro terminal:

```powershell
cd code/Back
.\.venv\Scripts\Activate.ps1
python consumers/consumer_solicitacoes.py
```

Painel do RabbitMQ:

```text
http://localhost:15672
usuário: forgedesk
senha: forgedesk
```

## Evidências esperadas

1. Ao enviar `POST http://localhost:8000/solicitacoes`, a API deve retornar `201 Created`.
2. No terminal do consumidor, deve aparecer um evento `solicitacao.criada`.
3. Ao enviar `PATCH http://localhost:8000/solicitacoes/1/status`, a API deve retornar `200 OK`.
4. No terminal do consumidor, deve aparecer um evento `solicitacao.status_atualizado`.
5. No painel do RabbitMQ, a fila `forgedesk_eventos` deve existir.

## Dificuldades e decisões técnicas

A principal decisão foi manter a publicação como uma operação best-effort. Assim, a integração com o RabbitMQ demonstra o uso real de MOM sem tornar o broker um ponto único de falha para os endpoints REST da Sprint 1.

Também foi escolhido o exchange padrão do RabbitMQ para evitar complexidade desnecessária. Como a Sprint 2 precisa demonstrar produtor, fila e consumidor, uma única fila durável chamada `forgedesk_eventos` é suficiente para o escopo atual.
