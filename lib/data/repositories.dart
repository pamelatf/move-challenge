import '../domain/models.dart';

/// Contratos de acesso a dados. As telas dependem só destas interfaces,
/// o que permite testar a interface com implementações falsas.

class AuthException implements Exception {
  AuthException(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}

class DesafioException implements Exception {
  DesafioException(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}

abstract class AuthRepository {
  Stream<Usuario?> get usuarioAtual;
  Future<void> entrar({required String email, required String senha});
  Future<void> criarConta({
    required String nome,
    required String email,
    required String senha,
  });
  Future<void> recuperarSenha(String email);
  Future<void> sair();
}

abstract class DesafioRepository {
  Stream<PerfilUsuario?> perfil(String uid);

  /// Cria o desafio, inclui quem criou como participante e devolve o código.
  Future<String> criarDesafio({
    required String uid,
    required String nomeUsuario,
    required String nomeDesafio,
    required String dataInicio,
  });

  Future<void> entrarNoDesafio({
    required String uid,
    required String nomeUsuario,
    required String codigo,
  });

  Stream<Desafio?> desafio(String desafioId);
  Stream<List<Participante>> participantes(String desafioId);
  Stream<List<Marcacao>> marcacoes(String desafioId);

  Future<void> salvarMarcacao(String desafioId, Marcacao marcacao);
  Future<void> removerMarcacao(String desafioId, String uid, String data);
  Future<void> atualizarNome({
    required String uid,
    required String nome,
    String? desafioId,
  });

  /// Remove a pessoa do desafio e apaga os dias que ela marcou.
  Future<void> sairDoDesafio({required String desafioId, required String uid});
}
