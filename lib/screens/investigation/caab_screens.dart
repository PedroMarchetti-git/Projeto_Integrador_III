import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_state.dart';
import '../../widgets/choice_button.dart';
import '../../widgets/clue_card.dart';
// import 'biblioteca_screen.dart'; // descomente quando criar essa tela

class CaabScreen extends StatefulWidget {
  @override
  _CaabScreenState createState() => _CaabScreenState();
}

class _CaabScreenState extends State<CaabScreen> {
  bool showingClues = false;
  bool showingCharacters = false;
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
    gameState.visitLocation('caab');
    setState(() {
      currentDialogue = _getInitialDescription();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final availableActions = _getAvailableActions(gameState);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CAAB'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentDialogue,
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ações Disponíveis:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: availableActions.length,
                itemBuilder: (context, index) {
                  final action = availableActions[index];
                  return ChoiceButton(
                    text: action,
                    onPressed: () => _handleAction(action),
                  );
                },
              ),
            ),
            if (gameState.allClues.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Pistas:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              ...gameState.allClues.map((clue) => TweenAnimationBuilder<double>(
                    key: ValueKey(clue),
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
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
                  )),
            ],
          ],
        ),
      ),
    );
  }

  String _getInitialDescription() {
    return "Você está no CAAB, o Centro de estudos Afro e Afro Brasileiros da PUC. "
        "O ambiente é vibrante, com paredes coloridas e uma atmosfera de aprendizado e cultura. "
        "Estantes repletas de livros sobre história, cultura e arte afro-brasileira. "
        "Há muitos estudantes aqui, e você pode conversar com eles para obter informações. "
        "As luzes suaves e as mesas cheias de papéis bagunçados que se espalharam durante o apagão, "
        "sendo organizados pela comendadora responsável pelo CAAB.";
  }

  void _showClueDiscoveryFeedback(String clue) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Nova Pista: $clue',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.indigo.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleAction(String action) {
    final gameState = Provider.of<GameState>(context, listen: false);
    setState(() {
      switch (action) {
        case "Procurar na estante de livros":
          currentDialogue =
              "Você encontrou um livro antigo sobre a história da PUC.";
          gameState.completeInteraction('caab_bookshelf');
          if (gameState.addClue('Livro de História da PUC')) {
            _showClueDiscoveryFeedback('Livro de História da PUC');
          }
          break;
        case "Examinar a obra de arte":
          currentDialogue =
              "A obra de arte parece esconder algo por trás dela.";
          gameState.completeInteraction('caab_artwork');
          break;
        case "Verificar os computadores":
          currentDialogue =
              "Os computadores estão desligados devido ao apagão.";
          gameState.completeInteraction('caab_computers');
          break;
        case "Conversar com a comendadora Edna":
          currentDialogue =
              "A comendadora Edna está muito ocupada organizando os papéis.";
          break;
        case "Procurar por pistas":
          currentDialogue = "Você não encontrou nada de novo por enquanto.";
          break;
        case "Verificar Inventário":
          currentDialogue = "Seu inventário está vazio.";
          break;
        case "Ir para a Biblioteca":
          currentDialogue = "A Biblioteca ainda não está disponível.";
          break;
        default:
          currentDialogue = "Você realizou uma ação desconhecida.";
      }
    });
  }

  List<String> _getAvailableActions(GameState gameState) {
    List<String> actions = [];

    if (!gameState.isInteractionDone('caab_bookshelf')) {
      actions.add("Procurar na estante de livros");
    }
    if (!gameState.isInteractionDone('caab_artwork')) {
      actions.add("Examinar a obra de arte");
    }
    if (!gameState.isInteractionDone('caab_computers')) {
      actions.add("Verificar os computadores");
    }

    actions.add("Conversar com a comendadora Edna");
    actions.add("Procurar por pistas");
    actions.add("Verificar Inventário");

    if (gameState.hasToken('token_biblioteca')) {
      actions.add("Ir para a Biblioteca");
    }

    return actions;
  }
}