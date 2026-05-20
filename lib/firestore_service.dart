import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart'; 

class FirestoreService {
  /// Inicializa a conexão com o Firebase utilizando as opções geradas pelo FlutterFire CLI
  static Future<void> iniciarFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("Conexão com o Firebase estabelecida com sucesso!");
    } catch (e) {
      debugPrint("Erro ao conectar com o Firebase: $e");
    }
  }
}
