// database.dart

import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'meal_plan_page.dart';

class MealPlanDatabase {
  static const String tableName = 'meal_plans';
  static const String columnId = 'id';
  static const String columnDate = 'date';
  static const String columnTargetCalories = 'target_calories';
  static const String columnItems = 'items';

  static final MealPlanDatabase _instance = MealPlanDatabase._internal();

  factory MealPlanDatabase() => _instance;

  MealPlanDatabase._internal() {
    _initDatabase();
  }

  Database? _database;

  Future<void> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'meal_plan_database.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnDate TEXT,
            $columnTargetCalories INTEGER,
            $columnItems TEXT
          )
        ''');
      },
    );
  }

  Future<Database> get database async {
    if (_database == null || !_database!.isOpen) {
      await _initDatabase();
    }
    return _database!;
  }

  Future<void> saveMealPlan(MealPlanRecord mealPlan) async {
    Database db = await database;
    await db.insert(
      tableName,
      mealPlan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MealPlanRecord?> getMealPlan(String formattedDate) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnDate = ?',
      whereArgs: [formattedDate],
    );

    if (maps.isEmpty) {
      return null;
    }

    return MealPlanRecord.fromMap(maps.first);
  }
}

