import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: '¿Qué es la Estrella de Boehm-Turner?',
              content:
                  'La Estrella de Boehm-Turner es un modelo de evaluación que ayuda a determinar si un proyecto debe seguir un enfoque ágil o prescriptivo (plan-driven). Fue desarrollado por Barry Boehm y Richard Turner para ayudar a los equipos a tomar decisiones informadas sobre la metodología de desarrollo más adecuada.',
            ),
            _buildSection(
              context,
              title: 'Las cinco dimensiones',
              content: 'El modelo considera cinco dimensiones clave:\n\n'
                  '1. Personal: Nivel de habilidad y experiencia del equipo.\n'
                  '2. Dinamismo: Tasa de cambio en los requisitos.\n'
                  '3. Cultura: Preferencia por el orden vs. la flexibilidad.\n'
                  '4. Tamaño: Tamaño del equipo y proyecto.\n'
                  '5. Criticidad: Impacto de los defectos en el sistema.',
            ),
            _buildSection(
              context,
              title: 'Cómo interpretar los resultados',
              content:
                  'Los valores cercanos al centro de la estrella (valores bajos) generalmente favorecen los enfoques ágiles, mientras que los valores alejados del centro (valores altos) tienden a favorecer los enfoques prescriptivos.\n\n'
                  'La aplicación calcula un porcentaje para cada enfoque basado en tus entradas y recomienda el más adecuado para tu proyecto.',
            ),
            _buildSection(
              context,
              title: 'Cómo usar esta aplicación',
              content:
                  '1. En la pantalla principal, toca "Comenzar Análisis".\n'
                  '2. Asigna un nombre a tu análisis.\n'
                  '3. Ajusta los valores para cada dimensión usando los deslizadores.\n'
                  '4. Toca "Analizar Resultados" para ver la recomendación.\n'
                  '5. Puedes guardar el análisis para referencia futura.',
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.email_outlined),
                label: const Text('Contactar Soporte'),
                onPressed: () {
                  // Implementar función de contacto
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Función no implementada'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
