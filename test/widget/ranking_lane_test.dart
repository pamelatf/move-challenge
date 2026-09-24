import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:move_challenge/domain/models.dart';
import 'package:move_challenge/domain/pontuacao.dart';
import 'package:move_challenge/domain/ranking.dart';
import 'package:move_challenge/ui/widgets/ranking_lane.dart';

import '../fakes.dart';

void main() {
  ItemRanking item({int pontos = 20, int bonus = 3}) => ItemRanking(
        participante: const Participante(uid: 'u1', nome: 'Pâmela', cor: 0),
        resultado: ResultadoPontuacao(
          pontos: pontos,
          bonus: bonus,
          diasAtivos: 1,
          diasComAmigo: 0,
        ),
        sequencia: 4,
        posicao: 2,
      );

  testWidgets('WID-12 [RN6] mostra posição, pontos, detalhes e destaca você', (tester) async {
    await tester.pumpWidget(
      comTema(Scaffold(body: RankingLane(item: item(), maxPontos: 40, ehVoce: true))),
    );

    expect(find.text('2'), findsOneWidget);
    expect(find.textContaining('(você)', findRichText: true), findsOneWidget);
    expect(find.textContaining('20', findRichText: true), findsWidgets);
    expect(find.text('1 dia ativo, sequência de 4, +3 de bônus'), findsOneWidget);

    final barra = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(barra.value, 0.5);
  });

  testWidgets('WID-13 [RN3, RN6] sem bônus, não mostra o texto de bônus', (tester) async {
    await tester.pumpWidget(
      comTema(Scaffold(body: RankingLane(item: item(bonus: 0), maxPontos: 20))),
    );
    expect(find.text('1 dia ativo, sequência de 4'), findsOneWidget);
    expect(find.textContaining('(você)', findRichText: true), findsNothing);
  });
}
