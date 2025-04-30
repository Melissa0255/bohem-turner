import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/analysis_provider.dart';
import '../models/analysis_result.dart';
import '../utils/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final provider = Provider.of<AnalysisProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    await provider.loadAnalysisHistory();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Análisis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<AnalysisProvider>(
              builder: (context, provider, child) {
                final history = provider.analysisHistory;

                if (history.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off,
                          size: 80,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay análisis guardados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Realice un análisis y guárdelo para verlo aquí',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return _buildHistoryItem(context, history[index]);
                  },
                );
              },
            ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, AnalysisResult analysis) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final formattedDate = dateFormat.format(analysis.date);
    final isAgile = analysis.recommendedApproach == 'Enfoque Ágil';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showAnalysisDetails(analysis),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isAgile
                          ? AppColors.agile.withOpacity(0.1)
                          : AppColors.prescriptive.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isAgile ? Icons.auto_awesome : Icons.architecture,
                      color: isAgile ? AppColors.agile : AppColors.prescriptive,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          analysis.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      analysis.recommendedApproach.split(' ').last,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor:
                        isAgile ? AppColors.agile : AppColors.prescriptive,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildScoreIndicator(
                    'Ágil',
                    analysis.agileScore,
                    AppColors.agile,
                    isAgile,
                  ),
                  _buildScoreIndicator(
                    'Prescriptivo',
                    analysis.prescriptiveScore,
                    AppColors.prescriptive,
                    !isAgile,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreIndicator(
    String label,
    double score,
    Color color,
    bool isHighlighted,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isHighlighted
                ? Border.all(color: Colors.white, width: 2)
                : null,
            boxShadow: isHighlighted
                ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)]
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ${score.toStringAsFixed(1)}%',
          style: TextStyle(
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted ? color : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showAnalysisDetails(AnalysisResult analysis) {
    // Implementar vista detallada del análisis
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              analysis.recommendedApproach == 'Enfoque Ágil'
                  ? Icons.auto_awesome
                  : Icons.architecture,
              color: analysis.recommendedApproach == 'Enfoque Ágil'
                  ? AppColors.agile
                  : AppColors.prescriptive,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                analysis.name,
                style: const TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(analysis.date)}'),
              const SizedBox(height: 16),
              Text(
                'Enfoque recomendado: ${analysis.recommendedApproach}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: analysis.recommendedApproach == 'Enfoque Ágil'
                      ? AppColors.agile
                      : AppColors.prescriptive,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Dimensiones:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...analysis.dimensions.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_getDimensionLabel(e.key)),
                        Text(
                          e.value.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _confirmDeleteAnalysis(analysis);
            },
            child: const Text(
              'ELIMINAR',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('CERRAR'),
          ),
        ],
      ),
    );
  }

  String _getDimensionLabel(String key) {
    final Map<String, String> labels = {
      'personnel': 'Personal',
      'dynamism': 'Dinamismo',
      'culture': 'Cultura',
      'size': 'Tamaño',
      'criticality': 'Criticidad',
    };

    return labels[key] ?? key;
  }

  void _confirmDeleteAnalysis(AnalysisResult analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar análisis'),
        content: Text(
          '¿Está seguro que desea eliminar el análisis "${analysis.name}"?'
          '\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              Navigator.of(context).pop();

              final provider = Provider.of<AnalysisProvider>(
                context,
                listen: false,
              );

              await provider.deleteAnalysis(analysis.id);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Análisis eliminado'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text(
              'ELIMINAR',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
