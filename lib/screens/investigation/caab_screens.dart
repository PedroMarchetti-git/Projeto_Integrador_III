import 'package:flutter/material.dart'; // Importa o pacote Flutter para construir a interface do usuário.
import 'package:provider/provider.dart'; // Importa o pacote Provider para gerenciamento de estado, permitindo que a tela acesse o estado do jogo.
import '../models/game_state.dart'; // Importa o modelo GameState, que contém o estado atual do jogo, como tokens obtidos, personagens interrogados, etc.
import '../widgets/choice_button.dart'; // Importa da pasta correta de widgets
import '../widgets/clue_card.dart'; // Importa da pasta correta de widgets
import 'biblioteca_screen.dart'; // Importa a tela da Biblioteca, permitindo que o jogador navegue para lá a partir do CAAB.

class CaabScreen extends StatefulWidget {
  @override // Sobrescreve o método createState para criar a instância do estado da tela.
  _CaabScreenState createState() => _CaabScreenState(); // Retorna uma nova instância do estado da tela, onde a lógica de interação e exibição será implementada.
}

class _CaabScreenState extends State<CaabScreen> {
  bool showingClues = false; // Controla se as pistas estão sendo mostradas na tela.
  bool showingCharacters = false; // Controla se os personagens interrogados estão sendo mostrados na tela.
  String currentDialogue = ""; // Armazena o diálogo atual a ser exibido, que pode mudar com base nas interações do jogador.

