import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/firebase_auth_repository.dart';
import 'data/firestore_desafio_repository.dart';
import 'data/repositories.dart';
import 'firebase_options.dart';
import 'ui/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _conectarEmuladoresSeNecessario();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => FirebaseAuthRepository()),
        Provider<DesafioRepository>(create: (_) => FirestoreDesafioRepository()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
      ],
      child: const MoveChallengeApp(),
    ),
  );
}

/// Nos testes de ponta a ponta, o app é compilado com
/// --dart-define=USE_FIREBASE_EMULATORS=true e passa a usar os emuladores do
/// Firebase, em vez do projeto real. No emulador Android, 10.0.2.2 é o
/// endereço do computador que roda o teste.
Future<void> _conectarEmuladoresSeNecessario() async {
  const usarEmuladores = bool.fromEnvironment('USE_FIREBASE_EMULATORS');
  if (!usarEmuladores) return;
  const host = String.fromEnvironment(
    'FIREBASE_EMULATOR_HOST',
    defaultValue: '10.0.2.2',
  );
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
}
