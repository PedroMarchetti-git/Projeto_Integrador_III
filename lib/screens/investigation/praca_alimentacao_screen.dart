import 'package:flutter/material.dart';

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
        pistaLiberada: 'Suspeita de que o apagão foi proposital',
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
// 3. INTERFACE VISUAL (A SUA TELA)
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
      
      if (escolha.pistaLiberada != null && !_pistasColetadas.contains(escolha.pistaLiberada)) {
        _pistasColetadas.add(escolha.pistaLiberada!);
      }

      // Condição para liberar o auditório: achar 3 pistas
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
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card do Local
            Card(
              elevation: 4,
              color: Colors.green.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Praça de Alimentação', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                    SizedBox(height: 4),
                    Text('📍 Área central do Campus I da PUC-Campinas, próxima à entrada principal.', style: TextStyle(color: Colors.black54)),
                    SizedBox(height: 8),
                    Text('Ambiente amplo, dinâmico e altamente movimentado, localizado no coração do Campus I da PUC-Campinas. O local possui grande circulação de estudantes, professores e visitantes ao longo do dia, sendo um dos principais pontos de convivência da universidade. Durante a investigação, a praça se torna um ambiente importante para coleta de depoimentos, observação de comportamentos suspeitos e descoberta de conflitos pessoais relacionados aos acontecimentos anteriores ao apagão.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Balão de Diálogo
            if (_npcAtivo != null) ...[
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.green, width: 2), borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          Text('${_npcAtivo!.nomeNPC} (${_npcAtivo!.papel})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                          IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: _fecharConversa),
                        ],
                      ),
                      const Divider(),
                      Text(_falaExibida, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                      const SizedBox(height: 16),
                      ..._npcAtivo!.escolhas.map((escolha) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.green.shade700,
                              minimumSize: const Size.fromHeight(40),
                            ),
                            onPressed: () => _processarEscolha(escolha),
                            child: Text(escolha.texto),
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
              const Text('Pessoas disponíveis na Praça:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...dialogosPracaAlimentacao.map((npc) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.green),
                    title: Text(npc.nomeNPC),
                    subtitle: Text(npc.papel),
                    trailing: const Icon(Icons.chat, color: Colors.green),
                    onTap: () => _iniciarConversa(npc),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],

            // Caderno de Pistas
            const Text('Caderno de Pistas:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _pistasColetadas.isEmpty
                ? const Text('Nenhuma pista coletada ainda. Converse com os NPCs!')
                : Column(
                    children: _pistasColetadas.map((pistaNome) {
                      final pistaOriginal = pistasPracaAlimentacao.firstWhere((p) => p.titulo == pistaNome);
                      return Card(
                        color: Colors.amber.shade50,
                        child: ListTile(
                          leading: const Icon(Icons.search, color: Colors.amber),
                          title: Text(pistaOriginal.titulo),
                          subtitle: Text('${pistaOriginal.tipo}: ${pistaOriginal.descricao}'),
                        ),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 25),

            // Mensagem de Desbloqueio
            if (_missaoConcluida)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.shade50, border: BorderSide(color: Colors.blue.shade700, width: 2), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    const Text('✨ O Auditório foi Desbloqueado! ✨', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 8),
                    const Text(
                      'Com as informações coletadas na praça de alimentação, fica claro que o apagão não foi apenas uma falha comum. Alguém parecia saber o que aconteceria. O próximo passo é investigar o auditório, onde tudo começou.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () {
                        Navigator.pop(context); // Retorna à lista de locais
                      },
                      child: const Text('Voltar aos Ambientes', style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
