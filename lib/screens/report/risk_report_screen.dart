import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/prediction_provider.dart';
import '../../widgets/common/app_widgets.dart';

class RiskReportScreen extends StatefulWidget {
  const RiskReportScreen({super.key});
  @override
  State<RiskReportScreen> createState() => _RiskReportScreenState();
}

class _RiskReportScreenState extends State<RiskReportScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final prediction = context.watch<PredictionProvider>().latestPrediction;

    if (prediction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Risk Report'), backgroundColor: AppColors.cream),
        body: const Center(child: Text('No prediction data yet.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(title: const Text('Your Risk Profile'), backgroundColor: AppColors.cream),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Dark header band ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF1C1A18), Color(0xFF3D2A24)]),
              borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('YOUR RISK PROFILE',
                  style: AppTextStyles.mono(fontSize: 10, color: Colors.white.withOpacity(0.4))),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Risk Score',
                        style: AppTextStyles.dmSans(fontSize: 10, color: Colors.white.withOpacity(0.5))),
                    RichText(text: TextSpan(children: [
                      TextSpan(text: '${prediction.riskPercent.toInt()}',
                          style: AppTextStyles.bigPercent),
                      TextSpan(text: '%',
                          style: AppTextStyles.dmSerif(fontSize: 18, color: Colors.white.withOpacity(0.5))),
                    ])),
                    const SizedBox(height: 6),
                    RiskBadge(riskPercent: prediction.riskPercent),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('Confidence',
                        style: AppTextStyles.mono(fontSize: 9, color: Colors.white.withOpacity(0.3))),
                    Text('${prediction.confidenceScore.toInt()}%',
                        style: AppTextStyles.dmSerif(fontSize: 20, color: Colors.white)),
                  ]),
                ]),
            ]),
          ),

          const SizedBox(height: 16),
          const SectionLabel(label: 'Top Risk Factors', padding: EdgeInsets.zero),
          const SizedBox(height: 8),

          // ── SHAP factors ──
          ...List.generate(prediction.shapFactors.length, (i) {
            final f = prediction.shapFactors[i];
            return AnimatedBuilder(animation: _ctrl, builder: (_, __) {
              final delay    = i * 0.12;
              final progress = ((_ctrl.value - delay) / (1 - delay)).clamp(0.0, 1.0);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(color: AppColors.cream,
                      border: Border.all(color: AppColors.border, width: 1.5),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    Text(f.icon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(f.displayName, style: AppTextStyles.dmSans(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      ClipRRect(borderRadius: BorderRadius.circular(2),
                        child: Stack(children: [
                          Container(height: 4, color: AppColors.border),
                          FractionallySizedBox(
                            widthFactor: (f.impactPercent / 100) * progress,
                            child: Container(height: 4,
                                color: f.isModifiable ? AppColors.coral : AppColors.muted)),
                        ])),
                    ])),
                    const SizedBox(width: 8),
                    Text('+${f.impactPercent.toStringAsFixed(1)}%',
                        style: AppTextStyles.mono(fontSize: 10,
                            color: f.isModifiable ? AppColors.coral : AppColors.muted)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: f.isModifiable
                            ? AppColors.lowGreen.withOpacity(0.12)
                            : AppColors.muted.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4)),
                      child: Text(f.isModifiable ? 'MOD' : 'FIXED',
                          style: AppTextStyles.mono(fontSize: 8, fontWeight: FontWeight.w600,
                              color: f.isModifiable ? AppColors.lowGreen : AppColors.muted)),
                    ),
                  ]),
                ),
              );
            });
          }),

          const SizedBox(height: 8),

          // ── Wellness message ──
          if (prediction.wellnessMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFFFFF8F0), Color(0xFFFAF0EC)]),
                border: Border.all(color: AppColors.roseSoft, width: 1.5),
                borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('💝', style: TextStyle(fontSize: 22)),
                const SizedBox(height: 8),
                Text(prediction.wellnessMessage,
                    style: AppTextStyles.dmSans(fontSize: 12, color: AppColors.inkLight)),
              ]),
            ),

          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}