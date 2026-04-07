import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _dataEncryption = true;
  bool _cloudBackup = false;
  bool _notifications = true;

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.warmWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Profile', style: AppTextStyles.screenTitle),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppTextStyles.dmSans(
                    fontSize: 13, color: AppColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coral,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final auth = context.read<AuthProvider>();
              auth.updateProfile(
                name: nameCtrl.text.isNotEmpty ? nameCtrl.text : null,
                email: emailCtrl.text.isNotEmpty ? emailCtrl.text : null,
              );
              Navigator.pop(context);
            },
            child: Text('Save', style: AppTextStyles.btnPrimary),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.warmWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Clear All Data?', style: AppTextStyles.screenTitle),
        content: Text(
          'This will permanently delete all your health records, predictions, and account data from this device. This cannot be undone.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppTextStyles.dmSans(
                    fontSize: 13, color: AppColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.highRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              // TODO: implement clear data
            },
            child: Text('Clear Everything', style: AppTextStyles.btnPrimary),
          ),
        ],
      ),
    );
  }

  void _showDisclaimerDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.warmWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Medical Disclaimer', style: AppTextStyles.screenTitle),
        content: SingleChildScrollView(
          child: Text(
            'VCardioCare is a health awareness tool, not a medical device. '
            'Risk scores are statistical estimates based on population data.\n\n'
            'These results are not a diagnosis. Always consult a qualified '
            'healthcare professional for medical advice, diagnosis, or treatment.',
            style: AppTextStyles.body,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('I Understand', style: AppTextStyles.btnPrimary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.cream,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar row ──
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.roseSoft, AppColors.sage],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('👩', style: TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sara Ahmed', style: AppTextStyles.screenTitle),
                    const SizedBox(height: 2),
                    Text(
                      'Member since Feb 2026  ·  6 checks',
                      style: AppTextStyles.labelMono,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Account section ──
            const SectionLabel(label: 'Account', padding: EdgeInsets.zero),
            _SettingRow(
              icon: '👤',
              label: 'Edit Profile',
              trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
              onTap: _showEditProfileDialog,
            ),
            _SettingRow(
              icon: '🔒',
              label: 'Change Password',
              trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
              onTap: () {},
            ),

            const SizedBox(height: 12),

            // ── Privacy & Data section ──
            const SectionLabel(
                label: 'Privacy & Data', padding: EdgeInsets.only(bottom: 0)),
            _SettingRow(
              icon: '🔐',
              label: 'Data Encryption',
              trailing: Switch(
                value: _dataEncryption,
                onChanged: (v) => setState(() => _dataEncryption = v),
                activeThumbColor: AppColors.coral,
              ),
            ),
            _SettingRow(
              icon: '☁️',
              label: 'Backup to Cloud',
              trailing: Switch(
                value: _cloudBackup,
                onChanged: (v) => setState(() => _cloudBackup = v),
                activeThumbColor: AppColors.coral,
              ),
            ),
            _SettingRow(
              icon: '🗑️',
              label: 'Clear All My Data',
              trailing: const Icon(Icons.chevron_right, color: AppColors.coral),
              onTap: _showClearDataDialog,
              labelColor: AppColors.coral,
            ),

            const SizedBox(height: 12),

            // ── App section ──
            const SectionLabel(label: 'App', padding: EdgeInsets.only(bottom: 0)),
            _SettingRow(
              icon: '🔔',
              label: 'Notifications',
              trailing: Switch(
                value: _notifications,
                onChanged: (v) => setState(() => _notifications = v),
                activeThumbColor: AppColors.coral,
              ),
            ),
            _SettingRow(
              icon: '📄',
              label: 'Medical Disclaimer',
              trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
              onTap: _showDisclaimerDialog,
            ),
            _SettingRow(
              icon: '🚪',
              label: 'Sign Out',
              trailing: const Icon(Icons.chevron_right, color: AppColors.coral),
              labelColor: AppColors.coral,
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.splash,
                  (route) => false,
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;
  final Color? labelColor;

  const _SettingRow({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.dmSans(
                  fontSize: 13,
                  color: labelColor ?? AppColors.inkLight,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}