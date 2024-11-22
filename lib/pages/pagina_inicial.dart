import 'package:avisa_mais/pages/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecentNotificationsPage extends StatefulWidget {
  final String selectedSemester;
  final String selectedCourse;

  const RecentNotificationsPage({
    super.key,
    required this.selectedSemester,
    required this.selectedCourse,
  });

  @override
  _RecentNotificationsPageState createState() =>
      _RecentNotificationsPageState();
}

class _RecentNotificationsPageState extends State<RecentNotificationsPage> {
  List<Map<String, String>> notifications = [];

  // Função para carregar os avisos do Firebase
  Future<void> loadNotifications() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('avisos')
        .where('semester', isEqualTo: widget.selectedSemester)
        .where('course', isEqualTo: widget.selectedCourse)
        .orderBy('date', descending: true)
        .get();

    setState(() {
      notifications = snapshot.docs.map((doc) {
        return {
          'name': doc.data().containsKey('name')
              ? doc['name'].toString()
              : 'Desconhecido',
          'message': doc.data().containsKey('message')
              ? doc['message'].toString()
              : 'Sem mensagem',
          'course': doc.data().containsKey('course')
              ? doc['course'].toString()
              : 'Desconhecido',
          'semester': doc.data().containsKey('semester')
              ? doc['semester'].toString()
              : 'Semestre desconhecido',
          'date': doc['date'] != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(doc['date'].toDate())
              : 'Data desconhecida',
        };
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            '${widget.selectedSemester}',
            style: const TextStyle(color: Colors.black),
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 87, 106, 50),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              const Text(
                'Avisos',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D452C),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: notifications.isEmpty
                      ? [
                          const Center(child: Text('Não há notificações.')),
                        ]
                      : notifications.map((notification) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4.0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.notifications_none,
                                  color: Colors.black,
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Data: ${notification['date']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${notification['name']}:',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(notification['message'] ?? ''),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          height: 50.0,
          child: Center(
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.black),
              onPressed: () {
                //
              },
            ),
          ),
        ));
  }
}
