import 'dart:math' as math;

import 'datas.dart';
import 'models.dart';

/// Regras de pontuação do desafio, centralizadas para facilitar ajustes.
class Regras {
  Regras._();

  static const int pontosPorDiaAtivo = 1;
  static const int pontosComAmigo = 1;
  static const Map<int, int> bonusPorSequencia = {7: 3, 14: 5, 30: 10};
  static const int coringasPorMes = 1;

  /// Próxima sequência que dá bônus, ou null se todas já foram alcançadas.
  static int? proximaMeta(int sequencia) {
    for (final meta in bonusPorSequencia.keys) {
      if (meta > sequencia) return meta;
    }
    return null;
  }
}

class ResultadoPontuacao {
  const ResultadoPontuacao({
    required this.pontos,
    required this.bonus,
    required this.diasAtivos,
    required this.diasComAmigo,
  });

  static const vazio =
      ResultadoPontuacao(pontos: 0, bonus: 0, diasAtivos: 0, diasComAmigo: 0);

  final int pontos;
  final int bonus;
  final int diasAtivos;
  final int diasComAmigo;
}

/// Calcula os pontos de UMA pessoa.
///
/// [dias] mapeia a data (`aaaa-mm-dd`) para a marcação daquele dia.
/// A sequência é contada em todo o histórico, mas só entram no resultado
/// os pontos e bônus de dias entre [inicio] e [fim] (inclusive).
/// Marcações depois de [hoje] são ignoradas.
ResultadoPontuacao calcularPontuacao(
  Map<String, Marcacao> dias, {
  required String hoje,
  String? inicio,
  String? fim,
}) {
  if (dias.isEmpty) return ResultadoPontuacao.vazio;

  final chaves = dias.keys.toList()..sort();
  var dia = chaves.first;
  var sequencia = 0;
  var pontos = 0;
  var bonus = 0;
  var diasAtivos = 0;
  var diasComAmigo = 0;

  while (dia.compareTo(hoje) <= 0) {
    final marcacao = dias[dia];
    final dentroDoPeriodo = (inicio == null || dia.compareTo(inicio) >= 0) &&
        (fim == null || dia.compareTo(fim) <= 0);

    if (marcacao == null) {
      sequencia = 0;
    } else {
      sequencia++;
      if (dentroDoPeriodo && marcacao.ativa) {
        pontos += Regras.pontosPorDiaAtivo;
        diasAtivos++;
        if (marcacao.comAmigo) {
          pontos += Regras.pontosComAmigo;
          diasComAmigo++;
        }
      }
      final extra = Regras.bonusPorSequencia[sequencia];
      if (dentroDoPeriodo && extra != null) {
        bonus += extra;
        pontos += extra;
      }
    }
    dia = somarDias(dia, 1);
  }

  return ResultadoPontuacao(
    pontos: pontos,
    bonus: bonus,
    diasAtivos: diasAtivos,
    diasComAmigo: diasComAmigo,
  );
}

/// Dias seguidos até hoje. Se hoje ainda não foi marcado, conta até ontem,
/// para a sequência não "zerar" logo de manhã.
int sequenciaAtual(Map<String, Marcacao> dias, {required String hoje}) {
  var dia = dias.containsKey(hoje) ? hoje : somarDias(hoje, -1);
  var total = 0;
  while (dias.containsKey(dia)) {
    total++;
    dia = somarDias(dia, -1);
  }
  return total;
}

/// [mes] no formato `aaaa-mm`.
int coringasUsadosNoMes(Map<String, Marcacao> dias, String mes) => dias.values
    .where((m) => m.tipo == TipoMarcacao.coringa && mesDaChave(m.data) == mes)
    .length;

int coringasRestantes(Map<String, Marcacao> dias, String mes) =>
    math.max(0, Regras.coringasPorMes - coringasUsadosNoMes(dias, mes));

/// Se a pessoa pode usar coringa em [data]. Editar um dia que já é coringa
/// continua permitido.
bool podeUsarCoringa(Map<String, Marcacao> dias, String data) {
  if (dias[data]?.tipo == TipoMarcacao.coringa) return true;
  return coringasUsadosNoMes(dias, mesDaChave(data)) < Regras.coringasPorMes;
}
