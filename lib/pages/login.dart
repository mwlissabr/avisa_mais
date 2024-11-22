import 'package:avisa_mais/defaults/button-cadastro.dart';
import 'package:avisa_mais/defaults/button-login.dart';
import 'package:avisa_mais/pages/nav_base.dart';
import 'package:avisa_mais/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isRecoveryMode = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Preencha todos os campos!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Wrapper()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Usuário não encontrado.';
          break;
        case 'wrong-password':
          errorMessage = 'Senha incorreta.';
          break;
        case 'invalid-email':
          errorMessage = 'E-mail inválido.';
          break;
        default:
          errorMessage = 'Falha no login. Tente novamente.';
      }

      _showError(errorMessage);
    } catch (e) {
      _showError('Erro inesperado. Tente novamente.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError('Digite seu e-mail para redefinir a senha.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'E-mail de recuperação enviado. Verifique sua caixa de entrada.')),
      );
    } on FirebaseAuthException catch (e) {
      _showError('Erro ao enviar e-mail de recuperação: ${e.message}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Avisa +',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/logo_unicv_colorida.png',
              height: 120,
              width: 400,
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 61, 69, 44),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            // Exibe o campo de senha apenas se não estiver no modo de recuperação
            if (!_isRecoveryMode)
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 20.0),
            // Mostra botão de login apenas se não estiver no modo de recuperação
            if (!_isRecoveryMode)
              _isLoading
                  ? const CircularProgressIndicator()
                  : LoginButton(
                      onPressed: _login,
                    ),
            const SizedBox(height: 10.0),
            if (!_isRecoveryMode) const SignupButton(),
            if (_isRecoveryMode)
              ElevatedButton(
                onPressed: _resetPassword,
                child: const Text('Enviar e-mail de recuperação'),
              ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                setState(() {
                  _isRecoveryMode =
                      !_isRecoveryMode; // Alterna o modo de recuperação
                });
              },
              child: Text(
                  _isRecoveryMode ? 'Voltar ao login' : 'Esqueci minha senha'),
            ),
          ],
        ),
      ),
    );
  }
}
