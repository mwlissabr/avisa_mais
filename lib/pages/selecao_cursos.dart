import 'package:avisa_mais/pages/avisos_docentes.dart';
import 'package:avisa_mais/pages/login.dart';
import 'package:avisa_mais/pages/pagina_inicial.dart';
import 'package:avisa_mais/wrapper.dart';
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
  List<Map<String, dynamic>> filteredCourses = [];
  bool isLoading = true;
  String? userRole;
  final TextEditingController _pesquisaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _pesquisaController.addListener(_filterCourses);
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await getUserRole();
    setState(() {
      userRole = role;
    });
  }

  Future<void> _loadCourses() async {
    try {
      final coursesSnapshot =
          await FirebaseFirestore.instance.collection('courses').get();
      final semestersSnapshot =
          await FirebaseFirestore.instance.collection('semesters').get();

      List<Map<String, dynamic>> loadedCourses = [];
      Map<String, String> semesterNames = {
        for (var doc in semestersSnapshot.docs) doc.id: doc.data()['name']
      };

      for (var courseDoc in coursesSnapshot.docs) {
        var courseData = courseDoc.data();
        if (courseData.containsKey('name') &&
            courseData.containsKey('qtd_semesters')) {
          for (int i = 1; i <= courseData['qtd_semesters']; i++) {
            String semesterId = '$i-semestre';
            String semesterName = semesterNames[semesterId] ?? '$iº Semestre';

            loadedCourses.add({
              'course': courseData['name'],
              'semester': semesterName,
              'fullName': '${courseData['name']} - $semesterName',
            });
          }
        }
      }

      if (mounted) {
        setState(() {
          courses = loadedCourses;
          filteredCourses = List.from(courses);
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

  void _filterCourses() {
    String query = _pesquisaController.text.toLowerCase();
    setState(() {
      filteredCourses = courses
          .where((course) => course['fullName'].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        actions: [
          // Botão de mensagens
          IconButton(
            icon: const Icon(Icons.message, color: Colors.black),
            onPressed: () {
              if (userRole == 'docente' || userRole == 'admin') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const EnviarAvisoPage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Acesso restrito à página de envio de avisos.',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          // Botão de logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
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
                width: 350,
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
                    TextField(
                      controller: _pesquisaController,
                      decoration: InputDecoration(
                        hintText: 'Pesquisar cursos...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    isLoading
                        ? const CircularProgressIndicator()
                        : filteredCourses.isEmpty
                            ? const Text('Nenhum curso disponível.')
                            : SizedBox(
                                height: 350,
                                child: ListView.builder(
                                  itemCount: filteredCourses.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                        filteredCourses[index]['fullName'],
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
                                                RecentNotificationsPage(
                                              selectedSemester:
                                                  filteredCourses[index]
                                                      ['semester'],
                                              selectedCourse:
                                                  filteredCourses[index]
                                                      ['course'],
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
