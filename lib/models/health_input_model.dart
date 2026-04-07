class HealthInput {
  final String id;
  final String userId;
  final double systolicBP;
  final double diastolicBP;
  final double bmi;
  final int age;
  final double? heartRate;
  final double totalCholesterol;
  final double fastingGlucose;
  final double? hdlCholesterol;
  final double? ldlCholesterol;
  final double? triglycerides;
  final String smokingStatus;
  final double? sleepHours;
  final double? stressLevel;
  final String physicalActivity;
  final bool hasDiabetes;
  final bool hasFamilyHistory;
  final bool hasHypertension;
  final DateTime recordedAt;

  HealthInput({
    required this.id,
    required this.userId,
    required this.systolicBP,
    required this.diastolicBP,
    required this.bmi,
    required this.age,
    this.heartRate,
    required this.totalCholesterol,
    required this.fastingGlucose,
    this.hdlCholesterol,
    this.ldlCholesterol,
    this.triglycerides,
    required this.smokingStatus,
    this.sleepHours,
    this.stressLevel,
    required this.physicalActivity,
    this.hasDiabetes = false,
    this.hasFamilyHistory = false,
    this.hasHypertension = false,
    required this.recordedAt,
  });

  factory HealthInput.fromJson(Map<String, dynamic> json) {
    return HealthInput(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      systolicBP: (json['systolicBP'] as num?)?.toDouble() ?? 0.0,
      diastolicBP: (json['diastolicBP'] as num?)?.toDouble() ?? 0.0,
      bmi: (json['bmi'] as num?)?.toDouble() ?? 0.0,
      age: json['age'] as int? ?? 0,
      heartRate: (json['heartRate'] as num?)?.toDouble(),
      totalCholesterol: (json['totalCholesterol'] as num?)?.toDouble() ?? 0.0,
      fastingGlucose: (json['fastingGlucose'] as num?)?.toDouble() ?? 0.0,
      hdlCholesterol: (json['hdlCholesterol'] as num?)?.toDouble(),
      ldlCholesterol: (json['ldlCholesterol'] as num?)?.toDouble(),
      triglycerides: (json['triglycerides'] as num?)?.toDouble(),
      smokingStatus: json['smokingStatus'] as String? ?? 'non-smoker',
      sleepHours: (json['sleepHours'] as num?)?.toDouble(),
      stressLevel: (json['stressLevel'] as num?)?.toDouble(),
      physicalActivity: json['physicalActivity'] as String? ?? 'moderate',
      hasDiabetes: json['hasDiabetes'] as bool? ?? false,
      hasFamilyHistory: json['hasFamilyHistory'] as bool? ?? false,
      hasHypertension: json['hasHypertension'] as bool? ?? false,
      recordedAt: json['recordedAt'] != null
          ? DateTime.parse(json['recordedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'systolicBP': systolicBP,
    'diastolicBP': diastolicBP,
    'bmi': bmi,
    'age': age,
    'heartRate': heartRate,
    'totalCholesterol': totalCholesterol,
    'fastingGlucose': fastingGlucose,
    'hdlCholesterol': hdlCholesterol,
    'ldlCholesterol': ldlCholesterol,
    'triglycerides': triglycerides,
    'smokingStatus': smokingStatus,
    'sleepHours': sleepHours,
    'stressLevel': stressLevel,
    'physicalActivity': physicalActivity,
    'hasDiabetes': hasDiabetes,
    'hasFamilyHistory': hasFamilyHistory,
    'hasHypertension': hasHypertension,
    'recordedAt': recordedAt.toIso8601String(),
  };
}
