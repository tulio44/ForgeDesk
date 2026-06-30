import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:prestador/models/solicitacao.dart';

const String _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
const String _configuredAuthToken = String.fromEnvironment('AUTH_TOKEN');

String get baseUrl {
  if (_configuredBaseUrl.isNotEmpty) {
    return _configuredBaseUrl;
  }

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8000';
  }

  return 'http://localhost:8000';
}

class SolicitacaoService {
  SolicitacaoService({
    http.Client? client,
    String? apiBaseUrl,
    String? authToken,
  }) : _client = client ?? http.Client(),
       _baseUrl = apiBaseUrl ?? baseUrl,
       _authToken = authToken ?? _configuredAuthToken;

  final http.Client _client;
  final String _baseUrl;
  final String _authToken;

  Future<List<Solicitacao>> listarSolicitacoes() async {
    final response = await _get('/solicitacoes');

    if (response.statusCode != 200) {
      throw Exception('Erro ao listar solicitacoes.');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => Solicitacao.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Solicitacao> buscarSolicitacaoPorId(int id) async {
    final response = await _get('/solicitacoes/$id');

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar solicitacao.');
    }

    return Solicitacao.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<Solicitacao> atualizarStatus({
    required int id,
    required String status,
    int? prestadorId,
  }) async {
    final body = <String, dynamic>{'status': status};

    if (prestadorId != null) {
      body['prestador_id'] = prestadorId;
    }

    final response = await _patch('/solicitacoes/$id/status', body);

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar status da solicitacao.');
    }

    return Solicitacao.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<http.Response> _get(String path) async {
    try {
      return await _client.get(_uri(path), headers: _headers());
    } on Exception {
      throw Exception('Falha ao conectar com a API.');
    }
  }

  Future<http.Response> _patch(String path, Map<String, dynamic> body) async {
    try {
      return await _client.patch(
        _uri(path),
        headers: _headers(contentTypeJson: true),
        body: jsonEncode(body),
      );
    } on Exception {
      throw Exception('Falha ao conectar com a API.');
    }
  }

  Uri _uri(String path) {
    return Uri.parse('$_baseUrl$path');
  }

  Map<String, String> _headers({bool contentTypeJson = false}) {
    return {
      if (contentTypeJson) 'Content-Type': 'application/json',
      if (_authToken.isNotEmpty) 'Authorization': 'Bearer $_authToken',
    };
  }
}
