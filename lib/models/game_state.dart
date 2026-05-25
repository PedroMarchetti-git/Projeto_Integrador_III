import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/ambiente.dart';
import '../data/ambientes_mock.dart';

class GameState extends ChangeNotifier {
  final Set<String> _tokens = {};
  final Set<String> _clues = {};
  final Set<String> _interactions = {};
  final Set<String> _visitedLocations = {};

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
  }

  // Retorna qual ambiente o jogador deve ir agora (o primeiro ainda trancado)
  Ambiente? get ambienteAtual {
    try {
      return _listaDeAmbientes.firstWhere((amb) => !amb.desbloqueado);
    } catch (e) {
      return null;
    }
  }

  // FUNÇÃO DE MONITORAMENTO (VERSÃO REAL)
  void _iniciarMonitoramentoGPS() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      debugPrint("DEBUG: Permissão de GPS negada pelo usuário.");
      return;
    }

    _gpsSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2, 
      ),
    ).listen((Position position) {
      _posicaoAtual = position;
      debugPrint("DEBUG: GPS Atualizado -> Lat: ${position.latitude}, Long: ${position.longitude}");
    
      if (estaNoRaioDoAmbiente()) {
        debugPrint("DEBUG: Jogador chegou ao local! Desbloqueando permanentemente...");
        desbloquearAmbiente(); 
      }
      notifyListeners(); 
    });
  }

  // CALCULO DE RAIO REAL (VERSÃO REAL)
  bool estaNoRaioDoAmbiente() {
    if (_posicaoAtual == null || ambienteAtual == null) {
      return false; 
    }

    double distanciaEmMetros = Geolocator.distanceBetween(
      _posicaoAtual!.latitude,
      _posicaoAtual!.longitude,
      ambienteAtual!.latitude,
      ambienteAtual!.longitude,
    );

    debugPrint("DEBUG: Distância até ${ambienteAtual!.nome}: ${distanciaEmMetros.toStringAsFixed(2)} metros");

    // Raio de tolerância configurado para 30 metros do local alvo
    return distanciaEmMetros <= 30.0; 
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

  @override
  void dispose() {
    _gpsSubscription?.cancel();
    super.dispose();
  }
}
