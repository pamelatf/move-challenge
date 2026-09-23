import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories.dart';
import '../../domain/models.dart';
import '../dados_desafio.dart';
import '../widgets/estados.dart';
import 'marcar_screen.dart';
import 'perfil_screen.dart';
import 'ranking_screen.dart';
import 'regras_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.desafioId, required this.uid});

  final String desafioId;
  final String uid;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final Stream<Desafio?> _desafio;
  late final Stream<List<Participante>> _participantes;
  late final Stream<List<Marcacao>> _marcacoes;
  int _aba = 0;

  @override
  void initState() {
    super.initState();
    final repo = context.read<DesafioRepository>();
    _desafio = repo.desafio(widget.desafioId);
    _participantes = repo.participantes(widget.desafioId);
    _marcacoes = repo.marcacoes(widget.desafioId);
  }

  Widget _erro() => TelaErro(
        titulo: 'Não foi possível abrir o desafio',
        mensagem:
            'Confira sua conexão. Se o problema continuar, saia e entre de novo.',
        rotuloAcao: 'Sair da conta',
        onAcao: () => context.read<AuthRepository>().sair(),
      );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Desafio?>(
      stream: _desafio,
      builder: (context, sDesafio) {
        if (sDesafio.hasError) return _erro();
        if (sDesafio.connectionState == ConnectionState.waiting) {
          return const TelaCarregando(mensagem: 'Carregando o desafio');
        }
        final desafio = sDesafio.data;
        if (desafio == null) return _erro();

        return StreamBuilder<List<Participante>>(
          stream: _participantes,
          builder: (context, sParticipantes) {
            if (sParticipantes.hasError) return _erro();
            final participantes = sParticipantes.data;
            if (participantes == null) {
              return const TelaCarregando(mensagem: 'Carregando o desafio');
            }
            return StreamBuilder<List<Marcacao>>(
              stream: _marcacoes,
              builder: (context, sMarcacoes) {
                if (sMarcacoes.hasError) return _erro();
                final marcacoes = sMarcacoes.data;
                if (marcacoes == null) {
                  return const TelaCarregando(mensagem: 'Carregando o desafio');
                }
                final dados = DadosDesafio(
                  uid: widget.uid,
                  desafio: desafio,
                  participantes: participantes,
                  marcacoes: marcacoes,
                );
                return _estrutura(dados);
              },
            );
          },
        );
      },
    );
  }

  Widget _estrutura(DadosDesafio dados) {
    final abas = <Widget>[
      MarcarScreen(dados: dados),
      RankingScreen(dados: dados),
      const RegrasScreen(),
      PerfilScreen(dados: dados),
    ];
    return Scaffold(
      body: abas[_aba],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: (i) => setState(() => _aba = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Marcar',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard),
            label: 'Ranking',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Regras',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
