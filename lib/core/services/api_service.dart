import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.backendUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // ── Initialize with token (call on app startup if token exists) ──
  static Future<void> init() async {
    final token = await StorageService.getToken();
    if (token != null) {
      setAuthToken(token);
    }
  }

  // ── Set Auth Bearer Token ──
  static void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // ── Clear Auth Token ──
  static void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // ── POST ──
  static Future<dynamic> post(
    String endpoint, {
    required dynamic data,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── GET ──
  static Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── PATCH ──
  static Future<dynamic> patch(
    String endpoint, {
    required dynamic data,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── DELETE ──
  static Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Error Handler ──
  static String parseError(dynamic error) {
    if (error is String) return error;
    if (error is Exception) {
      if (error is DioException) {
        if (error.response?.data is Map) {
          final data = error.response!.data as Map;
          return data['message'] ?? error.message ?? 'Request failed';
        }
        return error.message ?? 'Request failed';
      }
      return error.toString();
    }
    return 'An unknown error occurred';
  }

  static dynamic _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      if (data is Map && data.containsKey('message')) {
        return Exception(data['message']);
      }

      switch (statusCode) {
        case 400:
          return Exception('Bad request. Please check your input.');
        case 401:
          return Exception('Unauthorized. Please log in again.');
        case 403:
          return Exception('Access denied.');
        case 404:
          return Exception('Resource not found.');
        case 500:
          return Exception('Server error. Please try again later.');
        default:
          return Exception('Error: $statusCode');
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please check your internet.');
    }

    return Exception(e.message ?? 'An error occurred');
  }
}
