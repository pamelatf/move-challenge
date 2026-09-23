import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/codigo.dart';
import '../domain/models.dart';
import 'repositories.dart';

/// Estrutura no Firestore:
///
/// users/{uid}                              nome, email, desafioId
/// codigos/{codigo}                         desafioId
/// desafios/{id}                            nome, codigo, dataInicio, criadoPor
/// desafios/{id}/participantes/{uid}        nome, cor
/// desafios/{id}/marcacoes/{uid_aaaa-mm-dd} uid, data, tipo, comAmigo
class FirestoreDesafioRepository implements DesafioRepository {
  FirestoreDesafioRepository({FirebaseFirestore? db, Random? random})
      : _db = db ?? FirebaseFirestore.instance,
        _random = random ?? Random.secure();

  final FirebaseFirestore _db;
  final Random _random;

  static const int _tentativasCodigo = 5;

  DocumentReference<Map<String, dynamic>> _usuario(String uid) =>
      _db.collection('users').doc(uid);

  DocumentReference<Map<String, dynamic>> _desafio(String id) =>
      _db.collection('desafios').doc(id);

  CollectionReference<Map<String, dynamic>> _participantes(String id) =>
      _desafio(id).collection('participantes');

  CollectionReference<Map<String, dynamic>> _marcacoes(String id) =>
      _desafio(id).collection('marcacoes');

  /// Cor estável para cada pessoa, sem precisar ler o grupo inteiro.
  int _corPara(String uid) => uid.codeUnits.fold<int>(0, (a, b) => a + b) % 8;

  @override
  Stream<PerfilUsuario?> perfil(String uid) =>
      _usuario(uid).snapshots().map((snap) {
        final dados = snap.data();
        if (dados == null) return null;
        return PerfilUsuario(
          uid: uid,
          nome: (dados['nome'] as String?) ?? '',
          email: (dados['email'] as String?) ?? '',
          desafioId: dados['desafioId'] as String?,
        );
      });

  @override
  Future<String> criarDesafio({
    required String uid,
    required String nomeUsuario,
    required String nomeDesafio,
    required String dataInicio,
  }) async {
    for (var tentativa = 1; tentativa <= _tentativasCodigo; tentativa++) {
      final codigo = gerarCodigo(_random);
      final desafioRef = _db.collection('desafios').doc();
      final lote = _db.batch()
        ..set(_db.collection('codigos').doc(codigo), {
          'desafioId': desafioRef.id,
          'criadoEm': FieldValue.serverTimestamp(),
        })
        ..set(desafioRef, {
          'nome': nomeDesafio.trim(),
          'codigo': codigo,
          'dataInicio': dataInicio,
          'criadoPor': uid,
          'criadoEm': FieldValue.serverTimestamp(),
        })
        ..set(_participantes(desafioRef.id).doc(uid), {
          'nome': nomeUsuario,
          'cor': _corPara(uid),
          'entrouEm': FieldValue.serverTimestamp(),
        })
        ..set(
          _usuario(uid),
          {'nome': nomeUsuario, 'desafioId': desafioRef.id},
          SetOptions(merge: true),
        );
      try {
        await lote.commit();
        return codigo;
      } on FirebaseException catch (e) {
        // Código já usado: as regras recusam sobrescrever. Tenta outro.
        final codigoRepetido = e.code == 'permission-denied';
        if (!codigoRepetido || tentativa == _tentativasCodigo) {
          throw DesafioException(
            'Não foi possível criar o desafio. Tente de novo.',
          );
        }
      }
    }
    throw DesafioException('Não foi possível criar o desafio. Tente de novo.');
  }

  @override
  Future<void> entrarNoDesafio({
    required String uid,
    required String nomeUsuario,
    required String codigo,
  }) async {
    final normalizado = normalizarCodigo(codigo);
    try {
      final snap = await _db.collection('codigos').doc(normalizado).get();
      final desafioId = snap.data()?['desafioId'] as String?;
      if (desafioId == null) {
        throw DesafioException(
          'Código não encontrado. Confira com quem criou o desafio.',
        );
      }
      final lote = _db.batch()
        ..set(_participantes(desafioId).doc(uid), {
          'nome': nomeUsuario,
          'cor': _corPara(uid),
          'entrouEm': FieldValue.serverTimestamp(),
        })
        ..set(
          _usuario(uid),
          {'nome': nomeUsuario, 'desafioId': desafioId},
          SetOptions(merge: true),
        );
      await lote.commit();
    } on FirebaseException {
      throw DesafioException(
        'Não foi possível entrar no desafio. Confira sua conexão e tente de novo.',
      );
    }
  }

  @override
  Stream<Desafio?> desafio(String desafioId) =>
      _desafio(desafioId).snapshots().map((snap) {
        final d = snap.data();
        if (d == null) return null;
        return Desafio(
          id: snap.id,
          nome: (d['nome'] as String?) ?? '',
          codigo: (d['codigo'] as String?) ?? '',
          dataInicio: (d['dataInicio'] as String?) ?? '2000-01-01',
          criadoPor: (d['criadoPor'] as String?) ?? '',
        );
      });

  @override
  Stream<List<Participante>> participantes(String desafioId) =>
      _participantes(desafioId).snapshots().map((snap) {
        final lista = snap.docs
            .map(
              (doc) => Participante(
                uid: doc.id,
                nome: (doc.data()['nome'] as String?) ?? '',
                cor: (doc.data()['cor'] as num?)?.toInt() ?? 0,
              ),
            )
            .toList()
          ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
        return lista;
      });

  @override
  Stream<List<Marcacao>> marcacoes(String desafioId) =>
      _marcacoes(desafioId).snapshots().map(
            (snap) => snap.docs.map((doc) {
              final d = doc.data();
              return Marcacao(
                uid: (d['uid'] as String?) ?? '',
                data: (d['data'] as String?) ?? '',
                tipo: tipoMarcacaoDoId(d['tipo'] as String?),
                comAmigo: (d['comAmigo'] as bool?) ?? false,
              );
            }).toList(),
          );

  @override
  Future<void> salvarMarcacao(String desafioId, Marcacao marcacao) =>
      _marcacoes(desafioId).doc(marcacao.id).set({
        'uid': marcacao.uid,
        'data': marcacao.data,
        'tipo': marcacao.tipo.name,
        'comAmigo': marcacao.comAmigo,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> removerMarcacao(String desafioId, String uid, String data) =>
      _marcacoes(desafioId).doc('${uid}_$data').delete();

  @override
  Future<void> atualizarNome({
    required String uid,
    required String nome,
    String? desafioId,
  }) async {
    final lote = _db.batch()
      ..set(_usuario(uid), {'nome': nome.trim()}, SetOptions(merge: true));
    if (desafioId != null) {
      lote.update(_participantes(desafioId).doc(uid), {'nome': nome.trim()});
    }
    await lote.commit();
  }

  @override
  Future<void> sairDoDesafio({
    required String desafioId,
    required String uid,
  }) async {
    final minhas =
        await _marcacoes(desafioId).where('uid', isEqualTo: uid).get();
    final lote = _db.batch();
    for (final doc in minhas.docs) {
      lote.delete(doc.reference);
    }
    lote
      ..delete(_participantes(desafioId).doc(uid))
      ..update(_usuario(uid), {'desafioId': FieldValue.delete()});
    await lote.commit();
  }
}
