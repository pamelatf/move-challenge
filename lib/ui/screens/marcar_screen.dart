import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories.dart';
import '../../domain/datas.dart';
import '../../domain/models.dart';
import '../../domain/pontuacao.dart';
import '../dados_desafio.dart';
import '../theme/app_tokens.dart';
import '../widgets/activity_calendar.dart';
import '../widgets/app_card.dart';
import '../widgets/marcacao_sheet.dart';
import '../widgets/participant_avatar.dart';
import '../widgets/stat_card.dart';
import 'comemoracao_screen.dart';

class MarcarScreen extends StatefulWidget {
  const MarcarScreen({super.key, required this.dados});

  final DadosDesafio dados;

  @override
  State<MarcarScreen> createState() => _MarcarScreenState();
}

class _MarcarScreenState extends State<MarcarScreen> {
  late DateTime _mes = DateTime(DateTime.now().year, DateTime.now().month);

  Future<void> _abrirMarcacao(String data) async {
    final dados = widget.dados;
    final hoje = hojeChave();
    final dias = dados.diasDe(dados.uid);
    final resultado = await mostrarMarcacaoSheet(
      context,
      data: dataDaChave(data),
      atual: dias[data],
      podeUsarCoringa: podeUsarCoringa(dias, data),
    );
    if (resultado == null || !mounted) return;

    final repo = context.read<DesafioRepository>();
    final mensageiro = ScaffoldMessenger.of(context);
    final sequenciaAntes = sequenciaAtual(dias, hoje: hoje);
    final diasDepois = Map<String, Marcacao>.of(dias);

    Future<void> gravacao;
    if (resultado.remover) {
      diasDepois.remove(data);
      gravacao = repo.removerMarcacao(dados.desafio.id, dados.uid, data);
    } else {
      final nova = Marcacao(
        uid: dados.uid,
        data: data,
        tipo: resultado.tipo!,
        comAmigo: resultado.comAmigo,
      );
      diasDepois[data] = nova;
      gravacao = repo.salvarMarcacao(dados.desafio.id, nova);
    }

    // Não espera a confirmação do servidor: sem internet, o Firestore guarda
    // a alteração e envia quando a conexão voltar.
    gravacao.catchError((Object _) {
      mensageiro.showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível salvar o dia ${dataDaChave(data).day}.',
          ),
          action: SnackBarAction(
            label: 'Tentar de novo',
            onPressed: () => _abrirMarcacao(data),
          ),
        ),
      );
    });

    final sequenciaDepois = sequenciaAtual(diasDepois, hoje: hoje);
    final bonus = Regras.bonusPorSequencia[sequenciaDepois];
    if (!resultado.remover && bonus != null && sequenciaDepois > sequenciaAntes) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) =>
              ComemoracaoScreen(dias: sequenciaDepois, bonus: bonus),
        ),
      );
    } else {
      mensageiro.showSnackBar(
        SnackBar(
          content: Text(resultado.remover ? 'Dia desmarcado' : 'Dia salvo'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textos = Theme.of(context).textTheme;
    final dados = widget.dados;
    final hoje = hojeChave();
    final dias = dados.diasDe(dados.uid);
    final mesAtual = mesDaChave(hoje);
    final inicioDoMes = maiorChave(primeiroDiaDoMes(hoje), dados.desafio.dataInicio);
    final resultado = calcularPontuacao(
      dias,
      hoje: hoje,
      inicio: inicioDoMes,
      fim: ultimoDiaDoMes(hoje),
    );
    final sequencia = sequenciaAtual(dias, hoje: hoje);
    final restantes = coringasRestantes(dias, mesAtual);
    final chaveMesExibido = mesDaChave(chaveData(_mes));
    final podeAvancar = chaveMesExibido.compareTo(mesAtual) < 0;
    final podeVoltar =
        chaveMesExibido.compareTo(mesDaChave(dados.desafio.dataInicio)) > 0;
    final desafioComecou = hoje.compareTo(dados.desafio.dataInicio) >= 0;
    final primeiroNome = dados.eu.nome.split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dados.desafio.nome,
                        style:
                            textos.bodyMedium?.copyWith(color: t.textoSecundario),
                      ),
                      Text(
                        primeiroNome.isEmpty ? 'Olá' : 'Oi, $primeiroNome',
                        style: textos.headlineMedium,
                      ),
                    ],
                  ),
                ),
                ParticipantAvatar(nome: dados.eu.nome, cor: dados.eu.cor),
              ],
            ),
            if (!desafioComecou) ...[
              const SizedBox(height: 16),
              AppCard(
                cor: t.primariaContainer,
                child: Text(
                  'O desafio começa em ${dataCompleta(dataDaChave(dados.desafio.dataInicio))}.',
                  style: textos.bodyMedium
                      ?.copyWith(color: t.naPrimariaContainer),
                ),
              ),
            ],
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
                    valor: '$sequencia',
                    rotulo: sequencia == 1 ? 'dia seguido' : 'dias seguidos',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    icone: Icons.star_outline,
                    corIcone: t.coringaIcone,
                    valor: '$restantes',
                    rotulo: restantes == 1
                        ? 'coringa restante'
                        : 'coringas restantes',
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
                inicio: dados.desafio.dataInicio,
                onMesAnterior: podeVoltar
                    ? () => setState(
                          () => _mes = DateTime(_mes.year, _mes.month - 1),
                        )
                    : null,
                onProximoMes: podeAvancar
                    ? () => setState(
                          () => _mes = DateTime(_mes.year, _mes.month + 1),
                        )
                    : null,
                onDiaTocado: _abrirMarcacao,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: desafioComecou
          ? FloatingActionButton.extended(
              onPressed: () => _abrirMarcacao(hoje),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Marcar hoje'),
            )
          : null,
    );
  }
}
