import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../models/ambiente.dart';
import '../data/ambientes_mock.dart';

class GameState extends ChangeNotifier {
  final Set<String> _tokens = {};
  final Set<String> _clues = {};
  final Set<String> _interactions = {};
  final Set<String> _visitedLocations = {};

// ==========================================
// SISTEMA GLOBAL DE ÁUDIO
// ==========================================
final AudioPlayer _bgmPlayer = AudioPlayer();
bool _isMuted = false; 

// Permite que as telas saibam se está mudo para mudar o ícone
bool get isMuted => _isMuted;

  // Tokens
  bool hasToken(String token) => _tokens.contains(token);
  void addToken(String token) {
    _tokens.add(token);
    notifyListeners();
  }

  // Pistas
  List<String> get allClues => _clues.toList();
  bool addClue(String clue) {
    if (_clues.contains(clue)) return false;
    _clues.add(clue);
    notifyListeners();
    return true;
  }

  // Interações
  bool isInteractionDone(String interaction) => _interactions.contains(interaction);
  void completeInteraction(String interaction) {
    _interactions.add(interaction);
    notifyListeners();
  }

  // Localizações visitadas
  void visitLocation(String location) {
    _visitedLocations.add(location);
    notifyListeners();
  }

  bool hasVisited(String location) => _visitedLocations.contains(location);

  late List<Ambiente> _listaDeAmbientes;
  Position? _posicaoAtual;
  StreamSubscription<Position>? _gpsSubscription;

  /// Retorna a última posição conhecida (pode ser nula).
  Position? get posicaoAtual => _posicaoAtual;
  List<Ambiente> get todosAmbientes => _listaDeAmbientes;

  // CONSTRUTOR - Inicializa a lista e o GPS real
  GameState() {
    _listaDeAmbientes = List.from(ambientes); 
    _iniciarMonitoramentoGPS(); 
    _iniciarMusicaGlobal();
  }

  // Retorna qual ambiente o jogador deve ir agora (o primeiro ainda trancado)
  Ambiente? get ambienteAtual {
    try {
      return _listaDeAmbientes.firstWhere((amb) => !amb.desbloqueado);
    } catch (e) {
      return null;
    }
  }

void _iniciarMonitoramentoGPS() async {
    // 1. Checa e pede permissão
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      debugPrint("DEBUG: Permissão de GPS negada pelo usuário ou navegador.");
      return;
    }

    try {
      debugPrint("DEBUG: Tentando forçar a busca do GPS inicial...");
      _posicaoAtual = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium, 
        timeLimit: const Duration(seconds: 5), 
      );
      notifyListeners();
    } catch (e) {
      debugPrint("DEBUG: Falha na busca inicial (Timeout ou Bloqueio): $e");
      _posicaoAtual = await Geolocator.getLastKnownPosition();
      notifyListeners();
    }

    _gpsSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0, 
      ),
    ).listen((Position position) {
      _posicaoAtual = position; 
      debugPrint("DEBUG: GPS Movimento -> Lat: ${position.latitude}, Long: ${position.longitude}");
      
      notifyListeners(); 
    });
  }

  double? _ultimaDistancia;

  bool estaNoRaioDoAmbiente() {
    if (_posicaoAtual == null || ambienteAtual == null) {
      return false; 
    }

    _ultimaDistancia = Geolocator.distanceBetween(
      _posicaoAtual!.latitude,
      _posicaoAtual!.longitude,
      ambienteAtual!.latitude,
      ambienteAtual!.longitude,
    );

    // Raio de tolerância configurado para 70 metros
    return _ultimaDistancia! <= 70.0; 
  }

  // NOVA FUNÇÃO: O detetive que nos dirá o que está dando errado
  String obterMotivoBloqueio() {
    if (_posicaoAtual == null) {
      return "Aguardando sinal do satélite GPS... Vá para um local aberto.";
    }
    if (_ultimaDistancia != null) {
      return "Você está a ${_ultimaDistancia!.toStringAsFixed(0)} metros de distância. (Faltam chegar mais perto!)";
    }
    return "Calculando rota...";
  }
  // Conclui o ambiente atual
  void desbloquearAmbiente() {
    final atual = ambienteAtual;
    if (atual != null) {
      atual.desbloqueado = true;
      visitLocation(atual.nome);
      notifyListeners();
    }
  }

void _iniciarMusicaGlobal() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource('audios/A_Periment_of_Breath.mp3'));
  }

  void alternarMutarMusica() {
    _isMuted = !_isMuted; // Inverte o estado (se era falso, vira verdadeiro)
    if (_isMuted) {
      _bgmPlayer.pause(); // Se mutou, pausa a música
    } else {
      _bgmPlayer.resume(); // Se desmutou, volta a tocar de onde parou
    }
    notifyListeners(); // Avisa as telas para trocarem o ícone do botão
  }

  @override
  void dispose() {
    _bgmPlayer.dispose();
    _gpsSubscription?.cancel();
    super.dispose();
  }
}
