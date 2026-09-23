import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/repositories.dart';
import '../../domain/validacoes.dart';
import '../theme/app_tokens.dart';
import '../widgets/estados.dart';
import 'criar_desafio_screen.dart';

class EntrarDesafioScreen extends StatefulWidget {
  const EntrarDesafioScreen({super.key, required this.uid, required this.nome});

  final String uid;
  final String nome;

  @override
  State<EntrarDesafioScreen> createState() => _EntrarDesafioScreenState();
}

class _EntrarDesafioScreenState extends State<EntrarDesafioScreen> {
  final _form = GlobalKey<FormState>();
  final _codigo = TextEditingController();
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    setState(() => _erro = null);
    if (!_form.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      await context.read<DesafioRepository>().entrarNoDesafio(
            uid: widget.uid,
            nomeUsuario: widget.nome,
            codigo: _codigo.text,
          );
    } on DesafioException catch (e) {
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
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
            children: [
              Text('Entre no desafio', style: textos.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Peça o código para quem criou o desafio do grupo.',
                style: textos.bodyLarge?.copyWith(color: t.textoSecundario),
              ),
              const SizedBox(height: 32),
              TextFormField(
                key: const Key('campo-codigo'),
                controller: _codigo,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                  TextInputFormatter.withFunction(
                    (antigo, novo) =>
                        novo.copyWith(text: novo.text.toUpperCase()),
                  ),
                ],
                onFieldSubmitted: (_) => _entrar(),
                style: textos.displayMedium?.copyWith(letterSpacing: 8),
                decoration: const InputDecoration(
                  labelText: 'Código do desafio',
                  counterText: '',
                ),
                validator: validarCodigo,
              ),
              if (_erro != null) ...[
                const SizedBox(height: 12),
                Text(_erro!, style: textos.bodyMedium?.copyWith(color: t.erro)),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _carregando ? null : _entrar,
                child: _carregando
                    ? const CarregandoNoBotao()
                    : const Text('Entrar no desafio'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'ou',
                      style: textos.bodyMedium?.copyWith(color: t.textoSecundario),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        CriarDesafioScreen(uid: widget.uid, nome: widget.nome),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Criar novo desafio'),
              ),
              const SizedBox(height: 32),
              Center(
                child: TextButton(
                  onPressed: () => context.read<AuthRepository>().sair(),
                  child: const Text('Sair da conta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
