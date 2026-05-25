import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_state.dart';
import '../../widgets/choice_button.dart';
import '../../widgets/clue_card.dart';

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
      appBar: AppBar(title: const Text("Auditório")),
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
                children: [

                  // TEXTO SEM FUNDO PRETO
                  Text(
                    currentDialogue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView.builder(
                      itemCount: actions.length,
                      itemBuilder: (_, index) {
                        final action = actions[index];

                        return ElevatedButton(
                          onPressed: () => _handleAction(action),
                          child: Text(action),
                        );
                      },
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
    return "Você entra no auditório onde o evento acadêmico ocorreu. "
        "Cadeiras desalinhadas indicam o pânico causado pelo apagão. "
        "O palco permanece parcialmente iluminado e o painel elétrico está aberto. "
        "Aqui começou toda a confusão.";
  }


  List<String> _getAvailableActions(GameState gameState) {
    List<String> actions = [];

    if (!gameState.isInteractionDone('auditorio_painel')) {
      actions.add("Inspecionar painel elétrico");
    }

    if (!gameState.isInteractionDone('auditorio_cameras')) {
      actions.add("Analisar câmeras de segurança");
    }

    if (!gameState.isInteractionDone('auditorio_palco')) {
      actions.add("Examinar o palco");
    }

    actions.add("Conversar com Rafael (Técnico de Som)");
    actions.add("Conversar com Coordenador de Eventos");
    actions.add("Conversar com Técnico de TI");
    actions.add("Procurar por pistas");
    actions.add("Verificar Inventário");

    return actions;
  }

  void _showClueFeedback(String clue) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Nova pista descoberta: $clue"),
        duration: const Duration(seconds: 3),
      ),
    );
  }


  void _handleAction(String action) {
    final gameState = Provider.of<GameState>(context, listen: false);

    setState(() {
      switch (action) {

        // ---------- PAINEL ----------
        case "Inspecionar painel elétrico":
          currentDialogue =
              "O painel apresenta sinais claros de manipulação manual recente.";
          gameState.completeInteraction('auditorio_painel');

          if (gameState.addClue("Painel elétrico manipulado")) {
            _showClueFeedback("Painel elétrico manipulado");
          }
          break;

        case "Analisar câmeras de segurança":
          currentDialogue =
              "As câmeras mostram uma pessoa próxima ao sistema segundos antes do apagão.";
          gameState.completeInteraction('auditorio_cameras');

          if (gameState.addClue("Pessoa próxima ao sistema durante apagão")) {
            _showClueFeedback(
                "Pessoa próxima ao sistema durante apagão");
          }
          break;

        case "Examinar o palco":
          currentDialogue =
              "Cabos foram desconectados manualmente. O apagão pode ter sido proposital.";
          gameState.completeInteraction('auditorio_palco');

          if (gameState.addClue("Sabotagem no sistema de luz")) {
            _showClueFeedback("Sabotagem no sistema de luz");
          }

          _checkUnlockBiblioteca(gameState);
          break;

        case "Conversar com Rafael (Técnico de Som)":
          currentDialogue =
              "Rafael parece nervoso.\n\n"
              "'O sistema estava normal. Isso não foi falha elétrica comum.'";
          break;

        case "Conversar com Coordenador de Eventos":
          currentDialogue =
              "O coordenador evita contato visual.\n\n"
              "'O importante é não criar pânico. Deve ter sido só um problema técnico.'";
          break;

        case "Conversar com Técnico de TI":
          currentDialogue =
              "'Alguém usou minhas credenciais durante o apagão. Eu não estava aqui.'";

          if (gameState.addClue("Credenciais do TI utilizadas remotamente")) {
            _showClueFeedback("Credenciais do TI utilizadas remotamente");
          }

          _checkUnlockBiblioteca(gameState);
          break;

        case "Procurar por pistas":
          currentDialogue =
              "Você observa o ambiente, mas nada novo chama atenção.";
          break;

        case "Verificar Inventário":
          currentDialogue =
              "Você revisa mentalmente todas as pistas coletadas.";
          break;
      }
    });
  }

  void _checkUnlockBiblioteca(GameState gameState) {
    if (gameState.allClues.length >= 3 &&
        !gameState.hasToken('token_biblioteca')) {
      gameState.addToken('token_biblioteca');

      currentDialogue +=
          "\n\nAs evidências indicam que o apagão foi planejado. "
          "Talvez a resposta esteja na biblioteca...";
    }
  }
}