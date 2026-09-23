import '../domain/models.dart';

/// Tudo o que as abas precisam sobre o desafio atual, já carregado.
class DadosDesafio {
  const DadosDesafio({
    required this.uid,
    required this.desafio,
    required this.participantes,
    required this.marcacoes,
  });

  final String uid;
  final Desafio desafio;
  final List<Participante> participantes;
  final List<Marcacao> marcacoes;

  Map<String, Marcacao> diasDe(String uid) => {
        for (final m in marcacoes)
          if (m.uid == uid) m.data: m,
      };

  Participante? participante(String uid) {
    for (final p in participantes) {
      if (p.uid == uid) return p;
    }
    return null;
  }

  Participante get eu =>
      participante(uid) ?? Participante(uid: uid, nome: '', cor: 0);
}
