import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories.dart';
import '../../domain/validacoes.dart';
import '../theme/app_tokens.dart';
import '../widgets/estados.dart';

class RecuperarSenhaScreen extends StatefulWidget {
  const RecuperarSenhaScreen({super.key});

  @override
  State<RecuperarSenhaScreen> createState() => _RecuperarSenhaScreenState();
}

class _RecuperarSenhaScreenState extends State<RecuperarSenhaScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _carregando = false;
  bool _enviado = false;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    setState(() => _erro = null);
    if (!_form.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      await context.read<AuthRepository>().recuperarSenha(_email.text);
      if (mounted) setState(() => _enviado = true);
    } on AuthException catch (e) {
      if (mounted) setState(() => _erro = e.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Text('Recuperar senha', style: textos.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Enviaremos um link para você criar uma nova senha.',
                style: textos.bodyLarge?.copyWith(color: t.textoSecundario),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                onFieldSubmitted: (_) => _enviar(),
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: validarEmail,
              ),
              if (_erro != null) ...[
                const SizedBox(height: 12),
                Text(_erro!, style: textos.bodyMedium?.copyWith(color: t.erro)),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _carregando ? null : _enviar,
                child: _carregando
                    ? const CarregandoNoBotao()
                    : const Text('Enviar link de recuperação'),
              ),
              if (_enviado) ...[
                const SizedBox(height: 20),
                Semantics(
                  liveRegion: true,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: t.sucessoContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline, color: t.sucesso),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Link enviado', style: textos.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                'Confira sua caixa de entrada e o spam de ${_email.text.trim()}.',
                                style: textos.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
