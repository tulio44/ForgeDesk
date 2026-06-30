import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:prestador/services/auth_service.dart';

void main() {
  const apiBaseUrl = 'http://localhost:8000';

  test('login sends credentials and returns auth data', () async {
    final service = AuthService(
      apiBaseUrl: apiBaseUrl,
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), '$apiBaseUrl/auth/login');
        expect(request.headers['Content-Type'], 'application/json');
        expect(jsonDecode(request.body), {
          'email': 'prestador@forgedesk.com',
          'senha': '123456',
        });

        return http.Response(
          jsonEncode({
            'token': 'token-demo',
            'usuario': {
              'nome': 'Prestador Demo',
              'email': 'prestador@forgedesk.com',
            },
          }),
          200,
        );
      }),
    );

    final result = await service.login(
      email: 'prestador@forgedesk.com',
      senha: '123456',
    );

    expect(result.token, 'token-demo');
    expect(result.nome, 'Prestador Demo');
    expect(result.email, 'prestador@forgedesk.com');
  });

  test('login throws when API rejects credentials', () {
    final service = AuthService(
      apiBaseUrl: apiBaseUrl,
      client: MockClient((request) async {
        return http.Response('Erro', 401);
      }),
    );

    expect(
      service.login(email: 'prestador@forgedesk.com', senha: 'errada'),
      throwsA(isA<Exception>()),
    );
  });
}
