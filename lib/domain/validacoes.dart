import 'codigo.dart';

final RegExp _formatoEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validarNome(String? valor) {
  final texto = valor?.trim() ?? '';
  if (texto.isEmpty) return 'Informe seu nome.';
  if (texto.length > 30) return 'Use até 30 caracteres.';
  return null;
}

String? validarNomeDesafio(String? valor) {
  final texto = valor?.trim() ?? '';
  if (texto.isEmpty) return 'Informe o nome do desafio.';
  if (texto.length > 30) return 'Use até 30 caracteres.';
  return null;
}

String? validarEmail(String? valor) {
  final texto = valor?.trim() ?? '';
  if (texto.isEmpty) return 'Informe o e-mail.';
  if (!_formatoEmail.hasMatch(texto)) return 'E-mail inválido.';
  return null;
}

String? validarSenhaObrigatoria(String? valor) =>
    (valor ?? '').isEmpty ? 'Informe a senha.' : null;

String? validarNovaSenha(String? valor) {
  final texto = valor ?? '';
  if (texto.isEmpty) return 'Informe a senha.';
  if (texto.length < 6) return 'A senha precisa ter pelo menos 6 caracteres.';
  return null;
}

String? Function(String?) validarConfirmacaoSenha(String Function() senha) =>
    (valor) => (valor ?? '') != senha() ? 'As senhas não conferem.' : null;

String? validarCodigo(String? valor) {
  final codigo = normalizarCodigo(valor ?? '');
  if (codigo.isEmpty) return 'Informe o código do desafio.';
  if (!codigoValido(codigo)) return 'O código tem 6 letras e números.';
  return null;
}
