import 'package:flutter_test/flutter_test.dart';
import 'package:prestador/models/solicitacao.dart';

void main() {
  test('creates Solicitacao from API json', () {
    final solicitacao = Solicitacao.fromJson({
      'id': 1,
      'cliente_id': 2,
      'prestador_id': 3,
      'titulo': 'Instalacao eletrica',
      'descricao': 'Trocar tomada da cozinha',
      'tipo_servico': 'Eletrica',
      'orcamento': 120,
      'prazo': '2026-07-10',
      'referencia': 'Apartamento 101',
      'status': 'aberta',
      'criado_em': '2026-06-29T10:00:00',
      'atualizado_em': '2026-06-29T10:30:00',
    });

    expect(solicitacao.id, 1);
    expect(solicitacao.clienteId, 2);
    expect(solicitacao.prestadorId, 3);
    expect(solicitacao.titulo, 'Instalacao eletrica');
    expect(solicitacao.descricao, 'Trocar tomada da cozinha');
    expect(solicitacao.tipoServico, 'Eletrica');
    expect(solicitacao.orcamento, 120.0);
    expect(solicitacao.prazo, '2026-07-10');
    expect(solicitacao.referencia, 'Apartamento 101');
    expect(solicitacao.status, 'aberta');
    expect(solicitacao.criadoEm, '2026-06-29T10:00:00');
    expect(solicitacao.atualizadoEm, '2026-06-29T10:30:00');
  });

  test('converts Solicitacao to API json with nullable fields', () {
    const solicitacao = Solicitacao(
      clienteId: 2,
      titulo: 'Pintura',
      descricao: 'Pintar parede da sala',
      tipoServico: 'Pintura',
      status: 'aberta',
    );

    expect(solicitacao.toJson(), {
      'id': null,
      'cliente_id': 2,
      'prestador_id': null,
      'titulo': 'Pintura',
      'descricao': 'Pintar parede da sala',
      'tipo_servico': 'Pintura',
      'orcamento': null,
      'prazo': null,
      'referencia': null,
      'status': 'aberta',
      'criado_em': null,
      'atualizado_em': null,
    });
  });
}
