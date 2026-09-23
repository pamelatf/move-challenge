import 'package:flutter/material.dart';

import '../../domain/datas.dart';
import '../../domain/models.dart';
import '../theme/app_tokens.dart';
import 'status_visual.dart';

class ResultadoMarcacao {
  const ResultadoMarcacao({this.tipo, this.comAmigo = false, this.remover = false});

  final TipoMarcacao? tipo;
  final bool comAmigo;
  final bool remover;
}

Future<ResultadoMarcacao?> mostrarMarcacaoSheet(
  BuildContext context, {
  required DateTime data,
  required Marcacao? atual,
  required bool podeUsarCoringa,
}) =>
    showModalBottomSheet<ResultadoMarcacao>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => MarcacaoSheet(
        data: data,
        atual: atual,
        podeUsarCoringa: podeUsarCoringa,
      ),
    );

class MarcacaoSheet extends StatefulWidget {
  const MarcacaoSheet({
    super.key,
    required this.data,
    required this.atual,
    required this.podeUsarCoringa,
  });

  final DateTime data;
  final Marcacao? atual;
  final bool podeUsarCoringa;

  @override
  State<MarcacaoSheet> createState() => _MarcacaoSheetState();
}

class _MarcacaoSheetState extends State<MarcacaoSheet> {
  late TipoMarcacao? _tipo = widget.atual?.tipo;
  late bool _comAmigo = widget.atual?.comAmigo ?? false;

  void _escolher(TipoMarcacao tipo) => setState(() {
        _tipo = tipo;
        if (tipo == TipoMarcacao.coringa) _comAmigo = false;
      });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textos = Theme.of(context).textTheme;
    final coringaBloqueado = !widget.podeUsarCoringa;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(dataPorExtenso(widget.data), style: textos.headlineSmall),
          const SizedBox(height: 2),
          Text(
            'Como foi o seu dia?',
            style: textos.bodyMedium?.copyWith(color: t.textoSecundario),
          ),
          const SizedBox(height: 16),
          ActivityOption(
            tipo: TipoMarcacao.treino,
            descricao: '1 ponto',
            selecionada: _tipo == TipoMarcacao.treino,
            onTap: () => _escolher(TipoMarcacao.treino),
          ),
          const SizedBox(height: 8),
          ActivityOption(
            tipo: TipoMarcacao.leve,
            descricao: '1 ponto. Alongamento ou caminhada curta',
            selecionada: _tipo == TipoMarcacao.leve,
            onTap: () => _escolher(TipoMarcacao.leve),
          ),
          const SizedBox(height: 8),
          ActivityOption(
            tipo: TipoMarcacao.coringa,
            titulo: 'Usar coringa',
            descricao: coringaBloqueado
                ? 'Coringa do mês já usado'
                : 'Descanso que não quebra a sequência',
            selecionada: _tipo == TipoMarcacao.coringa,
            onTap:
                coringaBloqueado ? null : () => _escolher(TipoMarcacao.coringa),
          ),
          const SizedBox(height: 4),
          CheckboxListTile(
            value: _comAmigo,
            onChanged: _tipo == TipoMarcacao.coringa
                ? null
                : (v) => setState(() => _comAmigo = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: const Text('Treinei com alguém do desafio (+1)'),
            subtitle: const Text('Vale junto ou por chamada de vídeo'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _tipo == null
                ? null
                : () => Navigator.of(context).pop(
                      ResultadoMarcacao(tipo: _tipo, comAmigo: _comAmigo),
                    ),
            child: const Text('Salvar'),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (widget.atual != null)
                TextButton(
                  onPressed: () => Navigator.of(context)
                      .pop(const ResultadoMarcacao(remover: true)),
                  style: TextButton.styleFrom(foregroundColor: t.erro),
                  child: const Text('Desmarcar dia'),
                ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActivityOption extends StatelessWidget {
  const ActivityOption({
    super.key,
    required this.tipo,
    required this.descricao,
    required this.selecionada,
    this.titulo,
    this.onTap,
  });

  final TipoMarcacao tipo;
  final String? titulo;
  final String descricao;
  final bool selecionada;

  /// Nulo desabilita a opção.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textos = Theme.of(context).textTheme;
    final v = statusVisual(context, tipo);
    final habilitada = onTap != null;

    return Semantics(
      selected: selecionada,
      enabled: habilitada,
      child: Opacity(
        opacity: habilitada ? 1 : 0.45,
        child: Material(
          color: selecionada ? v.container : t.superficie,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: selecionada
                ? BorderSide(color: t.primaria, width: 2)
                : BorderSide(color: t.contornoSuave),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    StatusIcone(tipo: tipo),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(titulo ?? v.rotulo, style: textos.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            descricao,
                            style: textos.bodySmall
                                ?.copyWith(color: t.textoSecundario),
                          ),
                        ],
                      ),
                    ),
                    if (selecionada)
                      Icon(Icons.check_circle, color: t.primaria),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
