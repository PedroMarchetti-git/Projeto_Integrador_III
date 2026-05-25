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
  bool isInteractionDone(String interaction) =>
      _interactions.contains(interaction);
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

  GameState() {
    _listaDeAmbientes = ambientes; // Carrega os ambientes do mock
    //_iniciarMonitoramentoGPS();
    _listaDeAmbientes.first.desbloqueado = true;
  }

  Ambiente? get ambienteAtual {
    try{
      return _listaDeAmbientes.firstWhere((amb)=> !amb.desbloqueado);
    }catch(e){
      return null;
    }
  }

  void _iniciarMonitoramentoGPS() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    _gpsSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2, 
      ),
    ).listen((Position position) {
      _posicaoAtual = position;
      notifyListeners();
    });
  }

  bool estaNoRaioDoAmbiente(){
    return true;
  }

  void desbloquearAmbiente(){
    final atual = ambienteAtual;
    if (atual != null){
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
