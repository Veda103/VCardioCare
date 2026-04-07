import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static Database? _db;

  // ── Open / create the database ──────────────────────────
  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vcardiocare.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Predictions table
        await db.execute('''
          CREATE TABLE predictions (
            id          TEXT PRIMARY KEY,
            risk_percent  REAL NOT NULL,
            risk_label    TEXT NOT NULL,
            confidence    REAL NOT NULL,
            systolic_bp   REAL,
            diastolic_bp  REAL,
            bmi           REAL,
            cholesterol   REAL,
            wellness_msg  TEXT,
            predicted_at  TEXT NOT NULL,
            shap_json     TEXT
          )
        ''');

        // Health inputs table (cache of last submitted inputs)
        await db.execute('''
          CREATE TABLE health_inputs (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            systolic_bp  REAL,
            diastolic_bp REAL,
            bmi          REAL,
            age          INTEGER,
            cholesterol  REAL,
            glucose      REAL,
            smoking      TEXT,
            stress       REAL,
            sleep        REAL,
            recorded_at  TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // ── Save a prediction locally ────────────────────────────
  static Future<void> savePrediction({
    required String id,
    required double riskPercent,
    required String riskLabel,
    required double confidence,
    required double systolicBP,
    required double diastolicBP,
    required double bmi,
    required double cholesterol,
    required String wellnessMessage,
    required String predictedAt,
    required String shapJson,
  }) async {
    final database = await db;
    await database.insert(
      'predictions',
      {
        'id':           id,
        'risk_percent': riskPercent,
        'risk_label':   riskLabel,
        'confidence':   confidence,
        'systolic_bp':  systolicBP,
        'diastolic_bp': diastolicBP,
        'bmi':          bmi,
        'cholesterol':  cholesterol,
        'wellness_msg': wellnessMessage,
        'predicted_at': predictedAt,
        'shap_json':    shapJson,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── Get all predictions (newest first) ───────────────────
  static Future<List<Map<String, dynamic>>> getPredictions({
    int limit = 50,
    int offset = 0,
  }) async {
    final database = await db;
    return await database.query(
      'predictions',
      orderBy: 'predicted_at DESC',
      limit: limit,
      offset: offset,
    );
  }

  // ── Get latest prediction ────────────────────────────────
  static Future<Map<String, dynamic>?> getLatestPrediction() async {
    final database = await db;
    final results = await database.query(
      'predictions',
      orderBy: 'predicted_at DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // ── Save last health input (auto-fill next time) ─────────
  static Future<void> saveHealthInput(Map<String, dynamic> input) async {
    final database = await db;
    await database.insert(
      'health_inputs',
      {
        'systolic_bp':  input['systolicBP'],
        'diastolic_bp': input['diastolicBP'],
        'bmi':          input['bmi'],
        'age':          input['age'],
        'cholesterol':  input['totalCholesterol'],
        'glucose':      input['fastingGlucose'],
        'smoking':      input['smokingStatus'],
        'stress':       input['stressLevel'],
        'sleep':        input['sleepHours'],
        'recorded_at':  DateTime.now().toIso8601String(),
      },
    );
  }

  // ── Get last health input for auto-fill ──────────────────
  static Future<Map<String, dynamic>?> getLastHealthInput() async {
    final database = await db;
    final results = await database.query(
      'health_inputs',
      orderBy: 'recorded_at DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // ── Delete all data (clear data action in profile) ───────
  static Future<void> clearAll() async {
    final database = await db;
    await database.delete('predictions');
    await database.delete('health_inputs');
  }

  // ── Close the database ───────────────────────────────────
  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
