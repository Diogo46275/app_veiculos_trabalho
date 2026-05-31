import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:veiculos_app/services/auth_service.dart';
import 'package:veiculos_app/validacao/mensagens_validacao.dart';

void main() {
  group('AuthService.login', () {
    test('401 retorna email ou senha inválidos', () async {
      final service = AuthService(
        client: MockClient((_) async {
          return http.Response(
            jsonEncode({'detail': 'E-mail ou senha incorretos'}),
            401,
          );
        }),
      );

      expect(
        () => service.login(email: 'a@b.com', senha: 'x'),
        throwsA(
          predicate<AuthException>(
            (e) => e.message == 'Email ou senha inválidos' && e.campo == null,
          ),
        ),
      );
      service.dispose();
    });

    test('422 de email inválido retorna erro no campo email', () async {
      final service = AuthService(
        client: MockClient((_) async {
          return http.Response(
            jsonEncode({
              'detail': [
                {
                  'type': 'value_error',
                  'loc': ['body', 'email'],
                  'msg': 'value is not a valid email address',
                  'input': 'diogo46275@.gmail.com',
                },
              ],
            }),
            422,
          );
        }),
      );

      expect(
        () => service.login(
          email: 'diogo46275@.gmail.com',
          senha: 'senha123',
        ),
        throwsA(
          predicate<AuthException>(
            (e) =>
                e.message == MensagensValidacao.emailInvalido &&
                e.campo == 'email',
          ),
        ),
      );
      service.dispose();
    });
  });
}
