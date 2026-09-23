import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/repositories.dart';
import '../../domain/validacoes.dart';
import '../dados_desafio.dart';
import '../theme/app_tokens.dart';
import '../theme/theme_controller.dart';
import '../widgets/app_card.dart';
import '../widgets/estados.dart';
import '../widgets/participant_avatar.dart';
import 'desafio_criado_screen.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key, required this.dados});

  final DadosDesafio dados;

  Future<void> _editarNome(BuildContext context) async {
    final controlador = TextEditingController(text: dados.eu.nome);
    final form = GlobalKey<FormState>();
    final novoNome = await showDialog<String>(
      context: context,
      builder: (contexto) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Editar nome'),
        content: Form(
          key: form,
          child: TextFormField(
            controller: controlador,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Nome'),
            validator: validarNome,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.of(contexto).pop(controlador.text.trim());
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (novoNome == null || !context.mounted) return;
    await context.read<DesafioRepository>().atualizarNome(
          uid: dados.uid,
          nome: novoNome,
          desafioId: dados.desafio.id,
        );
  }

  Future<void> _sairDoDesafio(BuildContext context) async {
    final ok = await confirmar(
      context,
      titulo: 'Sair do desafio?',
      mensagem:
          'Seus dias marcados e seus pontos serão apagados do ranking. Essa ação não pode ser desfeita.',
      acao: 'Sair',
      perigo: true,
    );
    if (!ok || !context.mounted) return;
    await context
        .read<DesafioRepository>()
        .sairDoDesafio(desafioId: dados.desafio.id, uid: dados.uid);
  }

  Future<void> _sairDaConta(BuildContext context) async {
    final ok = await confirmar(
      context,
      titulo: 'Sair da conta?',
      mensagem: 'Você pode entrar de novo quando quiser. Seus dias continuam salvos.',
      acao: 'Sair',
    );
    if (!ok || !context.mounted) return;
    await context.read<AuthRepository>().sair();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textos = Theme.of(context).textTheme;
    final tema = context.watch<ThemeController>();
    final eu = dados.eu;
    final desafio = dados.desafio;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text('Perfil', style: textos.headlineLarge),
            const SizedBox(height: 16),
            AppCard(
              child: Row(
                children: [
                  ParticipantAvatar(nome: eu.nome, cor: eu.cor, tamanho: 52),
                  const SizedBox(width: 12),
                  Expanded(child: Text(eu.nome, style: textos.titleMedium)),
                  IconButton(
                    tooltip: 'Editar nome',
                    onPressed: () => _editarNome(context),
                    icon: Icon(Icons.edit_outlined, color: t.primaria),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(desafio.nome, style: textos.titleMedium),
                            Text(
                              'Código ${desafio.codigo}',
                              style: textos.bodyMedium
                                  ?.copyWith(color: t.textoSecundario),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copiar código',
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: desafio.codigo),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Código copiado')),
                            );
                          }
                        },
                        icon: const Icon(Icons.content_copy),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Compartilhar convite',
                        onPressed: () => Share.share(
                          textoConvite(desafio.nome, desafio.codigo),
                        ),
                        icon: const Icon(Icons.share),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 4),
                  for (final p in dados.participantes)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          ParticipantAvatar(nome: p.nome, cor: p.cor, tamanho: 32),
                          const SizedBox(width: 12),
                          Text(p.nome, style: textos.bodyMedium),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Tema', style: textos.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Claro')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Escuro')),
                ButtonSegment(value: ThemeMode.system, label: Text('Automático')),
              ],
              selected: {tema.modo},
              onSelectionChanged: (s) => tema.definir(s.first),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _sairDaConta(context),
              icon: const Icon(Icons.logout),
              label: const Text('Sair da conta'),
            ),
            const SizedBox(height: 8),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: t.erro),
              onPressed: () => _sairDoDesafio(context),
              child: const Text('Sair do desafio'),
            ),
          ],
        ),
      ),
    );
  }
}
