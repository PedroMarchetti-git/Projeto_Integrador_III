import 'package:flutter/material.dart';
import '../investigation/investigation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Mistério do Apagão"),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.search,
              size: 100,
            ),

            const SizedBox(height: 30),

            const Text(
              "RPG Investigativo",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              child: const Text("Iniciar Investigação"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InvestigationScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              child: const Text("Sair"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}