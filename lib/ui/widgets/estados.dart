import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class TelaCarregando extends StatelessWidget {
  const TelaCarregando({super.key, this.mensagem = 'Carregando'});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              mensagem,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: t.textoSecundario),
            ),
          ],
        ),
      ),
    );
  }
}

class TelaErro extends StatelessWidget {
  const TelaErro({
    super.key,
    required this.titulo,
    required this.mensagem,
    this.rotuloAcao,
    this.onAcao,
  });

  final String titulo;
  final String mensagem;
  final String? rotuloAcao;
  final VoidCallback? onAcao;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, size: 32, color: t.erro),
              const SizedBox(height: 16),
              Text(titulo, style: textos.headlineLarge),
              const SizedBox(height: 8),
              Text(
                mensagem,
                style: textos.bodyLarge?.copyWith(color: t.textoSecundario),
              ),
              if (rotuloAcao != null && onAcao != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(onPressed: onAcao, child: Text(rotuloAcao!)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Diálogo de confirmação. Devolve true quando a pessoa confirma.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  required String acao,
  bool perigo = false,
}) async {
  final t = context.tokens;
  final resposta = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      icon: perigo ? Icon(Icons.warning_amber_rounded, color: t.erro) : null,
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(contexto).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: perigo
              ? FilledButton.styleFrom(
                  backgroundColor: t.erro,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                )
              : null,
          onPressed: () => Navigator.of(contexto).pop(true),
          child: Text(acao),
        ),
      ],
    ),
  );
  return resposta ?? false;
}

/// Indicador pequeno para dentro de botões.
class CarregandoNoBotao extends StatelessWidget {
  const CarregandoNoBotao({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
}
