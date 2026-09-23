// Configuração do Firebase do projeto move-challenge-b5aa8.
//
// Estes valores identificam o projeto, mas não são senhas. A proteção dos
// dados é feita pelas regras em firestore.rules.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'O Move Challenge está configurado apenas para Android e web.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCvksdIGS4xjuNMdqajp7308AsH8shLuxQ',
    appId: '1:270434879269:web:595b89988f67a76a917ccc',
    messagingSenderId: '270434879269',
    projectId: 'move-challenge-b5aa8',
    authDomain: 'move-challenge-b5aa8.firebaseapp.com',
    storageBucket: 'move-challenge-b5aa8.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD6MtveyvkZ2ijaKX8yYVq5vyVF3rpysUM',
    appId: '1:270434879269:android:ea6c3cf88037ef8d917ccc',
    messagingSenderId: '270434879269',
    projectId: 'move-challenge-b5aa8',
    storageBucket: 'move-challenge-b5aa8.firebasestorage.app',
  );
}
