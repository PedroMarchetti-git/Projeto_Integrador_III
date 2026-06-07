import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/game_state.dart'; 
import 'screens/investigation/ceaab_screens.dart'; 

void main() {
  runApp(const AppTeste());
}

class AppTeste extends StatelessWidget {
  const AppTeste({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: ChangeNotifierProvider(
        create: (_) => GameState(),
        child: const CeaabScreen(), 
      ),
    );
  }
}
