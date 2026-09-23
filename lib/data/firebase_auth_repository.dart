import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/models.dart';
import 'repositories.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  @override
  Stream<Usuario?> get usuarioAtual => _auth.authStateChanges().map(
        (u) => u == null
            ? null
            : Usuario(uid: u.uid, email: u.email, nome: u.displayName),
      );

  @override
  Future<void> entrar({required String email, required String senha}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_traduzir(e.code));
    }
  }

  @override
  Future<void> criarConta({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      final usuario = credencial.user!;
      await usuario.updateDisplayName(nome.trim());
      await _db.collection('users').doc(usuario.uid).set({
        'nome': nome.trim(),
        'email': email.trim(),
        'criadoEm': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      throw AuthException(_traduzir(e.code));
    }
  }

  @override
  Future<void> recuperarSenha(String email) async {
    try {
      // Pede ao Firebase o e-mail de recuperação em português.
      await _auth.setLanguageCode('pt');
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_traduzir(e.code));
    }
  }

  @override
  Future<void> sair() => _auth.signOut();

  String _traduzir(String codigo) {
    switch (codigo) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'E-mail ou senha incorretos. Confira e tente de novo.';
      case 'email-already-in-use':
        return 'Já existe uma conta com este e-mail.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'weak-password':
        return 'A senha precisa ter pelo menos 6 caracteres.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos e tente de novo.';
      case 'network-request-failed':
        return 'Sem conexão com a internet. Confira e tente de novo.';
      default:
        return 'Não foi possível concluir. Tente de novo.';
    }
  }
}
