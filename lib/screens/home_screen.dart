import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Función para abrir enlaces
  void _launchURL(String url) async {
    Uri uri = Uri.parse(
        "https://github.com/HiramZednem/chatbot-gemini-flutter");

    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    //  logo de la universidad,
    // carrera, materia, nombre del alumno, matrícula, grupo y enlace a repositorio
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagen de perfil
              const CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRZd4QNRY8bNxWB5WI1PXYQSwiWA6-kdq95vw&s',
                ),
              ),
              const SizedBox(height: 16),

              // Información personal
              const Text(
                'Ingenieria en Software',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Moviles II',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nombre: Carlos Hiram Culebro Mendez',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Matrícula: 213456',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Grupo: 9b',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),

              // Enlaces a GitHub y LinkedIn
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: const Icon(Icons.link),
                      onPressed: () => _launchURL(
                          'github.com/HiramZednem/HEYCAP-FLUTTER/tree/hiram-individual')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
