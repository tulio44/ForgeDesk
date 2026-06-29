# Arquitetura do App Flutter Cliente

## 1. Visão geral

O App Cliente Flutter faz parte da Sprint 3 do ForgeDesk. Seu objetivo é permitir que o cliente faça login, crie, liste e acompanhe solicitações criativas dentro da plataforma.

No contexto do ForgeDesk, uma solicitação representa um pedido de serviço criativo, como arte, design, edição de vídeo, identidade visual, modelagem 3D, social media, motion graphics ou UI/UX. O app consome a API Flask existente no backend e apresenta uma interface focada nas operações do lado do cliente.

## 2. Estrutura do app

A estrutura principal do código Flutter está organizada da seguinte forma:

```text
code/Mobile/cliente/lib/
|-- main.dart
|-- models/
|   `-- solicitacao.dart
|-- services/
|   |-- auth_service.dart
|   `-- solicitacao_service.dart
|-- screens/
|   |-- login_screen.dart
|   |-- solicitacao_list_screen.dart
|   |-- solicitacao_detail_screen.dart
|   `-- solicitacao_create_screen.dart
|-- utils/
|   |-- formatters.dart
|   `-- reference_image.dart
`-- widgets/
    `-- solicitacao_card.dart
```

O arquivo `main.dart` inicializa o aplicativo e controla se o usuário vê a tela de login ou a listagem autenticada. A pasta `models` contém a representação da entidade de solicitação. A pasta `services` concentra a comunicação HTTP com a API. As telas ficam em `screens`, componentes reutilizáveis ficam em `widgets`, e helpers de formatação e referência ficam em `utils`.

## 3. Autenticação

O app começa na tela de login. O usuário de demonstração é:

```text
cliente@forgedesk.com
123456
```

O login chama:

```text
POST /auth/login
```

A API retorna um token. O app mantém esse token em memória e o envia nas requisições protegidas usando:

```http
Authorization: Bearer <token>
```

O botão de sair limpa o token local e retorna para a tela de login.

## 4. Telas implementadas

### Login

A tela de login coleta e-mail e senha, chama `AuthService` e, em caso de sucesso, libera o acesso à listagem de solicitações.

### Listagem de solicitações

A tela de listagem exibe as solicitações retornadas pelo backend em formato de cards. Cada card apresenta título, tipo de serviço, orçamento, prazo e status. A tela também possui botão de atualização manual, botão de sair e botão flutuante para criar uma nova solicitação.

### Detalhes da solicitação

A tela de detalhes recebe o identificador de uma solicitação e busca seus dados completos na API. A capa superior mostra status, tipo de serviço, título, orçamento, prazo e, quando houver, a imagem de referência.

Na área de detalhes, a tela mostra descrição, tipo de serviço, referências complementares em texto, data de criação e data de atualização. O status não é repetido no corpo porque já aparece no topo.

### Criação de solicitação

A tela de criação possui um formulário para cadastrar uma nova solicitação. Nesta versão, o `cliente_id` é fixo como `1`. Os campos obrigatórios são título, descrição e tipo de serviço. Orçamento, prazo e referências são opcionais.

A seção de referências combina:

- orientação textual;
- imagem anexada.

Esses dois dados são salvos juntos no campo `referencia`.

## 5. Referências de texto e imagem

Para manter compatibilidade com o schema atual do backend, o campo `referencia` continua sendo texto. Quando o app envia texto e imagem, ele salva uma string JSON neste formato:

```json
{
  "texto": "Estilo pintura digital escura",
  "imagem": "data:image/jpeg;base64,..."
}
```

Registros antigos com referência em texto simples continuam funcionando. O helper `reference_image.dart` reconhece os dois formatos:

- texto simples legado;
- JSON com `texto` e `imagem`;
- imagem isolada em `data:image/...;base64,...`.

## 6. Integração com backend

O app consome os seguintes endpoints da API Flask:

- `POST /auth/login`
- `GET /solicitacoes`
- `GET /solicitacoes/{id}`
- `POST /solicitacoes`

A comunicação é feita por `AuthService` e `SolicitacaoService`, usando o pacote `http`. Os dados recebidos e enviados seguem o formato JSON da API, com campos em `snake_case`.

## 7. Atualização assíncrona/polling

A atualização automática foi implementada por polling a cada 10 segundos na tela de listagem e na tela de detalhes. Essa abordagem simula o acompanhamento assíncrono de mudanças feitas no backend, mantendo o app atualizado sem exigir uma ação manual constante do usuário.

Os timers são cancelados no `dispose` das telas para evitar atualizações depois que a tela deixa de existir.

## 8. Como rodar

Antes de abrir o app, o backend Flask deve estar em execução.

```powershell
cd code/Mobile/cliente
flutter pub get
flutter run
```

Por padrão, o app escolhe a URL da API automaticamente:

```text
Web/Desktop: http://localhost:8000
Android Emulator: http://10.0.2.2:8000
```

Também é possível sobrescrever a URL:

```powershell
flutter run --dart-define=API_BASE_URL=http://SEU_IP:8000
```

No emulador Android, `localhost` aponta para o próprio emulador, e não para a máquina host onde o backend está rodando. Por isso o app usa `10.0.2.2` nessa plataforma.
