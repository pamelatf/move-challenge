import 'package:flutter_test/flutter_test.dart';
import 'package:move_challenge/domain/models.dart';
import 'package:move_challenge/domain/pontuacao.dart';

import '../fakes.dart';

void main() {
  const hoje = '2026-09-22';

  group('calcularPontuacao', () {
    test('UNI-05 [RN1] sem marcações não pontua', () {
      final r = calcularPontuacao({}, hoje: hoje);
      expect(r.pontos, 0);
      expect(r.diasAtivos, 0);
    });

    test('UNI-06 [RN1] treino e dia leve valem 1 ponto cada', () {
      final dias = {
        '2026-09-01': marcacao('2026-09-01'),
        '2026-09-03': marcacao('2026-09-03', tipo: TipoMarcacao.leve),
      };
      final r = calcularPontuacao(dias, hoje: hoje);
      expect(r.pontos, 2);
      expect(r.diasAtivos, 2);
    });

    test('UNI-07 [RN2] treinar com alguém do desafio soma 1 ponto extra', () {
      final dias = {'2026-09-01': marcacao('2026-09-01', comAmigo: true)};
      final r = calcularPontuacao(dias, hoje: hoje);
      expect(r.pontos, 2);
      expect(r.diasComAmigo, 1);
    });

    test('UNI-08 [RN4] coringa não pontua, mas mantém a sequência', () {
      final dias = diasSeguidos('2026-09-01', 7);
      dias['2026-09-04'] = marcacao('2026-09-04', tipo: TipoMarcacao.coringa);
      final r = calcularPontuacao(dias, hoje: hoje);
      // 6 dias ativos + 3 de bônus pelos 7 dias seguidos.
      expect(r.diasAtivos, 6);
      expect(r.bonus, 3);
      expect(r.pontos, 9);
    });

    test('UNI-09 [RN3] bônus de 7, 14 e 30 dias seguidos', () {
      expect(calcularPontuacao(diasSeguidos('2026-08-01', 7), hoje: hoje).bonus, 3);
      expect(calcularPontuacao(diasSeguidos('2026-08-01', 14), hoje: hoje).bonus, 8);
      final trinta = calcularPontuacao(diasSeguidos('2026-08-01', 30), hoje: hoje);
      expect(trinta.bonus, 18);
      expect(trinta.pontos, 48);
    });

    test('UNI-10 [RN3] um dia sem marcação zera a sequência', () {
      final dias = {
        ...diasSeguidos('2026-09-01', 6),
        ...diasSeguidos('2026-09-08', 6),
      };
      final r = calcularPontuacao(dias, hoje: hoje);
      expect(r.bonus, 0);
      expect(r.pontos, 12);
    });

    test('UNI-11 [RN3, RN6] filtra pontos e bônus pelo período, contando a sequência de antes', () {
      // 14 dias seguidos de 20/08 a 02/09: 7 dias em 26/08 e 14 dias em 02/09.
      final dias = diasSeguidos('2026-08-20', 14);
      final r = calcularPontuacao(
        dias,
        hoje: hoje,
        inicio: '2026-09-01',
        fim: '2026-09-30',
      );
      expect(r.diasAtivos, 2);
      expect(r.bonus, 5);
      expect(r.pontos, 7);
    });

    test('UNI-12 [RN5] ignora marcações depois de hoje', () {
      final dias = {'2026-09-30': marcacao('2026-09-30')};
      expect(calcularPontuacao(dias, hoje: hoje).pontos, 0);
    });
  });

  group('sequenciaAtual', () {
    test('UNI-13 [RN3] conta a partir de hoje quando hoje já foi marcado', () {
      expect(sequenciaAtual(diasSeguidos('2026-09-18', 5), hoje: hoje), 5);
    });

    test('UNI-14 [RN3] conta até ontem quando hoje ainda não foi marcado', () {
      expect(sequenciaAtual(diasSeguidos('2026-09-18', 4), hoje: hoje), 4);
    });

    test('UNI-15 [RN3] é zero quando ontem e hoje estão vazios', () {
      expect(sequenciaAtual(diasSeguidos('2026-09-10', 5), hoje: hoje), 0);
    });
  });

  group('coringa', () {
    test('UNI-16 [RN4] só um coringa por mês', () {
      final dias = {
        '2026-09-05': marcacao('2026-09-05', tipo: TipoMarcacao.coringa),
      };
      expect(podeUsarCoringa(dias, '2026-09-10'), isFalse);
      expect(coringasRestantes(dias, '2026-09'), 0);
    });

    test('UNI-17 [RN4] libera coringa em outro mês', () {
      final dias = {
        '2026-08-30': marcacao('2026-08-30', tipo: TipoMarcacao.coringa),
      };
      expect(podeUsarCoringa(dias, '2026-09-10'), isTrue);
    });

    test('UNI-18 [RN4, RN5] permite editar o dia que já é coringa', () {
      final dias = {
        '2026-09-05': marcacao('2026-09-05', tipo: TipoMarcacao.coringa),
      };
      expect(podeUsarCoringa(dias, '2026-09-05'), isTrue);
    });
  });

  group('Regras.proximaMeta', () {
    test('UNI-19 [RN3] indica a próxima sequência com bônus', () {
      expect(Regras.proximaMeta(0), 7);
      expect(Regras.proximaMeta(7), 14);
      expect(Regras.proximaMeta(14), 30);
      expect(Regras.proximaMeta(30), isNull);
    });
  });
}
