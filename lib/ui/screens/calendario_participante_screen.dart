import 'package:flutter/material.dart';

import '../../domain/datas.dart';
import '../../domain/pontuacao.dart';
import '../../domain/ranking.dart';
import '../dados_desafio.dart';
import '../theme/app_tokens.dart';
import '../widgets/activity_calendar.dart';
import '../widgets/app_card.dart';
import '../widgets/participant_avatar.dart';
import '../widgets/stat_card.dart';

/// Calendário de outra pessoa, somente leitura.
class CalendarioParticipanteScreen extends StatefulWidget {
  const CalendarioParticipanteScreen({
    super.key,
    required this.dados,
    required this.item,
  });

  final DadosDesafio dados;
  final ItemRanking item;

  @override
  State<CalendarioParticipanteScreen> createState() =>
      _CalendarioParticipanteScreenState();
}

class _CalendarioParticipanteScreenState
    extends State<CalendarioParticipanteScreen> {
  late DateTime _mes = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textos = Theme.of(context).textTheme;
    final p = widget.item.participante;
    final hoje = hojeChave();
    final dias = widget.dados.diasDe(p.uid);
    final inicio = widget.dados.desafio.dataInicio;
    final resultado = calcularPontuacao(
      dias,
      hoje: hoje,
      inicio: maiorChave(primeiroDiaDoMes(hoje), inicio),
      fim: ultimoDiaDoMes(hoje),
    );
    final restantes = coringasRestantes(dias, mesDaChave(hoje));
    final mesExibido = mesDaChave(chaveData(_mes));

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Row(
              children: [
                ParticipantAvatar(nome: p.nome, cor: p.cor, tamanho: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.nome, style: textos.headlineMedium),
                      Text(
                        '${widget.item.posicao}º lugar',
                        style: textos.bodyMedium
                            ?.copyWith(color: t.textoSecundario),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icone: Icons.leaderboard_outlined,
                    corIcone: t.primaria,
                    valor: '${resultado.pontos}',
                    rotulo: 'pontos no mês',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    icone: Icons.local_fire_department_outlined,
                    corIcone: t.treinoIcone,
                    valor: '${widget.item.sequencia}',
                    rotulo: 'dias seguidos',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    icone: Icons.star_outline,
                    corIcone: t.coringaIcone,
                    valor: '$restantes',
                    rotulo: 'coringa restante',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.all(12),
              child: ActivityCalendar(
                mes: _mes,
                dias: dias,
                hoje: hoje,
                inicio: inicio,
                onMesAnterior: mesExibido.compareTo(mesDaChave(inicio)) > 0
                    ? () => setState(
                          () => _mes = DateTime(_mes.year, _mes.month - 1),
                        )
                    : null,
                onProximoMes: mesExibido.compareTo(mesDaChave(hoje)) < 0
                    ? () => setState(
                          () => _mes = DateTime(_mes.year, _mes.month + 1),
                        )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
