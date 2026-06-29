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

  testWidgets('shows details TODO message when card is tapped', (
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
    await tester.pump();

    expect(
      find.text('Detalhes da oportunidade serao implementados em breve.'),
      findsOneWidget,
    );
  });
}

class _FakeSolicitacaoService extends SolicitacaoService {
  _FakeSolicitacaoService(this.solicitacoes, {this.shouldFail = false});

  final List<Solicitacao> solicitacoes;
  final bool shouldFail;

  @override
  Future<List<Solicitacao>> listarSolicitacoes() async {
    if (shouldFail) {
      throw Exception('Falha simulada');
    }

    return solicitacoes;
  }
}

Solicitacao _solicitacao({
  int id = 1,
  String titulo = 'Servico pendente',
  required String status,
}) {
  return Solicitacao(
    id: id,
    clienteId: 1,
    titulo: titulo,
    descricao: 'Descricao da oportunidade',
    tipoServico: 'Eletrica',
    orcamento: 150,
    prazo: '2026-07-10',
    status: status,
  );
}
