import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../theme/app_tokens.dart';

class StatusVisual {
  const StatusVisual({
    required this.cor,
    required this.container,
    required this.icone,
    required this.iconeData,
    required this.rotulo,
  });

  final Color cor;
  final Color container;
  final Color icone;
  final IconData iconeData;
  final String rotulo;
}

StatusVisual statusVisual(BuildContext context, TipoMarcacao tipo) {
  final t = context.tokens;
  return switch (tipo) {
    TipoMarcacao.treino => StatusVisual(
        cor: t.treino,
        container: t.treinoContainer,
        icone: t.treinoIcone,
        iconeData: Icons.check_circle_outline,
        rotulo: 'Treinei',
      ),
    TipoMarcacao.leve => StatusVisual(
        cor: t.leve,
        container: t.leveContainer,
        icone: t.leveIcone,
        iconeData: Icons.directions_walk,
        rotulo: 'Dia leve',
      ),
    TipoMarcacao.coringa => StatusVisual(
        cor: t.coringa,
        container: t.coringaContainer,
        icone: t.coringaIcone,
        iconeData: Icons.star_outline,
        rotulo: 'Coringa',
      ),
  };
}

/// Quadradinho com o ícone do status, usado na legenda e nas opções.
class StatusIcone extends StatelessWidget {
  const StatusIcone({super.key, required this.tipo, this.tamanho = 40});

  final TipoMarcacao tipo;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final v = statusVisual(context, tipo);
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: v.container,
        borderRadius: BorderRadius.circular(tamanho * 0.3),
        border: Border.all(color: v.cor, width: 1.5),
      ),
      child: Icon(v.iconeData, size: tamanho * 0.55, color: v.icone),
    );
  }
}
