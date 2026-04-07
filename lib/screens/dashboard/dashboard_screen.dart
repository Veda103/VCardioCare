import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/prediction_provider.dart';
import '../../widgets/common/app_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch user data on dashboard load
    Future.microtask(() {
      context.read<AuthProvider>().fetchMe();
      context.read<PredictionProvider>().fetchLatestPrediction();
      context.read<PredictionProvider>().fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final predictions = context.watch<PredictionProvider>().predictionHistory;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.cream,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                child: CircleAvatar(
                  backgroundColor: AppColors.coral,
                  child: Text(
                    user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.roseSoft, AppColors.roseMid],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back,', style: AppTextStyles.body),
                  Text(user?.name ?? 'User', style: AppTextStyles.screenTitle),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: '+ New Health Check',
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.healthInput),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick stats
            Text('Your Activity', style: AppTextStyles.dmSerif(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatCard(
                  label: 'Health Checks',
                  value: (user?.totalChecks ?? 0).toString(),
                  icon: '📊',
                ),
                const SizedBox(width: 8),
                _StatCard(
                  label: 'Last Check',
                  value: predictions.isNotEmpty ? 
                    predictions.first.riskCategory : 'None',
                  icon: '❤️',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent predictions
            Text('Recent Predictions', style: AppTextStyles.dmSerif(fontSize: 16)),
            const SizedBox(height: 8),
            if (predictions.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'No predictions yet. Start with a health check!',
                    style: AppTextStyles.caption,
                  ),
                ),
              )
            else
              ...predictions.take(3).map(
                (pred) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.report,
                        arguments: pred),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warmWhite,
                        border: Border.all(color: AppColors.border, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Risk Level: ${pred.riskCategory}',
                                  style: AppTextStyles.dmSans(
                                      fontSize: 12, fontWeight: FontWeight.w600)),
                              Text('${pred.riskPercent}% risk',
                                  style: AppTextStyles.caption),
                            ],
                          ),
                          Icon(
                            pred.riskPercent < 30
                                ? Icons.check_circle
                                : pred.riskPercent < 60
                                    ? Icons.info
                                    : Icons.warning,
                            color: pred.riskPercent < 30
                                ? Colors.green
                                : pred.riskPercent < 60
                                    ? AppColors.amber
                                    : AppColors.highRed,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          border: Border.all(color: AppColors.border, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(value,
                style: AppTextStyles.dmSans(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}