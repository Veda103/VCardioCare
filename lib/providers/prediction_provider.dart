import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../core/services/local_database.dart';
import '../models/prediction_model.dart';

// Alias for consistency
typedef HistoryItem = Prediction;

class PredictionProvider extends ChangeNotifier {
  Prediction?  _latestPrediction;
  List<Prediction> _history    = [];
  bool              _isLoading  = false;
  String?           _error;

  Prediction?  get latestPrediction => _latestPrediction;
  List<Prediction> get predictionHistory => _history;
  bool              get isLoading        => _isLoading;
  String?           get error            => _error;

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }
  void clearError() { _error = null; notifyListeners(); }

  // ── Submit health data to backend, returns healthInputId ─
  Future<String?> submitHealthData(Map<String, dynamic> healthData) async {
    _setLoading(true);
    _setError(null);
    try {
      // Also save locally for auto-fill next time
      await LocalDatabase.saveHealthInput(healthData);

      final data = await ApiService.post(
          ApiConstants.healthSubmit, data: healthData) as Map<String, dynamic>;
      _setLoading(false);
      return data['healthInputId'] as String?;
    } catch (e) {
      _setError(ApiService.parseError(e));
      _setLoading(false);
      return null;
    }
  }

  // ── Run ML prediction, save result to SQLite + Atlas ─────
  Future<Prediction?> runPrediction(String healthInputId) async {
    _setLoading(true);
    _setError(null);
    try {
      final data = await ApiService.post(
        ApiConstants.predictAnalyse,
        data: {'healthInputId': healthInputId},
      ) as Map<String, dynamic>;
      _latestPrediction = Prediction.fromJson(data['data'] as Map<String, dynamic>);

      // ── Save to local SQLite ──
      await LocalDatabase.savePrediction(
        id:             _latestPrediction!.id,
        riskPercent:    _latestPrediction!.riskPercent,
        riskLabel:      _latestPrediction!.riskLabel,
        confidence:     _latestPrediction!.confidenceScore,
        systolicBP:     _latestPrediction!.vitalSnapshot.systolicBP ?? 0,
        diastolicBP:    _latestPrediction!.vitalSnapshot.diastolicBP ?? 0,
        bmi:            _latestPrediction!.vitalSnapshot.bmi ?? 0,
        cholesterol:    _latestPrediction!.vitalSnapshot.cholesterol ?? 0,
        wellnessMessage: _latestPrediction!.wellnessMessage,
        predictedAt:    _latestPrediction!.predictedAt.toIso8601String(),
        shapJson:       jsonEncode(_latestPrediction!.shapFactors
            .map((f) => {
                  'feature':        f.feature,
                  'display_name':   f.displayName,
                  'icon':           f.icon,
                  'shap_value':     f.shapValue,
                  'impact_percent': f.impactPercent,
                  'is_modifiable':  f.isModifiable,
                })
            .toList()),
      );

      _setLoading(false);
      notifyListeners();
      return _latestPrediction;
    } catch (e) {
      _setError(ApiService.parseError(e));
      _setLoading(false);
      return null;
    }
  }

  // ── Combined submit + predict (called by health input screen) ──
  Future<Prediction?> submitAndPredict(
      Map<String, dynamic> healthData) async {
    final healthInputId = await submitHealthData(healthData);
    if (healthInputId == null) return null;
    return await runPrediction(healthInputId);
  }

  // ── Load latest prediction: SQLite first, then backend ───
  Future<void> fetchLatestPrediction() async {
    // 1. Load from SQLite immediately (fast, offline-safe)
    final local = await LocalDatabase.getLatestPrediction();
    if (local != null) {
      _latestPrediction = _predictionFromLocal(local);
      notifyListeners();
    }

    // 2. Try backend to get freshest data
    try {
      final data = await ApiService.get(
        '${ApiConstants.backendUrl}${ApiConstants.predictionHistory}?limit=1') as Map<String, dynamic>;
      final predictions = data['data'] as List?;
      if (predictions != null && predictions.isNotEmpty) {
        _latestPrediction = Prediction.fromJson(predictions.first as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (_) {
      // Silently stay on local data if offline
    }
  }

  // ── Fetch history: SQLite first, then backend ────────────
  Future<void> fetchHistory({String filter = '30d'}) async {
    _setLoading(true);
    _setError(null);

    // 1. Load from SQLite immediately
    final localRows = await LocalDatabase.getPredictions();
    if (localRows.isNotEmpty) {
      _history = localRows.map(_historyItemFromLocal).toList();
      _setLoading(false);
      notifyListeners();
    }

    // 2. Also fetch from backend to sync
    try {
      final data = await ApiService.get(
        ApiConstants.predictionHistory,
        queryParams: {'filter': filter},
      ) as Map<String, dynamic>;
      _history = (data['data'] as List)
          .map((e) => Prediction.fromJson(e as Map<String, dynamic>))
          .toList();
      _setLoading(false);
      notifyListeners();
    } catch (_) {
      // Already showing local data — just stop loading
      _setLoading(false);
    }
  }

  // ── Clear local data (called from profile clear-data) ────
  Future<void> clearLocalData() async {
    await LocalDatabase.clearAll();
    _latestPrediction = null;
    _history = [];
    notifyListeners();
  }

  // ── Helpers: convert SQLite rows to model objects ────────
  Prediction _predictionFromLocal(Map<String, dynamic> row) {
    List<ShapFactor> shaps = [];
    try {
      final decoded = jsonDecode(row['shap_json'] ?? '[]') as List;
      shaps = decoded
          .map((f) => ShapFactor.fromJson(f as Map<String, dynamic>))
          .toList();
    } catch (_) {}

    return Prediction(
      id:              row['id'] ?? '',
      userId:          '',
      healthInputId:   '',
      riskPercent:     (row['risk_percent'] ?? 0).toDouble(),
      riskLabel:       row['risk_label'] ?? 'low',
      confidenceScore: (row['confidence'] ?? 0).toDouble(),
      shapFactors:     shaps,
      wellnessMessage: row['wellness_msg'] ?? '',
      vitalSnapshot:   VitalSnapshot(
        systolicBP:  (row['systolic_bp']  ?? 0).toDouble(),
        diastolicBP: (row['diastolic_bp'] ?? 0).toDouble(),
        bmi:         (row['bmi']          ?? 0).toDouble(),
        cholesterol: (row['cholesterol']  ?? 0).toDouble(),
      ),
      predictedAt: DateTime.tryParse(row['predicted_at'] ?? '') ?? DateTime.now(),
    );
  }

  Prediction _historyItemFromLocal(Map<String, dynamic> row) {
    return Prediction(
      id:              row['id'] ?? '',
      userId:          '',
      healthInputId:   '',
      riskPercent:     (row['risk_percent'] ?? 0).toDouble(),
      riskLabel:       row['risk_label'] ?? 'low',
      confidenceScore: 0.0,
      shapFactors:     [],
      wellnessMessage: '',
      vitalSnapshot:   VitalSnapshot(
        systolicBP:  (row['systolic_bp']  ?? 0).toDouble(),
        diastolicBP: (row['diastolic_bp'] ?? 0).toDouble(),
        bmi:         (row['bmi']          ?? 0).toDouble(),
        cholesterol: (row['cholesterol']  ?? 0).toDouble(),
      ),
      predictedAt: DateTime.tryParse(row['predicted_at'] ?? '') ?? DateTime.now(),
    );
  }
}