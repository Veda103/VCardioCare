class Prediction {
  final String id;
  final String userId;
  final String healthInputId;
  final double riskPercent;
  final String riskLabel;
  final double confidenceScore;
  final List<ShapFactor> shapFactors;
  final String wellnessMessage;
  final VitalSnapshot vitalSnapshot;
  final DateTime predictedAt;

  Prediction({
    required this.id,
    required this.userId,
    required this.healthInputId,
    required this.riskPercent,
    required this.riskLabel,
    required this.confidenceScore,
    required this.shapFactors,
    required this.wellnessMessage,
    required this.vitalSnapshot,
    required this.predictedAt,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      id: json['predictionId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      healthInputId: json['healthInputId'] as String? ?? '',
      riskPercent: (json['riskPercent'] as num?)?.toDouble() ?? 0.0,
      riskLabel: json['riskLabel'] as String? ?? 'unknown',
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      shapFactors: (json['shapFactors'] as List?)
              ?.map((f) => ShapFactor.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
      wellnessMessage: json['wellnessMessage'] as String? ?? '',
      vitalSnapshot: VitalSnapshot.fromJson(json['vitalSnapshot'] ?? {}),
      predictedAt: json['predictedAt'] != null
          ? DateTime.parse(json['predictedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'predictionId': id,
    'userId': userId,
    'healthInputId': healthInputId,
    'riskPercent': riskPercent,
    'riskLabel': riskLabel,
    'confidenceScore': confidenceScore,
    'shapFactors': shapFactors.map((f) => f.toJson()).toList(),
    'wellnessMessage': wellnessMessage,
    'vitalSnapshot': vitalSnapshot.toJson(),
    'predictedAt': predictedAt.toIso8601String(),
  };

  String get riskCategory {
    if (riskPercent < 30) return 'Low';
    if (riskPercent < 60) return 'Moderate';
    return 'Elevated';
  }
}

class ShapFactor {
  final String feature;
  final String displayName;
  final String icon;
  final double shapValue;
  final double impactPercent;
  final bool isModifiable;

  ShapFactor({
    required this.feature,
    required this.displayName,
    required this.icon,
    required this.shapValue,
    required this.impactPercent,
    required this.isModifiable,
  });

  factory ShapFactor.fromJson(Map<String, dynamic> json) {
    return ShapFactor(
      feature: json['feature'] as String? ?? '',
      displayName: json['displayName'] as String? ?? json['display_name'] as String? ?? '',
      icon: json['icon'] as String? ?? '📊',
      shapValue: (json['shapValue'] as num?)?.toDouble() ?? (json['shap_value'] as num?)?.toDouble() ?? 0.0,
      impactPercent: (json['impactPercent'] as num?)?.toDouble() ?? (json['impact_percent'] as num?)?.toDouble() ?? 0.0,
      isModifiable: json['isModifiable'] as bool? ?? json['is_modifiable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'feature': feature,
    'displayName': displayName,
    'icon': icon,
    'shapValue': shapValue,
    'impactPercent': impactPercent,
    'isModifiable': isModifiable,
  };
}

class VitalSnapshot {
  final double? systolicBP;
  final double? diastolicBP;
  final double? bmi;
  final double? cholesterol;

  VitalSnapshot({
    this.systolicBP,
    this.diastolicBP,
    this.bmi,
    this.cholesterol,
  });

  factory VitalSnapshot.fromJson(Map<String, dynamic> json) {
    return VitalSnapshot(
      systolicBP: (json['systolicBP'] as num?)?.toDouble(),
      diastolicBP: (json['diastolicBP'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      cholesterol: (json['cholesterol'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'systolicBP': systolicBP,
    'diastolicBP': diastolicBP,
    'bmi': bmi,
    'cholesterol': cholesterol,
  };
}
