import 'package:flutter_test/flutter_test.dart';
import 'package:prestador/main.dart';
import 'package:prestador/models/solicitacao.dart';
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

    expect(find.text('Oportunidades'), findsOneWidget);
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
    await tester.scrollUntilVisible(find.text('Aceitar solicitacao'), 200);
    expect(find.text('Aceitar solicitacao'), findsOneWidget);
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

    await tester.scrollUntilVisible(find.text('Aceitar solicitacao'), 200);
    await tester.tap(find.text('Aceitar solicitacao'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(service.lastStatus, 'ACEITA');
    expect(service.lastPrestadorId, 1);
    expect(find.text('Solicitacao aceita com sucesso.'), findsOneWidget);
    expect(find.text('Aceitar solicitacao'), findsNothing);
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
