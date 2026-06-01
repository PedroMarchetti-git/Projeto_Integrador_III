import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_state.dart';
import '../../widgets/choice_button.dart';
import '../../widgets/clue_card.dart';
import 'manacas_screen.dart';

class TelaAcusacaoManacas extends StatefulWidget {
  @override
  _TelaAcusacaoManacasState createState() => _TelaAcusacaoManacasState();
}

class _TelaAcusacaoManacasState extends State<TelaAcusacaoManacas> {
  final List<String> npcs = [
    'Rafael (Técnico de Som)',
    'Coordenador de Eventos',
    'Técnico de TI',
    'Lucas',
    'Marta'
  ];

  List<String> npcsSelecionados = [];
  bool jogoFinalizado = false;

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
      tituloFinal = 'Final Completo';
      mensagemFinal = 'As peças se encaixaram perfeitamente. Você desmascarou os dois verdadeiros culpados. A justiça finalmente foi feita pela morte de Juliana!';
    } else if (acertos == 1) {
      tituloFinal = 'Final Parcial';
      mensagemFinal = 'Você expôs um dos assassinos, mas as sombras protegeram o outro. Um culpado permanece livre e a justiça foi feita apenas pela metade...';
    } else {
      tituloFinal = 'Final Incorreto';
      mensagemFinal = 'Suas acusações caíram no vazio. Os verdadeiros assassinos escaparam impunes e o caso permanecerá como um mistério sem solução. Mais sorte na próxima vez.';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1C24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            tituloFinal,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            mensagemFinal,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  jogoFinalizado = true;
                  npcsSelecionados.clear();
                });
              },
              child: const Text(
                'Fechar',
                style: TextStyle(color: Colors.redAccent, fontSize: 16),
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
        backgroundColor: const Color(0xFF0D0B10),
        title: const Text(
          'Manacás',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/manacas.jpeg",
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1924).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Text(
                    'As sombras do Manacás não podem mais esconder a verdade. Deixando o CAAB para trás, o tempo das investigações acabou. Agora que você chegou aqui com todas as peças deste quebra-cabeça macabro, o destino clama por justiça. Aponte, entre os presentes, quem são os dois assassinos responsáveis pela morte da Juliana. Escolha com sabedoria, pois não haverá volta.',
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
                        backgroundColor: isSelected ? const Color(0xFF4A3466).withOpacity(0.9) : const Color(0xFF262230).withOpacity(0.9),
                        disabledBackgroundColor: const Color(0xFF16141C).withOpacity(0.9),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: isSelected ? 4 : 0,
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
                }).toList(),
                const Spacer(),
                if (npcsSelecionados.length == 2 && !jogoFinalizado)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA12323),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: confirmarAcusacao,
                    child: const Text(
                      'Confirmar Acusação',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}