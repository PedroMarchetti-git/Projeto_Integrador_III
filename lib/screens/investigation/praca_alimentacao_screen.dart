import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_state.dart';

// ==========================================
// 1. MODELOS DE DADOS DA PRAÇA DE ALIMENTAÇÃO
// ==========================================
class EscolhaDialogo {
  final String texto;
  final String resultado;
  final String? pistaLiberada;

  const EscolhaDialogo({
    required this.texto,
    required this.resultado,
    this.pistaLiberada,
  });
}

class DialogoNPC {
  final String nomeNPC;
  final String papel;
  final String falaInicial;
  final List<EscolhaDialogo> escolhas;

  const DialogoNPC({
    required this.nomeNPC,
    required this.papel,
    required this.falaInicial,
    required this.escolhas,
  });
}

class Pista {
  final int id;
  final String titulo;
  final String descricao;
  final String tipo;

  const Pista({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.tipo,
  });
}

// ==========================================
// 2. DADOS DOS NPCs, DIÁLOGOS E PISTAS
// ==========================================
final List<DialogoNPC> dialogosPracaAlimentacao = [
  DialogoNPC(
    nomeNPC: 'Pedro',
    papel: 'Estudante',
    falaInicial: 'Eu estava aqui antes do apagão... estava cheio de gente. Mas eu ouvi uma discussão perto das mesas. Parecia envolver a Juliana.',
    escolhas: [
      EscolhaDialogo(
        texto: 'Perguntar com calma o que ele ouviu.',
        resultado: 'Pedro diz que ouviu Juliana discutindo com alguém sobre problemas no evento.',
        pistaLiberada: 'Relato de discussão envolvendo Juliana',
      ),
      EscolhaDialogo(
        texto: 'Pressionar Pedro para lembrar mais detalhes.',
        resultado: 'Pedro fica nervoso e diz apenas que não quer se envolver.',
      ),
      EscolhaDialogo(
        texto: 'Encerrar a conversa.',
        resultado: 'A conversa é encerrada sem novas informações.',
      ),
    ],
  ),
  DialogoNPC(
    nomeNPC: 'Ana',
    papel: 'Visitante',
    falaInicial: 'Eu não estudo aqui, então talvez eu tenha reparado em coisas diferentes. Quando as luzes começaram a falhar, algumas pessoas pareceram assustadas, mas uma delas parecia já esperar por aquilo.',
    escolhas: [
      EscolhaDialogo(
        texto: 'Perguntar por que ela acha isso.',
        resultado: 'Ana explica que uma pessoa olhou para o celular segundos antes do apagão e saiu rapidamente.',
        pistaLiberada: 'Suspeita de apagão proposital', 
      ),
      EscolhaDialogo(
        texto: 'Perguntar se ela reconheceu a pessoa.',
        resultado: 'Ana diz que não sabe o nome, mas lembra que a pessoa usava crachá do evento.',
      ),
      EscolhaDialogo(
        texto: 'Dizer que pode ter sido coincidência.',
        resultado: 'Ana insiste que o comportamento pareceu planejado.',
      ),
    ],
  ),
  DialogoNPC(
    nomeNPC: 'Marcos',
    papel: 'Segurança do Campus',
    falaInicial: 'Preciso manter a ordem por aqui. Depois do apagão, muita gente começou a circular sem controle. Vi algumas pessoas indo em direção ao auditório e outras tentando sair do campus.',
    escolhas: [
      EscolhaDialogo(
        texto: 'Perguntar sobre movimentações suspeitas.',
        resultado: 'Marcos menciona que alguém saiu apressado em direção ao auditório.',
        pistaLiberada: 'Movimentação suspeita em direção ao auditório',
      ),
      EscolhaDialogo(
        texto: 'Perguntar se alguém passou correndo.',
        resultado: 'Ele confirma que viu uma pessoa nervosa tentando evitar contato visual.',
      ),
      EscolhaDialogo(
        texto: 'Pedir acesso a outro ambiente.',
        resultado: 'Marcos informa que só permitirá a saída após o jogador reunir informações suficientes.',
      ),
    ],
  ),
];

final List<Pista> pistasPracaAlimentacao = [
  Pista(id: 1, titulo: 'Relato de discussão envolvendo Juliana', descricao: 'Pedro ouviu uma discussão entre Juliana e outra pessoa antes do apagão.', tipo: 'Depoimento'),
  Pista(id: 2, titulo: 'Suspeita de apagão proposital', descricao: 'Ana percebeu que uma pessoa parecia já esperar pelo apagão.', tipo: 'Depoimento'),
  Pista(id: 3, titulo: 'Movimentação suspeita em direção ao auditório', descricao: 'Marcos viu uma pessoa saindo apressada em direção ao auditório após o apagão.', tipo: 'Depoimento'),
  Pista(id: 4, titulo: 'Recibo com horário próximo ao apagão', descricao: 'Um recibo encontrado em uma mesa indica que alguém esteve na praça poucos minutos antes do apagão.', tipo: 'Pista física'),
];

// ==========================================
// 3. INTERFACE VISUAL
// ==========================================
class PracaAlimentacaoScreen extends StatefulWidget {
  const PracaAlimentacaoScreen({super.key});

  @override
  State<PracaAlimentacaoScreen> createState() => _PracaAlimentacaoScreenState();
}

class _PracaAlimentacaoScreenState extends State<PracaAlimentacaoScreen> {
  DialogoNPC? _npcAtivo;
  String _falaExibida = "";
  final List<String> _pistasColetadas = [];
  bool _missaoConcluida = false;

