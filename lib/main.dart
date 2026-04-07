import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/services/notification_service.dart';
import 'core/services/local_database.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/prediction_provider.dart';

// Screens
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/consent/consent_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/health_input/health_input_screen.dart';
import 'screens/report/risk_report_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // ── Init services ──
  await NotificationService.init();
  await LocalDatabase.db; // pre-open the database

  runApp(const VCardioCareApp());
}

class VCardioCareApp extends StatelessWidget {
  const VCardioCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<PredictionProvider>(
          create: (_) => PredictionProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'VCardioCare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash:        (_) => const SplashScreen(),
          AppRoutes.onboarding:    (_) => const OnboardingScreen(),
          AppRoutes.consent:       (_) => const ConsentScreen(),
          AppRoutes.dashboard:     (_) => const DashboardScreen(),
          AppRoutes.healthInput:   (_) => const HealthInputScreen(),
          AppRoutes.report:        (_) => const RiskReportScreen(),
          AppRoutes.history:       (_) => const HistoryScreen(),
          AppRoutes.notifications: (_) => const NotificationsScreen(),
          AppRoutes.profile:       (_) => const ProfileScreen(),
        },
      ),
    );
  }
}