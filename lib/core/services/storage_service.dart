import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _secureStorage = FlutterSecureStorage();

  // ── JWT Token Storage (Secure) ──
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'jwt_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'jwt_token');
  }

  // ── User Data (Shared Preferences) ──
  static Future<void> saveUser(String userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', userJson);
  }

  static Future<String?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_data');
  }

  static Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  // ── Consent Status ──
  static Future<void> saveConsent(String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('consent_timestamp', timestamp);
  }

  static Future<String?> getConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('consent_timestamp');
  }

  // ── Onboarding Flag ──
  static Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
  }

  static Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarded') ?? false;
  }

  // ── Logout (Clear sensitive data) ──
  static Future<void> logout() async {
    await deleteToken();
    await deleteUser();
    await deleteConsent();
  }

  static Future<void> deleteConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('consent_timestamp');
  }

  // ── Clear all local data ──
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secureStorage.deleteAll();
  }
}
