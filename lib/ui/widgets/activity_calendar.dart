import 'package:flutter/material.dart';

import '../../domain/datas.dart';
import '../../domain/models.dart';
import '../theme/app_tokens.dart';
import 'status_visual.dart';

/// Um dia do calendário. O status aparece por cor, ícone e borda, para não
/// depender só de cor.
class ActivityDay extends StatelessWidget {
  const ActivityDay({
    super.key,
    required this.dia,
    required this.rotulo,
    this.marcacao,
    this.ehHoje = false,
    this.bloqueado = false,
    this.onTap,
  });

  final int dia;
  final String rotulo;
  final Marcacao? marcacao;
  final bool ehHoje;
  final bool bloqueado;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final estilo = Theme.of(context).textTheme.labelLarge;
    final m = marcacao;
    final visual = m == null ? null : statusVisual(context, m.tipo);
    final comAmigo = m?.comAmigo ?? false;

    Color? fundo;
    BoxBorder? borda;
    Widget conteudo = Text('$dia', style: estilo);

    if (visual != null) {
      fundo = visual.container;
      borda = Border.all(color: visual.cor, width: 1.5);
      conteudo = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(visual.iconeData, size: 15, color: visual.icone),
          Text('$dia', style: estilo?.copyWith(height: 1.1)),
        ],
      );
    } else if (ehHoje) {
      borda = Border.all(color: t.primaria, width: 2);
      conteudo = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$dia', style: estilo?.copyWith(height: 1.1)),
          Text(
            'Hoje',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: t.primaria,
              height: 1.1,
            ),
          ),
        ],
      );
    }

    Widget celula = Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fundo,
        border: borda,
        borderRadius: BorderRadius.circular(12),
      ),
      child: conteudo,
    );

    if (comAmigo) {
      celula = Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: celula),
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: t.primaria,
                shape: BoxShape.circle,
                border: Border.all(color: t.superficie, width: 2),
              ),
              child: Icon(Icons.group, size: 10, color: t.naPrimaria),
            ),
          ),
        ],
      );
    }

    final descricao = [
      rotulo,
      if (ehHoje) 'hoje',
      if (visual != null) visual.rotulo.toLowerCase(),
      if (comAmigo) 'com alguém do desafio',
      if (bloqueado) 'indisponível',
    ].join(', ');

    return Semantics(
      container: true,
      button: onTap != null && !bloqueado,
      label: descricao,
      excludeSemantics: true,
      child: Opacity(
        opacity: bloqueado ? 0.4 : 1,
        child: InkWell(
          onTap: bloqueado ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: celula,
        ),
      ),
    );
  }
}

class ActivityCalendar extends StatelessWidget {
  const ActivityCalendar({
    super.key,
    required this.mes,
    required this.dias,
    required this.hoje,
    this.inicio,
    this.onMesAnterior,
    this.onProximoMes,
    this.onDiaTocado,
  });

  /// Qualquer data dentro do mês exibido.
  final DateTime mes;
  final Map<String, Marcacao> dias;
  final String hoje;

  /// Dias antes do início do desafio ficam bloqueados.
  final String? inicio;
  final VoidCallback? onMesAnterior;
  final VoidCallback? onProximoMes;

  /// Nulo deixa o calendário somente leitura.
  final ValueChanged<String>? onDiaTocado;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textos = Theme.of(context).textTheme;
    final primeiro = DateTime(mes.year, mes.month, 1);
    final vazios = primeiro.weekday % 7;
    final totalDias = DateTime(mes.year, mes.month + 1, 0).day;

    final celulas = <Widget>[
      for (var i = 0; i < vazios; i++) const SizedBox.shrink(),
      for (var d = 1; d <= totalDias; d++) _dia(d),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Mês anterior',
              onPressed: onMesAnterior,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                mesPorExtenso(primeiro),
                textAlign: TextAlign.center,
                style: textos.titleLarge,
              ),
            ),
            IconButton(
              tooltip: 'Próximo mês',
              onPressed: onProximoMes,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ExcludeSemantics(
          child: Row(
            children: [
              for (final inicial in iniciaisDaSemana)
                Expanded(
                  child: Text(
                    inicial,
                    textAlign: TextAlign.center,
                    style: textos.labelMedium
                        ?.copyWith(color: t.textoSecundario),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 0.85,
          children: celulas,
        ),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        const _Legenda(),
      ],
    );
  }

  Widget _dia(int d) {
    final chave = chaveData(DateTime(mes.year, mes.month, d));
    final futuro = chave.compareTo(hoje) > 0;
    final antesDoInicio = inicio != null && chave.compareTo(inicio!) < 0;
    final aoTocar = onDiaTocado;
    return ActivityDay(
      key: ValueKey('dia-$chave'),
      dia: d,
      rotulo: '$d de ${meses[mes.month - 1]}',
      marcacao: dias[chave],
      ehHoje: chave == hoje,
      bloqueado: futuro || antesDoInicio,
      onTap: aoTocar == null ? null : () => aoTocar(chave),
    );
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final estilo = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: t.textoSecundario, fontWeight: FontWeight.w500);

    Widget item(Widget marcador, String texto) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [marcador, const SizedBox(width: 6), Text(texto, style: estilo)],
        );

    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        for (final tipo in TipoMarcacao.values)
          item(
            StatusIcone(tipo: tipo, tamanho: 20),
            statusVisual(context, tipo).rotulo,
          ),
        item(
          Container(
            width: 18,
            height: 18,
            decoration:
                BoxDecoration(color: t.primaria, shape: BoxShape.circle),
            child: Icon(Icons.group, size: 10, color: t.naPrimaria),
          ),
          'Com alguém do desafio',
        ),
      ],
    );
  }
}
