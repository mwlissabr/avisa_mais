import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EnviarAvisoPage extends StatefulWidget {
  const EnviarAvisoPage({Key? key}) : super(key: key);

  @override
  _EnviarAvisoPageState createState() => _EnviarAvisoPageState();
}

class _EnviarAvisoPageState extends State<EnviarAvisoPage> {
  final TextEditingController _mensagemController = TextEditingController();
  final TextEditingController _pesquisaController = TextEditingController();
  List<Map<String, dynamic>> cursosESemestres = [];
  List<Map<String, dynamic>> cursosFiltrados = [];
  List<Map<String, dynamic>> selecionados = [];
  bool isLoading = true;
  bool listaAberta = false;

  @override
  void initState() {
    super.initState();
    _carregarCursosESemestres();
    _pesquisaController.addListener(_filtrarCursos);
  }

  Future<void> _carregarCursosESemestres() async {
    try {
      final cursosSnapshot =
          await FirebaseFirestore.instance.collection('courses').get();

      List<Map<String, dynamic>> carregados = [];
      for (var cursoDoc in cursosSnapshot.docs) {
        var cursoData = cursoDoc.data();
        if (cursoData.containsKey('name') &&
            cursoData.containsKey('qtd_semesters')) {
          for (int i = 1; i <= cursoData['qtd_semesters']; i++) {
            carregados.add({
              'curso': cursoData['name'],
              'semestre': '$iº Semestre',
              'nomeCompleto': '${cursoData['name']} - $iº Semestre',
            });
          }
        }
      }

      if (mounted) {
        setState(() {
          cursosESemestres = carregados;
          cursosFiltrados = List.from(carregados);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Erro ao carregar cursos e semestres: $e');
    }
  }

  void _filtrarCursos() {
    String query = _pesquisaController.text.toLowerCase();
    setState(() {
      cursosFiltrados = cursosESemestres
          .where((curso) => curso['nomeCompleto'].toLowerCase().contains(query))
          .toList();
    });
  }

  void _adicionarCurso(Map<String, dynamic> curso) {
    if (!selecionados.contains(curso)) {
      setState(() {
        selecionados.add(curso);
      });
    }
  }

  Future<void> _enviarAviso() async {
    if (selecionados.isEmpty || _mensagemController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Selecione pelo menos um curso/semestre e digite a mensagem.'),
        ),
      );
      return;
    }

    try {
      // Gravar aviso para cada curso/semestre selecionado
      for (var selected in selecionados) {
        await FirebaseFirestore.instance.collection('avisos').add({
          'name': 'Nome do Docente',
          'message': _mensagemController.text,
          'semester': selected['semestre'],
          'course': selected['curso'],
          'date': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aviso enviado com sucesso!'),
        ),
      );

      setState(() {
        selecionados.clear();
        _mensagemController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar aviso: $e')),
      );
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Image.asset(
          'assets/logo_unicv_colorida.png',
          height: 40,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFF576A32),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              const Text(
                'Enviar novo aviso',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D452C),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  setState(() {
                    listaAberta = !listaAberta;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Selecione cursos e semestres'),
                      Icon(listaAberta
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
              if (listaAberta)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  constraints: const BoxConstraints(
                    maxHeight: 300,
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _pesquisaController,
                        decoration: InputDecoration(
                          hintText: 'Pesquisar...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                itemCount: cursosFiltrados.length,
                                itemBuilder: (context, index) {
                                  final curso = cursosFiltrados[index];
                                  return ListTile(
                                    title: Text(curso['nomeCompleto']),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () => _adicionarCurso(curso),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _mensagemController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Digite a mensagem aqui.',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: selecionados.map((cursoSemestre) {
                  return Chip(
                    label: Text(cursoSemestre['nomeCompleto']),
                    onDeleted: () {
                      setState(() {
                        selecionados.remove(cursoSemestre);
                      });
                    },
                  );
                }).toList(),
              ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: _enviarAviso,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF576A32),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Enviar aviso',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
