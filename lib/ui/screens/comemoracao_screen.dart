import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/pontuacao.dart';
import '../theme/app_tokens.dart';

class ComemoracaoScreen extends StatelessWidget {
  const ComemoracaoScreen({super.key, required this.dias, required this.bonus});

  final int dias;
  final int bonus;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textos = Theme.of(context).textTheme;
    final cor = t.naPrimaria;
    final meta = Regras.proximaMeta(dias);
    final proximo = meta == null
        ? 'Você alcançou a maior meta do desafio.'
        : 'Próxima meta: $meta dias seguidos para ganhar +${Regras.bonusPorSequencia[meta]}.';

    return Scaffold(
      backgroundColor: t.primaria,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Wrap(
                  spacing: 8,
                  children: List.generate(
                    7,
                    (_) => Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.check_circle_outline,
                          color: t.primaria, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Semantics(
                header: true,
                label: '$dias dias seguidos',
                excludeSemantics: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$dias',
                      style: textos.displayLarge?.copyWith(
                        fontSize: 104,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: cor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'dias seguidos',
                        style: textos.headlineLarge?.copyWith(color: cor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: t.coringaContainer,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department_outlined,
                        size: 18, color: t.coringaIcone),
                    const SizedBox(width: 6),
                    Text(
                      '+$bonus pontos de bônus',
                      style: textos.labelLarge?.copyWith(color: t.texto),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(proximo, style: textos.bodyLarge?.copyWith(color: cor)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: cor,
                    foregroundColor: t.primaria,
                  ),
                  onPressed: () => Share.share(
                    'Completei $dias dias seguidos no Move Challenge.',
                  ),
                  icon: const Icon(Icons.share),
                  label: const Text('Contar para o grupo'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cor,
                    side: BorderSide(color: cor),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Continuar'),
                ),
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
