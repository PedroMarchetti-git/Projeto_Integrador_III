//import 'package:flutter/foundation.dart';
//import 'package:firebase_core/firebase_core.dart';
//import '../firebase_options.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart'; // 1. Certifique-se de que tem esse import no topo

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Função para salvar no Firestore (que já funciona)
  Future<void> salvarUsuario(String uid, String nome, String email, String senha) async {
    try {
      await _db.collection('players').doc(uid).set({
        'nome': nome,
        'email': email,
        'senha': senha,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Nova função para vincular sessão no Realtime Database
  Future<void> vincularSessaoRealtime(String uid, String nome) async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref("sessoes_ativas/$uid");
      await ref.set({
        "jogador": nome,
        "online": true,
        "faseAtual": "caab_pistas",
        "ultimaInteracao": ServerValue.timestamp,
      });
    } catch (e) {
      //print("Erro no Realtime: $e");
      rethrow;
    }
  }
} 