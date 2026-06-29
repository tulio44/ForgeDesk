# ForgeDesk

> Plataforma de contratação de serviços criativos para projetos independentes.

O **ForgeDesk** conecta clientes que precisam de serviços criativos com prestadores capazes de executar essas demandas.

A ideia é permitir que um cliente crie uma solicitação com título, descrição, tipo de serviço, orçamento e referência. Depois, um prestador pode visualizar a demanda, aceitá-la e atualizar seu status.

---

## Status

- Sprint 1: Arquitetura e Backend REST — concluída ✅
- Sprint 2: Integração com MOM — concluída ✅
- Sprint 3: App Flutter Cliente — pendente
- Sprint 4: App Flutter Prestador — pendente

---

## Tecnologias

- Python 3.13
- Flask
- SQLAlchemy
- PostgreSQL 16
- RabbitMQ
- Docker Compose
- Postman

Nas próximas sprints, o projeto também utilizará Flutter.

---

## Como rodar

### 1. Subir o banco

Na raiz do projeto:

```bash
cd infra
docker compose up -d
```

### 2. Rodar o backend

Em outro terminal:

```bash
cd code/Back
py -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python main.py
```

A API ficará disponível em:

```text
http://localhost:8000
```

---

## Variáveis de ambiente

O backend usa um arquivo `.env` dentro de `code/Back`.

Exemplo:

```env
DATABASE_URL=postgresql+psycopg://forgedesk_user:forgedesk_pass@localhost:5432/forgedesk_db
FLASK_PORT=8000
RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672
RABBITMQ_USER=forgedesk
RABBITMQ_PASSWORD=forgedesk
RABBITMQ_QUEUE=forgedesk_eventos
```

---

## Sprint 2 — MOM

A Sprint 2 adiciona integração com RabbitMQ. O backend publica eventos quando uma solicitação é criada e quando seu status é atualizado. Um consumidor separado processa essas mensagens pela fila `forgedesk_eventos`.

### Subir RabbitMQ e PostgreSQL

```powershell
cd infra
docker compose up -d
```

### Rodar backend

```powershell
cd code/Back
.\.venv\Scripts\Activate.ps1
python main.py
```

### Rodar consumidor

Em outro terminal:

```powershell
cd code/Back
.\.venv\Scripts\Activate.ps1
python consumers/consumer_solicitacoes.py
```

### Painel RabbitMQ

```text
http://localhost:15672
usuário: forgedesk
senha: forgedesk
```

### Eventos publicados

- `solicitacao.criada`
- `solicitacao.status_atualizado`

Documentação dos eventos:

```text
Docs/eventos-mom.md
```

Relatório de integração:

```text
Docs/relatorio-integracao-mom.md
```

---

## Sprint 3 - App Cliente Flutter

A Sprint 3 implementa o app Flutter do cliente, localizado em:

```text
code/Mobile/cliente
```

Funcionalidades entregues:

- listagem de solicitacoes;
- detalhes de uma solicitacao;
- criacao de solicitacao;
- integracao HTTP com a API Flask;
- atualizacao automatica por polling a cada 10 segundos.

Para rodar o app:

```powershell
cd code/Mobile/cliente
flutter pub get
flutter run
```

Por padrao, o app usa:

```text
http://localhost:8000
```

Esse endereco e adequado para web e desktop. Para emulador Android, use:

```text
http://10.0.2.2:8000
```

Documentacao da arquitetura Flutter Cliente:

```text
Docs/arquitetura-flutter-cliente.md
```

---

## Sprint 4 — App Prestador Flutter

A Sprint 4 implementa o app Flutter do prestador, localizado em:

```text
code/Mobile/prestador
```

Funcionalidades entregues:

- listagem de oportunidades pendentes;
- detalhes de uma solicitacao;
- aceite de solicitacao pelo prestador;
- tela de Minhas Solicitacoes;
- inicio e conclusao de servico;
- integracao HTTP com a API Flask;
- atualizacao automatica por polling a cada 10 segundos.

Para rodar o app:

```powershell
cd code/Mobile/prestador
flutter pub get
flutter run
```

Fluxo integrado:

```text
Cliente cria solicitacao -> Backend registra e publica eventos -> Prestador aceita e atualiza status -> Cliente acompanha a evolucao
```

Por padrao, o app usa:

```text
http://localhost:8000
```

Esse endereco e adequado para web e desktop. Para emulador Android, use:

```text
http://10.0.2.2:8000
```

Documentacao da arquitetura Flutter Prestador:

```text
Docs/arquitetura-flutter-prestador.md
```

---

## Endpoints

- `GET /health` — verifica se a API está funcionando
- `POST /solicitacoes` — cria uma solicitação
- `GET /solicitacoes` — lista as solicitações
- `GET /solicitacoes/{id}` — busca uma solicitação por ID
- `PATCH /solicitacoes/{id}/status` — atualiza o status
- `PUT /solicitacoes/{id}` — atualiza os dados da solicitação
- `DELETE /solicitacoes/{id}` — remove uma solicitação

---

## Exemplo de solicitação

```json
{
  "cliente_id": 1,
  "titulo": "Capa para PDF de RPG independente",
  "descricao": "Preciso de uma capa digital para um suplemento autoral de fantasia.",
  "tipo_servico": "Design",
  "orcamento": 150.0,
  "referencia": "Estilo pintura digital escura"
}
```

---

## Banco de dados

A entidade principal do sistema é a tabela `solicitacoes`.

O schema está documentado em:

```text
code/Back/database/schema.sql
```

Status possíveis:

```text
PENDENTE
ACEITA
EM_ANDAMENTO
CONCLUIDA
CANCELADA
RECUSADA
```

---

## Testes

A coleção Postman da Sprint 1 está em:

```text
code/tests/forgedesk_postman_collection.json
```

Ela contém exemplos para criar, listar, buscar, atualizar e remover solicitações.

---

## Documentação

- Proposta do projeto: `Docs/Documento de Proposta - ForgeDesk.pdf`
- Arquitetura: `Docs/diagrama-arquitetura.md`
- Eventos MOM: `Docs/eventos-mom.md`
- Relatório MOM: `Docs/relatorio-integracao-mom.md`
- Arquitetura Flutter Prestador: `Docs/arquitetura-flutter-prestador.md`
- Schema do banco: `code/Back/database/schema.sql`
- Collection Postman: `code/tests/forgedesk_postman_collection.json`

---

## Estrutura

```text
ForgeDesk/
├── code/
│   ├── Back/
│   ├── Mobile/
│   └── tests/
├── Docs/
├── infra/
├── .gitignore
└── README.md
```
