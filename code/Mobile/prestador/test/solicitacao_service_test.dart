import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:prestador/services/solicitacao_service.dart';

void main() {
  const apiBaseUrl = 'http://localhost:8000';

  final solicitacaoJson = {
    'id': 1,
    'cliente_id': 2,
    'prestador_id': 3,
    'titulo': 'Instalacao eletrica',
    'descricao': 'Trocar tomada da cozinha',
    'tipo_servico': 'Eletrica',
    'orcamento': 120.0,
    'prazo': '2026-07-10',
    'referencia': 'Apartamento 101',
    'status': 'ACEITA',
    'criado_em': '2026-06-29T10:00:00',
    'atualizado_em': '2026-06-29T10:30:00',
  };

  test('listarSolicitacoes fetches solicitacoes from API', () async {
    final service = SolicitacaoService(
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), '$apiBaseUrl/solicitacoes');

        return http.Response(jsonEncode([solicitacaoJson]), 200);
      }),
    );

    final solicitacoes = await service.listarSolicitacoes();

    expect(solicitacoes, hasLength(1));
    expect(solicitacoes.first.id, 1);
    expect(solicitacoes.first.status, 'ACEITA');
  });

  test('buscarSolicitacaoPorId fetches a solicitacao by id', () async {
    final service = SolicitacaoService(
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), '$apiBaseUrl/solicitacoes/1');

        return http.Response(jsonEncode(solicitacaoJson), 200);
      }),
    );

    final solicitacao = await service.buscarSolicitacaoPorId(1);

    expect(solicitacao.id, 1);
    expect(solicitacao.titulo, 'Instalacao eletrica');
  });

  test('atualizarStatus sends status and prestador_id to API', () async {
    final service = SolicitacaoService(
      client: MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.toString(), '$apiBaseUrl/solicitacoes/1/status');
        expect(request.headers['Content-Type'], 'application/json');
        expect(jsonDecode(request.body), {
          'status': 'EM_ANDAMENTO',
          'prestador_id': 3,
        });

        return http.Response(jsonEncode(solicitacaoJson), 200);
      }),
    );

    final solicitacao = await service.atualizarStatus(
      id: 1,
      status: 'EM_ANDAMENTO',
      prestadorId: 3,
    );

    expect(solicitacao.id, 1);
  });

  test('throws exception when API returns a non-200 status', () {
    final service = SolicitacaoService(
      client: MockClient((request) async {
        return http.Response('Erro', 500);
      }),
    );

    expect(service.listarSolicitacoes(), throwsA(isA<Exception>()));
  });

  test('throws exception when API connection fails', () {
    final service = SolicitacaoService(
      client: MockClient((request) {
        throw Exception('Connection refused');
      }),
    );

    expect(service.listarSolicitacoes(), throwsA(isA<Exception>()));
  });
}
