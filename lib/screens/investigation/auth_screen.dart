import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../home/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Nenhum usuário encontrado com esse e-mail.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado. Faça login.';
      case 'weak-password':
        return 'Senha muito fraca (mínimo 6 caracteres).';
      case 'operation-not-allowed':
        return 'Login por e-mail/senha está desabilitado no Firebase Console.';
      case 'network-request-failed':
        return 'Sem conexão com o servidor. Verifique sua internet.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return 'Erro de autenticação: ${e.code} - ${e.message}';
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'uid': userCredential.user!.uid,
            'nome': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });
        } on FirebaseException catch (e) {
          debugPrint('Erro ao gravar no Firestore: ${e.code} - ${e.message}');
          _showError(
            'Conta criada, mas falhou ao salvar perfil: ${e.code}. '
            'Verifique as regras do Firestore.',
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
      _showError(_mapAuthError(e));
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException: ${e.code} - ${e.message}');
      _showError('Erro Firebase: ${e.code} - ${e.message}');
    } catch (e, st) {
      debugPrint('Erro inesperado: $e\n$st');
      _showError('Erro inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.flashlight_on_rounded,
                    size: 80, color: Theme.of(context).primaryColor),
                const SizedBox(height: 16),
                Text(
                  _isLogin ? 'Entrar no Mistério' : 'Criar Nova Conta',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Informe seu nome'
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      (value == null || !value.contains('@'))
                          ? 'E-mail inválido'
                          : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) => (value == null || value.length < 6)
                      ? 'Senha muito curta (mín. 6 caracteres)'
                      : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_isLogin ? 'ENTRAR' : 'CADASTRAR'),
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => setState(() => _isLogin = !_isLogin),
                  child: Text(_isLogin
                      ? 'Não tem uma conta? Registre-se'
                      : 'Já tem uma conta? Faça Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
