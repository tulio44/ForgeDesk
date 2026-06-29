# Arquitetura Flutter Prestador

## 1. Visao geral

O app Prestador do ForgeDesk permite visualizar oportunidades de servicos criativos, aceitar solicitacoes pendentes e atualizar o andamento dos servicos assumidos.

O fluxo principal do prestador cobre a consulta de oportunidades, a aceitacao de uma solicitacao e a evolucao do status ate a conclusao do servico.

## 2. Estrutura do app

```text
code/Mobile/prestador/lib/
├── main.dart
├── models/
│   └── solicitacao.dart
├── services/
│   └── solicitacao_service.dart
├── screens/
│   ├── oportunidade_list_screen.dart
│   ├── oportunidade_detail_screen.dart
│   └── minhas_solicitacoes_screen.dart
└── widgets/
    └── oportunidade_card.dart
```

## 3. Telas implementadas

### Oportunidades

Lista solicitacoes com status `PENDENTE`, exibindo titulo, tipo de servico, orcamento, prazo e status em cards. A tela possui atualizacao manual e polling automatico a cada 10 segundos.

### Detalhes da solicitacao

Exibe os dados completos da solicitacao selecionada. Nessa tela, o prestador pode aceitar uma oportunidade pendente, iniciar um servico aceito e concluir um servico em andamento.

### Minhas Solicitacoes

Lista solicitacoes assumidas pelo prestador fixo `prestadorId == 1`, com status `ACEITA` ou `EM_ANDAMENTO`. Ao tocar em uma solicitacao, a tela de detalhes e aberta para permitir a continuidade do fluxo.

## 4. Integracao com backend

Endpoints consumidos pelo app:

- `GET /solicitacoes`
- `GET /solicitacoes/{id}`
- `PATCH /solicitacoes/{id}/status`

O app usa `SolicitacaoService` para centralizar as chamadas HTTP e o model `Solicitacao` para converter dados entre snake_case da API Flask e camelCase no Dart.

## 5. Fluxo do prestador

```text
PENDENTE -> ACEITA -> EM_ANDAMENTO -> CONCLUIDA
```

O prestador aceita uma oportunidade pendente com `prestador_id: 1`. Depois, em Minhas Solicitacoes, pode iniciar o servico e concluir a execucao.

## 6. Atualizacao automatica

As telas de oportunidades, detalhes e minhas solicitacoes possuem polling automatico a cada 10 segundos. Os timers sao cancelados no `dispose` para evitar atualizacoes apos a tela ser descartada.

## 7. Como rodar

```powershell
cd code/Mobile/prestador
flutter pub get
flutter run
```

Para web e desktop, use a API em:

```text
http://localhost:8000
```

Para emulador Android, altere a `baseUrl` do service para:

```text
http://10.0.2.2:8000
```
