import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/espece.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    debugPrint('📁 Initialisation de la base de données');
    String path = join(await getDatabasesPath(), 'especes_database.db');
    debugPrint('📂 Chemin de la base de données: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        debugPrint('🔧 Création des tables de la base de données');
        await db.execute('''
          CREATE TABLE especes(
            id INTEGER PRIMARY KEY,
            nom TEXT NOT NULL,
            syncStatus TEXT DEFAULT 'pending'
          )
        ''');
        debugPrint('✅ Tables créées avec succès');
      },
    );
  }

  Future<void> insertEspece(Espece espece) async {
    debugPrint('💾 Tentative d\'insertion d\'une espèce: ${espece.toMap()}');
    final db = await database;
    try {
      await db.insert(
        'especes',
        espece.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('✅ Espèce insérée avec succès');
      
      // Vérification de l'insertion
      final List<Map<String, dynamic>> maps = await db.query(
        'especes',
        where: 'id = ?',
        whereArgs: [espece.id],
      );
      debugPrint('🔍 Vérification après insertion: ${maps.first}');
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'insertion: $e');
      rethrow;
    }
  }

  Future<List<Espece>> getPendingEspeces() async {
    debugPrint('🔍 Recherche des espèces en attente de synchronisation');
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'especes',
        where: 'syncStatus = ?',
        whereArgs: ['pending'],
      );
      
      debugPrint('📊 Nombre d\'espèces en attente trouvées: ${maps.length}');
      if (maps.isNotEmpty) {
        debugPrint('📋 Première espèce en attente: ${maps.first}');
      }
      
      return List.generate(maps.length, (i) => Espece.fromMap(maps[i]));
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des espèces en attente: $e');
      return [];
    }
  }

  Future<void> updateSyncStatus(int id, String status) async {
    debugPrint('🔄 Mise à jour du status de synchronisation pour l\'ID: $id à $status');
    final db = await database;
    try {
      await db.update(
        'especes',
        {'syncStatus': status},
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('✅ Statut mis à jour avec succès');
      
      // Vérification de la mise à jour
      final List<Map<String, dynamic>> maps = await db.query(
        'especes',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        debugPrint('🔍 Vérification après mise à jour: ${maps.first}');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour du statut: $e');
      rethrow;
    }
  }

  Future<void> deleteDatabase() async {
    debugPrint('🗑️ Suppression de la base de données');
    String path = join(await getDatabasesPath(), 'especes_database.db');
    try {
      await databaseFactory.deleteDatabase(path);
      debugPrint('✅ Base de données supprimée avec succès');
      _database = null;
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression de la base de données: $e');
      rethrow;
    }
  }
}