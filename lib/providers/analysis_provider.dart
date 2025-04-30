import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/analysis_result.dart';

class AnalysisProvider extends ChangeNotifier {
  List<AnalysisResult> _analysisHistory = [];
  Database? _database;
  
  List<AnalysisResult> get analysisHistory => _analysisHistory;
  
  // Inicializar base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'analyses.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE analyses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            date TEXT,
            dimensions TEXT,
            agileScore REAL,
            prescriptiveScore REAL,
            recommendedApproach TEXT
          )
        ''');
      },
    );
  }
  
  // Cargar historial de análisis
  Future<void> loadAnalysisHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('analyses');
    
    _analysisHistory = List.generate(maps.length, (i) {
      return AnalysisResult.fromMap(maps[i]);
    });
    
    // Ordenar por fecha (más reciente primero)
    _analysisHistory.sort((a, b) => b.date.compareTo(a.date));
    
    notifyListeners();
  }
  
  // Guardar un nuevo análisis
  Future<int> saveAnalysis(AnalysisResult result) async {
    final db = await database;
    final id = await db.insert('analyses', result.toMap());
    
    final newResult = result.copyWith(id: id);
    _analysisHistory.insert(0, newResult);
    
    notifyListeners();
    return id;
  }
  
  // Actualizar nombre de un análisis
  Future<void> updateAnalysisName(int id, String newName) async {
    final db = await database;
    await db.update(
      'analyses',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
    
    final index = _analysisHistory.indexWhere((analysis) => analysis.id == id);
    if (index != -1) {
      _analysisHistory[index] = _analysisHistory[index].copyWith(name: newName);
      notifyListeners();
    }
  }
  
  // Eliminar un análisis
  Future<void> deleteAnalysis(int id) async {
    final db = await database;
    await db.delete(
      'analyses',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    _analysisHistory.removeWhere((analysis) => analysis.id == id);
    notifyListeners();
  }
  
  // Método para realizar un nuevo análisis
  Future<AnalysisResult> performAnalysis({
    required String name,
    required Map<String, double> dimensions,
  }) async {
    // Obtener nuevo ID
    final db = await database;
    final maxIdResult = await db.rawQuery('SELECT MAX(id) as id FROM analyses');
    final newId = (maxIdResult.first['id'] as int? ?? 0) + 1;
    
    // Calcular resultado
    final result = AnalysisResult.calculate(
      id: newId,
      name: name,
      dimensions: dimensions,
    );
    
    // Guardar en base de datos
    await saveAnalysis(result);
    
    return result;
  }
}
