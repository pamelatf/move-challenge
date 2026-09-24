import 'package:flutter_test/flutter_test.dart';
import 'package:move_challenge/domain/models.dart';
import 'package:move_challenge/domain/ranking.dart';

import '../fakes.dart';

void main() {
  const hoje = '2026-09-22';
  const ana = Participante(uid: 'ana', nome: 'Ana', cor: 0);
  const bia = Participante(uid: 'bia', nome: 'Bia', cor: 1);
  const carol = Participante(uid: 'carol', nome: 'Carol', cor: 2);

  List<ItemRanking> ranking(
    List<Marcacao> marcacoes, {
    PeriodoRanking periodo = PeriodoRanking.mes,
  }) =>
      gerarRanking(
        participantes: const [ana, bia, carol],
        marcacoes: marcacoes,
        periodo: periodo,
        hoje: hoje,
        inicioDesafio: '2026-08-01',
      );

  test('UNI-20 [RN6] ordena por pontos e inclui quem não marcou nada', () {
    final itens = ranking([
      marcacao('2026-09-01', uid: 'bia'),
      marcacao('2026-09-02', uid: 'bia'),
      marcacao('2026-09-01', uid: 'ana'),
    ]);
    expect(itens.map((i) => i.participante.uid), ['bia', 'ana', 'carol']);
    expect(itens.map((i) => i.posicao), [1, 2, 3]);
    expect(itens.last.resultado.pontos, 0);
  });

  test('UNI-21 [RN6] no empate, vence a maior sequência atual', () {
    final itens = ranking([
      marcacao('2026-09-01', uid: 'ana'),
      marcacao('2026-09-02', uid: 'ana'),
      marcacao('2026-09-20', uid: 'carol'),
      marcacao('2026-09-21', uid: 'carol'),
    ]);
    expect(itens.first.participante.uid, 'carol');
    expect(itens.first.sequencia, 2);
  });

  test('UNI-22 [RN6] no empate total, usa ordem alfabética', () {
    final itens = ranking([]);
    expect(itens.map((i) => i.participante.nome), ['Ana', 'Bia', 'Carol']);
  });

  test('UNI-23 [RN6] período do mês ignora meses anteriores; total considera tudo', () {
    final marcacoes = [
      marcacao('2026-08-10', uid: 'ana'),
      marcacao('2026-08-11', uid: 'ana'),
      marcacao('2026-09-10', uid: 'bia'),
    ];
    final doMes = ranking(marcacoes);
    expect(doMes.first.participante.uid, 'bia');

    final total = ranking(marcacoes, periodo: PeriodoRanking.total);
    expect(total.first.participante.uid, 'ana');
    expect(total.first.resultado.pontos, 2);
  });

  test('UNI-24 [RN6] gera texto para compartilhar no grupo', () {
    final itens = ranking([
      marcacao('2026-09-21', uid: 'ana'),
      marcacao('2026-09-22', uid: 'ana'),
    ]);
    final texto = textoRanking(
      nomeDesafio: 'Desafio das amigas',
      itens: itens,
      periodo: PeriodoRanking.mes,
      hoje: hoje,
    );
    expect(
      texto,
      'Move Challenge: Desafio das amigas\n'
      'Ranking de setembro\n'
      '\n'
      '1. Ana: 2 pts (sequência de 2 dias)\n'
      '2. Bia: 0 pts\n'
      '3. Carol: 0 pts',
    );
  });
}
