import 'package:flutter/material.dart';

import '../../domain/ranking.dart';
import '../theme/app_tokens.dart';
import 'participant_avatar.dart';

/// Linha do ranking em formato de raia: a barra mostra os pontos da pessoa
/// em relação aos pontos de quem lidera.
class RankingLane extends StatelessWidget {
  const RankingLane({
    super.key,
    required this.item,
    required this.maxPontos,
    this.ehVoce = false,
    this.onTap,
  });

  final ItemRanking item;
  final int maxPontos;
  final bool ehVoce;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textos = Theme.of(context).textTheme;
    final r = item.resultado;
    final progresso =
        maxPontos <= 0 ? 0.0 : (r.pontos / maxPontos).clamp(0.0, 1.0).toDouble();
    final cor = corDoParticipante(item.participante.cor);
    final detalhes = [
      '${r.diasAtivos} ${r.diasAtivos == 1 ? 'dia ativo' : 'dias ativos'}',
      'sequência de ${item.sequencia}',
      if (r.bonus > 0) '+${r.bonus} de bônus',
    ].join(', ');

    return Material(
      color: ehVoce ? t.superficieContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 22,
                    child: Text(
                      '${item.posicao}',
                      style: textos.titleMedium
                          ?.copyWith(color: t.textoSecundario),
                    ),
                  ),
                  ParticipantAvatar(
                    nome: item.participante.nome,
                    cor: item.participante.cor,
                    tamanho: 36,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: item.participante.nome,
                        style: textos.titleMedium,
                        children: [
                          if (ehVoce)
                            TextSpan(
                              text: ' (você)',
                              style: textos.labelMedium
                                  ?.copyWith(color: t.textoSecundario),
                            ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: '${r.pontos}',
                      style: textos.headlineSmall,
                      children: [
                        TextSpan(
                          text: ' pts',
                          style: textos.labelMedium
                              ?.copyWith(color: t.textoSecundario),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 34),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progresso,
                    minHeight: 8,
                    color: cor,
                    backgroundColor: t.superficieMaisAlta,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 34),
                child: Text(
                  detalhes,
                  style: textos.bodySmall?.copyWith(color: t.textoSecundario),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
