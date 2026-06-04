import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart'; // PACOTE DE ÁUDIO
import '../../models/game_state.dart';

class ManacasScreen extends StatefulWidget {
  const ManacasScreen({super.key});

  @override
  _ManacasScreenState createState() => _ManacasScreenState();
}

class _ManacasScreenState extends State<ManacasScreen> {
  // === CONFIGURAÇÃO DO ÁUDIO ===
  late AudioPlayer _audioPlayer;

  final List<String> npcs = [
    'Rafael (Técnico de Som)',
    'Coordenador de Eventos',
    'Técnico de TI',
    'Lucas',
    'Marta'
  ];

  List<String> npcsSelecionados = [];
  bool jogoFinalizado = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _iniciarMusicaDeTencao();
  }

  // Função para tocar a música em Loop constante
  void _iniciarMusicaDeTencao() async {
    // Toca o arquivo 'suspense.mp3' localizado na pasta assets/audio/
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('audio/suspense.mp3'));
  }

  @override
  void dispose() {
    // É EXTREMAMENTE IMPORTANTE desligar a música quando sair da tela
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  void selecionarNpc(String npc) {
    if (jogoFinalizado) return;

    setState(() {
      if (npcsSelecionados.contains(npc)) {
        npcsSelecionados.remove(npc);
      } else if (npcsSelecionados.length < 2) {
        npcsSelecionados.add(npc);
      }
    });
  }

  void confirmarAcusacao() {
    if (npcsSelecionados.length != 2) return;

    int acertos = 0;
    if (npcsSelecionados.contains('Coordenador de Eventos')) acertos++;
    if (npcsSelecionados.contains('Rafael (Técnico de Som)')) acertos++;

    String tituloFinal = '';
    String mensagemFinal = '';

    if (acertos == 2) {
      tituloFinal = 'CASO ENCERRADO';
      // TEXTO CLARO E EXPLICATIVO DO MOTIVO DO CRIME
      mensagemFinal = 'Exato! A discussão no CAAB foi o estopim. O Coordenador de Eventos planejou o apagão para acobertar fraudes financeiras no evento da PUC. '
          'Para isso, ele contratou Rafael, o Técnico de Som, que usou o mapa roubado na Biblioteca para sabotar o painel no Auditório. '
          'O recibo na Praça foi o único erro deles. A morte de Juliana não ficará impune!';
    } else if (acertos == 1) {
      tituloFinal = 'FINAL PARCIAL';
      mensagemFinal = 'Você conectou algumas pistas e expôs um dos envolvidos, mas a mente brilhante por trás da sabotagem escapou. '
          'A justiça foi feita apenas pela metade, e as sombras do campus ainda escondem segredos...';
    } else {
      tituloFinal = 'FINAL INCORRETO';
      mensagemFinal = 'Suas acusações não se alinham com as evidências (Auditório, Praça e Biblioteca). '
          'Os verdadeiros culpados escaparam impunes e o caso de Juliana permanecerá como um mistério sem solução na universidade.';
    }

    // Para a música de tensão ao dar o veredito
    _audioPlayer.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1C24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.redAccent, width: 2)),
          title: Text(
            tituloFinal,
            style: TextStyle(color: acertos == 2 ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 22),
            textAlign: TextAlign.center,
          ),
          content: Text(
            mensagemFinal,
            style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            textAlign: TextAlign.justify,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    jogoFinalizado = true;
                    npcsSelecionados.clear();
                  });
                },
                child: const Text('Encerrar Jogo', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121016),
      appBar: AppBar(
        backgroundColor: Colors.red.shade900, // Cor de tensão para o clímax
        title: const Text('Manacás - O Veredito', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/manacas.jpeg", fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.75)), // Mais escuro para focar no texto
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  // === QUADRO DE RESUMO LÓGICO PARA AJUDAR O JOGADOR ===
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade900.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amberAccent.shade400, width: 1),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🔍 REVISÃO DO DOSSIÊ', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 10),
                        Text('• O apagão foi sabotagem física no painel (Alguém com acesso técnico).', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        Text('• O mapa foi roubado para planejar a rota de fuga.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        Text('• A briga com a organização sugere um motivo financeiro ou gerencial.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1924).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Text(
                      'O destino clama por justiça. Baseado nas evidências acima, aponte quem foi o mandante e quem foi o executor da sabotagem. Escolha os DOIS culpados. Não haverá volta.',
                      style: TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  ...npcs.map((npc) {
                    final isSelected = npcsSelecionados.contains(npc);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? Colors.red.shade800 : const Color(0xFF262230).withOpacity(0.9),
                          disabledBackgroundColor: const Color(0xFF16141C).withOpacity(0.9),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: isSelected ? const BorderSide(color: Colors.redAccent, width: 2) : BorderSide.none,
                          ),
                          elevation: isSelected ? 8 : 0,
                        ),
                        onPressed: jogoFinalizado ? null : () => selecionarNpc(npc),
                        child: Text(
                          npc,
                          style: TextStyle(
                            color: jogoFinalizado ? Colors.white24 : (isSelected ? Colors.white : Colors.white70),
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 20),
                  
                  if (npcsSelecionados.length == 2 && !jogoFinalizado)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA12323),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: confirmarAcusacao,
                      child: const Text(
                        'CONFIRMAR ACUSAÇÃO (IRREVERSÍVEL)',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
}