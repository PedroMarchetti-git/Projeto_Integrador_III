import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'home/home_screen.dart';
import 'screens/auth/auth_screen.dart'; // Importa a nova tela de login
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Arquivo gerado pelo FlutterFire

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Erro ao inicializar Firebase: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mistério do Apagão',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthScreen(), // Define a tela de login como tela inicial
    );
  }
}