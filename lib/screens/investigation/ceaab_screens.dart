import 'package:flutter/material.dart'; // Importa o Flutter Material para criar a interface do usuário
import 'package:provider/provider.dart';// Importa o Provider para gerenciamento de estado
import '../../models/game_state.dart'; // Importa o GameState para acessar o estado do jogo e as interações
import '../../widgets/choice_button.dart'; // Importa o ChoiceButton para criar botões de escolha personalizados
import '../../widgets/clue_card.dart'; // Importa o ClueCard para exibir as pistas coletadas de forma estilizada
import 'package:firebase_auth/firebase_auth.dart'; // Importa o FirebaseAuth para acessar o usuário atual e salvar o progresso no Firebase
import '../../realtime_service.dart'; // Importa o RealtimeService para salvar o progresso do jogador no Firebase Realtime Database
//import '../../screens/manacas.dart';// Importa a tela de Manacás para permitir a navegação após coletar as pistas do CEAAB

class CeaabScreen extends StatefulWidget { // Define a tela do CEAAB como um StatefulWidget para permitir atualizações dinâmicas com base nas interações do jogador
  const CeaabScreen({super.key}); // Construtor da tela do CEAAB, que é uma tela de investigação onde o jogador pode explorar o ambiente, coletar pistas e interagir com personagens para avançar na história.
  @override // Sobrescreve o método createState para criar o estado da tela do CEAAB, que gerenciará as interações do jogador, o progresso das pistas e a atualização da interface com base nas ações realizadas.
  State<CeaabScreen> createState() => _CeaabScreenState();// Cria o estado da tela do CEAAB, que é onde a lógica de jogo e a interface do usuário serão implementadas.
}

class _CeaabScreenState extends State<CeaabScreen> {// Define o estado da tela do CEAAB, onde serão gerenciadas as interações do jogador, o progresso das pistas e a atualização da interface com base nas ações realizadas.
  bool showingClues = false;// Variável para controlar a exibição das pistas coletadas
  bool showingCharacters = false;// Variável para controlar a exibição dos personagens disponíveis para interação
  String currentDialogue = "";// Variável para armazenar o diálogo ou descrição atual do ambiente, que será atualizado com base nas ações do jogador e nas interações realizadas.

  @override
  void initState() {// Sobrescreve o método initState para realizar a inicialização da tela do CEAAB, onde o jogador visita a localização e o diálogo inicial é configurado.
    super.initState();// Chama o método initState da classe pai para garantir a inicialização adequada do estado do widget
    WidgetsBinding.instance.addPostFrameCallback((_) {// Adiciona um callback para ser executado após a construção do widget, garantindo que o contexto esteja disponível para acessar o estado do jogo e configurar o diálogo inicial.
      _initializeLocation();// Chama a função para inicializar a localização do CEAAB, onde o jogador visita o local e o diálogo inicial é configurado com base na descrição do ambiente.
    });
  }

