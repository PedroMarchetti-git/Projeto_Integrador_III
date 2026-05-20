import 'package:flutter/material.dart';

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
}
