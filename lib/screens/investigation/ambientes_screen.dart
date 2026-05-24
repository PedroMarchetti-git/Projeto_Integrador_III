import 'package:flutter/material.dart';
import '../../data/ambientes_mock.dart';
import '../../widgets/ambiente_card.dart';
import 'caab_screens.dart';
import 'auditorio_screen.dart';

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

  void _navegarParaAmbiente(BuildContext context, ambiente) {
    switch (ambiente.id) {

      case '1':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AuditorioScreen()),
        );
        break;

      case '4':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CaabScreen()),
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Entrando no ${ambiente.nome}")),
        );
    }
  }
}