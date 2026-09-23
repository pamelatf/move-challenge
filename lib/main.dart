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
