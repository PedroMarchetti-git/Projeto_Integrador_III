import 'package:flutter/material.dart';
import '../../data/ambientes_mock.dart';
import '../../widgets/ambiente_card.dart';

class AmbientesScreen extends StatelessWidget {
  const AmbientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ambientes"),
      ),
      body: ListView.builder(
        itemCount: ambientes.length,
        itemBuilder: (context, index) {

          final ambiente = ambientes[index];

          return AmbienteCard(
            ambiente: ambiente,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Entrando no ${ambiente.nome}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}