import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class ParticipantAvatar extends StatelessWidget {
  const ParticipantAvatar({
    super.key,
    required this.nome,
    required this.cor,
    this.tamanho = 40,
  });

  final String nome;
  final int cor;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final texto = nome.trim();
    final inicial = texto.isEmpty ? '?' : texto[0].toUpperCase();
    return ExcludeSemantics(
      child: Container(
        width: tamanho,
        height: tamanho,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: corDoParticipante(cor),
          shape: BoxShape.circle,
        ),
        child: Text(
          inicial,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: tamanho * 0.42,
          ),
        ),
      ),
    );
  }
}
