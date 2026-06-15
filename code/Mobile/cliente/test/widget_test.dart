import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forgedesk_cliente/models/solicitacao.dart';
import 'package:forgedesk_cliente/screens/solicitacao_create_screen.dart';
import 'package:forgedesk_cliente/screens/solicitacao_detail_screen.dart';
import 'package:forgedesk_cliente/screens/solicitacao_list_screen.dart';
import 'package:forgedesk_cliente/services/solicitacao_service.dart';

void main() {
  testWidgets('shows solicitacao list screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SolicitacaoListScreen(
          service: _FakeSolicitacaoService(),
          enablePolling: false,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('ForgeDesk Cliente'), findsOneWidget);
    expect(find.text('Quadro de contratos'), findsOneWidget);
    expect(find.text('Identidade visual'), findsOneWidget);
    expect(find.text('Oficio: Design'), findsOneWidget);
    expect(find.text('Recompensa: R\$ 250.00'), findsOneWidget);
    expect(find.text('PENDENTE'), findsOneWidget);
  });

  testWidgets('shows solicitacao detail screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SolicitacaoDetailScreen(
          solicitacaoId: 1,
          service: _FakeSolicitacaoService(),
          enablePolling: false,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Contrato da forja'), findsOneWidget);
    expect(find.text('Identidade visual'), findsOneWidget);
    expect(
      find.text('Criar identidade visual para projeto independente.'),
      findsOneWidget,
    );
    expect(find.text('Oficio'), findsOneWidget);
    expect(find.text('Design'), findsOneWidget);
    expect(find.text('Recompensa'), findsOneWidget);
    expect(find.text('R\$ 250.00'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();

    expect(find.text('Status'), findsOneWidget);
    expect(find.text('PENDENTE'), findsOneWidget);
  });

  testWidgets('shows solicitacao create screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SolicitacaoCreateScreen(service: _FakeSolicitacaoService()),
      ),
    );

    expect(find.text('Forjar solicitacao'), findsOneWidget);
    expect(find.text('Novo contrato'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Titulo'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Descricao'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Tipo de servico'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextFormField, 'Orcamento'), findsOneWidget);
  });
}

class _FakeSolicitacaoService extends SolicitacaoService {
  static final _solicitacao = Solicitacao(
    id: 1,
    clienteId: 1,
    titulo: 'Identidade visual',
    descricao: 'Criar identidade visual para projeto independente.',
    tipoServico: 'Design',
    orcamento: 250,
    prazo: DateTime(2026, 6, 30),
    referencia: 'Briefing inicial',
    status: 'PENDENTE',
    criadoEm: DateTime(2026, 6, 14, 10),
    atualizadoEm: DateTime(2026, 6, 14, 11),
  );

  @override
  Future<List<Solicitacao>> listarSolicitacoes() async {
    return [_solicitacao];
  }

  @override
  Future<Solicitacao> buscarSolicitacaoPorId(int id) async {
    return _solicitacao;
  }

  @override
  Future<Solicitacao> criarSolicitacao(Solicitacao solicitacao) async {
    return solicitacao;
  }
}
