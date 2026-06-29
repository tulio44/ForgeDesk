import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prestador/main.dart';
import 'package:prestador/models/solicitacao.dart';
import 'package:prestador/screens/oportunidade_detail_screen.dart';
import 'package:prestador/services/solicitacao_service.dart';

void main() {
  testWidgets('shows pending oportunidades on the home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      PrestadorApp(
        service: _FakeSolicitacaoService([
          _solicitacao(status: 'PENDENTE'),
          _solicitacao(id: 2, titulo: 'Servico aceito', status: 'ACEITA'),
        ]),
        enablePolling: false,
      ),
    );

    await tester.pump();

    expect(find.text('Oportunidades'), findsWidgets);
    expect(find.text('Servico pendente'), findsOneWidget);
    expect(find.text('Servico aceito'), findsNothing);
    expect(find.text('PENDENTE'), findsOneWidget);
  });

  testWidgets('shows empty message when there are no pending oportunidades', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      PrestadorApp(
        service: _FakeSolicitacaoService([_solicitacao(status: 'ACEITA')]),
        enablePolling: false,
      ),
    );

    await tester.pump();

    expect(
      find.text('Nenhuma oportunidade pendente encontrada.'),
      findsOneWidget,
    );
  });

  testWidgets('shows error message when loading fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      PrestadorApp(
        service: _FakeSolicitacaoService([], shouldFail: true),
        enablePolling: false,
      ),
    );

    await tester.pump();

    expect(
      find.text('Nao foi possivel carregar as oportunidades.'),
      findsOneWidget,
    );
  });

  testWidgets('opens oportunidade details when card is tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      PrestadorApp(
        service: _FakeSolicitacaoService([_solicitacao(status: 'PENDENTE')]),
        enablePolling: false,
      ),
    );

    await tester.pump();
    await tester.tap(find.text('Servico pendente'));
    await tester.pumpAndSettle();

    expect(find.text('Detalhes da oportunidade'), findsOneWidget);
    expect(find.text('Descricao da oportunidade'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Aceitar solicitação'), 200);
    expect(find.text('Aceitar solicitação'), findsOneWidget);
  });

  testWidgets('accepts pending oportunidade from details screen', (
    WidgetTester tester,
  ) async {
    final service = _FakeSolicitacaoService([_solicitacao(status: 'PENDENTE')]);

    await tester.pumpWidget(
      PrestadorApp(service: service, enablePolling: false),
    );

    await tester.pump();
    await tester.tap(find.text('Servico pendente'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Aceitar solicitação'), 200);
    await tester.tap(find.text('Aceitar solicitação'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(service.lastStatus, 'ACEITA');
    expect(service.lastPrestadorId, 1);
    expect(find.text('Solicitacao aceita com sucesso.'), findsOneWidget);
    expect(find.text('Aceitar solicitação'), findsNothing);
  });

  testWidgets('shows minhas solicitacoes assigned to prestador', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      PrestadorApp(
        service: _FakeSolicitacaoService([
          _solicitacao(status: 'PENDENTE'),
          _solicitacao(
            id: 2,
            titulo: 'Servico aceito',
            status: 'ACEITA',
            prestadorId: 1,
          ),
          _solicitacao(
            id: 3,
            titulo: 'Servico de outro prestador',
            status: 'EM_ANDAMENTO',
            prestadorId: 2,
          ),
        ]),
        enablePolling: false,
      ),
    );

    await tester.pump();
    await tester.tap(find.byIcon(Icons.assignment));
    await tester.pump();

    expect(find.text('Minhas Solicitações'), findsWidgets);
    expect(find.text('Servico aceito'), findsOneWidget);
    expect(find.text('Servico pendente'), findsNothing);
    expect(find.text('Servico de outro prestador'), findsNothing);
  });

  testWidgets('starts accepted solicitacao from details screen', (
    WidgetTester tester,
  ) async {
    final service = _FakeSolicitacaoService([
      _solicitacao(status: 'ACEITA', prestadorId: 1),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: OportunidadeDetailScreen(
          solicitacaoId: 1,
          service: service,
          enablePolling: false,
        ),
      ),
    );

    await tester.pump();
    await tester.scrollUntilVisible(find.text('Iniciar serviço'), 200);
    await tester.tap(find.text('Iniciar serviço'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(service.lastStatus, 'EM_ANDAMENTO');
    expect(service.lastPrestadorId, 1);
  });

  testWidgets('concludes in-progress solicitacao from details screen', (
    WidgetTester tester,
  ) async {
    final service = _FakeSolicitacaoService([
      _solicitacao(status: 'EM_ANDAMENTO', prestadorId: 1),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: OportunidadeDetailScreen(
          solicitacaoId: 1,
          service: service,
          enablePolling: false,
        ),
      ),
    );

    await tester.pump();
    await tester.scrollUntilVisible(find.text('Concluir serviço'), 200);
    await tester.tap(find.text('Concluir serviço'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(service.lastStatus, 'CONCLUIDA');
    expect(service.lastPrestadorId, 1);
    await tester.scrollUntilVisible(find.text('Serviço concluído.'), 200);
    expect(find.text('Serviço concluído.'), findsOneWidget);
  });
}

class _FakeSolicitacaoService extends SolicitacaoService {
  _FakeSolicitacaoService(this.solicitacoes, {this.shouldFail = false});

  final List<Solicitacao> solicitacoes;
  final bool shouldFail;
  String? lastStatus;
  int? lastPrestadorId;

  @override
  Future<List<Solicitacao>> listarSolicitacoes() async {
    if (shouldFail) {
      throw Exception('Falha simulada');
    }

    return solicitacoes;
  }

  @override
  Future<Solicitacao> buscarSolicitacaoPorId(int id) async {
    if (shouldFail) {
      throw Exception('Falha simulada');
    }

    return solicitacoes.firstWhere((solicitacao) => solicitacao.id == id);
  }

  @override
  Future<Solicitacao> atualizarStatus({
    required int id,
    required String status,
    int? prestadorId,
  }) async {
    lastStatus = status;
    lastPrestadorId = prestadorId;

    final index = solicitacoes.indexWhere(
      (solicitacao) => solicitacao.id == id,
    );
    final atualizada = _solicitacao(
      id: id,
      status: status,
      prestadorId: prestadorId,
    );

    solicitacoes[index] = atualizada;
    return atualizada;
  }
}

Solicitacao _solicitacao({
  int id = 1,
  String titulo = 'Servico pendente',
  required String status,
  int? prestadorId,
}) {
  return Solicitacao(
    id: id,
    clienteId: 1,
    prestadorId: prestadorId,
    titulo: titulo,
    descricao: 'Descricao da oportunidade',
    tipoServico: 'Eletrica',
    orcamento: 150,
    prazo: '2026-07-10',
    status: status,
  );
}
