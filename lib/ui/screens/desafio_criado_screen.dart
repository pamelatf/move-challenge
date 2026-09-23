import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/app_tokens.dart';
import '../widgets/app_card.dart';

String textoConvite(String nomeDesafio, String codigo) =>
    'Participe do desafio "$nomeDesafio" no Move Challenge. '
    'Baixe o app e entre com o código $codigo.';

class DesafioCriadoScreen extends StatelessWidget {
  const DesafioCriadoScreen({
    super.key,
    required this.codigo,
    required this.nomeDesafio,
  });

  final String codigo;
  final String nomeDesafio;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: t.sucessoContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.check_circle_outline,
                      color: t.sucesso, size: 30),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Desafio criado. Agora é chamar o grupo.',
                style: textos.displayMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'As pessoas entram no app com este código:',
                style: textos.bodyLarge?.copyWith(color: t.textoSecundario),
              ),
              const SizedBox(height: 20),
              AppCard(
                cor: t.primariaContainer,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SelectableText(
                      codigo,
                      style: textos.displayLarge?.copyWith(
                        fontSize: 44,
                        letterSpacing: 12,
                        color: t.naPrimariaContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: codigo));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Código copiado')),
                          );
                        }
                      },
                      icon: const Icon(Icons.content_copy, size: 18),
                      label: const Text('Copiar código'),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => Share.share(textoConvite(nomeDesafio, codigo)),
                icon: const Icon(Icons.share),
                label: const Text('Compartilhar convite'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((rota) => rota.isFirst),
                child: const Text('Ir para o desafio'),
              ),
            ],
          ),
        ),
            ),
          ],
        ),
      ),
    );
  }
}
