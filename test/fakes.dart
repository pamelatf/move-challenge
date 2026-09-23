import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:move_challenge/data/repositories.dart';
import 'package:move_challenge/domain/models.dart';
import 'package:move_challenge/ui/theme/app_theme.dart';

/// Implementação falsa de autenticação para testes de tela.
class FakeAuthRepository implements AuthRepository {
  AuthException? erroAoEntrar;
  String? emailUsado;
  int tentativasDeEntrar = 0;

  @override
  Stream<Usuario?> get usuarioAtual => const Stream.empty();

  @override
  Future<void> entrar({required String email, required String senha}) async {
    tentativasDeEntrar++;
    emailUsado = email;
    final erro = erroAoEntrar;
    if (erro != null) throw erro;
  }

  @override
  Future<void> criarConta({
    required String nome,
    required String email,
    required String senha,
  }) async {}

  @override
  Future<void> recuperarSenha(String email) async {}

  @override
  Future<void> sair() async {}
}

/// Envolve um widget com o tema do app, sem baixar fontes da internet.
Widget comTema(Widget filho) => MaterialApp(
      theme: AppTheme.claro(usarGoogleFonts: false),
      home: filho,
    );

Marcacao marcacao(
  String data, {
  TipoMarcacao tipo = TipoMarcacao.treino,
  bool comAmigo = false,
  String uid = 'u1',
}) =>
    Marcacao(uid: uid, data: data, tipo: tipo, comAmigo: comAmigo);

/// Cria [quantidade] dias seguidos a partir de [inicio], todos de treino.
Map<String, Marcacao> diasSeguidos(
  String inicio,
  int quantidade, {
  String uid = 'u1',
}) {
  final base = DateTime.parse(inicio);
  final resultado = <String, Marcacao>{};
  for (var i = 0; i < quantidade; i++) {
    final d = DateTime(base.year, base.month, base.day + i);
    final chave =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    resultado[chave] = marcacao(chave, uid: uid);
  }
  return resultado;
}

/// Simula a tela de um celular (390 x 844) durante o teste.
void usarTelaDeCelular(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}
