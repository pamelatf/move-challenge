import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:move_challenge/ui/screens/boas_vindas_screen.dart';

import 'fakes.dart';

void main() {
  testWidgets('tela de boas-vindas mostra o nome do app e as ações',
      (tester) async {
    await tester.pumpWidget(comTema(const BoasVindasScreen()));

    expect(find.text('Move Challenge'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Criar conta'), findsOneWidget);
  });
}
