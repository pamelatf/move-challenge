import 'dart:math';

/// Sem I, O, 0 e 1, que se confundem ao digitar.
const String alfabetoCodigo = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const int tamanhoCodigo = 6;

final RegExp _formatoCodigo = RegExp(r'^[A-HJ-NP-Z2-9]{6}$');

String gerarCodigo(Random random) => List.generate(
      tamanhoCodigo,
      (_) => alfabetoCodigo[random.nextInt(alfabetoCodigo.length)],
    ).join();

String normalizarCodigo(String entrada) =>
    entrada.trim().toUpperCase().replaceAll(' ', '');

bool codigoValido(String codigo) => _formatoCodigo.hasMatch(codigo);
