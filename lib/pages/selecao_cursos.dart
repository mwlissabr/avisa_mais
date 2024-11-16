import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoursesSelectionPage extends StatefulWidget {
  const CoursesSelectionPage({super.key});

  @override
  _CoursesSelectionPageState createState() => _CoursesSelectionPageState();
}

class _CoursesSelectionPageState extends State<CoursesSelectionPage> {
  List<String> courses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('courses').get();

    print('Documentos recebidos: ${snapshot.docs.length}');
    
    List<String> loadedCourses = [];
    for (var doc in snapshot.docs) {
      var courseName = doc['name']; 
      loadedCourses.add(courseName);
      print('Curso: $courseName'); 
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        title: const Text(
          'Selecione o curso',
          style: TextStyle(color: Colors.black),
        ),
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
                height: 100,
                width: 250,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Selecione o curso:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D4530),
                      ),
                    ),
                    const SizedBox(height: 16),
                    isLoading
                        ? const CircularProgressIndicator()
                        : courses.isEmpty
                            ? const Text('Nenhum curso disponível.')
                            : SizedBox(
                                height: 350,
                                width: 400,
                                child: ListView.builder(
                                  itemCount: courses.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                        courses[index],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF3D4530),
                                        ),
                                      ),
                                      onTap: () {
                                        // ação ao selecionar o curso
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
