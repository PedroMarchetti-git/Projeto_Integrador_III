import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_state.dart';
import '../../widgets/clue_card.dart';
import '../../widgets/choice_button.dart';
import 'minigames/electrical_puzzle_dialog.dart';

class AuditorioScreen extends StatefulWidget {
  const AuditorioScreen({super.key});

  @override
  State<AuditorioScreen> createState() => _AuditorioScreenState();
}

class _AuditorioScreenState extends State<AuditorioScreen> {
  String currentDialogue = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  void _initializeLocation() {
    final gameState = Provider.of<GameState>(context, listen: false);

    gameState.visitLocation('auditorio');

    setState(() {
      currentDialogue = _getInitialDescription();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final actions = _getAvailableActions(gameState);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Auditório"),
      ),
      body: Stack(
        children: [

          // FUNDO
          Positioned.fill(
            child: Image.asset(
              "assets/images/auditorio.jpeg",
              fit: BoxFit.cover,
            ),
          ),

          // CONTEÚDO
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // TEXTO PRINCIPAL
                  Text(
                    currentDialogue,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.5,

                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Ações Disponíveis:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // AÇÕES
                  Expanded(
                    flex: 2,
                    child: ListView.builder(
                      itemCount: actions.length,
                      itemBuilder: (_, index) {
                        final action = actions[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ChoiceButton(
                            text: action,
                            onPressed: () => _handleAction(action),
                          ),
                        );
                      },
                    ),
                  ),

                  // PISTAS
                  if (gameState.allClues.isNotEmpty) ...[
                    const SizedBox(height: 10),

                    const Text(
                      "Pistas Descobertas:",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Expanded(
                      flex: 1,
                      child: ListView(
                        children: gameState.allClues.map((clue) {
                          return TweenAnimationBuilder<double>(
                            key: ValueKey(clue),
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 500),

                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },

                            child: ClueCard(clue: clue),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DESCRIÇÃO INICIAL
  // =========================================================

  String _getInitialDescription() {
    return "Você entra no auditório onde ocorreu o apagão durante o evento acadêmico.\n\n"
        "As cadeiras estão desalinhadas, cabos estão espalhados pelo palco e parte do sistema ainda pisca intermitentemente.\n\n"
        "Algo naquele caos parece ter sido planejado.";
  }

  // =========================================================
  // AÇÕES DISPONÍVEIS
  // =========================================================

  List<String> _getAvailableActions(GameState gameState) {
    List<String> actions = [];

    if (!gameState.isInteractionDone('auditorio_painel')) {
      actions.add("Inspecionar painel elétrico");
    }

    if (!gameState.isInteractionDone('auditorio_cameras')) {
      actions.add("Analisar câmeras de segurança");
    }

    if (!gameState.isInteractionDone('auditorio_palco')) {
      actions.add("Examinar palco");
    }

    if (!gameState.isInteractionDone('auditorio_puzzle')) {
      actions.add("Reconstruir sistema elétrico");
    }

    actions.add("Conversar com Rafael");
    actions.add("Conversar com Coordenador");
    actions.add("Conversar com Técnico de TI");

    return actions;
  }

  // =========================================================
  // FEEDBACK DE PISTA
  // =========================================================

  void _showClueFeedback(String clue) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.white,

      behavior: SnackBarBehavior.floating,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      duration: const Duration(seconds: 3),

      content: Row(
        children: [

          const Icon(
            Icons.search,
            color: Colors.amber,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              "Nova pista descoberta: $clue",

              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  // =========================================================
  // AÇÕES
  // =========================================================

  void _handleAction(String action) {
    final gameState = Provider.of<GameState>(
      context,
      listen: false,
    );

    setState(() {
      switch (action) {

        // PAINEL
        case "Inspecionar painel elétrico":
          currentDialogue =
              "Os disjuntores apresentam sinais claros de manipulação manual.\n\n"
              "Alguém mexeu aqui pouco antes do apagão.";

          gameState.completeInteraction('auditorio_painel');

          if (gameState.addClue(
              "Painel elétrico manipulado")) {
            _showClueFeedback(
                "Painel elétrico manipulado");
          }

          break;

        // CAMERAS
        case "Analisar câmeras de segurança":
          currentDialogue =
              "As gravações falham exatamente durante o apagão.\n\n"
              "Pouco antes da interrupção, uma pessoa aparece próxima ao sistema.";

          gameState.completeInteraction(
              'auditorio_cameras');

          if (gameState.addClue(
              "Falha proposital nas câmeras")) {
            _showClueFeedback(
                "Falha proposital nas câmeras");
          }

          break;

        // PALCO
        case "Examinar palco":
          currentDialogue =
              "Cabos foram desconectados manualmente atrás do palco.\n\n"
              "Somente alguém com conhecimento técnico conseguiria fazer isso rapidamente.";

          gameState.completeInteraction(
              'auditorio_palco');

          if (gameState.addClue(
              "Sabotagem técnica no palco")) {
            _showClueFeedback(
                "Sabotagem técnica no palco");
          }

          break;

        // PUZZLE
        case "Reconstruir sistema elétrico":
          _openPuzzle();
          break;

        // RAFAEL
        case "Conversar com Rafael":
          currentDialogue =
              "Rafael parece desconfiado.\n\n"
              "'O sistema estava funcionando normalmente antes do evento começar.'\n\n"
              "'Isso não foi um simples problema elétrico.'";

          break;

        // COORDENADOR
        case "Conversar com Coordenador":
          currentDialogue =
              "O coordenador ajeita os óculos repetidamente.\n\n"
              "'Precisamos evitar pânico.'\n\n"
              "'O importante agora é manter o evento sob controle.'";

          break;

        // TI
        case "Conversar com Técnico de TI":
          currentDialogue =
              "O Técnico de TI parece cansado.\n\n"
              "'Os servidores sofreram acesso remoto durante o apagão.'\n\n"
              "'Ainda estou tentando entender como isso aconteceu.'";

          if (gameState.addClue(
              "Acesso remoto detectado")) {
            _showClueFeedback(
                "Acesso remoto detectado");
          }

          break;

      }
    });
  }

  // =========================================================
  // PUZZLE
  // =========================================================

  void _openPuzzle() async {
    final result = await showDialog(
      context: context,
      builder: (_) => const ElectricalPuzzleDialog(),
    );

    if (result == true) {

      final gameState = Provider.of<GameState>(
        context,
        listen: false,
      );

      gameState.completeInteraction(
          'auditorio_puzzle');

      if (gameState.addClue(
          "Sistema restaurado revela acesso remoto")) {

        _showClueFeedback(
            "Sistema restaurado revela acesso remoto");
      }

      setState(() {
        currentDialogue =
            "Após restaurar parcialmente o sistema, você encontra registros ocultos indicando acesso remoto ao painel durante o apagão.";
      });
    }
  }
}