  void _initializeLocation() {// Função para inicializar a localização do CEAAB, onde o jogador visita o local e o diálogo inicial é configurado com base na descrição do ambiente.
    final gameState = Provider.of<GameState>(context, listen: false);// Acessa o estado do jogo para registrar que o jogador visitou a localização do CEAAB
    gameState.visitLocation('ceaab');// Registra que o jogador visitou a localização do CEAAB, o que pode ser usado para controlar o progresso do jogo e as interações disponíveis
    setState(() {// Atualiza o estado para configurar o diálogo inicial com a descrição do ambiente do CEAAB, fornecendo ao jogador uma introdução ao local e incentivando a exploração e a coleta de pistas.
      currentDialogue = _getInitialDescription();// Configura o diálogo inicial com a descrição do ambiente do CEAAB, fornecendo ao jogador uma introdução ao local e incentivando a exploração e a coleta de pistas.
    });
  }
    void _salvarFaseNoFirebase(int novaFase) async {// Função para salvar a fase atual do jogador no Firebase Realtime Database, permitindo que o progresso seja registrado e sincronizado em tempo real.
    final User? usuarioAtual = FirebaseAuth.instance.currentUser;// Acessa o usuário atual autenticado no Firebase para obter o ID do usuário, que será usado para salvar o progresso específico do jogador no Realtime Database.
    if (usuarioAtual != null) {// Verifica se há um usuário autenticado antes de tentar salvar o progresso, garantindo que o progresso seja associado ao usuário correto no Realtime Database.
      final realtimeService = RealtimeService();// Cria uma instância do RealtimeService para acessar as funções de salvamento e sincronização do progresso no Firebase Realtime Database.
      await realtimeService.salvarProgresso(usuarioAtual.uid, novaFase);// Chama a função para salvar o progresso do jogador no Realtime Database, passando o ID do usuário e a nova fase alcançada, permitindo que o progresso seja registrado e sincronizado em tempo real.
      debugPrint("Progresso salvo no Firebase para a fase: $novaFase");// Imprime uma mensagem de depuração indicando que o progresso foi salvo com sucesso no Firebase, o que pode ser útil para verificar se a função de salvamento está funcionando corretamente durante o desenvolvimento.
    } else {
      debugPrint("Nenhum usuário logado. Progresso não salvo.");// Imprime uma mensagem de depuração indicando que nenhum usuário está logado, o que significa que o progresso não pode ser salvo no Firebase, alertando os desenvolvedores sobre a necessidade de autenticação para salvar o progresso do jogo.
    }
  }
    void _verificarProgressoDasPistas() {// Função para verificar se o jogador concluiu todas as interações necessárias para coletar as pistas do CEAAB
    final gameState = Provider.of<GameState>(context, listen: false);// Acessa o estado do jogo para verificar as interações realizadas pelo jogador

    bool concluiuLivros = gameState.isInteractionDone('ceaab_bookshelf');// Verifica se o jogador concluiu a interação de procurar na estante de livros
    bool concluiuArte = gameState.isInteractionDone('ceaab_artwork');// Verifica se o jogador concluiu a interação de examinar a obra de arte
    bool concluiuComputadores = gameState.isInteractionDone('ceaab_computers');// Verifica se o jogador concluiu as interações necessárias para coletar as pistas do CEAAB

    if (concluiuLivros && concluiuArte && concluiuComputadores) {// Verifica se o jogador concluiu todas as interações necessárias para coletar as pistas do CEAAB
      _salvarFaseNoFirebase(2);// Salva automaticamente o progresso da Fase 2 no Firebase
      
      ScaffoldMessenger.of(context).showSnackBar( // Exibe um feedback visual para o jogador indicando que todas as pistas foram colet
        const SnackBar( // Exibe um SnackBar para fornecer feedback visual ao jogador
          content: Text('Você coletou todas as pistas! Acesso a Manacás liberado.'), // Mensagem de conteúdo do SnackBar indicando que o jogador coletou todas as pistas e que o acesso a Manacás foi liberado
          backgroundColor: Colors.green,  // Define a cor de fundo do SnackBar como verde para indicar sucesso
          duration: Duration(seconds: 3),  // Define a duração do SnackBar para 3 segundos, permitindo que o jogador tenha tempo suficiente para ler a mensagem antes que ela desapareça
        ),
      );
      setState(() { // Atualiza o estado para configurar o diálogo central do jogo, informando ao jogador que todas as pistas do CEAAB foram coletadas e que o acesso a Manacás agora está liberado, incentivando o jogador a avançar para a próxima fase da investigação.
        currentDialogue = "Sensacional! Você coletou todas as pistas do CEAAB. O acesso a Manacás agora está liberado!"; // Configura o diálogo central do jogo para informar ao jogador que todas as pistas do CEAAB foram coletadas e que o acesso a Manacás agora está liberado, incentivando o jogador a avançar para a próxima fase da investigação.
      });
    }
  }
void _checkUnlockManacas(GameState gameState) { // Função para verificar se o jogador concluiu todas as interações necessárias para coletar as pistas do CEAAB e desbloquear o acesso a Manacás
    bool concluiuLivros = gameState.isInteractionDone('ceaab_bookshelf'); // Verifica se o jogador concluiu a interação de procurar na estante de livros
    bool concluiuArte = gameState.isInteractionDone('ceaab_artwork'); // Verifica se o jogador concluiu a interação de examinar a obra de arte
    bool concluiuComputadores = gameState.isInteractionDone('ceaab_computers'); // Verifica se o jogador concluiu a interação de verificar os computadores

    if (concluiuLivros && concluiuArte && concluiuComputadores) { // Verifica se o jogador concluiu todas as interações necessárias para coletar as pistas do CEAAB
      if (!gameState.hasToken('token_manacas')) { // Verifica se o jogador ainda não possui o token de acesso a Manacás para evitar adicionar o token múltiplas vezes
        gameState.addToken('token_manacas'); // Adiciona o token de acesso a Manacás ao inventário do jogador, permitindo que ele avance para a próxima fase da investigação
        _salvarFaseNoFirebase(2); // Salva automaticamente o progresso da Fase 2 no Firebase, garantindo que o progresso do jogador seja registrado e sincronizado em tempo real
        currentDialogue += "\n\n[SISTEMA]: Você coletou todas as pistas do CEAAB! O acesso a Manacás foi liberado."; // Atualiza o diálogo central do jogo para informar ao jogador que todas as pistas do CEAAB foram coletadas e que o acesso a Manacás foi liberado, incentivando o jogador a avançar para a próxima fase da investigação.
      }
    }
  }

