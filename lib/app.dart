import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'data/repositories.dart';
import 'domain/models.dart';
import 'ui/screens/boas_vindas_screen.dart';
import 'ui/screens/entrar_desafio_screen.dart';
import 'ui/screens/home_shell.dart';
import 'ui/theme/app_theme.dart';
import 'ui/theme/theme_controller.dart';
import 'ui/widgets/estados.dart';

class MoveChallengeApp extends StatelessWidget {
  const MoveChallengeApp({super.key, this.usarGoogleFonts = true});

  final bool usarGoogleFonts;

  @override
  Widget build(BuildContext context) {
    final modo = context.watch<ThemeController>().modo;
    return MaterialApp(
      title: 'Move Challenge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro(usarGoogleFonts: usarGoogleFonts),
      darkTheme: AppTheme.escuro(usarGoogleFonts: usarGoogleFonts),
      themeMode: modo,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const RaizApp(),
    );
  }
}

/// Decide a primeira tela: boas-vindas, entrar em um desafio ou o desafio.
class RaizApp extends StatefulWidget {
  const RaizApp({super.key});

  @override
  State<RaizApp> createState() => _RaizAppState();
}

class _RaizAppState extends State<RaizApp> {
  late final Stream<Usuario?> _usuario =
      context.read<AuthRepository>().usuarioAtual;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Usuario?>(
      stream: _usuario,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const TelaCarregando();
        }
        final usuario = snapshot.data;
        if (usuario == null) return const BoasVindasScreen();
        return AreaLogada(key: ValueKey(usuario.uid), usuario: usuario);
      },
    );
  }
}

class AreaLogada extends StatefulWidget {
  const AreaLogada({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<AreaLogada> createState() => _AreaLogadaState();
}

class _AreaLogadaState extends State<AreaLogada> {
  late final Stream<PerfilUsuario?> _perfil =
      context.read<DesafioRepository>().perfil(widget.usuario.uid);

  String _nome(PerfilUsuario? perfil) {
    final candidatos = [
      perfil?.nome,
      widget.usuario.nome,
      widget.usuario.email?.split('@').first,
    ];
    for (final c in candidatos) {
      if (c != null && c.trim().isNotEmpty) return c.trim();
    }
    return 'Participante';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PerfilUsuario?>(
      stream: _perfil,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const TelaCarregando();
        }
        final perfil = snapshot.data;
        final desafioId = perfil?.desafioId;
        if (desafioId == null) {
          return EntrarDesafioScreen(
            uid: widget.usuario.uid,
            nome: _nome(perfil),
          );
        }
        return HomeShell(
          key: ValueKey(desafioId),
          desafioId: desafioId,
          uid: widget.usuario.uid,
        );
      },
    );
  }
}
