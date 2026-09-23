import 'package:flutter/material.dart';

/// Tokens do design system do Move Challenge (paleta "Pista de atletismo").
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.fundo,
    required this.superficie,
    required this.superficieContainer,
    required this.superficieAlta,
    required this.superficieMaisAlta,
    required this.texto,
    required this.textoSecundario,
    required this.contorno,
    required this.contornoSuave,
    required this.primaria,
    required this.naPrimaria,
    required this.primariaContainer,
    required this.naPrimariaContainer,
    required this.treino,
    required this.treinoContainer,
    required this.treinoIcone,
    required this.leve,
    required this.leveContainer,
    required this.leveIcone,
    required this.coringa,
    required this.coringaContainer,
    required this.coringaIcone,
    required this.sucesso,
    required this.sucessoContainer,
    required this.erro,
    required this.erroContainer,
  });

  final Color fundo;
  final Color superficie;
  final Color superficieContainer;
  final Color superficieAlta;
  final Color superficieMaisAlta;
  final Color texto;
  final Color textoSecundario;
  final Color contorno;
  final Color contornoSuave;
  final Color primaria;
  final Color naPrimaria;
  final Color primariaContainer;
  final Color naPrimariaContainer;
  final Color treino;
  final Color treinoContainer;
  final Color treinoIcone;
  final Color leve;
  final Color leveContainer;
  final Color leveIcone;
  final Color coringa;
  final Color coringaContainer;
  final Color coringaIcone;
  final Color sucesso;
  final Color sucessoContainer;
  final Color erro;
  final Color erroContainer;

  static const claro = AppTokens(
    fundo: Color(0xFFEEF0EC),
    superficie: Color(0xFFFFFFFF),
    superficieContainer: Color(0xFFE6E9E3),
    superficieAlta: Color(0xFFDDE1DB),
    superficieMaisAlta: Color(0xFFD3D8D0),
    texto: Color(0xFF1F2A24),
    textoSecundario: Color(0xFF5A655E),
    contorno: Color(0xFF7A857E),
    contornoSuave: Color(0xFFCFD5CD),
    primaria: Color(0xFFB84E02),
    naPrimaria: Color(0xFFFFFFFF),
    primariaContainer: Color(0xFFFBE3D2),
    naPrimariaContainer: Color(0xFF6B2D00),
    treino: Color(0xFFE0621A),
    treinoContainer: Color(0xFFFCE0CF),
    treinoIcone: Color(0xFFB84E02),
    leve: Color(0xFF5E8C6A),
    leveContainer: Color(0xFFDCEADF),
    leveIcone: Color(0xFF3F6B4B),
    coringa: Color(0xFFD4A017),
    coringaContainer: Color(0xFFF8ECC4),
    coringaIcone: Color(0xFF8A6500),
    sucesso: Color(0xFF3F8F5A),
    sucessoContainer: Color(0xFFDCEFE2),
    erro: Color(0xFFB3261E),
    erroContainer: Color(0xFFF9DEDC),
  );

  static const escuro = AppTokens(
    fundo: Color(0xFF131815),
    superficie: Color(0xFF1C2320),
    superficieContainer: Color(0xFF232B27),
    superficieAlta: Color(0xFF2A332E),
    superficieMaisAlta: Color(0xFF323C36),
    texto: Color(0xFFEEF1EC),
    textoSecundario: Color(0xFFAAB3AC),
    contorno: Color(0xFF8A948D),
    contornoSuave: Color(0xFF3A443E),
    primaria: Color(0xFFFF8A3D),
    naPrimaria: Color(0xFF2A1200),
    primariaContainer: Color(0xFF5A2A08),
    naPrimariaContainer: Color(0xFFFFDCC6),
    treino: Color(0xFFFF8A3D),
    treinoContainer: Color(0xFF4A2A15),
    treinoIcone: Color(0xFFFF8A3D),
    leve: Color(0xFF8CC29A),
    leveContainer: Color(0xFF22382A),
    leveIcone: Color(0xFF8CC29A),
    coringa: Color(0xFFF2C14E),
    coringaContainer: Color(0xFF45391A),
    coringaIcone: Color(0xFFF2C14E),
    sucesso: Color(0xFF6FCF8E),
    sucessoContainer: Color(0xFF1E3A28),
    erro: Color(0xFFFF8A80),
    erroContainer: Color(0xFF4A2220),
  );

  @override
  AppTokens copyWith() => this;

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppTokensNoContexto on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}

/// Cores individuais das participantes. Não indicam status.
const List<Color> coresParticipantes = [
  Color(0xFF16707A),
  Color(0xFFD2601A),
  Color(0xFF2F7D5B),
  Color(0xFF2F6DB5),
  Color(0xFFB8427A),
  Color(0xFF9A7209),
  Color(0xFF6F4FB8),
  Color(0xFF8A5A44),
];

Color corDoParticipante(int indice) =>
    coresParticipantes[indice.abs() % coresParticipantes.length];
