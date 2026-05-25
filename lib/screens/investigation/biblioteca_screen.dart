import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_state.dart';

class BibliotecaScreen extends StatefulWidget {
  const BibliotecaScreen({super.key});

  @override
  State<BibliotecaScreen> createState() => _BibliotecaScreenState();
}

class _BibliotecaScreenState extends State<BibliotecaScreen> {
  // Variáveis do Minigame
  final String _codigoCorreto = "1968"; // Ex: Ano de fundação da PUC Campinas
  String _codigoDigitado = "";
  bool _feedbackVisivel = false;
  bool _progressoSalvo = false;

  @override
  void initState() {
    super.initState();
    // Registra que o jogador visitou a biblioteca
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameState>(context, listen: false).visitLocation('biblioteca');
    });
  }

  // Função para lidar com a digitação dos números
  void _addNumero(String numero) {
    if (_codigoDigitado.length < 4) {
      setState(() {
        _codigoDigitado += numero;
        _feedbackVisivel = false; // Esconde feedback de erro anterior
      });
    }

    // Se completou 4 dígitos, verifica automaticamente
    if (_codigoDigitado.length == 4) {
      _verificarCodigo();
    }
  }

  void _limpar() {
    setState(() {
      _codigoDigitado = "";
      _feedbackVisivel = false;
    });
  }

  void _verificarCodigo() {
    final gameState = Provider.of<GameState>(context, listen: false);

    if (_codigoDigitado == _codigoCorreto) {
      // SUCESSO!
      setState(() {
        _progressoSalvo = true;
      });
      
      // Adiciona a pista no GameState
      gameState.addClue("Documento secreto encontrado na Biblioteca (Código 1968)");
      gameState.completeInteraction('biblioteca_puzzle_resolvido');
      
      // Opcional: Dar um token ou desbloquear o próximo ambiente aqui
      // gameState.desbloquearAmbiente(); 
    } else {
      // ERRO
      setState(() {
        _feedbackVisivel = true;
        // Opcional: Limpar automaticamente após erro
        Future.delayed(const Duration(seconds: 1), () => _limpar());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mantemos o Scaffold com fundo preto para o caso da imagem demorar a carregar
      backgroundColor: const Color(0xFF121212), 
      appBar: AppBar(
        title: const Text("Biblioteca Central"),
        backgroundColor: Colors.black54,
        elevation: 0,
      ),
      // O Scaffold estende o corpo para trás da AppBar para evitar cortes
      extendBodyBehindAppBar: true, 
      body: Stack(
        children: [
          // 1. IMAGEM DE FUNDO - Ocupa 100% da tela do aparelho
          Positioned.fill(
            child: Image.asset(
              "assets/images/biblioteca.png", 
              fit: BoxFit.cover, // Corta e estica proporcionalmente para cobrir tudo
            ),
          ),
          
          // 2. MÁSCARA ESCURA - Também cobre 100% da tela para manter o contraste
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.55), // Escurece um pouco mais para dar leitura
            ),
          ),

          // 3. CONTEÚDO NARRATIVO E MINIGAME
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Texto Narrativo
                  _buildNarrativeText(),
                  
                  const SizedBox(height: 30),
                  
                  // O MINIGAME OU TELA DE SUCESSO
                  _progressoSalvo 
                    ? _buildSucessoWidget()
                    : Expanded(child: SingleChildScrollView(child: _buildPuzzleWidget())),
                  
                  const SizedBox(height: 10),
                  // BOTÃO DE TESTE 
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                    onPressed: () {
                      // 1. Avisa o GameState que esta sala foi concluída!
                      context.read<GameState>().desbloquearAmbiente();
                      
                      // 2. Volta para a lista de ambientes
                      Navigator.pop(context); 
                    },
                    child: const Text("Finalizar Investigação desta Sala", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrativeText() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: const Text(
        "O silêncio na Biblioteca Central é absoluto, quebrado apenas pelo ranger do chão de madeira. "
        "Entre as estantes de História, você nota quatro livros desalinhados. "
        "Suas lombadas parecem conter uma mensagem cifrada. Há um pequeno cofre digital escondido atrás deles.",
        style: TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
      ),
    );
  }

  // Estrutura do Puzzle
  Widget _buildPuzzleWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amberAccent.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          const Text(
            "Pista nas Lombadas:",
            style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          const Text(
            "'O saber começou aqui. Digite o ano em que estas portas se abriram pela primeira vez.'",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 15, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 25),
          
          // Display do Código
          _buildCodeDisplay(),
          
          const SizedBox(height: 10),
          
          // Feedback de erro
          if (_feedbackVisivel)
            const Text("Código Incorreto!", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          
          const SizedBox(height: 20),
          
          // Teclado Numérico
          _buildNumericKeyboard(),
        ],
      ),
    );
  }

  // Visualização dos dígitos
  Widget _buildCodeDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        String char = "";
        if (index < _codigoDigitado.length) {
          char = _codigoDigitado[index];
        }
        return Container(
          width: 50,
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _feedbackVisivel ? Colors.redAccent : Colors.white24),
          ),
          alignment: Alignment.center,
          child: Text(
            char,
            style: const TextStyle(color: Colors.amberAccent, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }

  // Teclado Numérico (Bões de 0 a 9 e Limpar)
  Widget _buildNumericKeyboard() {
    return Column(
      children: [
        for (var row in [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((n) => _buildKeyButton(n.toString())).toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKeyButton("Limpar", isSpecial: true),
            _buildKeyButton("0"),
            // Botão vazio para alinhar
            const SizedBox(width: 70),
          ],
        )
      ],
    );
  }

  Widget _buildKeyButton(String label, {bool isSpecial = false}) {
    return Container(
      width: isSpecial ? 150 : 70,
      height: 60,
      margin: const EdgeInsets.all(5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSpecial ? Colors.red.shade900 : Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          if (isSpecial) {
            _limpar();
          } else {
            _addNumero(label);
          }
        },
        child: Text(label, style: TextStyle(fontSize: isSpecial ? 16 : 24, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Tela de Sucesso após resolver
  Widget _buildSucessoWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.greenAccent, width: 2),
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 60),
          SizedBox(height: 15),
          Text(
            "Cofre Aberto!",
            style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 22),
          ),
          SizedBox(height: 10),
          Text(
            "Você encontrou um documento antigo sobre o sistema elétrico da PUC. "
            "Uma nova pista foi adicionada ao seu inventário.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}