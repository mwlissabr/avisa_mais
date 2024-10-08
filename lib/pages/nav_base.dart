import 'package:flutter/material.dart';

class BasePage extends StatelessWidget {
  final String title;
  final Widget body;

  const BasePage({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 86, 105, 48),
        title: Text(title, style: const TextStyle(color: Colors.white)),
      ),
      body: body,
    );
  }
}
