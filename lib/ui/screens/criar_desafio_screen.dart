import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories.dart';
import '../../domain/datas.dart';
import '../../domain/validacoes.dart';
import '../theme/app_tokens.dart';
import '../widgets/estados.dart';
import 'desafio_criado_screen.dart';

class CriarDesafioScreen extends StatefulWidget {
  const CriarDesafioScreen({super.key, required this.uid, required this.nome});

  final String uid;
  final String nome;

  @override
  State<CriarDesafioScreen> createState() => _CriarDesafioScreenState();
}

class _CriarDesafioScreenState extends State<CriarDesafioScreen> {
  final _form = GlobalKey<FormState>();
  final _nomeDesafio = TextEditingController();
  DateTime _inicio = DateTime.now();
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _nomeDesafio.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _inicio,
      firstDate: DateTime(hoje.year, hoje.month - 1, hoje.day),
      lastDate: DateTime(hoje.year + 1, hoje.month, hoje.day),
      helpText: 'Data de início',
    );
    if (escolhida != null) setState(() => _inicio = escolhida);
  }

  Future<void> _criar() async {
    setState(() => _erro = null);
    if (!_form.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      final codigo = await context.read<DesafioRepository>().criarDesafio(
            uid: widget.uid,
            nomeUsuario: widget.nome,
            nomeDesafio: _nomeDesafio.text,
            dataInicio: chaveData(_inicio),
          );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DesafioCriadoScreen(
            codigo: codigo,
            nomeDesafio: _nomeDesafio.text.trim(),
          ),
        ),
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
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Text('Novo desafio', style: textos.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Depois você recebe um código para convidar o grupo.',
                style: textos.bodyLarge?.copyWith(color: t.textoSecundario),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nomeDesafio,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Nome do desafio'),
                validator: validarNomeDesafio,
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _escolherData,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data de início',
                    suffixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                  child: Text(dataCompleta(_inicio), style: textos.bodyLarge),
                ),
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
                    : const Text('Criar desafio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
