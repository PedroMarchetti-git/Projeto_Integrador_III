import 'package:flutter/material.dart'; 
import 'package:provider/provider.dart';
import '../../models/game_state.dart'; 
import '../../widgets/choice_button.dart'; 
import '../../widgets/clue_card.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import '../../realtime_service.dart'; 

class CeaabScreen extends StatefulWidget { 
  const CeaabScreen({super.key}); 
  
  @override 
  State<CeaabScreen> createState() => _CeaabScreenState();
}

class _CeaabScreenState extends State<CeaabScreen> { 
  String currentDialogue = "";

  @override
  void initState() { 
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) { 
      _initializeLocation();
    });
  }

  // Inicializa a sala marcando como visitada e carregando o texto descritivo
  void _initializeLocation() { 
    final gameState = Provider.of<GameState>(context, listen: false);
    gameState.visitLocation('ceaab');
    setState(() { 
      currentDialogue = _getInitialDescription();
    });
  }

  // Salva o progresso do usuário no banco de dados do Firebase
  void _salvarFaseNoFirebase(int novaFase) async { 
    final User? usuarioAtual = FirebaseAuth.instance.currentUser;
    if (usuarioAtual != null) { 
      final realtimeService = RealtimeService();
      await realtimeService.salvarProgresso(usuarioAtual.uid, novaFase);
      debugPrint("Progresso salvo no Firebase para a fase: $novaFase");
    } else {
      debugPrint("Nenhum usuário logado. Progresso não salvo.");
    }
  }

  // === LÓGICA DE VITÓRIA ===
  // Verifica se o jogador já pegou as 3 pistas necessárias
  void _verificarProgressoDasPistas() { 
    final gameState = Provider.of<GameState>(context, listen: false);

    if (gameState.allClues.length >= 3 && !gameState.hasToken('token_manacas')) { 
      gameState.addToken('token_manacas');
      _salvarFaseNoFirebase(2);
      
      ScaffoldMessenger.of(context).showSnackBar( 
        const SnackBar( 
          content: Text('Você coletou todas as pistas essenciais!'), 
          backgroundColor: Colors.green,  
          duration: Duration(seconds: 3),  
        ),
      );
      
      setState(() { 
        currentDialogue += "\n\n✨ [DESBLOQUEADO] Sensacional! Você coletou todas as pistas do CAAB. Já temos o suficiente para a acusação final!"; 
      });
    }
  }

  @override
  Widget build(BuildContext context) { 
    final gameState = Provider.of<GameState>(context); 
    final availableActions = _getAvailableActions(gameState); 

    return Scaffold( 
      appBar: AppBar( 
        title: const Text('CAAB'), 
        backgroundColor: Colors.black87, 
        foregroundColor: Colors.white,
      ),
      body: Stack( 
        children: [ 
          Positioned.fill( 
            child: Image.asset( 
              'assets/images/ceaab.jpeg', 
              fit: BoxFit.cover, 
            ),
          ),
          // 2. Película escura para dar contraste ao texto
          Positioned.fill( 
            child: Container( 
              color: Colors.black.withValues(alpha: 0.35), 
            ),
          ),
          
          // 3. Conteúdo rolável e adaptável
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0), 
              child: Column( 
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [ 
                  // Caixa de Diálogo
                  Container( 
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0), 
                    decoration: BoxDecoration( 
                      color: Colors.black45, 
                      borderRadius: BorderRadius.circular(8), 
                    ),
                    child: Text( 
                      currentDialogue, 
                      style: const TextStyle(fontSize: 16.0, color: Colors.white, height: 1.4), 
                    ),
                  ),
                  const SizedBox(height: 20), 
                  
                  // Título da Lista de Ações
                  const Text( 
                    'Ações Disponíveis:', 
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white), 
                  ),
                  const SizedBox(height: 10), 
                  
                  // Construtor da Lista de Ações Dinâmicas
                  ListView.builder( 
                    shrinkWrap: true, 
                    physics: const NeverScrollableScrollPhysics(), 
                    itemCount: availableActions.length, 
                    itemBuilder: (context, index) { 
                      final action = availableActions[index]; 
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ChoiceButton( 
                          text: action, 
                          onPressed: () => _handleAction(action), 
                        ),
                      );
                    },
                  ),
                  
                  // === BOTÃO DE FINALIZAR AMBIENTE E DICA DO MANACÁS ===
                  if (gameState.hasToken('token_manacas')) ...[
                    const SizedBox(height: 25),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50.withValues(alpha: 0.95), 
                        border: Border.all(color: Colors.green.shade700, width: 2), 
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Column(
                        children: [
                          const Text('✨ Investigação Concluída! ✨', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                          const SizedBox(height: 8),
                          const Text(
                            'Você reuniu todas as provas e já sabe quem são os culpados.\n\nO seu próximo e último destino é o prédio dos Manacás!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50)
                            ),
                            onPressed: () {
                              // Desbloqueia o Manacás no GPS e volta pra tela inicial
                              context.read<GameState>().desbloquearAmbiente();
                              Navigator.pop(context); 
                            },
                            child: const Text('Finalizar Investigação desta Sala', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                  ],

                  // Caderno de Pistas Visuais (com animação)
                  if (gameState.allClues.isNotEmpty) ...[ 
                    const SizedBox(height: 20),
                    const Text(
                      "📋 Pistas Encontradas no Ambiente:", 
                      style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold, fontSize: 16), 
                    ),
                    const SizedBox(height: 10),
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
          ),
        ],
      ),
    );
  }

  // Textos e Diálogos do Jogo
  String _getInitialDescription() { 
    return "Você está no CAAB, o Centro de Estudo Africanos e AfroBrasileiros da PUC. "
        "O ambiente é vibrante, com paredes coloridas e uma atmosfera de aprendizado e cultura. "
        "Algumas estantes repletas de livros sobre história, cultura e arte afro-brasileira. "
        "Há algumas pessoas e estudantes aqui, e você pode conversar com eles para obter informações. "
        "As luzes suaves e as mesas cheias de papéis bagunçados que se espalharam durante o apagão, "
        "sendo organizados pela comendadora responsável pelo CAAB.";
  }

  // Gera a notificação na tela quando uma pista é encontrada
  void _showClueDiscoveryFeedback(String clue) { 
    var row = Row( 
          children: [ 
            const Icon(Icons.auto_awesome, color: Colors.amber), 
            const SizedBox(width: 12), 
            Expanded( 
              child: Text( 
                'Nova Pista: $clue', 
                style: const TextStyle( 
                    color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16, 
              ),
            ),
            )
          ],
        );
    ScaffoldMessenger.of(context).showSnackBar( 
      SnackBar( 
        content: row, 
        backgroundColor: Colors.indigo.shade800, 
        behavior: SnackBarBehavior.floating, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
        duration: const Duration(seconds: 3), 
      ),
    );
  }

  // Motor principal: reage aos cliques nos botões de ação
  void _handleAction(String action) { 
    final gameState = Provider.of<GameState>(context, listen: false); 

    setState(() {
      switch (action) { 
        case "Procurar na estante de livros": 
          currentDialogue = "Você encontrou um livro antigo sobre a história da PUC."; 
          gameState.completeInteraction('ceaab_bookshelf'); 
          if (gameState.addClue('Livro de História da PUC')) { 
            _showClueDiscoveryFeedback('Livro de História da PUC'); 
          }
          break;

        case "Examinar a obra de arte": 
          currentDialogue = "A obra de arte parece esconder algo por trás dela."; 
          gameState.completeInteraction('ceaab_artwork'); 
          if (gameState.addClue('Esconderijo na obra de arte')) {
            _showClueDiscoveryFeedback('Esconderijo na obra de arte');
          }
          break; 

        case "Verificar os computadores": 
          currentDialogue = "💻 Os computadores estão desligados devido ao apagão, mas você nota um pen-drive deixado em uma das portas USB com arquivos sobre o sistema elétrico!"; 
          gameState.completeInteraction('ceaab_computers'); 
          if (gameState.addClue("Pen-drive com arquivos criptografados")) {
             _showClueDiscoveryFeedback("Pen-drive com arquivos criptografados");
          }
          break;

        case "Conversar com a comendadora Edna": 
          currentDialogue = "A comendadora Edna está muito ocupada organizando os papéis."; 
          gameState.completeInteraction('ceaab_comendadora'); 
          break; 

        case "Procurar por pistas": 
          currentDialogue = "Você não encontrou nada de novo por enquanto."; 
          gameState.completeInteraction('ceaab_procurar_pistas'); 
          break; 

        case "Verificar Inventário":
          currentDialogue = "Você revisa as informações e pistas que já coletou na sua mente.";
          break;
      }
      
      _verificarProgressoDasPistas(); 
    });
  } 

  // Filtra quais ações ainda estão disponíveis para não poluir a tela
  List<String> _getAvailableActions(GameState gameState) { 
    List<String> actions = []; 

    if (!gameState.isInteractionDone('ceaab_bookshelf')) { 
      actions.add("Procurar na estante de livros"); 
    }
    if (!gameState.isInteractionDone('ceaab_artwork')) { 
      actions.add("Examinar a obra de arte"); 
    }
    if (!gameState.isInteractionDone('ceaab_computers')) { 
      actions.add("Verificar os computadores"); 
    }

    actions.add("Conversar com a comendadora Edna"); 
    actions.add("Procurar por pistas");
    actions.add("Verificar Inventário"); 
    
    return actions;
  }
}