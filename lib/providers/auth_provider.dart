import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  // ── Getters ──
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _token != null && _user != null;

  // ── Try auto login (on app startup) ──
  Future<bool> tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await StorageService.getToken();
      final userJson = await StorageService.getUser();

      if (token != null && userJson != null) {
        _token = token;
        _user = User.fromJson(jsonDecode(userJson));
        ApiService.setAuthToken(token);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Auto-login failed: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Register ──
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String consentTimestamp,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔍 Registration attempt - Calling /api/auth/register');
      print('📦 Payload: {name: $name, email: $email, consentTimestamp: $consentTimestamp}');
      
      final response = await ApiService.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'consentTimestamp': consentTimestamp,
        },
      );

      print('📥 Registration response: $response');

      if (response is Map && response['success'] == true) {
        _token = response['token'];
        _user = User.fromJson(response['user']);

        await StorageService.saveToken(_token!);
        await StorageService.saveUser(jsonEncode(_user!.toJson()));
        ApiService.setAuthToken(_token!);

        _isLoading = false;
        notifyListeners();
        print('✅ Registration successful');
        return true;
      } else if (response is Map) {
        // Registration failed with server response
        final errors = response['errors'];
        if (errors is List && errors.isNotEmpty) {
          _error = errors.first ?? response['message'] ?? 'Registration failed';
        } else {
          _error = response['message'] ?? 'Registration failed';
        }
        print('❌ Registration failed: $_error');
      } else {
        _error = 'Unexpected response format';
        print('❌ Unexpected response: $response');
      }
    } catch (e) {
      _error = ApiService.parseError(e);
      print('❌ Registration exception: $_error');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Login ──
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response['success'] == true) {
        _token = response['token'];
        _user = User.fromJson(response['user']);

        await StorageService.saveToken(_token!);
        await StorageService.saveUser(jsonEncode(_user!.toJson()));
        ApiService.setAuthToken(_token!);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
      }
    } catch (e) {
      _error = 'Login error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Logout ──
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await StorageService.logout();
      _user = null;
      _token = null;
      _error = null;
      ApiService.clearAuthToken();
    } catch (e) {
      _error = 'Logout failed: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Fetch current user ──
  Future<bool> fetchMe() async {
    if (_token == null) return false;

    try {
      final response = await ApiService.get(ApiConstants.authMe);
      if (response['success'] == true) {
        _user = User.fromJson(response['user']);
        await StorageService.saveUser(jsonEncode(_user!.toJson()));
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to fetch user: $e';
    }

    return false;
  }

  // ── Update profile ──
  Future<bool> updateProfile({
    String? name,
    String? email,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;

      final response = await ApiService.patch(
        ApiConstants.profileUpdate,
        data: data,
      );

      if (response['success'] == true) {
        _user = User.fromJson(response['data'] as Map<String, dynamic>);
        await StorageService.saveUser(jsonEncode(_user!.toJson()));
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Update failed';
      }
    } catch (e) {
      _error = ApiService.parseError(e);
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Clear error ──
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