  @override
  Widget build(BuildContext context) { // Sobrescreve o método build para construir a interface do usuário da tela do CEAAB, onde o jogador pode ver o ambiente, as ações disponíveis, as pistas coletadas e interagir com os elementos do jogo para avançar na investigação.
    final gameState = Provider.of<GameState>(context); // Acessa o estado do jogo para obter as informações necessárias para construir a interface, como as interações realizadas, as pistas coletadas e os tokens disponíveis, permitindo que a interface seja atualizada dinamicamente com base no progresso do jogador.
    final availableActions = _getAvailableActions(gameState); // Obtém a lista de ações disponíveis para o jogador com base nas interações realizadas e no progresso do jogo, permitindo que a interface exiba apenas as ações relevantes para o momento atual da investigação.

    return Scaffold( // Retorna um Scaffold para construir a estrutura básica da tela do CEAAB, incluindo o AppBar, o corpo da tela e os elementos de interface para exibir o ambiente, as ações disponíveis e as pistas coletadas.
      appBar: AppBar( // Define o AppBar da tela do CEAAB, que exibe o título "CEAAB" e tem um fundo preto para combinar com a estética do jogo.
        title: const Text('CEAAB'), // Define o título do AppBar como "CEAAB", indicando a localização atual do jogador na investigação.
        backgroundColor: Colors.black87, // Define a cor de fundo do AppBar como preto para combinar com a estética do jogo e criar um contraste visual com o conteúdo da tela, destacando o título e proporcionando uma experiência imersiva ao jogador.
      ),
      body: Stack( // Utiliza um Stack para sobrepor a imagem de fundo do CEAAB, uma camada escura para dar contraste ao texto do jogo e a interface do jogo por cima do fundo, criando uma experiência visual imersiva e estilizada para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        children: [ // Define os filhos do Stack, que incluem a imagem de fundo do CEAAB, uma camada escura para dar contraste ao texto do jogo e a interface do jogo por cima do fundo, criando uma experiência visual imersiva e estilizada para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
          Positioned.fill( // Utiliza Positioned.fill para garantir que a imagem de fundo do CEAAB ocupe toda a área disponível da tela, criando uma experiência visual imersiva para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
            child: Image.asset( // Exibe a imagem de fundo do CEAAB, que é uma representação visual do ambiente onde o jogador está investigando, criando uma experiência imersiva e estilizada para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
              'assets/images/ceaab.jpeg', // Define o caminho da imagem de fundo do CEAAB, que deve estar localizada na pasta assets/images do projeto, garantindo que a imagem seja carregada corretamente e exibida como plano de fundo da tela do CEAAB.
              fit: BoxFit.cover, // Define o ajuste da imagem para cobrir toda a área disponível, garantindo que a imagem de fundo do CEAAB seja exibida de forma completa e proporcional, criando uma experiência visual imersiva para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
            ),
          ),
          // Camada escura para dar contraste ao texto do jogo
          Positioned.fill( // Utiliza Positioned.fill para garantir que a camada escura ocupe toda a área disponível da tela, criando um contraste visual com o texto do jogo e melhorando a legibilidade, proporcionando uma experiência mais confortável para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
            child: Container( // Exibe uma camada escura sobre a imagem de fundo do CEAAB, que ajuda a criar um contraste visual com o texto do jogo, melhorando a legibilidade e proporcionando uma experiência mais confortável para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
              color: Colors.black.withValues(alpha: 0.65), // Define a cor da camada escura como preto com uma opacidade de 65%, criando um contraste visual com o texto do jogo e melhorando a legibilidade, proporcionando uma experiência mais confortável para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
            ),
          ),
          
          // 2. Interface do jogo por cima do fundo
          Padding( // Utiliza Padding para adicionar um espaçamento interno ao redor da interface do jogo, garantindo que os elementos da interface não fiquem colados nas bordas da tela e proporcionando uma experiência visual mais agradável para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
            padding: const EdgeInsets.all(16.0), // Define o espaçamento interno ao redor da interface do jogo como 16 pixels, garantindo que os elementos da interface não fiquem colados nas bordas da tela e proporcionando uma experiência visual mais agradável para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
            child: Column( // Utiliza uma Column para organizar os elementos da interface do jogo verticalmente, permitindo que o diálogo, as ações disponíveis e as pistas coletadas sejam exibidos de forma estruturada e fácil de ler para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
              crossAxisAlignment: CrossAxisAlignment.start, // Alinha os elementos da Column à esquerda, garantindo que o diálogo, as ações disponíveis e as pistas coletadas sejam exibidos de forma estruturada e fácil de ler para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
              children: [ // Define os filhos da Column, que incluem o diálogo atual do jogo, as ações disponíveis para o jogador e as pistas coletadas, organizados de forma estruturada e fácil de ler para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                Container( // Exibe o diálogo atual do jogo em um Container estilizado, que fornece uma área de texto para o jogador ler as descrições do ambiente, os diálogos dos personagens e as informações relevantes para a investigação, criando uma experiência imersiva e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                  padding: const EdgeInsets.all(12.0), // Define o espaçamento interno do Container como 12 pixels, garantindo que o texto do diálogo tenha um espaço adequado para ser lido confortavelmente pelo jogador enquanto explora o ambiente e interage com os elementos do jogo.
                  decoration: BoxDecoration( // Define a decoração do Container, que inclui uma cor de fundo semi-transparente, bordas arredondadas e uma borda sutil para criar um estilo visual atraente e imersivo para o diálogo do jogo, proporcionando uma experiência mais envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                    color: Colors.black38, // Define a cor de fundo do Container como preto com uma opacidade de 38%, criando um contraste visual com o texto do diálogo e melhorando a legibilidade, proporcionando uma experiência mais confortável para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                    borderRadius: BorderRadius.circular(8), // Define as bordas do Container como arredondadas com um raio de 8 pixels, criando um estilo visual mais suave e atraente para o diálogo do jogo, proporcionando uma experiência mais envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                  ),
                  child: Text( // Exibe o texto do diálogo atual do jogo, que é atualizado dinamicamente com base nas ações do jogador e nas interações realizadas, fornecendo informações relevantes para a investigação e criando uma experiência imersiva e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                    currentDialogue, // Exibe o texto do diálogo atual do jogo, que é atualizado dinamicamente com base nas ações do jogador e nas interações realizadas, fornecendo informações relevantes para a investigação e criando uma experiência imersiva e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                    style: const TextStyle(fontSize: 16.0, color: Colors.white, height: 1.4), // Define o estilo do texto do diálogo, com um tamanho de fonte de 16 pixels, cor branca e espaçamento entre linhas de 1.4 para melhorar a legibilidade e criar uma experiência visual mais agradável para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                  ),
                ),
                const SizedBox(height: 20), // Adiciona um espaçamento vertical de 20 pixels entre o diálogo e as ações disponíveis, criando uma separação visual clara e melhorando a organização da interface para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                const Text( // Exibe o título "Ações Disponíveis:" para indicar ao jogador que as opções de ações estão listadas abaixo, criando uma estrutura clara e fácil de entender para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                  'Ações Disponíveis:', // Define o título para as ações disponíveis, indicando ao jogador que as opções de ações estão listadas abaixo, criando uma estrutura clara e fácil de entender para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white), // Define o estilo do título das ações disponíveis, com um tamanho de fonte de 18 pixels, negrito e cor branca para destacar a seção de ações disponíveis e criar uma experiência visual mais atraente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                ),
                const SizedBox(height: 10), // Adiciona um espaçamento vertical de 10 pixels entre o título das ações disponíveis e a lista de ações, criando uma separação visual clara e melhorando a organização da interface para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                Expanded( // Utiliza Expanded para garantir que a lista de ações disponíveis ocupe o espaço restante da tela, permitindo que o jogador veja todas as opções de ações disponíveis sem que a interface fique sobrecarregada, proporcionando uma experiência visual mais agradável e fácil de navegar para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                  child: ListView.builder( // Utiliza ListView.builder para criar uma lista dinâmica de botões de escolha para as ações disponíveis, permitindo que o jogador interaja com as opções de ações de forma fluida e responsiva, criando uma experiência mais envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                    itemCount: availableActions.length, // Define o número de itens na lista como o número de ações disponíveis, garantindo que cada ação tenha um botão correspondente na interface para o jogador interagir.
                    itemBuilder: (context, index) { // Define a função de construção para cada item da lista, que é chamada para cada ação disponível, permitindo que o jogador interaja com as opções de ações de forma fluida e responsiva, criando uma experiência mais envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                      final action = availableActions[index]; // Obtém a ação correspondente ao índice atual da lista, permitindo que o jogador interaja com as opções de ações de forma fluida e responsiva, criando uma experiência mais envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                      return ChoiceButton( // Retorna um ChoiceButton para cada ação disponível, permitindo que o jogador interaja com as opções de ações de forma fluida e responsiva, criando uma experiência mais envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                        text: action, // Define o texto do botão como a ação correspondente, permitindo que o jogador entenda claramente qual ação está selecionando e criando uma experiência mais intuitiva para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                        onPressed: () => _handleAction(action), // Define a função a ser chamada quando o botão for pressionado, que é responsável por lidar com a ação selecionada pelo jogador, atualizando o estado do jogo e a interface de acordo com a ação escolhida, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),// Adiciona um espaçamento vertical de 10 pixels entre a lista de ações disponíveis e a seção de pistas coletadas, criando uma separação visual clara e melhorando a organização da interface para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                Row( // Utiliza um Row para organizar os botões de "Voltar" e "Próximo" horizontalmente, permitindo que o jogador navegue entre as telas de forma intuitiva e fácil, criando uma experiência mais fluida para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                  children: [ // Define os filhos do Row, que incluem os botões de "Voltar" e "Próximo", permitindo que o jogador navegue entre as telas de forma intuitiva e fácil, criando uma experiência mais fluida para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                    Expanded( // Utiliza Expanded para garantir que o botão de "Voltar" ocupe metade do espaço disponível, permitindo que o jogador navegue de volta para a tela anterior de forma fácil e intuitiva, criando uma experiência mais fluida para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                      child: ChoiceButton( // Retorna um ChoiceButton para o botão de "Voltar", permitindo que o jogador navegue de volta para a tela anterior de forma fácil e intuitiva, criando uma experiência mais fluida para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                        text: "Voltar", // Define o texto do botão como "Voltar", indicando claramente a função do botão para o jogador e criando uma experiência mais intuitiva para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                        onPressed: () => Navigator.pop(context), // Define a função a ser chamada quando o botão de "Voltar" for pressionado, que é responsável por navegar de volta para a tela anterior, permitindo que o jogador retorne facilmente à tela anterior e criando uma experiência mais fluida para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                      ),
                    ),
                    const SizedBox(width: 8), // Adiciona um espaçamento horizontal de 8 pixels entre os botões de "Voltar" e "Próximo", criando uma separação visual clara e melhorando a organização da interface para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                    Expanded( // Utiliza Expanded para garantir que o botão de "Próximo" ocupe metade do espaço disponível, permitindo que o jogador navegue para a próxima tela de forma fácil e intuitiva, criando uma experiência mais fluida para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                      child: ChoiceButton( // Retorna um ChoiceButton para o botão de "Próximo", permitindo que o jogador navegue para a próxima tela de forma fácil e intuitiva, criando uma experiência mais fluida para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                        text: "Próximo", // Define o texto do botão como "Próximo", indicando claramente a função do botão para o jogador e criando uma experiência mais intuitiva para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                        onPressed: () { // Define a função a ser chamada quando o botão de "Próximo" for pressionado, que é responsável por navegar para a próxima tela, permitindo que o jogador avance para a próxima fase da investigação de forma fácil e intuitiva, criando uma experiência mais flu
  }),
                    ),
                  ],
                ),
                if (gameState.allClues.isNotEmpty) ...[ // Verifica se o jogador coletou alguma pista e, se sim, exibe a seção de pistas coletadas, permitindo que o jogador veja as informações relevantes para a investigação de forma clara e organizada, criando uma experiência mais envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                  const SizedBox(height: 16),// Adiciona um espaçamento vertical de 20 pixels entre a seção de navegação e a seção de pistas coletadas, criando uma separação visual clara e melhorando a organização da interface para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                  const Text(// Exibe o título "Pistas:" para indicar ao jogador que as informações listadas abaixo são as pistas coletadas, criando uma estrutura clara e fácil de entender para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                    "📋 Pistas Encontradas no Ambiente:", // Define o título para as pistas coletadas, indicando ao jogador que as informações listadas abaixo são as pistas coletadas, criando uma estrutura clara e fácil de entender para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                    style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold, fontSize: 16), // Define o estilo do título das pistas coletadas, com uma cor azul clara, negrito e tamanho de fonte de 16 pixels para destacar a seção de pistas coletadas e criar uma experiência visual mais atraente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                  ),
                  ...gameState.allClues.map((clue) => TweenAnimationBuilder<double>( // Utiliza TweenAnimationBuilder para criar uma animação suave de fade-in e slide-up para cada pista coletada, tornando a experiência de visualização das pistas mais dinâmica e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                        key: ValueKey(clue), // Define uma chave única para cada pista com base no seu conteúdo, garantindo que a animação seja aplicada corretamente a cada pista individualmente e criando uma experiência visual mais fluida e personalizada para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                        tween: Tween(begin: 0.0, end: 1.0), // Define a animação para variar a opacidade de 0 a 1, criando um efeito de fade-in para cada pista coletada, tornando a experiência de visualização das pistas mais dinâmica e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                        duration: const Duration(milliseconds: 600), // Define a duração da animação para 600 milissegundos, garantindo que o efeito de fade-in e slide-up seja suave e perceptível para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                        builder: (context, value, child) { // Define a função de construção para a animação, onde o valor da animação é usado para ajustar a opacidade e a posição vertical da pista, criando um efeito visual mais dinâmico e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                          return Opacity( // Aplica a opacidade à pista com base no valor da animação, criando um efeito de fade-in para cada pista coletada, tornando a experiência de visualização das pistas mais dinâmica e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                            opacity: value, // Define a opacidade da pista com base no valor da animação, criando um efeito de fade-in para cada pista coletada, tornando a experiência de visualização das pistas mais dinâmica e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                            child: Transform.translate( // Aplica uma transformação de tradução à pista para criar um efeito de slide-up, onde a pista começa 20 pixels abaixo da posição final e sobe suavemente para sua posição normal à medida que a animação avança, tornando a experiência de visualização das pistas mais dinâmica e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                              offset: Offset(0, 20 * (1 - value)), // Define o deslocamento da pista com base no valor da animação, criando um efeito de slide-up onde a pista começa 20 pixels abaixo da posição final e sobe suavemente para sua posição normal à medida que a animação avança, tornando a experiência de visualização das pistas mais dinâmica e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                              child: child, // O child é o widget da pista que será animado, permitindo que a animação de fade-in e slide-up seja aplicada corretamente a cada pista individualmente, criando uma experiência visual mais fluida e personalizada para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                            ),
                          );
                        },
                        child: ClueCard(clue: clue), // O child do TweenAnimationBuilder é um ClueCard que exibe o conteúdo da pista, permitindo que a animação de fade-in e slide-up seja aplicada corretamente a cada pista individualmente, criando uma experiência visual mais fluida e personalizada para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitialDescription() { // Função para obter a descrição inicial do ambiente do CEAAB, que é exibida para o jogador quando ele visita a localização pela primeira vez, fornecendo uma introdução ao local e incentivando a exploração e a coleta de pistas.
    return "Você está no CEAAB, o Centro de Estudos Afro e Afro Brasileiros da PUC. "
        "O ambiente é vibrante, com paredes coloridas e uma atmosfera de aprendizado e cultura. "
        "Algumas estantes repletas de livros sobre história, cultura e arte afro-brasileira. "
        "Há algumas pessoas e estudantes aqui, e você pode conversar com eles para obter informações. "
        "As luzes suaves e as mesas cheias de papéis bagunçados que se espalharam durante o apagão, "
        "sendo organizados pela comendadora responsável pelo CEAAB.";
  }

  void _showClueDiscoveryFeedback(String clue) { // Função para exibir um feedback visual para o jogador quando ele descobre uma nova pista, utilizando um SnackBar estilizado para informar o jogador sobre a nova pista coletada, criando uma experiência mais envolvente e gratificante para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
    var row = Row( // Cria um Row para organizar o conteúdo do SnackBar horizontalmente, permitindo que o ícone e o texto da pista sejam exibidos de forma clara e atraente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
          children: [ // Define os filhos do Row, que incluem um ícone de descoberta e o texto da nova pista coletada, criando um feedback visual mais envolvente e gratificante para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
            const Icon(Icons.auto_awesome, color: Colors.amber), // Exibe um ícone de descoberta (auto_awesome) com a cor amarela para indicar que o jogador descobriu uma nova pista, criando um feedback visual mais envolvente e gratificante para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
            const SizedBox(width: 12), // Adiciona um espaçamento horizontal de 12 pixels entre o ícone de descoberta e o texto da nova pista, criando uma separação visual clara e melhorando a legibilidade do feedback para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
            Expanded( // Utiliza Expanded para garantir que o texto da nova pista ocupe o espaço restante do Row, permitindo que o feedback seja exibido de forma clara e legível para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
              child: Text( // Exibe o texto da nova pista coletada, informando ao jogador sobre a descoberta de forma clara e atraente, criando um feedback visual mais envolvente e gratificante para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                'Nova Pista: $clue', // Define o texto do feedback para incluir a nova pista coletada, informando ao jogador sobre a descoberta de forma clara e atraente, criando um feedback visual mais envolvente e gratificante para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                style: const TextStyle( // Define o estilo do texto do feedback, com uma cor azul clara, negrito e tamanho de fonte de 16 pixels para destacar a nova pista coletada e criar uma experiência visual mais atraente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
                    color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16, // Define o estilo do texto do feedback, com uma cor azul clara, negrito e tamanho de fonte de 16 pixels para destacar a nova pista coletada e criar uma experiência visual mais atraente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
              ),
            ),
            )
          ],
        );
    ScaffoldMessenger.of(context).showSnackBar( // Exibe um SnackBar para fornecer feedback visual ao jogador sobre a descoberta de uma nova pista, utilizando um estilo personalizado para tornar o feedback mais atraente e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
      SnackBar( // Exibe um SnackBar para fornecer feedback visual ao jogador sobre a descoberta de uma nova pista, utilizando um estilo personalizado para tornar o feedback mais atraente e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        content: row, // Define o conteúdo do SnackBar como o Row criado anteriormente, que inclui um ícone de descoberta e o texto da nova pista coletada, criando um feedback visual mais envolvente e gratificante para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        backgroundColor: Colors.indigo.shade800, // Define a cor de fundo do SnackBar como um tom escuro de azul índigo para criar um contraste visual com o conteúdo do feedback e tornar a mensagem mais atraente e legível para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        behavior: SnackBarBehavior.floating, // Define o comportamento do SnackBar como flutuante, permitindo que ele se destaque visualmente na tela e crie um feedback mais envolvente e gratificante para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Define a forma do SnackBar como um RoundedRectangle com bordas arredondadas de 10 pixels, criando um estilo visual mais suave e atraente para o feedback, tornando a experiência mais envolvente e gratificante para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        duration: const Duration(seconds: 3), // Define a duração do SnackBar para 3 segundos, garantindo que o jogador tenha tempo suficiente para ler a mensagem de feedback antes que ela desapareça, criando uma experiência mais envolvente e gratificante para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
      ),
    );
  }

  void _handleAction(String action) { // Função para lidar com as ações selecionadas pelo jogador, atualizando o estado do jogo e a interface de acordo com a ação escolhida, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
    final gameState = Provider.of<GameState>(context, listen: false); // Acessa o estado do jogo para obter as informações necessárias para lidar com a ação selecionada pelo jogador, permitindo que o estado do jogo seja atualizado de forma adequada e que a interface seja refletida de acordo com as ações do jogador, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.

    switch (action) { // Utiliza um switch para lidar com as diferentes ações disponíveis para o jogador, permitindo que cada ação tenha um comportamento específico e criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
      case "Procurar na estante de livros": // Lida com a ação de procurar na estante de livros, atualizando o diálogo do jogo para informar o jogador sobre a descoberta de um livro antigo sobre a história da PUC, marcando a interação como concluída no estado do jogo, adicionando a pista "Livro de História da PUC" ao inventário do jogador (se ainda não tiver sido adicionada) e verificando o progresso das pistas para desbloquear novas ações ou locais, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        currentDialogue = "Você encontrou um livro antigo sobre a história da PUC."; // Atualiza o diálogo do jogo para informar o jogador sobre a descoberta de um livro antigo sobre a história da PUC, criando uma experiência mais imersiva e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        gameState.completeInteraction('ceaab_bookshelf'); // Marca a interação de procurar na estante de livros como concluída no estado do jogo, garantindo que o jogador não possa repetir essa ação e que o progresso do jogo seja registrado corretamente, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        if (!gameState.addClue('Livro de História da PUC')) { // Tenta adicionar a pista "Livro de História da PUC" ao inventário do jogador e, se a pista já tiver sido adicionada anteriormente, exibe um feedback visual para o jogador informando que a pista já foi descoberta, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
          _showClueDiscoveryFeedback('Livro de História da PUC'); // Exibe um feedback visual para o jogador informando que a pista "Livro de História da PUC" já foi descoberta, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        }
        _verificarProgressoDasPistas(); // Verifica o progresso das pistas para desbloquear novas ações ou locais com base nas pistas coletadas, permitindo que o jogador avance na investigação de forma fluida e criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        break;// Fecha o case "Procurar na estante de livros"

      case "Examinar a obra de arte": // Lida com a ação de examinar a obra de arte, atualizando o diálogo do jogo para informar o jogador sobre a descoberta de que a obra de arte parece esconder algo por trás dela, marcando a interação como concluída no estado do jogo e verificando o progresso das pistas para desbloquear novas ações ou locais, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        currentDialogue = "A obra de arte parece esconder algo por trás dela."; // Atualiza o diálogo do jogo para informar o jogador sobre a descoberta de que a obra de arte parece esconder algo por trás dela, criando uma experiência mais imersiva e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        gameState.completeInteraction('ceaab_artwork'); // Marca a interação de examinar a obra de arte como concluída no estado do jogo, garantindo que o jogador não possa repetir essa ação e que o progresso do jogo seja registrado corretamente, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        _verificarProgressoDasPistas(); // Verifica o progresso das pistas para desbloquear novas ações ou locais com base nas pistas coletadas, permitindo que o jogador avance na investigação de forma fluida e criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        break; // Fecha o case "Examinar a obra de arte"

      case "Verificar os computadores": // Lida com a ação de verificar os computadores, atualizando o diálogo do jogo para informar o jogador que os computadores estão desligados devido ao apagão, marcando a interação como concluída no estado do jogo e verificando o progresso das pistas para desbloquear novas ações ou locais, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        currentDialogue = "💻 Os computadores estão desligados devido ao apagão, mas você nota um pen-drive deixado em uma das portas USB com arquivos sobre o sistema elétrico!"; // Atualiza o diálogo do jogo para informar o jogador que os computadores estão desligados devido ao apagão, criando uma experiência mais imersiva e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        gameState.addClue("Pen-drive com arquivos criptografados encontrado no computador central.");
        gameState.completeInteraction('ceaab_computers'); // Marca a interação de verificar os computadores como concluída no estado do jogo, garantindo que o jogador não possa repetir essa ação e que o progresso do jogo seja registrado corretamente, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        _verificarProgressoDasPistas(); // Verifica o progresso das pistas para desbloquear novas ações ou locais com base nas pistas coletadas, permitindo que o jogador avance na investigação de forma fluida e criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        break;// Fecha o case "Verificar os computadores"

      case "Conversar com a comendadora Edna": // Lida com a ação de conversar com a comendadora Edna, atualizando o diálogo do jogo para informar o jogador que a comendadora está ocupada organizando os papéis, marcando a interação como concluída no estado do jogo e verificando o progresso das pistas para desbloquear novas ações ou locais, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        currentDialogue = "A comendadora Edna está muito ocupada organizando os papéis."; // Atualiza o diálogo do jogo para informar o jogador que a comendadora Edna está ocupada organizando os papéis, criando uma experiência mais imersiva e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        gameState.completeInteraction('ceaab_comendadora'); // Marca a interação de conversar com a comendadora Edna como concluída no estado do jogo, garantindo que o jogador não possa repetir essa ação e que o progresso do jogo seja registrado corretamente, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        _verificarProgressoDasPistas(); // Verifica o progresso das pistas para desbloquear novas ações ou locais com base nas pistas coletadas, permitindo que o jogador avance na investigação de forma fluida e criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        break; // Fecha o case "Conversar com a comendadora Edna"

      case "Procurar por pistas": // Lida com a ação de procurar por pistas, atualizando o diálogo do jogo para informar o jogador que não encontrou nada de novo por enquanto, marcando a interação como concluída no estado do jogo e verificando o progresso das pistas para desbloquear novas ações ou locais, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        currentDialogue = "Você não encontrou nada de novo por enquanto."; // Atualiza o diálogo do jogo para informar o jogador que não encontrou nada de novo por enquanto, criando uma experiência mais imersiva e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        gameState.completeInteraction('ceaab_procurar_pistas'); // Marca a interação de procurar por pistas como concluída no estado do jogo, garantindo que o jogador não possa repetir essa ação e que o progresso do jogo seja registrado corretamente, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        _checkUnlockManacas(gameState); // Verifica se as condições para desbloquear a ação de ir para a Manacás foram atendidas com base nas pistas coletadas, permitindo que o jogador avance para a próxima fase da investigação de forma fluida e criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        break; // Fecha o case "Procurar por pistas"

      case "Ir para a Manacás": // Lida com a ação de ir para a Manacás, verificando se o jogador possui o token necessário para acessar a localização, atualizando o diálogo do jogo para informar o jogador sobre a viagem para a Manacás ou sobre a necessidade de investigar mais pistas no CEAAB, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        if (gameState.hasToken('token_manacas')) { // Verifica se o jogador possui o token necessário para acessar a Manacás, permitindo que o jogador avance para a próxima fase da investigação de forma fluida e criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
          currentDialogue = "Viajando para Manacás..."; // Atualiza o diálogo do jogo para informar o jogador sobre a viagem para a Manacás, criando uma experiência mais imersiva e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
          Navigator.pushNamed(context, '/manacas'); // Navega para a tela da Manacás, permitindo que o jogador avance para a próxima fase da investigação de forma fluida e criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        } else {// Se o jogador não tiver o token necessário, atualiza o diálogo para informar que a Manacás ainda não está disponível e que ele precisa investigar mais pistas no CEAAB, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
          currentDialogue = "O Manacás ainda não está disponível. Você precisa investigar todas as pistas do CEAAB primeiro!"; // Atualiza o diálogo do jogo para informar o jogador que a Manacás ainda não está disponível e que ele precisa investigar mais pistas no CEAAB, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
        }
        break;// Fecha o case "Ir para a Manacás"
    } // Fecha o switch (action)
  } // Fecha a função _handleAction

