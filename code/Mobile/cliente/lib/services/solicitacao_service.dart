import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/solicitacao.dart';

const String _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

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
  SolicitacaoService({String? token, http.Client? client})
    : _token = token,
      _client = client ?? http.Client();

  final String? _token;
  final http.Client _client;

  Future<List<Solicitacao>> listarSolicitacoes() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/solicitacoes'),
        headers: _headers(),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao listar solicitações.');
      }

      final data = jsonDecode(response.body) as List<dynamic>;

      return data
          .map((item) => Solicitacao.fromJson(item as Map<String, dynamic>))
          .toList();
    } on http.ClientException {
      throw Exception('Falha ao conectar com a API.');
    }
  }

  Future<Solicitacao> buscarSolicitacaoPorId(int id) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/solicitacoes/$id'),
        headers: _headers(),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao buscar solicitação.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return Solicitacao.fromJson(data);
    } on http.ClientException {
      throw Exception('Falha ao conectar com a API.');
    }
  }

  Future<Solicitacao> criarSolicitacao(Solicitacao solicitacao) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/solicitacoes'),
        headers: _headers(contentTypeJson: true),
        body: jsonEncode(solicitacao.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Erro ao criar solicitação.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return Solicitacao.fromJson(data);
    } on http.ClientException {
      throw Exception('Falha ao conectar com a API.');
    }
  }

  Map<String, String> _headers({bool contentTypeJson = false}) {
    return {
      if (contentTypeJson) 'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }
}
