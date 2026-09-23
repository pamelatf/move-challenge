import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Card padrão: superfície com borda sutil, sem sombra.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.cor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: cor ?? t.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.contornoSuave),
      ),
      child: child,
    );
  }
}
