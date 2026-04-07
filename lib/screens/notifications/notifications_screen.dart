import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/common/app_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_Reminder> _reminders = [
    const _Reminder(
      emoji: '💧',
      title: 'Hydration Reminder',
      time: 'Every 2 hrs  ·  8:00 AM – 8:00 PM',
      body: '"Drink a glass of water, dear — staying hydrated keeps your heart happy."',
      bgColor: AppColors.waterBg,
      type: 'water',
    ),
    const _Reminder(
      emoji: '💊',
      title: 'Medication Reminder',
      time: 'Daily  ·  7:30 AM',
      body: '"Don\'t forget your morning medication. Consistency matters so much."',
      bgColor: AppColors.medBg,
      type: 'med',
    ),
    const _Reminder(
      emoji: '🚶',
      title: 'Movement Nudge',
      time: 'Daily  ·  5:30 PM',
      body: '"A short evening walk would do wonders for you today. Even 10 minutes counts."',
      bgColor: AppColors.lifeBg,
      type: 'life',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        title: const Text('Your Reminders'),
        backgroundColor: AppColors.cream,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Reminders', style: AppTextStyles.screenTitle),
            const SizedBox(height: 2),
            Text('Caring, gentle nudges', style: AppTextStyles.labelMono),
            const SizedBox(height: 16),

            const SectionLabel(label: 'Today', padding: EdgeInsets.zero),
            const SizedBox(height: 8),

            ...List.generate(_reminders.length, (i) {
              final reminder = _reminders[i];
              return Dismissible(
                key: Key(reminder.title),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.highRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: AppColors.highRed),
                ),
                onDismissed: (_) {
                  setState(() => _reminders.removeAt(i));
                },
                child: GestureDetector(
                  onTap: () => _editReminder(context, reminder),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ReminderCard(reminder: reminder),
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),
            const SectionLabel(
                label: 'Add New',
                padding: EdgeInsets.only(top: 8, bottom: 8)),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: Text('+ Schedule a Reminder',
                    style: AppTextStyles.btnPrimary),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _editReminder(BuildContext context, _Reminder reminder) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.warmWhite,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Reminder', style: AppTextStyles.screenTitle),
            const SizedBox(height: 16),
            Text(reminder.title,
                style:
                    AppTextStyles.dmSans(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(reminder.time, style: AppTextStyles.caption),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Save Changes', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

class _Reminder {
  final String emoji;
  final String title;
  final String time;
  final String body;
  final Color bgColor;
  final String type;

  const _Reminder({
    required this.emoji,
    required this.title,
    required this.time,
    required this.body,
    required this.bgColor,
    required this.type,
  });
}

class _ReminderCard extends StatelessWidget {
  final _Reminder reminder;
  const _ReminderCard({required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon box
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: reminder.bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(reminder.emoji,
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: AppTextStyles.dmSans(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(reminder.time, style: AppTextStyles.labelMono),
                const SizedBox(height: 4),
                Text(
                  reminder.body,
                  style: AppTextStyles.dmSans(
                      fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}