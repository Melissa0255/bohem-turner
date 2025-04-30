import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' show pi;

import '../providers/analysis_provider.dart';
import '../providers/theme_provider.dart';
import '../models/analysis_result.dart';
import '../utils/app_theme.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  // Valores iniciales para cada dimensión
  final Map<String, double> _dimensions = {
    'personnel': 3.0,
    'dynamism': 3.0,
    'culture': 3.0,
    'size': 3.0,
    'criticality': 3.0,
  };

  // Para mostrar/ocultar secciones
  bool _showResults = false;
  AnalysisResult? _result;

  final Map<String, String> _dimensionLabels = {
    'personnel': 'Personal (Nivel de habilidad)',
    'dynamism': 'Dinamismo (Cambios en requisitos)',
    'culture': 'Cultura (Actitud hacia el caos vs orden)',
    'size': 'Tamaño del equipo',
    'criticality': 'Criticidad (Impacto de defectos)',
  };

  final Map<String, String> _dimensionTooltips = {
    'personnel':
        '1 = Equipo altamente calificado, 5 = Equipo con poca experiencia',
    'dynamism': '1 = Requisitos altamente cambiantes, 5 = Requisitos estables',
    'culture':
        '1 = Cultura que prospera en la flexibilidad, 5 = Cultura que valora el orden y la planificación',
    'size': '1 = Equipo pequeño, 5 = Equipo grande',
    'criticality':
        '1 = Bajo impacto de defectos, 5 = Alto impacto, puede afectar vidas',
  };

  final Map<String, List<String>> _dimensionExtremes = {
    'personnel': ['Ágil (Alto nivel)', 'Prescriptivo (Bajo nivel)'],
    'dynamism': ['Ágil (Alta)', 'Prescriptivo (Baja)'],
    'culture': ['Ágil (Flexibilidad)', 'Prescriptivo (Orden)'],
    'size': ['Ágil (Pequeño)', 'Prescriptivo (Grande)'],
    'criticality': ['Ágil (Baja)', 'Prescriptivo (Alta)'],
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis de Boehm-Turner'),
        actions: [
          if (_showResults)
            IconButton(
              icon: const Icon(Icons.save_alt),
              onPressed: _saveAnalysis,
              tooltip: 'Guardar análisis',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_showResults) _buildInputForm(isDarkMode),
            if (_showResults) _buildResultsView(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildInputForm(bool isDarkMode) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Qué es la Estrella de Boehm-Turner?',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'La Estrella de Boehm-Turner es una herramienta que permite evaluar qué enfoque de desarrollo '
                    'es más adecuado para un proyecto específico: Ágil o Prescriptivo (Plan-driven). '
                    'Se basa en cinco dimensiones clave que determinan la compatibilidad del proyecto con cada enfoque.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nombre del análisis:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Ej: Proyecto de E-commerce',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingrese un nombre para el análisis';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valores para cada dimensión:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Califique cada dimensión en una escala del 1 al 5, donde 1 favorece enfoques ágiles y 5 favorece enfoques prescriptivos.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),
                  ..._dimensions.keys.map((key) => _buildDimensionSlider(key)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.assessment),
                      label: const Text('ANALIZAR RESULTADOS'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _analyzeResults();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionSlider(String dimension) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                _dimensionLabels[dimension] ?? dimension,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Tooltip(
              message: _dimensionTooltips[dimension] ?? '',
              child: const Icon(Icons.info_outline, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _dimensions[dimension] ?? 3.0,
                min: 1.0,
                max: 5.0,
                divisions: 8,
                label: _dimensions[dimension]?.toString(),
                onChanged: (value) {
                  setState(() {
                    _dimensions[dimension] = value;
                  });
                },
              ),
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.light,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _dimensions[dimension]?.toString() ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _dimensionExtremes[dimension]?[0] ?? 'Ágil',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.agile,
              ),
            ),
            Text(
              _dimensionExtremes[dimension]?[1] ?? 'Prescriptivo',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.prescriptive,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }

  Widget _buildResultsView(bool isDarkMode) {
    if (_result == null) return const SizedBox.shrink();

    final agileScore = _result!.agileScore.toStringAsFixed(1);
    final prescriptiveScore = _result!.prescriptiveScore.toStringAsFixed(1);
    final isAgile = _result!.recommendedApproach == 'Enfoque Ágil';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isAgile ? Icons.auto_awesome : Icons.architecture,
                      color: isAgile ? AppColors.agile : AppColors.prescriptive,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Enfoque recomendado:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isAgile
                        ? AppColors.agile.withAlpha(51) // 0.2 * 255 ≈ 51
                        : AppColors.prescriptive
                            .withAlpha(51), // 0.2 * 255 ≈ 51
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isAgile ? AppColors.agile : AppColors.prescriptive,
                    ),
                  ),
                  child: Text(
                    _result!.recommendedApproach,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isAgile ? AppColors.agile : AppColors.prescriptive,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildScoreCard(
                        'Puntaje Ágil',
                        agileScore,
                        AppColors.agile,
                        isAgile,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildScoreCard(
                        'Puntaje Prescriptivo',
                        prescriptiveScore,
                        AppColors.prescriptive,
                        !isAgile,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gráfico de Estrella:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: _buildRadarChart(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('NUEVO ANÁLISIS'),
              onPressed: () {
                setState(() {
                  _showResults = false;
                  _nameController.clear();
                  _dimensions.updateAll((key, value) => 3.0);
                });
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('GUARDAR'),
              onPressed: _saveAnalysis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreCard(
    String title,
    String score,
    Color color,
    bool isHighlighted,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26), // 0.1 * 255 ≈ 26
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHighlighted ? color : color.withAlpha(77), // 0.3 * 255 ≈ 77
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$score%',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarChart() {
    if (_result == null) return const SizedBox.shrink();

    // Invertimos la escala: 1->5, 2->4, 3->3, 4->2, 5->1
    final data = [
      6 - (_dimensions['personnel'] ?? 3.0),
      6 - (_dimensions['dynamism'] ?? 3.0),
      6 - (_dimensions['culture'] ?? 3.0),
      6 - (_dimensions['size'] ?? 3.0),
      6 - (_dimensions['criticality'] ?? 3.0),
    ];

    // Eliminamos títulos del radar chart
    return Column(
      children: [
        // Etiquetas superiores
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Personal',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),

        // Etiquetas laterales y gráfico
        Row(
          children: [
            // Etiqueta izquierda
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RotatedBox(
                  quarterTurns: 3,
                  child: Text('Dinamismo',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            // El gráfico sin títulos
            Expanded(
              child: SizedBox(
                height: 250,
                child: RadarChart(
                  RadarChartData(
                    radarBorderData:
                        const BorderSide(color: Colors.transparent),
                    tickBorderData: const BorderSide(color: Colors.transparent),
                    gridBorderData:
                        BorderSide(color: Colors.grey.withAlpha(77)),
                    radarBackgroundColor: Colors.transparent,
                    radarShape: RadarShape.polygon,
                    dataSets: [
                      RadarDataSet(
                        dataEntries:
                            data.map((e) => RadarEntry(value: e)).toList(),
                        fillColor: AppColors.primary.withAlpha(51),
                        borderColor: AppColors.primary,
                        borderWidth: 2,
                        entryRadius: 5,
                      ),
                    ],
                    tickCount: 5,
                    ticksTextStyle: const TextStyle(
                      color: Colors.transparent,
                      fontSize: 10,
                    ),
                    titleTextStyle: const TextStyle(fontSize: 12),
                    titlePositionPercentageOffset: 0.18,
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 400),
                ),
              ),
            ),

            // Etiqueta derecha
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RotatedBox(
                  quarterTurns: 1,
                  child: Text('Tamaño',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),

        // Etiqueta inferior
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Criticidad',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  void _analyzeResults() {
    setState(() {
      _showResults = true;
      _result = AnalysisResult.calculate(
        id: 0, // Temporal
        name: _nameController.text.trim(),
        dimensions: _dimensions,
      );
    });
  }

  void _saveAnalysis() async {
    if (_result == null) return;

    try {
      final provider = Provider.of<AnalysisProvider>(context, listen: false);
      await provider.performAnalysis(
        name: _nameController.text.trim(),
        dimensions: _dimensions,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Análisis guardado correctamente'),
          backgroundColor: AppColors.success,
        ),
      );

      // Opcional: volver a la pantalla anterior
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el análisis: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}
