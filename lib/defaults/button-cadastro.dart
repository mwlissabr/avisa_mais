// signup_button.dart
import 'package:flutter/material.dart';
import 'package:avisa_mais/pages/cadastro.dart';

class SignupButton extends StatelessWidget {
  const SignupButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignupPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 218, 152, 58), // Cor do texto
        minimumSize: const Size(200, 40),
      ),
      child: const Text('Cadastro'),
    );
  }
}
