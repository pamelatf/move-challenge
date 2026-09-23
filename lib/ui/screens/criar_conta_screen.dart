import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories.dart';
import '../../domain/validacoes.dart';
import '../theme/app_tokens.dart';
import '../widgets/estados.dart';
import 'login_screen.dart';

class CriarContaScreen extends StatefulWidget {
  const CriarContaScreen({super.key});

  @override
  State<CriarContaScreen> createState() => _CriarContaScreenState();
}

class _CriarContaScreenState extends State<CriarContaScreen> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmacao = TextEditingController();
  bool _ocultarSenha = true;
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    _confirmacao.dispose();
    super.dispose();
  }

  Future<void> _criar() async {
    setState(() => _erro = null);
    if (!_form.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      await context.read<AuthRepository>().criarConta(
            nome: _nome.text,
            email: _email.text,
            senha: _senha.text,
          );
      if (!mounted) return;
      Navigator.of(context).popUntil((rota) => rota.isFirst);
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
    final botaoSenha = IconButton(
      tooltip: _ocultarSenha ? 'Mostrar senha' : 'Ocultar senha',
      onPressed: () => setState(() => _ocultarSenha = !_ocultarSenha),
      icon: Icon(
        _ocultarSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Text('Criar conta', style: textos.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Seu nome aparece no ranking do grupo.',
                style: textos.bodyLarge?.copyWith(color: t.textoSecundario),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _nome,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: validarNome,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: validarEmail,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _senha,
                obscureText: _ocultarSenha,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  helperText: 'Mínimo de 6 caracteres',
                  suffixIcon: botaoSenha,
                ),
                validator: validarNovaSenha,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmacao,
                obscureText: _ocultarSenha,
                onFieldSubmitted: (_) => _criar(),
                decoration: const InputDecoration(labelText: 'Confirmar senha'),
                validator: validarConfirmacaoSenha(() => _senha.text),
              ),
              if (_erro != null) ...[
                const SizedBox(height: 12),
                Text(_erro!, style: textos.bodyMedium?.copyWith(color: t.erro)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _carregando ? null : _criar,
                child: _carregando
                    ? const CarregandoNoBotao()
                    : const Text('Criar conta'),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Já tem conta?',
                    style: textos.bodyMedium?.copyWith(color: t.textoSecundario),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text('Entrar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
