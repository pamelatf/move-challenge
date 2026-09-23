import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:move_challenge/domain/codigo.dart';
import 'package:move_challenge/domain/validacoes.dart';

void main() {
  group('código do desafio', () {
    test('gera códigos válidos de 6 caracteres', () {
      final random = Random(42);
      for (var i = 0; i < 200; i++) {
        final codigo = gerarCodigo(random);
        expect(codigo, hasLength(6));
        expect(codigoValido(codigo), isTrue, reason: codigo);
      }
    });

    test('recusa caracteres que se confundem', () {
      expect(codigoValido('ABC0DE'), isFalse);
      expect(codigoValido('ABCODE'), isFalse);
      expect(codigoValido('ABC1DE'), isFalse);
      expect(codigoValido('ABCIDE'), isFalse);
    });

    test('normaliza o que a pessoa digitou', () {
      expect(normalizarCodigo(' amg 7k2 '), 'AMG7K2');
    });
  });

  group('validações', () {
    test('e-mail', () {
      expect(validarEmail(''), 'Informe o e-mail.');
      expect(validarEmail('pamela'), 'E-mail inválido.');
      expect(validarEmail('pamela@email.com'), isNull);
    });

    test('senha nova precisa de 6 caracteres', () {
      expect(validarNovaSenha('123'), 'A senha precisa ter pelo menos 6 caracteres.');
      expect(validarNovaSenha('123456'), isNull);
    });

    test('confirmação de senha', () {
      final validar = validarConfirmacaoSenha(() => 'segredo1');
      expect(validar('outra'), 'As senhas não conferem.');
      expect(validar('segredo1'), isNull);
    });

    test('nome obrigatório e com limite', () {
      expect(validarNome('  '), 'Informe seu nome.');
      expect(validarNome('A' * 31), 'Use até 30 caracteres.');
      expect(validarNome('Pâmela'), isNull);
    });

    test('código', () {
      expect(validarCodigo(''), 'Informe o código do desafio.');
      expect(validarCodigo('abc'), 'O código tem 6 letras e números.');
      expect(validarCodigo('amg7k2'), isNull);
    });
  });
}
