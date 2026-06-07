import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import para pegar o ID do usuário
//import 'package:firebase_database/firebase_database.dart'; // Import do Firebase Database
import '../screens/investigation/ambientes_screen.dart'; // Import da tela de ambientes
import '../realtime_service.dart'; // Import do serviço de Realtime Database
 // Import do seu serviço

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Buscamos o ID do usuário logado e instanciamos o serviço
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quem Apagou as Luzes?"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.flashlight_on,
              size: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              "RPG Investigativo",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            //INÍCIO DO STREAMBUILDER
            if (userId != null)
              FutureBuilder<Map<String, dynamic>?>(
                future: RealtimeService.obterProgresso(userId),
                builder: (context, snapshot) {
                  int faseSalvaNoFirebase = 1;

                  if (snapshot.hasData && snapshot.data != null) {
                    final dados = snapshot.data!; 
                    faseSalvaNoFirebase = dados['fase_atual'] ?? 1;
                  }
                  return Column(
                    children: [
                      Text(
                        "Seu Progresso: Ambiente $faseSalvaNoFirebase",
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.w500,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        child: Text(faseSalvaNoFirebase == 1 ? "Iniciar Investigação" : "Continuar Investigação"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // 3. Passamos a fase carregada para a tela de ambientes
                              builder: (_) => AmbientesScreen(faseInicial: faseSalvaNoFirebase),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              )
            else ...[
              // Caso o fluxo de login falhe e chegue sem ID aqui
              const Text("Usuário não autenticado no Firebase."),
              const SizedBox(height: 40),
              ElevatedButton(
                child: const Text("Iniciar Investigação (Modo Convidado)"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AmbientesScreen()),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
