import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/datas.dart';
import '../../domain/ranking.dart';
import '../dados_desafio.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_card.dart';
import '../widgets/ranking_lane.dart';
import 'calendario_participante_screen.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key, required this.dados});

  final DadosDesafio dados;

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  PeriodoRanking _periodo = PeriodoRanking.mes;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textos = Theme.of(context).textTheme;
    final dados = widget.dados;
    final hoje = hojeChave();
    final itens = gerarRanking(
      participantes: dados.participantes,
      marcacoes: dados.marcacoes,
      periodo: _periodo,
      hoje: hoje,
      inicioDesafio: dados.desafio.dataInicio,
    );
    final maxPontos = itens.isEmpty ? 0 : itens.first.resultado.pontos;
    final ninguemPontuou = maxPontos == 0;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text('Ranking', style: textos.headlineLarge),
            const SizedBox(height: 16),
            SegmentedButton<PeriodoRanking>(
              segments: const [
                ButtonSegment(value: PeriodoRanking.mes, label: Text('Este mês')),
                ButtonSegment(
                  value: PeriodoRanking.total,
                  label: Text('Desde o início'),
                ),
              ],
              selected: {_periodo},
              onSelectionChanged: (s) => setState(() => _periodo = s.first),
            ),
            const SizedBox(height: 16),
            if (ninguemPontuou)
              AppCard(
                child: Text(
                  'O ranking aparece quando as pessoas começarem a marcar os dias.',
                  style: textos.bodyMedium?.copyWith(color: t.textoSecundario),
                ),
              )
            else
              AppCard(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    for (final item in itens)
                      RankingLane(
                        item: item,
                        maxPontos: maxPontos,
                        ehVoce: item.participante.uid == dados.uid,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CalendarioParticipanteScreen(
                              dados: dados,
                              item: item,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: ninguemPontuou
                  ? null
                  : () => Share.share(
                        textoRanking(
                          nomeDesafio: dados.desafio.nome,
                          itens: itens,
                          periodo: _periodo,
                          hoje: hoje,
                        ),
                      ),
              icon: const Icon(Icons.share),
              label: const Text('Compartilhar ranking'),
            ),
          ],
        ),
      ),
    );
  }
}
