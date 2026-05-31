import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:veiculos_app/providers/login_provider.dart';
import 'package:veiculos_app/screens/login_screen.dart';

void main() {
  testWidgets('Login screen shows email, password and submit button',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LoginProvider(),
        child: const MaterialApp(home: LoginScreen(pularIntro: true)),
      ),
    );

    await tester.pump();

    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
  });
}
