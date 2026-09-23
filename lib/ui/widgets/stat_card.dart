import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icone,
    required this.corIcone,
    required this.valor,
    required this.rotulo,
  });

  final IconData icone;
  final Color corIcone;
  final String valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textos = Theme.of(context).textTheme;
    return Semantics(
      label: '$valor $rotulo',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: t.superficie,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: t.contornoSuave),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, size: 20, color: corIcone),
            const SizedBox(height: 8),
            Text(
              valor,
              style: textos.displayMedium?.copyWith(height: 1),
            ),
            const SizedBox(height: 6),
            Text(
              rotulo,
              style: textos.bodySmall?.copyWith(color: t.textoSecundario),
            ),
          ],
        ),
      ),
    );
  }
}
