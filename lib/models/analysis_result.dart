import 'dart:convert';

class AnalysisResult {
  final int id;
  final String name;
  final DateTime date;
  final Map<String, double> dimensions;
  final double agileScore;
  final double prescriptiveScore;
  final String recommendedApproach;

  AnalysisResult({
    required this.id,
    required this.name,
    required this.date,
    required this.dimensions,
    required this.agileScore,
    required this.prescriptiveScore,
    required this.recommendedApproach,
  });

  // Constructor de copia con nombre opcional
  AnalysisResult copyWith({
    int? id,
    String? name,
    DateTime? date,
    Map<String, double>? dimensions,
    double? agileScore,
    double? prescriptiveScore,
    String? recommendedApproach,
  }) {
    return AnalysisResult(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      dimensions: dimensions ?? this.dimensions,
      agileScore: agileScore ?? this.agileScore,
      prescriptiveScore: prescriptiveScore ?? this.prescriptiveScore,
      recommendedApproach: recommendedApproach ?? this.recommendedApproach,
    );
  }

  // Convertir a Map para almacenamiento
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'dimensions': jsonEncode(dimensions),
      'agileScore': agileScore,
      'prescriptiveScore': prescriptiveScore,
      'recommendedApproach': recommendedApproach,
    };
  }

  // Crear desde Map para recuperación
  factory AnalysisResult.fromMap(Map<String, dynamic> map) {
    return AnalysisResult(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      dimensions: Map<String, double>.from(
        jsonDecode(map['dimensions']).map((k, v) => MapEntry(k, v.toDouble()))
      ),
      agileScore: map['agileScore'],
      prescriptiveScore: map['prescriptiveScore'],
      recommendedApproach: map['recommendedApproach'],
    );
  }

  // Método para calcular el resultado de un análisis
  static AnalysisResult calculate({
    required int id,
    required String name,
    required Map<String, double> dimensions,
  }) {
    // Calcular puntajes ágil y prescriptivo
    double agileScore = 0;
    double prescriptiveScore = 0;
    
    dimensions.forEach((dim, value) {
      // Convertir escala 1-5 a 0-1 para ágil (invertido)
      final agileValue = (6 - value) / 4;  // 5 -> 0.25, 1 -> 1.25
      // Convertir escala 1-5 a 0-1 para prescriptivo
      final prescriptiveValue = value / 5;  // 1 -> 0.2, 5 -> 1
      
      agileScore += agileValue;
      prescriptiveScore += prescriptiveValue;
    });
    
    // Normalizar puntajes a 0-100%
    agileScore = (agileScore / dimensions.length) * 100;
    prescriptiveScore = (prescriptiveScore / dimensions.length) * 100;
    
    // Determinar enfoque recomendado
    final recommendedApproach = agileScore > prescriptiveScore 
      ? 'Enfoque Ágil' 
      : 'Enfoque Prescriptivo';
    
    return AnalysisResult(
      id: id,
      name: name,
      date: DateTime.now(),
      dimensions: dimensions,
      agileScore: agileScore,
      prescriptiveScore: prescriptiveScore,
      recommendedApproach: recommendedApproach,
    );
  }
}
