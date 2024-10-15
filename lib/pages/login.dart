import 'package:avisa_mais/defaults/button-cadastro.dart';
import 'package:avisa_mais/defaults/button-login.dart';
import 'package:avisa_mais/pages/nav_base.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Preencha todos os campos!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // CONFIGURAR ENDPOINT
    // final response = await http.post(
    //   Uri.parse('http://localhost:9000/login'),
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8',
    //   },
    //   body: jsonEncode(<String, String>{
    //     'email': email,
    //     'password': password,
    //   }),
    // );

    // setState(() {
    //   _isLoading = false;
    // });

    // VALIDAÇÃO DO FIREBASE
    // if (response.statusCode == 200) {
    //     // Navigator.pushReplacement(
    //     //   context,
    //     //   MaterialPageRoute(builder: (context) => const HomePage()),
    //     // );
    // } else {
    //   _showError('Login falhou. Verifique suas credenciais.');
    // }
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
              height: 100,
              width: 250,
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
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            _isLoading
                ? const CircularProgressIndicator()
                : LoginButton(
                    onPressed: _login,
                  ),
            const SizedBox(height: 10.0),
            const SignupButton(),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                // );
              },
              child: const Text('Esqueci minha senha'),
            ),
          ],
        ),
      ),
    );
  }
}
