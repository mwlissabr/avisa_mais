import 'package:flutter/material.dart';
import 'pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avisa +',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 86,105,48)),
        useMaterial3: true,
        // Configura o tema para os botões
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(
                255, 86, 105, 48), // Cor do texto dos botões
          ),
        ),
        // Configura o tema para os botões de texto
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(
                255, 86, 105, 48), // Cor do texto dos botões de texto
          ),
        ),
        // Configura o tema para os botões de ícones
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: Colors.white, // Cor dos ícones
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
