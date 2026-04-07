import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/common/app_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardSlide> _slides = [
    const _OnboardSlide(
      emoji: '🫀',
      title: 'Know Your Heart Risk',
      subtitle:
          'Enter your health data and get a personalised cardiovascular risk score — powered by real clinical data patterns.',
      gradientColors: [AppColors.roseSoft, AppColors.sage],
    ),
    const _OnboardSlide(
      emoji: '📊',
      title: 'Understand What Matters',
      subtitle:
          'We show you exactly which factors influence your result — so you know where to focus your health efforts.',
      gradientColors: [AppColors.sage, AppColors.forest],
    ),
    const _OnboardSlide(
      emoji: '🔒',
      title: 'Your Data Stays Private',
      subtitle:
          'Your health information is encrypted on your device. We never share your data without your explicit consent.',
      gradientColors: [AppColors.roseSoft, AppColors.roseMid],
    ),
  ];

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.consent);
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, AppRoutes.consent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress dots ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: List.generate(
                  _slides.length,
                  (i) => Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i == _currentPage
                            ? AppColors.coral
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Page content ──
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // ── Illustration box ──
                        Container(
                          width: double.infinity,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: slide.gradientColors,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              slide.emoji,
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Title ──
                        Text(slide.title, style: AppTextStyles.screenTitle),
                        const SizedBox(height: 8),

                        // ── Subtitle ──
                        Text(
                          slide.subtitle,
                          style: AppTextStyles.dmSans(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Buttons ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                children: [
                  PrimaryButton(
                    label: _currentPage == _slides.length - 1
                        ? 'Get Started →'
                        : 'Continue →',
                    onPressed: _next,
                  ),
                  const SizedBox(height: 10),
                  SecondaryButton(label: 'Skip intro', onPressed: _skip),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardSlide {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;

  const _OnboardSlide({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
  });
}