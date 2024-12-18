import 'package:avisa_mais/pages/login.dart';
import 'package:avisa_mais/pages/nav_base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _registerUser() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Preencha todos os campos!');
      return;
    }

    String? role;

    if (email.endsWith('@aluno.unicv.edu.br')) {
      role = 'aluno';
    } else if (email.endsWith('@unicv.edu.br')) {
      role = 'docente';
    } else if (email.endsWith('@admin.unicv.edu.br')) {
      role = 'admin';
    } else {
      _showError('E-mail inválido! Use um e-mail institucional.');
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showError('A senha é muito fraca.');
      } else if (e.code == 'email-already-in-use') {
        _showError('Este e-mail já está sendo usado.');
      } else if (e.code == 'invalid-email') {
        _showError('E-mail inválido.');
      } else {
        _showError('Erro no cadastro: ${e.message}');
      }
    } catch (e) {
      _showError('Erro: $e');
    }

    setState(() {
      _isLoading = false;
    });
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
            const SizedBox(height: 18.0),
            const Text(
              'Cadastro',
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
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32.0),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 86, 105, 48),
                      minimumSize: const Size(200, 40),
                    ),
                    child: const Text('Cadastrar'),
                  ),
          ],
        ),
      ),
    );
  }
}
