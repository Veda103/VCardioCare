import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

// ─────────────────────────────────────────────
// RISK BADGE — colored pill based on risk %
// ─────────────────────────────────────────────
class RiskBadge extends StatelessWidget {
  final double riskPercent;
  const RiskBadge({super.key, required this.riskPercent});

  String get _label {
    if (riskPercent < 30) return '● Low Risk';
    if (riskPercent < 60) return '● Moderate Risk';
    return '● Elevated Risk';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.riskBadgeBg(riskPercent),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: AppTextStyles.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.riskBadgeText(riskPercent),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PRIMARY BUTTON — coral full-width
// ─────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label, style: AppTextStyles.btnPrimary),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECONDARY BUTTON — outlined
// ─────────────────────────────────────────────
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const SecondaryButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(label, style: AppTextStyles.btnSecondary),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION LABEL — monospace uppercase label
// ─────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String label;
  final EdgeInsets? padding;

  const SectionLabel({super.key, required this.label, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.sectionLabel,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// QUICK ACTION CARD — used on dashboard 2x2 grid
// ─────────────────────────────────────────────
class QuickCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String? unit;
  final VoidCallback? onTap;

  const QuickCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cream,
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 2),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: AppTextStyles.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  if (unit != null)
                    TextSpan(
                      text: ' $unit',
                      style: AppTextStyles.caption,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CREAM CARD — generic content card
// ─────────────────────────────────────────────
class CreamCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;

  const CreamCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}