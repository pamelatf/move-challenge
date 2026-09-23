import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:move_challenge/domain/models.dart';
import 'package:move_challenge/ui/widgets/activity_calendar.dart';

import '../fakes.dart';

void main() {
  Future<void> montar(
    WidgetTester tester, {
    ValueChanged<String>? onDiaTocado,
  }) async {
    usarTelaDeCelular(tester);
    final dias = {
      '2026-09-01': marcacao('2026-09-01'),
      '2026-09-02':
          marcacao('2026-09-02', tipo: TipoMarcacao.leve, comAmigo: true),
      '2026-09-03': marcacao('2026-09-03', tipo: TipoMarcacao.coringa),
    };
    await tester.pumpWidget(
      comTema(
        Scaffold(
          body: SingleChildScrollView(
            child: ActivityCalendar(
              mes: DateTime(2026, 9),
              dias: dias,
              hoje: '2026-09-22',
              inicio: '2026-09-01',
              onDiaTocado: onDiaTocado,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('mostra o mês e descreve o status de cada dia', (tester) async {
    final semantica = tester.ensureSemantics();
    await montar(tester);

    expect(find.text('Setembro 2026'), findsOneWidget);
    expect(find.bySemanticsLabel('1 de setembro, treinei'), findsOneWidget);
    expect(
      find.bySemanticsLabel('2 de setembro, dia leve, com alguém do desafio'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('3 de setembro, coringa'), findsOneWidget);
    expect(find.bySemanticsLabel('22 de setembro, hoje'), findsOneWidget);
    expect(
      find.bySemanticsLabel('25 de setembro, indisponível'),
      findsOneWidget,
    );
    semantica.dispose();
  });

  testWidgets('permite tocar em dias passados e bloqueia dias futuros',
      (tester) async {
    String? tocado;
    await montar(tester, onDiaTocado: (dia) => tocado = dia);

    await tester.tap(find.byKey(const ValueKey('dia-2026-09-10')));
    expect(tocado, '2026-09-10');

    tocado = null;
    await tester.tap(
      find.byKey(const ValueKey('dia-2026-09-25')),
      warnIfMissed: false,
    );
    expect(tocado, isNull);
  });

  testWidgets('sem callback o calendário fica somente leitura', (tester) async {
    await montar(tester);
    await tester.tap(find.byKey(const ValueKey('dia-2026-09-10')));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
