import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories.dart';
import '../../domain/validacoes.dart';
import '../theme/app_tokens.dart';
import '../widgets/estados.dart';
import 'criar_conta_screen.dart';
import 'recuperar_senha_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _ocultarSenha = true;
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    setState(() => _erro = null);
    if (!_form.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      await context
          .read<AuthRepository>()
          .entrar(email: _email.text, senha: _senha.text);
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

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Text('Que bom te ver de novo', style: textos.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Entre para marcar o seu dia.',
                style: textos.bodyLarge?.copyWith(color: t.textoSecundario),
              ),
              const SizedBox(height: 32),
              TextFormField(
                key: const Key('campo-email'),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: validarEmail,
              ),
              const SizedBox(height: 20),
              TextFormField(
                key: const Key('campo-senha'),
                controller: _senha,
                obscureText: _ocultarSenha,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _entrar(),
                decoration: InputDecoration(
                  labelText: 'Senha',
                  suffixIcon: IconButton(
                    tooltip: _ocultarSenha ? 'Mostrar senha' : 'Ocultar senha',
                    onPressed: () =>
                        setState(() => _ocultarSenha = !_ocultarSenha),
                    icon: Icon(
                      _ocultarSenha
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: validarSenhaObrigatoria,
              ),
              if (_erro != null) ...[
                const SizedBox(height: 12),
                Text(
                  _erro!,
                  key: const Key('erro-login'),
                  style: textos.bodyMedium?.copyWith(color: t.erro),
                ),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RecuperarSenhaScreen(),
                    ),
                  ),
                  child: const Text('Esqueci minha senha'),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _carregando ? null : _entrar,
                child: _carregando
                    ? const CarregandoNoBotao()
                    : const Text('Entrar'),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ainda não tem conta?',
                    style: textos.bodyMedium?.copyWith(color: t.textoSecundario),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const CriarContaScreen()),
                    ),
                    child: const Text('Criar conta'),
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
