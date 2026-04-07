class User {
  final String id;
  final String name;
  final String email;
  final DateTime memberSince;
  final int totalChecks;
  final UserSettings settings;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.memberSince,
    required this.totalChecks,
    required this.settings,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      memberSince: DateTime.parse(json['memberSince'] as String),
      totalChecks: json['totalChecks'] as int? ?? 0,
      settings: UserSettings.fromJson(json['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'memberSince': memberSince.toIso8601String(),
    'totalChecks': totalChecks,
    'settings': settings.toJson(),
  };
}

class UserSettings {
  final bool dataEncryption;
  final bool cloudBackup;
  final bool notifications;

  UserSettings({
    this.dataEncryption = true,
    this.cloudBackup = false,
    this.notifications = true,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      dataEncryption: json['dataEncryption'] as bool? ?? true,
      cloudBackup: json['cloudBackup'] as bool? ?? false,
      notifications: json['notifications'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'dataEncryption': dataEncryption,
    'cloudBackup': cloudBackup,
    'notifications': notifications,
  };
}