  @override // Sobrescreve o método build para construir a interface do usuário da tela do CAAB, exibindo opções de interação, pistas e personagens com base no estado atual do jogo.
  void initState() {// Sobrescreve o método initState para inicializar o estado da tela, como carregar dados iniciais ou configurar variáveis.
    super.initState(); // Inicializa o estado da tela, como carregar dados iniciais ou configurar variáveis.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  void _initializeLocation() {
    final gameState = Provider.of<GameState>(context, listen: false);
    gameState.visitLocation ('caab'); // Marca a localização do CAAB como visitada no estado do jogo, o que pode desbloquear interações ou pistas específicas para essa localização.

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
        title: Text('CAAB'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentDialogue,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20),
            Text(
              'Ações Disponíveis:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: availableActions.length,
                itemBuilder: (context, index) {
                  final action = availableActions[index];
                  return ChoiceButton(
                    text: action,
                    onPressed: () {
                      _handleAction(action);
                    },
                  );
                },
              ),
            ),
            if (gameState.allClues.isNotEmpty) ...[
              SizedBox(height: 20),
              Text(
                'Pistas:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              ...gameState.allClues.map((clue) => TweenAnimationBuilder<double>(
                    key: ValueKey(clue), // Garante que a animação rode apenas para itens novos
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
                  )).toList(),
            ],
            if (showingCharacters) ...[
              SizedBox(height: 20),
              Text(
                'Personagens Interrogados:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              // Aqui você pode adicionar a exibição de personagens
              // Exemplo: Text('Comendadora Edna'),
            ],
          ],
        ),
      ),
    );
  }

   String _getInitialDescription() { // Retorna a descrição inicial do ambiente do CAAB, que pode ser exibida quando o jogador entra pela primeira vez, fornecendo uma introdução ao ambiente e suas características.
     return "Você está no CAAB, o Centro de estudos Afro e Afro Brasileiros da PUC."
            "O ambiente é vibrante, com paredes coloridas e uma atmosfera de aprendizado e cultura. "
            "Estantes repletas de livros sobre história, cultura e arte afro-brasileira. "
            "Há muitos estudantes aqui, e você pode conversar com eles para obter informações." 
            "As luzes suaves e as mesas cheias de papéis bagunçados que se espalharam durante o apagão, sendo organizados pela comendadora responsável pelo CAAB. ";
   }

  void _showClueDiscoveryFeedback(String clue) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Nova Pista: $clue', 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          currentDialogue = "Você encontrou um livro antigo sobre a história da PUC.";
          gameState.completeInteraction('caab_bookshelf');
          if (gameState.addClue('Livro de História da PUC')) {
            _showClueDiscoveryFeedback('Livro de História da PUC');
          }
          break;
        case "Examinar a obra de arte":
          currentDialogue = "A obra de arte parece esconder algo por trás dela.";
          gameState.completeInteraction('caab_artwork');
          break;
        case "Verificar os computadores":
          currentDialogue = "Os computadores estão desligados devido ao apagão.";
          gameState.completeInteraction('caab_computers');
          break;
        case "Conversar com a comendadora Edna":
          currentDialogue = "A comendadora Edna está muito ocupada organizando os papéis.";
          break;
        case "Procurar por pistas":
          currentDialogue = "Você não encontrou nada de novo por enquanto.";
          break;
        case "Verificar Inventário":
          currentDialogue = "Seu inventário está vazio."; // Idealmente, isso abriria uma tela de inventário
          break;
        case "Ir para a Biblioteca":
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => BibliotecaScreen()));
          currentDialogue = "Você se dirigiu à Biblioteca.";
          break;
        default:
          currentDialogue = "Você realizou uma ação desconhecida.";
      }
    });
  }

   List<String> _getAvailableActions(GameState gameState){ // Retorna uma lista de ações disponíveis para o jogador no ambiente do CAAB, com base no estado atual do jogo, como quais interações já foram feitas e quais tokens o jogador possui, permitindo que a interface exiba as opções corretas para o jogador.
    List<String> actions = []; // Lista de ações disponíveis, que será preenchida com base no estado atual do jogo, como quais interações já foram feitas e quais tokens o jogador possui.
    if (!gameState.isInteractionDone('caab_bookshelf')) { // Controla se o jogador já procurou a estante de livros, para evitar mostrar a mesma pista repetidamente. Se ainda não procurou, adiciona a ação de procurar na estante de livros à lista de ações disponíveis.
      actions.add("Procurar na estante de livros"); // Adiciona a ação de procurar na estante de livros à lista de ações disponíveis, permitindo que o jogador interaja com esse elemento do ambiente para obter pistas ou informações.
    }
    if (!gameState.isInteractionDone('caab_artwork')) { // Controla se o jogador já examinou a obra de arte, para evitar mostrar a mesma pista repetidamente. Se ainda não examinou, adiciona a ação de examinar a obra de arte à lista de ações disponíveis.
      actions.add("Examinar a obra de arte");// Adiciona a ação de examinar a obra de arte à lista de ações disponíveis, permitindo que o jogador interaja com esse elemento do ambiente para obter pistas ou informações.
    }
    if (!gameState.isInteractionDone('caab_computers')) {// Controla se o jogador já verificou os computadores, para evitar mostrar a mesma pista repetidamente. Se ainda não verificou, adiciona a ação de verificar os computadores à lista de ações disponíveis.
      actions.add("Verificar os computadores");// Adiciona a ação de verificar os computadores à lista de ações disponíveis, permitindo que o jogador interaja com esse elemento do ambiente para obter pistas ou informações.
    }

    actions.add("Conversar com a comendadora Edna");// Adiciona a ação de conversar com a comendadora Edna à lista de ações disponíveis, permitindo que o jogador interaja com esse personagem para obter pistas ou informações.
    actions.add("Procurar por pistas");// Adiciona a ação de procurar por pistas à lista de ações disponíveis, permitindo que o jogador interaja com o ambiente para encontrar pistas relacionadas ao caso.
    actions.add("Verificar Inventário");// Adiciona a ação de verificar o inventário à lista de ações disponíveis, permitindo que o jogador acesse seus tokens e pistas coletados para ajudar na investigação.

    if (gameState.hasToken('token_biblioteca')) {// Verifica se o jogador possui o token da biblioteca, e se sim, adiciona a ação de ir para a biblioteca à lista de ações disponíveis, permitindo que o jogador navegue para essa tela se já tiver desbloqueado o acesso à biblioteca.
      actions.add("Ir para a Biblioteca");// Adiciona a ação de ir para a biblioteca à lista de ações disponíveis, permitindo que o jogador navegue para essa tela se já tiver desbloqueado o acesso à biblioteca.
    }
    return actions;// Retorna a lista de ações disponíveis, que será usada para exibir as opções corretas para o jogador na interface do CAAB, com base no estado atual do jogo e nas interações já feitas.
   }
}