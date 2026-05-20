import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Importa o arquivo que já existe no seu projeto

class Service {
  // Cria uma função assíncrona para iniciar a conexão com o Firebase
  static Future<void> iniciarFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("Conexão com o Firebase do pi3-rpg estabelecida com sucesso!");
    } catch (e) {
      print("Erro ao conectar com o Firebase: $e");
    }
  }
}
