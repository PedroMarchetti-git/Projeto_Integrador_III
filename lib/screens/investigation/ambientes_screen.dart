import 'package:flutter/material.dart';
import '../../data/ambientes_mock.dart';
import '../../widgets/ambiente_card.dart';
import 'caab_screens.dart';
import '../../models/ambiente.dart'; // Importa o modelo Ambiente

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
            onTap: () => _navegarParaAmbiente(context, ambiente),
          );
        },
      ),
    );
  }

  void _navegarParaAmbiente(BuildContext context, Ambiente ambiente) { // Adicionado tipo Ambiente
    switch (ambiente.nome) {
      case "Centro de Estudos Africanos e Afro-Brasileiros": // Corrigido para o nome completo
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => CaabScreen()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Entrando no ${ambiente.nome}")),
        );
    }
  }
}
