import 'package:avisa_mais/pages/login.dart';
import 'package:avisa_mais/pages/selecao_cursos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Erro ao verificar autenticação"));
            } else if (snapshot.data == null) {
              // Usuário não autenticado, redireciona para a página de login
              return const LoginPage();
            } else {
            // Usuário autenticado, buscar a role
              return FutureBuilder<String?>(
                future: getUserRole(),
                builder: (context, roleSnapshot) {
                  if (roleSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (roleSnapshot.hasError) {
                    return const Center(child: Text("Erro ao carregar dados do usuário"));
                  } else if (roleSnapshot.hasData) {
                    final role = roleSnapshot.data;
                      switch(role){
                        case 'aluno': 
                          return const CoursesSelectionPage();
                        case 'docente':
                          return const CoursesSelectionPage();
                        default:
                          return const Center(child: Text("Role desconhecida"));
                      }

                    }else{
                      return const Center(child: Text("Nenhum dado encontrado"));
                    }
             
                },
              );
            }
          }
      ),
    );
  }
}

Future<String?> getUserRole() async{
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Recupera o documento do usuário
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return doc.data()?['role']; // Retorna a role do documento
      } else {
        throw Exception("Usuário não encontrado no Firestore");
      }
    } else {
      throw Exception("Nenhum usuário logado");
    }
  } catch (e) {
    print("Erro ao recuperar role do usuário: $e");
    return null;
  }
}
