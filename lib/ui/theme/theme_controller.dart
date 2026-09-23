import 'package:flutter/material.dart';

/// Guarda o tema escolhido no Perfil (claro, escuro ou automático).
class ThemeController extends ChangeNotifier {
  ThemeMode _modo = ThemeMode.system;

  ThemeMode get modo => _modo;

  void definir(ThemeMode modo) {
    if (modo == _modo) return;
    _modo = modo;
    notifyListeners();
  }
}
