import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:move_challenge/domain/codigo.dart';
import 'package:move_challenge/domain/validacoes.dart';

void main() {
  group('código do desafio', () {
    test('UNI-25 [RN8] gera códigos válidos de 6 caracteres', () {
      final random = Random(42);
      for (var i = 0; i < 200; i++) {
        final codigo = gerarCodigo(random);
        expect(codigo, hasLength(6));
        expect(codigoValido(codigo), isTrue, reason: codigo);
      }
    });

    test('UNI-26 [RN8] recusa caracteres que se confundem', () {
      expect(codigoValido('ABC0DE'), isFalse);
      expect(codigoValido('ABCODE'), isFalse);
      expect(codigoValido('ABC1DE'), isFalse);
      expect(codigoValido('ABCIDE'), isFalse);
    });

    test('UNI-27 [RN8] normaliza o que a pessoa digitou', () {
      expect(normalizarCodigo(' amg 7k2 '), 'AMG7K2');
    });
  });

  group('validações', () {
    test('UNI-28 [RN7] e-mail', () {
      expect(validarEmail(''), 'Informe o e-mail.');
      expect(validarEmail('pamela'), 'E-mail inválido.');
      expect(validarEmail('pamela@email.com'), isNull);
    });

    test('UNI-29 [RN7] senha nova precisa de 6 caracteres', () {
      expect(validarNovaSenha('123'), 'A senha precisa ter pelo menos 6 caracteres.');
      expect(validarNovaSenha('123456'), isNull);
    });

    test('UNI-30 [RN7] confirmação de senha', () {
      final validar = validarConfirmacaoSenha(() => 'segredo1');
      expect(validar('outra'), 'As senhas não conferem.');
      expect(validar('segredo1'), isNull);
    });

    test('UNI-31 [RN7] nome obrigatório e com limite', () {
      expect(validarNome('  '), 'Informe seu nome.');
      expect(validarNome('A' * 31), 'Use até 30 caracteres.');
      expect(validarNome('Pâmela'), isNull);
    });

    test('UNI-32 [RN8] código', () {
      expect(validarCodigo(''), 'Informe o código do desafio.');
      expect(validarCodigo('abc'), 'O código tem 6 letras e números.');
      expect(validarCodigo('amg7k2'), isNull);
    });
  });
}
