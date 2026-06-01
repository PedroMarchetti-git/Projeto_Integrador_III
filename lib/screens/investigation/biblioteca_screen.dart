import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_state.dart';

class BibliotecaScreen extends StatefulWidget {
  const BibliotecaScreen({super.key});

  @override
  State<BibliotecaScreen> createState() => _BibliotecaScreenState();
}

class _BibliotecaScreenState extends State<BibliotecaScreen> {
  String currentDialogue = "";
  
  // Variável para controlar se o minigame já foi vencido
  bool terminalDesbloqueado = false; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  void _initializeLocation() {
    final gameState = Provider.of<GameState>(context, listen: false);
    gameState.visitLocation('biblioteca');
    setState(() {
      currentDialogue = _getInitialDescription();
    });
  }

  // === REGRA PARA O BOTÃO VERDE APARECER (Agora exige o vídeo das câmeras) ===
  bool _todasPistasColetadas(GameState gameState) {
    return gameState.allClues.contains("Relato da Bibliotecária") &&
           gameState.allClues.contains("Página do mapa elétrico roubada") &&
           gameState.allClues.contains("Vídeo das câmeras: Recibo da Praça");
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final actions = _getAvailableActions(gameState);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Biblioteca"),
        backgroundColor: Colors.brown.shade800,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(color: const Color(0xFF1E1E1E)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: Colors.brown.shade50,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        currentDialogue,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text("Ações Disponíveis:", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      itemCount: actions.length,
                      itemBuilder: (_, index) {
                        final action = actions[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: action.contains("Terminal") ? Colors.blue.shade800 : Colors.brown.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => _handleAction(action),
                            child: Text(action, textAlign: TextAlign.center),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 10),

                  if (_todasPistasColetadas(gameState))
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.green.shade50, border: Border.all(color: Colors.green.shade700, width: 2), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          const Text('✨ Pista Crucial Encontrada! ✨', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                          const SizedBox(height: 8),
                          const Text('As câmeras mostraram o suspeito fugindo. Na pressa, ele deixou cair um recibo da Praça de Alimentação.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black87)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(45)),
                            onPressed: () {
                              context.read<GameState>().desbloquearAmbiente();
                              Navigator.pop(context); 
                            },
                            child: const Text("Avançar para a Praça de Alimentação"),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitialDescription() {
    return "O silêncio da biblioteca contrasta com a confusão lá fora. Você veio buscar a planta do sistema elétrico da PUC. O acervo de engenharia fica no segundo andar, e o terminal de computadores da Dona Marta está piscando um aviso de erro.";
  }

  List<String> _getAvailableActions(GameState gameState) {
    List<String> actions = [];

    if (!gameState.isInteractionDone('biblioteca_balcao')) {
      actions.add("Conversar com Dona Marta (Bibliotecária)");
    }
    if (!gameState.isInteractionDone('biblioteca_estante')) {
      actions.add("Procurar na Seção de Engenharia");
    }
    if (gameState.isInteractionDone('biblioteca_estante') && !gameState.isInteractionDone('biblioteca_livro')) {
      actions.add("Analisar o livro 'Infraestrutura Elétrica'");
    }
    
    // O Minigame aparece depois de encontrar o livro rasgado
    if (gameState.isInteractionDone('biblioteca_livro') && !terminalDesbloqueado) {
      actions.add("Acessar Terminal de Câmeras (Bloqueado)");
    }

    actions.add("Revisar Caderno de Pistas");
    return actions;
  }

  void _showClueFeedback(String clue) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Nova pista: $clue"), backgroundColor: Colors.amber.shade800, duration: const Duration(seconds: 3)),
    );
  }

  void _handleAction(String action) {
    final gameState = Provider.of<GameState>(context, listen: false);

    setState(() {
      switch (action) {
        case "Conversar com Dona Marta (Bibliotecária)":
          currentDialogue = "Dona Marta ajeita os óculos, nervosa.\n\n'Alguém subiu correndo para o setor de exatas antes do apagão. O sistema do meu computador travou logo depois que ele saiu.'";
          gameState.completeInteraction('biblioteca_balcao');
          if (gameState.addClue("Relato da Bibliotecária")) _showClueFeedback("Alguém apressado foi para o setor de exatas.");
          break;

        case "Procurar na Seção de Engenharia":
          currentDialogue = "Na prateleira de Engenharia, o volume 4 de 'Infraestrutura do Campus' foi deixado jogado em cima de uma mesa.";
          gameState.completeInteraction('biblioteca_estante');
          break;

        case "Analisar o livro 'Infraestrutura Elétrica'":
          currentDialogue = "A página que continha a planta principal foi arrancada com força!\n\nPrecisamos ver nas câmeras de segurança quem estava sentado aqui. O terminal da biblioteca fica no térreo.";
          gameState.completeInteraction('biblioteca_livro');
          if (gameState.addClue("Página do mapa elétrico roubada")) _showClueFeedback("Página roubada");
          break;

        case "Acessar Terminal de Câmeras (Bloqueado)":
          // Abre a janela do Minigame!
          _iniciarMinigameTerminal(gameState);
          break;

        case "Revisar Caderno de Pistas":
          currentDialogue = "Você tem ${gameState.allClues.length} pistas coletadas no total. Pensa no que tudo isso significa...";
          break;
      }
    });
  }

  // =========================================================================
  // MOTOR DO MINIGAME - JANELA FLUTUANTE
  // =========================================================================
  void _iniciarMinigameTerminal(GameState gameState) {
    showDialog(
      context: context,
      barrierDismissible: false, // Impede de fechar clicando fora
      builder: (BuildContext context) {
        return MinigameTerminal(
          onVictory: () {
            Navigator.of(context).pop(); // Fecha o dialog
            setState(() {
              terminalDesbloqueado = true;
              currentDialogue = "ACESSO CONCEDIDO.\n\nO vídeo da câmera mostra o suspeito rasgando o livro. Ao correr, algo cai do bolso dele. Você vai até a mesa e encontra a pista: um recibo de lanche comprado minutos antes.";
              if (gameState.addClue("Vídeo das câmeras: Recibo da Praça")) {
                _showClueFeedback("Vídeo das câmeras: Recibo da Praça");
              }
            });
          },
        );
      },
    );
  }
}

// =========================================================================
// CLASSE DO MINIGAME (Lógica Separada para manter o Clean Code)
// =========================================================================
class MinigameTerminal extends StatefulWidget {
  final VoidCallback onVictory;
  
  const MinigameTerminal({super.key, required this.onVictory});

  @override
  State<MinigameTerminal> createState() => _MinigameTerminalState();
}

class _MinigameTerminalState extends State<MinigameTerminal> {
  // A ordem correta exigida (Índices dos botões)
  // Portas: 21, 80, 443, 8080 -> Posições na lista: 2, 0, 3, 1
  final List<int> sequenciaCorreta = [2, 0, 3, 1];
  List<int> sequenciaDoJogador = [];
  bool erro = false;

  final List<String> botoes = ["Porta 80", "Porta 8080", "Porta 21", "Porta 443"];

  void _pressionarBotao(int index) {
    setState(() {
      erro = false;
      // Adiciona o botão na sequência se ele já não foi apertado
      if (!sequenciaDoJogador.contains(index)) {
        sequenciaDoJogador.add(index);
        
        // Verifica a vitória
        if (sequenciaDoJogador.length == sequenciaCorreta.length) {
          bool venceu = true;
          for (int i = 0; i < sequenciaCorreta.length; i++) {
            if (sequenciaDoJogador[i] != sequenciaCorreta[i]) {
              venceu = false;
              break;
            }
          }

          if (venceu) {
            widget.onVictory();
          } else {
            // Se errou, mostra feedback visual e reseta
            erro = true;
            sequenciaDoJogador.clear();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.blueGrey.shade900,
      title: const Text("Bypass de Segurança", style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "O terminal foi travado pelo suspeito.\nPara acessar o log de câmeras, reconecte as portas de rede em ORDEM CRESCENTE.",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          if (erro)
            const Text("SEQUÊNCIA INVÁLIDA. SISTEMA REINICIADO.", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          // Geração dos botões do minigame
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(botoes.length, (index) {
              bool pressionado = sequenciaDoJogador.contains(index);
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: pressionado ? Colors.green : Colors.blueGrey.shade700,
                  foregroundColor: Colors.white,
                ),
                onPressed: pressionado ? null : () => _pressionarBotao(index),
                child: Text(botoes[index]),
              );
            }),
          ),
          
          const SizedBox(height: 20),
          Text(
            "Conexões estabelecidas: ${sequenciaDoJogador.length} / ${botoes.length}",
            style: const TextStyle(color: Colors.greenAccent),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Botão de desistir/voltar
          child: const Text("Abortar", style: TextStyle(color: Colors.redAccent)),
        )
      ],
    );
  }
}