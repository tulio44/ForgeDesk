# Arquitetura do App Flutter Cliente

## 1. Visao geral

O App Cliente Flutter faz parte da Sprint 3 do ForgeDesk. Seu objetivo e permitir que o cliente crie, liste e acompanhe solicitacoes criativas dentro da plataforma.

No contexto do ForgeDesk, uma solicitacao representa um pedido de servico criativo, como arte, design, escrita, diagramacao ou materiais voltados a projetos independentes e RPGs. O app consome a API Flask ja existente no backend e apresenta uma interface simples para operacoes do lado do cliente.

## 2. Estrutura do app

A estrutura principal do codigo Flutter esta organizada da seguinte forma:

```text
code/Mobile/cliente/lib/
|-- main.dart
|-- models/
|   `-- solicitacao.dart
|-- services/
|   `-- solicitacao_service.dart
|-- screens/
|   |-- solicitacao_list_screen.dart
|   |-- solicitacao_detail_screen.dart
|   `-- solicitacao_create_screen.dart
`-- widgets/
    `-- solicitacao_card.dart
```

O arquivo `main.dart` inicializa o aplicativo e direciona o usuario para a tela de listagem. A pasta `models` contem a representacao da entidade de solicitacao. A pasta `services` concentra a comunicacao HTTP com a API. As telas ficam em `screens`, enquanto componentes reutilizaveis ficam em `widgets`.

## 3. Telas implementadas

### Listagem de solicitacoes

A tela de listagem exibe as solicitacoes retornadas pelo backend em formato de cards. Cada card apresenta titulo, tipo de servico, orcamento e status. A tela tambem possui botao de atualizacao manual e botao flutuante para criar uma nova solicitacao.

### Detalhes da solicitacao

A tela de detalhes recebe o identificador de uma solicitacao e busca seus dados completos na API. Ela apresenta informacoes como titulo, descricao, tipo de servico, orcamento, prazo, referencia, status, cliente, prestador e datas de criacao e atualizacao.

### Criacao de solicitacao

A tela de criacao possui um formulario para cadastrar uma nova solicitacao. Nesta sprint, o `cliente_id` e fixo como `1`. Os campos obrigatorios sao titulo, descricao e tipo de servico. Orcamento, referencia e prazo sao opcionais.

## 4. Integracao com backend

O app consome os seguintes endpoints da API Flask:

- `GET /solicitacoes`
- `GET /solicitacoes/{id}`
- `POST /solicitacoes`

A comunicacao e feita pela classe `SolicitacaoService`, usando o pacote `http`. Os dados recebidos e enviados seguem o formato JSON da API, com campos em `snake_case`.

## 5. Atualizacao assincrona/polling

A atualizacao automatica foi implementada por polling a cada 10 segundos na tela de listagem e na tela de detalhes. Essa abordagem simula o acompanhamento assincrono de mudancas feitas no backend, mantendo o app atualizado sem exigir uma acao manual constante do usuario.

Os timers sao cancelados no `dispose` das telas para evitar atualizacoes depois que a tela deixa de existir.

## 6. Como rodar

Antes de abrir o app, o backend Flask deve estar em execucao.

```powershell
cd code/Mobile/cliente
flutter pub get
flutter run
```

Por padrao, o app usa a API em:

```text
http://localhost:8000
```

Esse endereco funciona para web e desktop. Para executar no emulador Android, a URL deve ser ajustada para:

```text
http://10.0.2.2:8000
```

Essa diferenca existe porque, no emulador Android, `localhost` aponta para o proprio emulador, e nao para a maquina host onde o backend esta rodando.
