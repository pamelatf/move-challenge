import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';

class AppTheme {
  AppTheme._();

  /// [usarGoogleFonts] fica falso nos testes, que rodam sem internet.
  static ThemeData claro({bool usarGoogleFonts = true}) =>
      _criar(Brightness.light, AppTokens.claro, usarGoogleFonts);

  static ThemeData escuro({bool usarGoogleFonts = true}) =>
      _criar(Brightness.dark, AppTokens.escuro, usarGoogleFonts);

  static ThemeData _criar(
    Brightness brilho,
    AppTokens t,
    bool usarGoogleFonts,
  ) {
    final claro = brilho == Brightness.light;
    final esquema = ColorScheme(
      brightness: brilho,
      primary: t.primaria,
      onPrimary: t.naPrimaria,
      primaryContainer: t.primariaContainer,
      onPrimaryContainer: t.naPrimariaContainer,
      secondary: t.leve,
      onSecondary: claro ? Colors.white : const Color(0xFF10261A),
      secondaryContainer: t.leveContainer,
      onSecondaryContainer: t.texto,
      tertiary: t.coringa,
      onTertiary: const Color(0xFF3A2800),
      error: t.erro,
      onError: claro ? Colors.white : const Color(0xFF3A0B08),
      errorContainer: t.erroContainer,
      onErrorContainer: t.texto,
      surface: t.superficie,
      onSurface: t.texto,
      onSurfaceVariant: t.textoSecundario,
      surfaceContainerLowest: t.superficie,
      surfaceContainerLow: t.fundo,
      surfaceContainer: t.superficieContainer,
      surfaceContainerHigh: t.superficieAlta,
      surfaceContainerHighest: t.superficieMaisAlta,
      outline: t.contorno,
      outlineVariant: t.contornoSuave,
    );

    final base = ThemeData(brightness: brilho, useMaterial3: true).textTheme;
    final fonte =
        usarGoogleFonts ? GoogleFonts.plusJakartaSansTextTheme(base) : base;
    final textos = fonte
        .copyWith(
          displayLarge: fonte.displayLarge
              ?.copyWith(fontSize: 36, fontWeight: FontWeight.w700, height: 1.1),
          displayMedium: fonte.displayMedium
              ?.copyWith(fontSize: 32, fontWeight: FontWeight.w700, height: 1.15),
          headlineLarge: fonte.headlineLarge
              ?.copyWith(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2),
          headlineMedium: fonte.headlineMedium
              ?.copyWith(fontSize: 24, fontWeight: FontWeight.w700, height: 1.25),
          headlineSmall: fonte.headlineSmall
              ?.copyWith(fontSize: 20, fontWeight: FontWeight.w700, height: 1.3),
          titleLarge: fonte.titleLarge
              ?.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
          titleMedium: fonte.titleMedium
              ?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
          bodyLarge: fonte.bodyLarge
              ?.copyWith(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
          bodyMedium: fonte.bodyMedium
              ?.copyWith(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
          bodySmall: fonte.bodySmall
              ?.copyWith(fontSize: 12, fontWeight: FontWeight.w400),
          labelLarge: fonte.labelLarge
              ?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
          labelMedium: fonte.labelMedium
              ?.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
        )
        .apply(bodyColor: t.texto, displayColor: t.texto);

    final bordaCampo = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: t.contorno),
    );
    final formaBotao =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));

    return ThemeData(
      useMaterial3: true,
      brightness: brilho,
      colorScheme: esquema,
      scaffoldBackgroundColor: t.fundo,
      textTheme: textos,
      extensions: [t],
      appBarTheme: AppBarTheme(
        backgroundColor: t.fundo,
        foregroundColor: t.texto,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: formaBotao,
          textStyle: textos.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: formaBotao,
          side: BorderSide(color: t.contorno),
          textStyle: textos.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: formaBotao,
          textStyle: textos.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.superficie,
        border: bordaCampo,
        enabledBorder: bordaCampo,
        focusedBorder: bordaCampo.copyWith(
          borderSide: BorderSide(color: t.primaria, width: 2),
        ),
        errorBorder: bordaCampo.copyWith(borderSide: BorderSide(color: t.erro)),
        focusedErrorBorder: bordaCampo.copyWith(
          borderSide: BorderSide(color: t.erro, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.superficie,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleSize: const Size(32, 4),
        dragHandleColor: t.contorno,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: t.superficieContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: t.primariaContainer,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (estados) => textos.labelMedium?.copyWith(
            color: estados.contains(WidgetState.selected)
                ? t.texto
                : t.textoSecundario,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (estados) => IconThemeData(
            color: estados.contains(WidgetState.selected)
                ? t.primaria
                : t.textoSecundario,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: t.primaria,
        foregroundColor: t.naPrimaria,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      dividerTheme: DividerThemeData(color: t.contornoSuave, space: 1),
    );
  }
}