  List<String> _getAvailableActions(GameState gameState) { // Função para obter a lista de ações disponíveis para o jogador com base no estado atual do jogo, verificando quais interações já foram concluídas e quais pistas foram coletadas, permitindo que o jogador veja apenas as opções relevantes para a investigação e criando uma experiência mais fluida e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
    List<String> actions = []; // Inicializa uma lista vazia de ações disponíveis, que será preenchida com as opções relevantes para o jogador com base no estado atual do jogo, permitindo que o jogador veja apenas as opções relevantes para a investigação e criando uma experiência mais fluida e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.

    if (!gameState.isInteractionDone('ceaab_bookshelf')) { // Verifica se a interação de procurar na estante de livros ainda não foi concluída e, se for o caso, adiciona a ação "Procurar na estante de livros" à lista de ações disponíveis, permitindo que o jogador interaja com essa opção e avance na investigação de forma fluida, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
      actions.add("Procurar na estante de livros"); // Adiciona a ação "Procurar na estante de livros" à lista de ações disponíveis, permitindo que o jogador interaja com essa opção e avance na investigação de forma fluida, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
    }
    if (!gameState.isInteractionDone('ceaab_artwork')) { // Verifica se a interação de examinar a obra de arte ainda não foi concluída e, se for o caso, adiciona a ação "Examinar a obra de arte" à lista de ações disponíveis, permitindo que o jogador interaja com essa opção e avance na investigação de forma fluida, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
      actions.add("Examinar a obra de arte"); // Adiciona a ação "Examinar a obra de arte" à lista de ações disponíveis, permitindo que o jogador interaja com essa opção e avance na investigação de forma fluida, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
    }
    if (!gameState.isInteractionDone('ceaab_computers')) { // Verifica se a interação de verificar os computadores ainda não foi concluída e, se for o caso, adiciona a ação "Verificar os computadores" à lista de ações disponíveis, permitindo que o jogador interaja com essa opção e avance na investigação de forma fluida, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
      actions.add("Verificar os computadores"); // Adiciona a ação "Verificar os computadores" à lista de ações disponíveis, permitindo que o jogador interaja com essa opção e avance na investigação de forma fluida, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
    }

    actions.add("Conversar com a comendadora Edna"); // A ação de conversar com a comendadora Edna está sempre disponível, permitindo que o jogador interaja com esse personagem e avance na investigação de forma fluida, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
    actions.add("Procurar por pistas");// A ação de procurar por pistas está sempre disponível, permitindo que o jogador interaja com essa opção para tentar encontrar novas informações e avançar na investigação de forma fluida, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
    actions.add("Verificar Inventário"); // A ação de verificar o inventário está sempre disponível, permitindo que o jogador veja as pistas coletadas e os itens adquiridos, criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.

      // Se o jogador coletou pelo menos 3 pistas e ainda não ganhou o token, ele desbloqueia a fase!
  if (gameState.allClues.length >= 3 && !gameState.hasToken('token_manacas')) { // Verifica se o jogador coletou pelo menos 3 pistas e ainda não possui o token necessário para acessar a Manacás, e se for o caso, concede o token ao jogador, atualiza o diálogo para informar sobre
    gameState.addToken('token_manacas');// Concede o token necessário para acessar a Manacás ao jogador, permitindo que ele avance para a próxima fase da investigação de forma fluida e criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
    // Adiciona uma mensagem avisando o jogador no diálogo atual
    currentDialogue += "\n\n✨ [DESBLOQUEADO] Sensacional! Você coletou todas as pistas. O acesso ao Manacás está liberado!";
  }
  // Se o usuário já tiver o token (porque acabou de ganhar ou já tinha antes), a opção aparece na tela
  if (gameState.hasToken('token_manacas')) {
    actions.add("Ir para o Manacás");
  } else {
    //Adiciona uma opção visual de cadeado desativada para dar a dica pro jogador
    actions.add("🔒 Ir para o Manacás (Bloqueado: Requer no mínimo 2 pistas)");
  }
    if (gameState.hasToken('token_manacas')) {// Verifica se o jogador possui o token necessário para acessar a Manacás e, se for o caso, adiciona a ação "Ir para a Manacás" à lista de ações disponíveis, permitindo que o jogador avance para a próxima fase da investigação de forma fluida e criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
      actions.add("Ir para o Manacás"); // Adiciona a ação "Ir para o Manacás" à lista de ações disponíveis, permitindo que o jogador avance para a próxima fase da investigação de forma fluida e criando uma experiência mais interativa e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
    }
    return actions;// Retorna a lista de ações disponíveis para o jogador com base no estado atual do jogo, permitindo que o jogador veja apenas as opções relevantes para a investigação e criando uma experiência mais fluida e envolvente para o jogador enquanto explora o ambiente e interage com os elementos do jogo.
  }
}
