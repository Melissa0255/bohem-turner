import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Boehm-Turner Analyzer',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Versión 1.0.0',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Propósito de la aplicación',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Esta aplicación está diseñada para ayudar a profesionales y equipos de desarrollo a evaluar qué enfoque de desarrollo es más adecuado para sus proyectos utilizando el modelo de la Estrella de Boehm-Turner.',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Basado en la investigación de:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Barry Boehm y Richard Turner, "Balancing Agility and Discipline: A Guide for the Perplexed" (2003)',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Desarrollado por:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDeveloperInfo(
                      context,
                      name: 'Tu Nombre',
                      role: 'Desarrollador',
                      email: 'correo@ejemplo.com',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.star),
              label: const Text('Calificar esta aplicación'),
              onPressed: () {
                // Implementar enlace a tienda de aplicaciones
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función no implementada'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Compartir'),
              onPressed: () {
                // Implementar función de compartir
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función no implementada'),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              '© 2023 Todos los derechos reservados',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperInfo(
    BuildContext context, {
    required String name,
    required String role,
    required String email,
  }) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.2),
          child: Text(
            name.substring(0, 1),
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                role,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              InkWell(
                onTap: () async {
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: email,
                    query: 'subject=Acerca de Boehm-Turner Analyzer',
                  );

                  try {
                    if (!await launchUrl(emailUri)) {
                      throw Exception('No se pudo abrir el correo');
                    }
                  } catch (e) {
                    // Manejar error
                  }
                },
                child: Text(
                  email,
                  style: TextStyle(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
