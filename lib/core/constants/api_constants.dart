
class ApiConstants {
  // ── Base URLs (Update these with your server addresses) ──
  static const String backendUrl = "http://10.32.10.170:5000";
  static const String mlUrl = "http://10.32.10.170:8000";

  // ── Auth Endpoints ──
  static const String register = "/api/auth/register";
  static const String login = "/api/auth/login";
  static const String authMe = "/api/auth/me";

  // ── Health Input Endpoints ──
  static const String healthSubmit = "/api/health/submit";
  static const String healthHistory = "/api/health/history";
  static const String healthDelete = "/api/health/delete";

  // ── Prediction Endpoints ──
  static const String predictAnalyse = "/api/predictions/analyse";
  static const String predictionHistory = "/api/predictions/history";
  static const String predictionDetail = "/api/predictions/detail";

  // ── Profile Endpoints ──
  static const String profileSettings = "/api/profile/settings";
  static const String profileUpdate = "/api/profile";
  static const String clearData = "/api/profile/clear-data";
}