import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../theme/app_tokens.dart';
import '../widgets/status_visual.dart';
import 'criar_conta_screen.dart';
import 'login_screen.dart';

class BoasVindasScreen extends StatelessWidget {
  const BoasVindasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textos = Theme.of(context).textTheme;
    const semana = [
      TipoMarcacao.treino,
      TipoMarcacao.treino,
      TipoMarcacao.leve,
      TipoMarcacao.treino,
      TipoMarcacao.coringa,
      TipoMarcacao.treino,
    ];

    return Scaffold(
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
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: t.primaria,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.local_fire_department_outlined,
                      color: t.naPrimaria,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Move Challenge', style: textos.titleLarge),
                ],
              ),
              const SizedBox(height: 24),
              ExcludeSemantics(
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final tipo in semana) StatusIcone(tipo: tipo),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: t.primaria, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Um movimento por dia, com o seu grupo.',
                style: textos.displayLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Marque suas atividades, mantenha a sequência e acompanhe o ranking em tempo real.',
                style: textos.bodyLarge?.copyWith(color: t.textoSecundario),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: const Text('Entrar'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CriarContaScreen()),
                  ),
                  child: const Text('Criar conta'),
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
