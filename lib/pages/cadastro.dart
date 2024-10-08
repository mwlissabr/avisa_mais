import 'package:avisa_mais/pages/nav_base.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _checkEmail(String email) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:9000/codigo-validacao/enviar'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 201) {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => VerificationPage(email: email),
        //   ),
        // );
      } else if (response.statusCode == 403) {
        _showError('O e-mail já está cadastrado.');
      } else {
        _showError('Erro ao verificar e-mail. Código: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Erro ao verificar e-mail: $e');
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
      title: 'Cadastro',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/Logo fundo branco.png',
              height: 100,
              width: 100,
            ),
            const SizedBox(height: 32.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 32.0),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () {
                final email = _emailController.text;
                if (email.isEmpty) {
                  _showError('O e-mail é obrigatório.');
                  return;
                }
                _checkEmail(email);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 31, 17, 65),
              ),
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
