import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:move_challenge/domain/models.dart';
import 'package:move_challenge/ui/widgets/marcacao_sheet.dart';

import '../fakes.dart';

class _Captura {
  ResultadoMarcacao? resultado;
}

void main() {
  /// Monta um botão que abre a folha de marcação e já toca nele.
  Future<_Captura> abrirSheet(
    WidgetTester tester, {
    Marcacao? atual,
    bool podeUsarCoringa = true,
  }) async {
    usarTelaDeCelular(tester);
    final captura = _Captura();
    await tester.pumpWidget(
      comTema(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                captura.resultado = await mostrarMarcacaoSheet(
                  context,
                  data: DateTime(2026, 9, 22),
                  atual: atual,
                  podeUsarCoringa: podeUsarCoringa,
                );
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    return captura;
  }

  FilledButton botaoSalvar(WidgetTester tester) =>
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Salvar'));

  testWidgets('WID-04 [RN1, RN2] mostra a data e só libera salvar após escolher', (tester) async {
    final captura = await abrirSheet(tester);

    expect(find.text('Terça-feira, 22 de setembro'), findsOneWidget);
    expect(botaoSalvar(tester).onPressed, isNull);

    await tester.tap(find.text('Dia leve'));
    await tester.pump();
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(captura.resultado?.tipo, TipoMarcacao.leve);
    expect(captura.resultado?.comAmigo, isTrue);
    expect(captura.resultado?.remover, isFalse);
  });

  testWidgets('WID-05 [RN4] coringa já usado no mês fica indisponível', (tester) async {
    await abrirSheet(tester, podeUsarCoringa: false);

    expect(find.text('Coringa do mês já usado'), findsOneWidget);
    await tester.tap(find.text('Usar coringa'), warnIfMissed: false);
    await tester.pump();
    expect(botaoSalvar(tester).onPressed, isNull);
  });

  testWidgets('WID-06 [RN2, RN4] ao escolher coringa, treinar com alguém fica desabilitado',
      (tester) async {
    await abrirSheet(tester);

    await tester.tap(find.text('Usar coringa'));
    await tester.pump();
    final opcao = tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
    expect(opcao.onChanged, isNull);
  });

  testWidgets('WID-07 [RN5] desmarcar não aparece para um dia sem marcação', (tester) async {
    await abrirSheet(tester);
    expect(find.text('Desmarcar dia'), findsNothing);
  });

  testWidgets('WID-08 [RN5] desmarcar devolve o pedido de remoção', (tester) async {
    final captura = await abrirSheet(tester, atual: marcacao('2026-09-22'));

    await tester.tap(find.text('Desmarcar dia'));
    await tester.pumpAndSettle();
    expect(captura.resultado?.remover, isTrue);
  });
}
