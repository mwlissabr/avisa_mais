import 'package:avisa_mais/pages/login.dart';
import 'package:avisa_mais/pages/selecao_semestre.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoursesSelectionPage extends StatefulWidget {
  const CoursesSelectionPage({super.key});

  @override
  _CoursesSelectionPageState createState() => _CoursesSelectionPageState();
}

class _CoursesSelectionPageState extends State<CoursesSelectionPage> {
  List<Map<String, dynamic>> courses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('courses').get();

      List<Map<String, dynamic>> loadedCourses = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();

        if (data.containsKey('name') && data.containsKey('semesters')) {
          loadedCourses.add({
            'name': data['name'],
            'semesters': List<String>.from(data['semesters']),
          });
        }
      }

      if (mounted) {
        setState(() {
          courses = loadedCourses;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Erro ao carregar cursos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              // Deslogar o usuário
              await FirebaseAuth.instance.signOut();
              // Navegar para a tela de login
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 87, 106, 50),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo_unicv_colorida.png',
                height: 120,
                width: 400,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Selecione o curso:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    isLoading
                        ? const CircularProgressIndicator()
                        : courses.isEmpty
                            ? const Text('Nenhum curso disponível.')
                            : SizedBox(
                                height: 350,
                                width: 320,
                                child: ListView.builder(
                                  itemCount: courses.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                        courses[index]['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SemestersSelectionPage(
                                              courseName: courses[index]
                                                  ['name'],
                                              semesters: courses[index]
                                                  ['semesters'],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
