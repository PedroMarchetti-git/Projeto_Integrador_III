import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../realtime_service.dart'; 
import 'package:provider/provider.dart';
import '../../models/game_state.dart'; 
import 'ceaab_screens.dart'; 
import 'auditorio_screen.dart';
import 'biblioteca_screen.dart';
import 'manacas_screen.dart';
import 'praca_alimentacao_screen.dart';
class AmbientesScreen extends StatelessWidget {
  final int faseInicial;
  const AmbientesScreen({super.key, this.faseInicial = 1});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    int indexAtual = gameState.todosAmbientes.indexWhere((a) => !a.desbloqueado);
    if (indexAtual == -1) indexAtual = gameState.todosAmbientes.length;

    final ambientesVisiveis = gameState.todosAmbientes.sublist(
      0,
      (indexAtual < gameState.todosAmbientes.length) ? indexAtual + 1 : indexAtual,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ambientes"),
        backgroundColor: Colors.black87, 
        foregroundColor: Colors.white,
        // ==========================================
        // BOTÃO DE MUTAR A MÚSICA GLOBAL
        // ==========================================
        actions: [
          IconButton(
            // Se isMuted for verdadeiro, mostra ícone cortado. Senão, alto-falante ligado.
            icon: Icon(
              gameState.isMuted ? Icons.volume_off : Icons.volume_up,
              color: const Color.fromARGB(255, 255, 255, 255), // Uma cor de destaque legal
            ),
            onPressed: () {
              // Chama a função que criamos no GameState
              gameState.alternarMutarMusica();
            },
            tooltip: 'Ligar/Desligar Música', // Ajuda de acessibilidade
          ),
        ],
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
              onTap: () {
                if (cadeadoAberto) {
                  // Se o cadeado está verde, viaja para a tela
                  _navegarParaAmbiente(context, ambiente);
                } else {
                  // Se está vermelho, mostra o aviso!
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(gameState.obterMotivoBloqueio()),
                      duration: const Duration(seconds: 3),
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

  void _navegarParaAmbiente(BuildContext context, ambiente) async {
    // Pegamos o ID e forçamos a virar String para não dar erro
    final String idSeguro = ambiente.id.toString();

    try{
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      final int? faseInt = int.tryParse(idSeguro);
      if(userId != null && faseInt != null){
        await RealtimeService().salvarProgresso(userId, faseInt);
      }
    } catch (e) {
      debugPrint("⚠️ Erro ao navegar para o ambiente: $e"); 
    }
    if (!context.mounted) return;

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
          MaterialPageRoute(builder: (_) => const CeaabScreen()),
        );
        break;
      case '5':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ManacasScreen()),
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