import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_state.dart';
import 'caab_screens.dart';
import 'auditorio_screen.dart';
import 'biblioteca_screen.dart';
import 'manacas.dart';
import 'praca_alimentacao_screen.dart';

class AmbientesScreen extends StatelessWidget {
  const AmbientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    int indexAtual = gameState.todosAmbientes.indexWhere((a) => !a.desbloqueado);
    if (indexAtual == -1) indexAtual = gameState.todosAmbientes.length;

    final ambientesVisiveis = gameState.todosAmbientes.sublist(
      0,
      (indexAtual < gameState.todosAmbientes.length) ? indexAtual + 1 : indexAtual,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ambientes"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: ambientesVisiveis.length,
        itemBuilder: (context, index) {
          final ambiente = ambientesVisiveis[index];
          
          final bool isConcluido = ambiente.desbloqueado;
          final bool isAlvoAtual = (index == indexAtual);
          
          // 3. Verificamos o cadeado com o GPS
          bool cadeadoAberto = isConcluido;
          if (isAlvoAtual) {
            cadeadoAberto = gameState.estaNoRaioDoAmbiente();
          }

          // 4. Interface gráfica com o cadeado reativo
          // 4. Interface gráfica com o cadeado reativo
          return Card(
            color: const Color(0xFF1E1E1E), // Cor escura do seu layout
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                ambiente.nome,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  ambiente.descricao,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              trailing: Icon(
                cadeadoAberto ? Icons.lock_open_rounded : Icons.lock_rounded,
                color: cadeadoAberto ? Colors.greenAccent : Colors.redAccent,
                size: 28,
              ),
              // === NOVA LÓGICA DE CLIQUE AQUI ===
              onTap: () {
                if (cadeadoAberto) {
                  // Se o cadeado está verde, viaja para a tela
                  _navegarParaAmbiente(context, ambiente);
                } else {
                  // Se está vermelho, mostra o aviso!
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Você ainda não chegou ao local correto para investigar!"),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _navegarParaAmbiente(BuildContext context, ambiente) {
    // Pegamos o ID e forçamos a virar String para não dar erro
    final String idSeguro = ambiente.id.toString(); 

    switch (idSeguro) {
      case '1':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AuditorioScreen()),
        );
        break;
      case '2':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BibliotecaScreen()),
        );
        break;
      case '3':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PracaAlimentacaoScreen()),
        );
        break;
      case '4':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CaabScreen()),
        );
        break;
      case '5':
        Navigator.of(context).push(
          // O erro do const estava aqui! Removido.
          MaterialPageRoute(builder: (_) => ManacasScreen()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("A tela para o ambiente '${ambiente.nome}' (ID: $idSeguro) ainda não foi encontrada."),
            backgroundColor: Colors.orange,
          ),
        );
        break;
    }
  }
}