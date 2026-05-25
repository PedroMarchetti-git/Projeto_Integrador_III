import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // PACOTE DE GPS ADICIONADO

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
    falaInicial: 'Eu não estudo aqui, então talvez eu tenha reparado in coisas diferentes. Quando as luzes começaram a falhar, algumas pessoas pareceram assustadas, mas uma delas parecia já esperar por aquilo.',
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
// 3. INTERFACE VISUAL COM VALIDAÇÃO DE GPS
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

  // VARIÁVEIS DO GPS
  bool _carregandoGPS = true;
  bool _estaNoLocalCorreto = false;
  String _mensagemErroGPS = "";

  // COORDENADAS EXATAS FORNECIDAS PARA A PRAÇA DE ALIMENTAÇÃO
  final double _pucLatitude = -22.83305010393137;
  final double _pucLongitude = -47.0520150652189;
  final double _raioAtivacaoMetros = 20.0; // Raio de proximidade permitido

  @override
  void initState() {
    super.initState();
    _verificarGeolocalizacao(); // Executa a validação assim que o ecrã abre
  }

  Future<void> _verificarGeolocalizacao() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // 1. Verifica se a localização do smartphone está ligada
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _mensagemErroGPS = "Por favor, ative o GPS do seu telemóvel.";
          _carregandoGPS = false;
        });
        return;
      }

      // 2. Trata as permissões de acesso ao sensor de GPS
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _mensagemErroGPS = "Permissão de GPS negada pelo utilizador.";
            _carregandoGPS = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _mensagemErroGPS = "Permissão de GPS negada permanentemente nas definições.";
          _carregandoGPS = false;
        });
        return;
      }

      // 3. Captura a posição geográfica do utilizador
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      // 4. Calcula a distância real em metros até à Praça
      double distanciaEmMetros = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        _pucLatitude,
        _pucLongitude,
      );

      setState(() {
        // Se a distância for menor ou igual a 20 metros, o ecrã desbloqueia
        _estaNoLocalCorreto = distanciaEmMetros <= _raioAtivacaoMetros;
        _carregandoGPS = false;
      });

    } catch (e) {
      setState(() {
        _mensagemErroGPS = "Erro ao ler as coordenadas: $e";
        _carregandoGPS = false;
      });
    }
  }

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
      body: _carregandoGPS
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text("A obter a sua localização por GPS..."),
                ],
              ),
            )
          : !_estaNoLocalCorreto
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off, size: 80, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          "Acesso Bloqueado",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _mensagemErroGPS.isNotEmpty 
                              ? _mensagemErroGPS 
                              : "Precisa de estar fisicamente na Praça de Alimentação da PUC para investigar este local.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() { _carregandoGPS = true; });
                            _verificarGeolocalizacao();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text("Tentar Novamente"),
                        )
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
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
                              Text('Ambiente amplo, dinâmico e altamente movimentado, localizado no coração do Campus I da PUC-Campinas. O local possui grande circulação de estudantes, professores e visitantes ao longo do dia, sendo um dos principais pontos de convivência da universidade.'),
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
                                'Com as informações coletadas na praça de alimentação, o próximo passo é investigar o auditório.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                onPressed: () {
                                  Navigator.pop(context);
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
