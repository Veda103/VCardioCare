import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/storage_service.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade  = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<double>(begin: 30, end: 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    _decideRoute();
  }

  Future<void> _decideRoute() async {
    // Wait for animation + auth check
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final loggedIn = await auth.tryAutoLogin();

    if (!mounted) return;

    if (loggedIn) {
      // Has valid JWT → go straight to dashboard
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      final onboarded = await StorageService.isOnboardingDone();
      if (onboarded) {
        Navigator.pushReplacementNamed(context, AppRoutes.consent);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1C1A18), Color(0xFF3D2A24), AppColors.roseDeep],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) => Opacity(
              opacity: _fade.value,
              child: Transform.translate(
                  offset: Offset(0, _slide.value), child: child),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.roseSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(child: Text('❤️', style: TextStyle(fontSize: 34))),
                ),
                const SizedBox(height: 16),
                Text('VCardioCare', style: AppTextStyles.splashLogo),
                const SizedBox(height: 8),
                Text('Heart health awareness,\nguided with care.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.splashTagline),
                const Spacer(flex: 2),
                Text('checking your session...',
                    style: AppTextStyles.mono(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.3))),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}