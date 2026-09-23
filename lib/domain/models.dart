enum TipoMarcacao { treino, leve, coringa }

TipoMarcacao tipoMarcacaoDoId(String? id) => TipoMarcacao.values.firstWhere(
      (t) => t.name == id,
      orElse: () => TipoMarcacao.treino,
    );

class Marcacao {
  const Marcacao({
    required this.uid,
    required this.data,
    required this.tipo,
    this.comAmigo = false,
  });

  final String uid;

  /// Data no formato `aaaa-mm-dd`.
  final String data;
  final TipoMarcacao tipo;
  final bool comAmigo;

  /// Coringa não soma pontos; os outros tipos contam como dia ativo.
  bool get ativa => tipo != TipoMarcacao.coringa;

  String get id => '${uid}_$data';
}

class Participante {
  const Participante({required this.uid, required this.nome, required this.cor});

  final String uid;
  final String nome;

  /// Índice na lista de cores de participantes.
  final int cor;
}

class Desafio {
  const Desafio({
    required this.id,
    required this.nome,
    required this.codigo,
    required this.dataInicio,
    required this.criadoPor,
  });

  final String id;
  final String nome;
  final String codigo;
  final String dataInicio;
  final String criadoPor;
}

class PerfilUsuario {
  const PerfilUsuario({
    required this.uid,
    required this.nome,
    required this.email,
    this.desafioId,
  });

  final String uid;
  final String nome;
  final String email;
  final String? desafioId;
}

class Usuario {
  const Usuario({required this.uid, this.email, this.nome});

  final String uid;
  final String? email;
  final String? nome;
}
