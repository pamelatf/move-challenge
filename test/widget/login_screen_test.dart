import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:move_challenge/data/repositories.dart';
import 'package:move_challenge/ui/screens/login_screen.dart';
import 'package:provider/provider.dart';

import '../fakes.dart';

void main() {
  late FakeAuthRepository auth;

  setUp(() => auth = FakeAuthRepository());

  Future<void> montar(WidgetTester tester) => tester.pumpWidget(
        Provider<AuthRepository>.value(
          value: auth,
          child: comTema(const LoginScreen()),
        ),
      );

  Future<void> tocarEmEntrar(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pumpAndSettle();
  }

  testWidgets('WID-09 [RN7] valida campos vazios sem chamar o login', (tester) async {
    await montar(tester);
    await tocarEmEntrar(tester);

    expect(find.text('Informe o e-mail.'), findsOneWidget);
    expect(find.text('Informe a senha.'), findsOneWidget);
    expect(auth.tentativasDeEntrar, 0);
  });

  testWidgets('WID-10 [RN7] mostra a mensagem quando o login falha', (tester) async {
    auth.erroAoEntrar =
        AuthException('E-mail ou senha incorretos. Confira e tente de novo.');
    await montar(tester);

    await tester.enterText(find.byKey(const Key('campo-email')), 'ana@email.com');
    await tester.enterText(find.byKey(const Key('campo-senha')), 'errada');
    await tocarEmEntrar(tester);

    expect(
      find.text('E-mail ou senha incorretos. Confira e tente de novo.'),
      findsOneWidget,
    );
  });

  testWidgets('WID-11 [RN7] envia o e-mail digitado quando os dados são válidos',
      (tester) async {
    await montar(tester);

    await tester.enterText(find.byKey(const Key('campo-email')), 'ana@email.com');
    await tester.enterText(find.byKey(const Key('campo-senha')), 'segredo1');
    await tocarEmEntrar(tester);

    expect(auth.tentativasDeEntrar, 1);
    expect(auth.emailUsado, 'ana@email.com');
    expect(find.byKey(const Key('erro-login')), findsNothing);
  });
}
