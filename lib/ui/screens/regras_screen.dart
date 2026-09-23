import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../../domain/pontuacao.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_card.dart';
import '../widgets/status_visual.dart';

class RegrasScreen extends StatelessWidget {
  const RegrasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textos = Theme.of(context).textTheme;
    String pontos(int n) => n == 1 ? '1 ponto' : '$n pontos';

    final linhas = <(IconData, Color, String, String)>[
      (
        Icons.check_circle_outline,
        t.treinoIcone,
        'Dia com atividade (20 a 30 minutos ou mais)',
        pontos(Regras.pontosPorDiaAtivo),
      ),
      (
        Icons.directions_walk,
        t.leveIcone,
        'Dia leve: alongamento ou caminhada curta',
        pontos(Regras.pontosPorDiaAtivo),
      ),
      (
        Icons.group_outlined,
        t.primaria,
        'Treinar com alguém do desafio, junto ou por chamada de vídeo',
        '+${pontos(Regras.pontosComAmigo)}',
      ),
      for (final entrada in Regras.bonusPorSequencia.entries)
        (
          Icons.local_fire_department_outlined,
          t.treinoIcone,
          '${entrada.key} dias seguidos',
          '+${pontos(entrada.value)}',
        ),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text('Regras', style: textos.headlineLarge),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  for (var i = 0; i < linhas.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Icon(linhas[i].$1, color: linhas[i].$2, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(linhas[i].$3, style: textos.bodyMedium),
                          ),
                          const SizedBox(width: 8),
                          Text(linhas[i].$4, style: textos.labelLarge),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StatusIcone(tipo: TipoMarcacao.coringa),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Como funciona o coringa', style: textos.titleLarge),
                        const SizedBox(height: 6),
                        Text(
                          'Cada pessoa tem ${Regras.coringasPorMes} coringa por mês. '
                          'Ele vale como descanso: não soma pontos, mas mantém a sua sequência de dias.',
                          style: textos.bodyMedium
                              ?.copyWith(color: t.textoSecundario),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
