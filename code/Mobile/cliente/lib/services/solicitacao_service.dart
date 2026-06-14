import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/solicitacao.dart';

const String baseUrl = 'http://localhost:8000';
// Para emulador Android, use: http://10.0.2.2:8000

class SolicitacaoService {
  SolicitacaoService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Solicitacao>> listarSolicitacoes() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/solicitacoes'));

      if (response.statusCode != 200) {
        throw Exception('Erro ao listar solicitacoes.');
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
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao buscar solicitacao.');
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
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(solicitacao.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Erro ao criar solicitacao.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return Solicitacao.fromJson(data);
    } on http.ClientException {
      throw Exception('Falha ao conectar com a API.');
    }
  }
}
