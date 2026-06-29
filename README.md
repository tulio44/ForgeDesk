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
DATABASE_URL=postgresql+psycopg://forgedesk_user:forgedesk_pass@localhost:5433/forgedesk_db
FLASK_PORT=8000
RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672
RABBITMQ_USER=forgedesk
RABBITMQ_PASSWORD=forgedesk
RABBITMQ_QUEUE=forgedesk_eventos
AUTH_SECRET=forgedesk-dev-secret
TOKEN_TTL_SECONDS=86400
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

- login com token de autenticação;
- listagem de solicitações;
- detalhes de uma solicitação;
- criação de solicitação;
- referência combinando orientação em texto e imagem anexada;
- integração HTTP com a API Flask;
- atualização automática por polling a cada 10 segundos.

Para rodar o app:

```powershell
cd code/Mobile/cliente
flutter pub get
flutter run
```

Por padrão, o app usa:

```text
Web/Desktop: http://localhost:8000
Android Emulator: http://10.0.2.2:8000
```

Também é possível sobrescrever a URL da API:

```powershell
flutter run --dart-define=API_BASE_URL=http://SEU_IP:8000
```

Documentação da arquitetura Flutter Cliente:

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
- `POST /auth/login` — autentica o usuário e retorna um token
- `POST /solicitacoes` — cria uma solicitação
- `GET /solicitacoes` — lista as solicitações
- `GET /solicitacoes/{id}` — busca uma solicitação por ID
- `PATCH /solicitacoes/{id}/status` — atualiza o status
- `PUT /solicitacoes/{id}` — atualiza os dados da solicitação
- `DELETE /solicitacoes/{id}` — remove uma solicitação

Com exceção de `/health` e `/auth/login`, as rotas exigem:

```http
Authorization: Bearer SEU_TOKEN
```

### Login

Usuário de demonstração:

```text
cliente@forgedesk.com
123456
```

Exemplo:

```http
POST http://localhost:8000/auth/login
Content-Type: application/json
```

```json
{
  "email": "cliente@forgedesk.com",
  "senha": "123456"
}
```

Use o campo `token` retornado nas demais requisições.

---

## Exemplo de solicitação

```json
{
  "cliente_id": 1,
  "titulo": "Capa para PDF de RPG independente",
  "descricao": "Preciso de uma capa digital para um suplemento autoral de fantasia.",
  "tipo_servico": "Design",
  "orcamento": 150.0,
  "referencia": "{\"texto\":\"Estilo pintura digital escura\",\"imagem\":\"data:image/jpeg;base64,...\"}"
}
```

O campo `referencia` aceita um texto simples legado ou um JSON em string com:

- `texto`: orientação textual da referência;
- `imagem`: imagem em formato `data:image/...;base64,...`.

No app Flutter, os dois campos são preenchidos juntos em uma única seção de referências.

### Atualizar status

O ID da solicitação vai na URL:

```http
PATCH http://localhost:8000/solicitacoes/120/status
Authorization: Bearer SEU_TOKEN
Content-Type: application/json
```

```json
{
  "status": "ACEITA",
  "prestador_id": 2
}
```

Status válidos:

```text
PENDENTE
ACEITA
EM_ANDAMENTO
CONCLUIDA
CANCELADA
RECUSADA
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

Tipos de serviço aceitos:

```text
Design
Ilustração
Edição de vídeo
Identidade visual
Modelagem 3D
Social media
Motion graphics
UI/UX
```

---

## Testes

A coleção Postman está em:

```text
code/tests/forgedesk_postman_collection.json
```

Ela contém exemplos para login, criar, listar, buscar, atualizar e remover solicitações. Para usar:

1. Rode o request `Login`.
2. Copie o valor de `token` da resposta.
3. Use o token no header das rotas protegidas:

```text
Authorization: Bearer SEU_TOKEN
```

Também existe uma collection mínima para teste de importação:

```text
code/tests/forgedesk_postman_minimal_collection.json
```

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