  void _iniciarConversa(DialogoNPC npc) {
    setState(() {
      _npcAtivo = npc;
      _falaExibida = npc.falaInicial;
    });
  }

  void _processarEscolha(EscolhaDialogo escolha) {
    setState(() {
      _falaExibida = escolha.resultado;
      
      // Adiciona a pista local
      if (escolha.pistaLiberada != null && !_pistasColetadas.contains(escolha.pistaLiberada)) {
        _pistasColetadas.add(escolha.pistaLiberada!);
      }

      // Se pegou 3 pistas, libera o botão de finalizar
      if (_pistasColetadas.length >= 3) {
        _missaoConcluida = true;
      }
    });
  }

  void _fecharConversa() {
    setState(() {
      _npcAtivo = null;
      _falaExibida = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investigação: Praça de Alimentação'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      // STACK para colocar a imagem de fundo e o conteúdo por cima
      body: Stack(
        children: [
          // IMAGEM DE FUNDO GLOBAL
          Positioned.fill(
            child: Image.asset(
              'assets/images/praca_de_alimentacao.jpeg', // Seu arquivo de imagem
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.6), // Película escura para dar contraste
              colorBlendMode: BlendMode.darken,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: const Color(0xFF1E1E1E)); // Fundo escuro de emergência
              },
            ),
          ),
          
          // CONTEÚDO ROLÁVEL
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card do Local (Levemente transparente com letras escuras)
                  Card(
                    elevation: 8,
                    color: Colors.green.shade50.withOpacity(0.95),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Praça de Alimentação', 
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)
                          ),
                          SizedBox(height: 8),
                          Text(
                            '📍 Área central do Campus I da PUC-Campinas, próxima à entrada principal.', 
                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600) // COR CORRIGIDA
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Ambiente amplo, dinâmico e altamente movimentado, localizado no coração do Campus I da PUC-Campinas. O local possui grande circulação de estudantes, professores e visitantes ao longo do dia, sendo um dos principais pontos de convivência da universidade.',
                            style: TextStyle(color: Colors.black87, fontSize: 15, height: 1.4), // COR CORRIGIDA
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Balão de Diálogo
                  if (_npcAtivo != null) ...[
                    Card(
                      color: Colors.white.withOpacity(0.95),
                      elevation: 8,
                      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.green.shade700, width: 2), borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${_npcAtivo!.nomeNPC} (${_npcAtivo!.papel})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                                IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: _fecharConversa),
                              ],
                            ),
                            const Divider(color: Colors.grey),
                            // COR CORRIGIDA NA FALA
                            Text(_falaExibida, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black87)),
                            const SizedBox(height: 16),
                            ..._npcAtivo!.escolhas.map((escolha) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white, 
                                    backgroundColor: Colors.green.shade700,
                                    minimumSize: const Size.fromHeight(45),
                                  ),
                                  onPressed: () => _processarEscolha(escolha),
                                  child: Text(escolha.texto, textAlign: TextAlign.center),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    // NPCs livres
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: Colors.black54, // Fundo escuro para destacar o título
                      child: const Text('Pessoas disponíveis na Praça:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    ...dialogosPracaAlimentacao.map((npc) {
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 8),
                        color: const Color(0xFF2C2C2C).withOpacity(0.95), // Cartão escuro para NPCs
                        child: ListTile(
                          leading: const Icon(Icons.person, color: Colors.greenAccent),
                          title: Text(npc.nomeNPC, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(npc.papel, style: const TextStyle(color: Colors.white70)),
                          trailing: const Icon(Icons.chat, color: Colors.greenAccent),
                          onTap: () => _iniciarConversa(npc),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],

                  // Caderno de Pistas
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.black54,
                    child: const Text('Caderno de Pistas:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  _pistasColetadas.isEmpty
                      ? Card(
                          color: Colors.black.withOpacity(0.6),
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Nenhuma pista coletada ainda. Converse com os NPCs!', style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                          ),
                        )
                      : Column(
                          children: _pistasColetadas.map((pistaNome) {
                            // Proteção extra com orElse para evitar quebra de tela
                            final pistaOriginal = pistasPracaAlimentacao.firstWhere(
                              (p) => p.titulo == pistaNome,
                              orElse: () => Pista(id: 999, titulo: pistaNome, descricao: 'Erro', tipo: 'Erro')
                            );
                            return Card(
                              elevation: 4,
                              color: Colors.amber.shade50.withOpacity(0.95),
                              child: ListTile(
                                leading: const Icon(Icons.search, color: Colors.amber),
                                // CORES CORRIGIDAS NAS PISTAS
                                title: Text(pistaOriginal.titulo, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                                subtitle: Text('${pistaOriginal.tipo}: ${pistaOriginal.descricao}', style: const TextStyle(color: Colors.black54)),
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 25),

                  // Mensagem de Desbloqueio e Botão de Finalizar
                  if (_missaoConcluida)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withOpacity(0.95), 
                        border: Border.all(color: Colors.blue.shade700, width: 2), 
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Column(
                        children: [
                          const Text('✨ Investigação Concluída! ✨', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                          const SizedBox(height: 8),
                          // COR CORRIGIDA NA MENSAGEM FINAL
                          const Text(
                            'Com as informações coletadas na praça de alimentação, você já pode avançar para o próximo ambiente.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black87, fontSize: 15),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50)
                            ),
                            onPressed: () {
                              context.read<GameState>().desbloquearAmbiente();
                              Navigator.pop(context);
                            },
                            child: const Text('Finalizar Investigação desta Sala', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          )
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
}