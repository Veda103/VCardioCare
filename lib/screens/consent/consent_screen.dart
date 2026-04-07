import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/storage_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_widgets.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});
  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _check1 = false, _check2 = false, _check3 = false;
  bool get _allChecked => _check1 && _check2 && _check3;

  // ── Simple register form shown after consent ──
  bool _showRegister = false;
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  Future<void> _proceed() async {
    final ts = DateTime.now().toIso8601String();
    await StorageService.saveConsent(ts);
    setState(() => _showRegister = true);
  }

  Future<void> _register() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name:             _nameCtrl.text.trim(),
      email:            _emailCtrl.text.trim(),
      password:         _passCtrl.text.trim(),
      consentTimestamp: await StorageService.getConsent() ?? DateTime.now().toIso8601String(),
    );
    if (!mounted) return;
    if (success) {
      await StorageService.setOnboardingDone();
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Registration failed'),
          backgroundColor: AppColors.highRed,
        ),
      );
    }
  }

  Future<void> _goToLogin() async {
    // Simple login bottom sheet
    final emailC = TextEditingController();
    final passC  = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.warmWhite,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sign In', style: AppTextStyles.screenTitle),
            const SizedBox(height: 16),
            TextField(controller: emailC,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 10),
            TextField(controller: passC,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true),
            const SizedBox(height: 20),
            Consumer<AuthProvider>(
              builder: (ctx, auth, _) => PrimaryButton(
                label: 'Sign In',
                isLoading: auth.isLoading,
                onPressed: () async {
                  final ok = await auth.login(
                      email: emailC.text.trim(),
                      password: passC.text.trim());
                  if (!mounted) return;
                  if (ok) {
                    Navigator.pop(ctx);
                    Navigator.pushReplacementNamed(
                        context, AppRoutes.dashboard);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(auth.error ?? 'Login failed'),
                      backgroundColor: AppColors.highRed,
                    ));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _showRegister ? _buildRegisterForm() : _buildConsentForm(),
        ),
      ),
    );
  }

  Widget _buildConsentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text('Before We Begin', style: AppTextStyles.screenTitle),
        const SizedBox(height: 4),
        Text('Please read and agree to continue', style: AppTextStyles.caption),
        const SizedBox(height: 20),

        // Disclaimer box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F0),
            border: Border.all(color: AppColors.amber, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('⚠️  Medical Disclaimer',
                  style: AppTextStyles.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.amber)),
              const SizedBox(height: 8),
              Text(
                'VCardioCare is a health awareness tool, not a medical device. '
                'Risk scores are statistical estimates and should not be used '
                'for diagnosis or treatment. Always consult a healthcare professional.',
                style: AppTextStyles.dmSans(fontSize: 11, color: AppColors.inkLight),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        _ConsentItem(
          checked: _check1,
          text: 'I understand this app is for informational purposes only and is not a substitute for professional medical advice.',
          onChanged: (v) => setState(() => _check1 = v ?? false),
        ),
        _ConsentItem(
          checked: _check2,
          text: 'I consent to my health data being processed locally and on secure servers to generate a risk estimate.',
          onChanged: (v) => setState(() => _check2 = v ?? false),
        ),
        _ConsentItem(
          checked: _check3,
          text: 'I confirm I am 18 years of age or older.',
          onChanged: (v) => setState(() => _check3 = v ?? false),
        ),

        const SizedBox(height: 28),
        AnimatedOpacity(
          opacity: _allChecked ? 1.0 : 0.45,
          duration: const Duration(milliseconds: 200),
          child: PrimaryButton(
            label: 'I Agree — Continue →',
            onPressed: _allChecked ? _proceed : null,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: _goToLogin,
            child: Text('Already have an account? Sign in',
                style: AppTextStyles.dmSans(
                    fontSize: 12, color: AppColors.coral)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text('Create Account', style: AppTextStyles.screenTitle),
        const SizedBox(height: 4),
        Text('Your data is encrypted and private', style: AppTextStyles.caption),
        const SizedBox(height: 24),
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Full Name'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailCtrl,
          decoration: const InputDecoration(labelText: 'Email Address'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passCtrl,
          decoration: const InputDecoration(labelText: 'Password (min 6 chars)'),
          obscureText: true,
        ),
        const SizedBox(height: 28),
        Consumer<AuthProvider>(
          builder: (_, auth, __) => PrimaryButton(
            label: 'Create Account →',
            isLoading: auth.isLoading,
            onPressed: _register,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: () => setState(() => _showRegister = false),
            child: Text('← Back',
                style: AppTextStyles.dmSans(fontSize: 12, color: AppColors.muted)),
          ),
        ),
      ],
    );
  }
}

class _ConsentItem extends StatelessWidget {
  final bool checked;
  final String text;
  final ValueChanged<bool?> onChanged;
  const _ConsentItem({required this.checked, required this.text, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(value: checked, onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(text,
                  style: AppTextStyles.dmSans(fontSize: 12, color: AppColors.inkLight)),
            ),
          ),
        ],
      ),
    );
  }
}