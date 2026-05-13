import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'screens/investigation/auth_screen.dart';
import 'models/game_state.dart'; // Import do estado global
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Erro ao inicializar Firebase: $e');
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quem Apagou as Luzes?',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthScreen(), // Define a tela de login como tela inicial
    );
  }
}