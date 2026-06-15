import 'dart:convert';

import 'package:http/http.dart' as http;

import 'solicitacao_service.dart';

class AuthResult {
  const AuthResult({
    required this.token,
    required this.nome,
    required this.email,
  });

  final String token;
  final String nome;
  final String email;
}

class AuthService {
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<AuthResult> login({
    required String email,
    required String senha,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      if (response.statusCode != 200) {
        throw Exception('E-mail ou senha inválidos.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final usuario = data['usuario'] as Map<String, dynamic>;

      return AuthResult(
        token: data['token'] as String,
        nome: usuario['nome'] as String,
        email: usuario['email'] as String,
      );
    } on http.ClientException {
      throw Exception('Falha ao conectar com a API.');
    }
  }
}
