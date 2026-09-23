import 'datas.dart';
import 'models.dart';
import 'pontuacao.dart';

enum PeriodoRanking { mes, total }

class ItemRanking {
  const ItemRanking({
    required this.participante,
    required this.resultado,
    required this.sequencia,
    required this.posicao,
  });

  final Participante participante;
  final ResultadoPontuacao resultado;
  final int sequencia;
  final int posicao;
}

Map<String, Map<String, Marcacao>> agruparPorParticipante(
  Iterable<Marcacao> marcacoes,
) {
  final resultado = <String, Map<String, Marcacao>>{};
  for (final m in marcacoes) {
    resultado.putIfAbsent(m.uid, () => <String, Marcacao>{})[m.data] = m;
  }
  return resultado;
}

/// Ordena por pontos; empate vai para a maior sequência e depois ordem
/// alfabética.
List<ItemRanking> gerarRanking({
  required List<Participante> participantes,
  required List<Marcacao> marcacoes,
  required PeriodoRanking periodo,
  required String hoje,
  required String inicioDesafio,
}) {
  final porParticipante = agruparPorParticipante(marcacoes);
  final doMes = periodo == PeriodoRanking.mes;
  final inicio =
      doMes ? maiorChave(primeiroDiaDoMes(hoje), inicioDesafio) : inicioDesafio;
  final fim = doMes ? ultimoDiaDoMes(hoje) : null;

  final itens = participantes.map((p) {
    final dias = porParticipante[p.uid] ?? <String, Marcacao>{};
    return (
      participante: p,
      resultado: calcularPontuacao(dias, hoje: hoje, inicio: inicio, fim: fim),
      sequencia: sequenciaAtual(dias, hoje: hoje),
    );
  }).toList();

  itens.sort((a, b) {
    final porPontos = b.resultado.pontos.compareTo(a.resultado.pontos);
    if (porPontos != 0) return porPontos;
    final porSequencia = b.sequencia.compareTo(a.sequencia);
    if (porSequencia != 0) return porSequencia;
    return a.participante.nome
        .toLowerCase()
        .compareTo(b.participante.nome.toLowerCase());
  });

  return [
    for (var i = 0; i < itens.length; i++)
      ItemRanking(
        participante: itens[i].participante,
        resultado: itens[i].resultado,
        sequencia: itens[i].sequencia,
        posicao: i + 1,
      ),
  ];
}

/// Texto pronto para compartilhar no grupo.
String textoRanking({
  required String nomeDesafio,
  required List<ItemRanking> itens,
  required PeriodoRanking periodo,
  required String hoje,
}) {
  final titulo = periodo == PeriodoRanking.mes
      ? 'Ranking de ${meses[dataDaChave(hoje).month - 1]}'
      : 'Ranking geral';
  final linhas = itens.map((i) {
    final dias = i.sequencia == 1 ? 'dia' : 'dias';
    final sequencia =
        i.sequencia > 0 ? ' (sequência de ${i.sequencia} $dias)' : '';
    return '${i.posicao}. ${i.participante.nome}: ${i.resultado.pontos} pts$sequencia';
  });
  return ['Move Challenge: $nomeDesafio', titulo, '', ...linhas].join('\n');
}
