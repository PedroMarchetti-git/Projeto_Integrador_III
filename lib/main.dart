import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'screens/investigation/auth_screen.dart';
import 'models/game_state.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? firebaseInitError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase inicializado com sucesso.');
  } catch (e, st) {
    firebaseInitError = '$e';
    debugPrint('ERRO ao inicializar Firebase: $e\n$st');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => GameState(),
      child: MyApp(firebaseInitError: firebaseInitError),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? firebaseInitError;
  const MyApp({super.key, this.firebaseInitError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quem Apagou as Luzes?',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: firebaseInitError != null
          ? _FirebaseErrorScreen(error: firebaseInitError!)
          : const AuthScreen(),
    );
  }
}

class _FirebaseErrorScreen extends StatelessWidget {
  final String error;
  const _FirebaseErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Falha ao inicializar o Firebase',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SelectableText(error, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
