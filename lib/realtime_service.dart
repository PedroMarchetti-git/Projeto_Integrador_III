import 'package:firebase_database/firebase_database.dart';

class RealtimeService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // Função para salvar a fase atual do jogador no Realtime Database
  Future<void> salvarProgresso(String userId, int faseAtual) async {
    try {
      DatabaseReference ref = _db.ref("usuarios/$userId");
      await ref.set({
        "fase_atual": faseAtual,
        "ultima_atualizacao": ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint("Erro ao salvar progresso no Realtime: $e");
    }
  }

  // Função para ouvir a fase em tempo real
  Stream<DatabaseEvent> escutarProgresso(String userId) {
    return _db.ref("usuarios/$userId/fase_atual").onValue;
  }
}