import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/local_database.dart';
import '../../providers/prediction_provider.dart';
import '../../widgets/common/app_widgets.dart';

class HealthInputScreen extends StatefulWidget {
  const HealthInputScreen({super.key});
  @override
  State<HealthInputScreen> createState() => _HealthInputScreenState();
}

class _HealthInputScreenState extends State<HealthInputScreen> {
  final _systolicCtrl  = TextEditingController();
  final _diastolicCtrl = TextEditingController();
  final _bmiCtrl       = TextEditingController();
  final _ageCtrl       = TextEditingController();
  final _cholCtrl      = TextEditingController();
  final _glucoseCtrl   = TextEditingController();
  final _ldlCtrl       = TextEditingController();
  final _hdlCtrl       = TextEditingController();
  final _sleepCtrl     = TextEditingController();
  final _stressCtrl    = TextEditingController();

  int  _smokingIndex  = 0;
  int  _activityIndex = 2;
  bool _hasDiabetes      = false;
  bool _hasFamilyHistory = false;
  bool _hasHypertension  = false;
  bool _isObese          = false;
  bool _autoFilled       = false;

  String? _systolicError, _diastolicError;

  final _smokeOptions    = ['Non-smoker', 'Former', 'Smoker'];
  final _activityOptions = ['Sedentary', 'Light', 'Moderate', 'Active'];

  @override
  void initState() {
    super.initState();
    _loadLastValues();
  }

  // ── Auto-fill from last SQLite entry ────────────────────
  Future<void> _loadLastValues() async {
    final last = await LocalDatabase.getLastHealthInput();
    if (last == null) {
      // First time — set sensible defaults
      _systolicCtrl.text  = '118';
      _diastolicCtrl.text = '76';
      _bmiCtrl.text       = '23.4';
      _ageCtrl.text       = '35';
      _cholCtrl.text      = '180';
      _glucoseCtrl.text   = '90';
      _ldlCtrl.text       = '100';
      _hdlCtrl.text       = '50';
      _sleepCtrl.text     = '7';
      _stressCtrl.text    = '3';
      return;
    }

    setState(() {
      _systolicCtrl.text  = (last['systolic_bp']  ?? 118).toString();
      _diastolicCtrl.text = (last['diastolic_bp'] ?? 76).toString();
      _bmiCtrl.text       = (last['bmi']          ?? 23.4).toString();
      _ageCtrl.text       = (last['age']           ?? 35).toString();
      _cholCtrl.text      = (last['cholesterol']   ?? 180).toString();
      _glucoseCtrl.text   = (last['glucose']       ?? 90).toString();
      _sleepCtrl.text     = (last['sleep']         ?? 7).toString();
      _stressCtrl.text    = (last['stress']        ?? 3).toString();

      final smoking = last['smoking'] ?? 'non-smoker';
      _smokingIndex = ['non-smoker','former','smoker'].indexOf(smoking).clamp(0, 2);
      _autoFilled = true;
    });
  }

  void _validate() {
    setState(() {
      final sys = double.tryParse(_systolicCtrl.text) ?? 0;
      _systolicError = (sys < 70 || sys > 200) ? 'Range: 70–200' : null;
      final dia = double.tryParse(_diastolicCtrl.text) ?? 0;
      _diastolicError = (dia < 40 || dia > 130) ? 'Range: 40–130' : null;
    });
  }

  Future<void> _analyse() async {
    _validate();
    if (_systolicError != null || _diastolicError != null) return;

    final smokingMap = ['non-smoker', 'former', 'smoker'];
    final activityMap = ['sedentary', 'light', 'moderate', 'active'];

    final payload = {
      'systolicBP':       double.tryParse(_systolicCtrl.text)  ?? 118,
      'diastolicBP':      double.tryParse(_diastolicCtrl.text) ?? 76,
      'bmi':              double.tryParse(_bmiCtrl.text)        ?? 23.4,
      'age':              int.tryParse(_ageCtrl.text)           ?? 35,
      'totalCholesterol': double.tryParse(_cholCtrl.text)       ?? 180,
      'fastingGlucose':   double.tryParse(_glucoseCtrl.text)    ?? 90,
      'ldlCholesterol':   double.tryParse(_ldlCtrl.text),
      'hdlCholesterol':   double.tryParse(_hdlCtrl.text),
      'smokingStatus':    smokingMap[_smokingIndex],
      'sleepHours':       double.tryParse(_sleepCtrl.text),
      'stressLevel':      double.tryParse(_stressCtrl.text),
      'physicalActivity': activityMap[_activityIndex],
      'hasDiabetes':      _hasDiabetes,
      'hasFamilyHistory': _hasFamilyHistory,
      'hasHypertension':  _hasHypertension,
      'obesity':          _isObese,
    };

    final provider = context.read<PredictionProvider>();
    final result   = await provider.submitAndPredict(payload);

    if (!mounted) return;
    if (result != null) {
      Navigator.pushNamed(context, AppRoutes.report);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(provider.error ?? 'Prediction failed. Please try again.'),
        backgroundColor: AppColors.highRed,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<PredictionProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        title: const Text('Health Check'),
        backgroundColor: AppColors.cream,
      ),
      body: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Health Check', style: AppTextStyles.screenTitle),
              const SizedBox(height: 2),
              Row(children: [
                Text('All fields · Timestamped', style: AppTextStyles.labelMono),
                if (_autoFilled) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.forest.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8)),
                    child: Text('Auto-filled from last entry',
                        style: AppTextStyles.mono(fontSize: 9, color: AppColors.forest)),
                  ),
                ],
              ]),
              const SizedBox(height: 16),

              // ── VITALS ──
              const SectionLabel(label: '🫀  Vitals'),
              Row(children: [
                Expanded(child: _InputField(label: 'Systolic BP', unit: 'mmHg',
                    controller: _systolicCtrl, error: _systolicError, isFocused: true)),
                const SizedBox(width: 8),
                Expanded(child: _InputField(label: 'Diastolic BP', unit: 'mmHg',
                    controller: _diastolicCtrl, error: _diastolicError)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _InputField(label: 'BMI', controller: _bmiCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                const SizedBox(width: 8),
                Expanded(child: _InputField(label: 'Age', unit: 'yrs',
                    controller: _ageCtrl, keyboardType: TextInputType.number)),
              ]),

              // ── BLOOD WORK ──
              const SectionLabel(label: '🩸  Blood Work'),
              _FullRow(label: 'Total Cholesterol', unit: 'mg/dL', controller: _cholCtrl),
              const SizedBox(height: 8),
              _FullRow(label: 'Fasting Glucose', unit: 'mg/dL', controller: _glucoseCtrl),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _InputField(label: 'LDL', unit: 'mg/dL', controller: _ldlCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                const SizedBox(width: 8),
                Expanded(child: _InputField(label: 'HDL', unit: 'mg/dL', controller: _hdlCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true))),
              ]),

              // ── LIFESTYLE ──
              const SectionLabel(label: '🌿  Lifestyle'),
              _ToggleRow(options: _smokeOptions, selected: _smokingIndex,
                  onSelect: (i) => setState(() => _smokingIndex = i)),
              const SizedBox(height: 8),
              _ToggleRow(options: _activityOptions, selected: _activityIndex,
                  onSelect: (i) => setState(() => _activityIndex = i)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _InputField(label: 'Sleep', unit: 'hrs',
                    controller: _sleepCtrl, keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(child: _InputField(label: 'Stress', unit: '/10',
                    controller: _stressCtrl, keyboardType: TextInputType.number)),
              ]),

              // ── MEDICAL HISTORY ──
              const SectionLabel(label: '🏥  Medical History'),
              _BoolRow(label: 'Diabetes', value: _hasDiabetes,
                  onChanged: (v) => setState(() => _hasDiabetes = v)),
              _BoolRow(label: 'Hypertension', value: _hasHypertension,
                  onChanged: (v) => setState(() => _hasHypertension = v)),
              _BoolRow(label: 'Family History of Heart Disease', value: _hasFamilyHistory,
                  onChanged: (v) => setState(() => _hasFamilyHistory = v)),
              _BoolRow(label: 'Obesity', value: _isObese,
                  onChanged: (v) => setState(() => _isObese = v)),

              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Analyse My Risk →',
                onPressed: _analyse,
                isLoading: isLoading,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),

        // Loading overlay
        if (isLoading)
          Container(
            color: AppColors.ink.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.warmWhite,
                  borderRadius: BorderRadius.circular(20)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const CircularProgressIndicator(color: AppColors.coral, strokeWidth: 3),
                  const SizedBox(height: 16),
                  Text('Analysing your data...', style: AppTextStyles.body),
                  const SizedBox(height: 4),
                  Text('Contacting ML model...', style: AppTextStyles.caption),
                ]),
              ),
            ),
          ),
      ]),
    );
  }
}

// ── Reusable widgets ─────────────────────────────────────

class _InputField extends StatelessWidget {
  final String label;
  final String? unit, error;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isFocused;

  const _InputField({
    required this.label,
    required this.controller,
    this.unit,
    this.error,
    this.keyboardType = TextInputType.number,
    this.isFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: AppColors.cream,
          border: Border.all(
            color: error != null ? AppColors.highRed
                : isFocused ? AppColors.coral : AppColors.border,
            width: 1.5),
          borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTextStyles.mono(fontSize: 9)),
          const SizedBox(height: 2),
          Row(children: [
            Expanded(child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: AppTextStyles.dmSans(
                  fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
              decoration: const InputDecoration(
                isDense: true, contentPadding: EdgeInsets.zero,
                border: InputBorder.none, filled: false))),
            if (unit != null) Text(unit!, style: AppTextStyles.mono(fontSize: 9)),
          ]),
        ]),
      ),
      if (error != null) ...[
        const SizedBox(height: 4),
        Text(error!, style: AppTextStyles.dmSans(fontSize: 10, color: AppColors.highRed)),
      ],
    ]);
  }
}

class _FullRow extends StatelessWidget {
  final String label, unit;
  final TextEditingController controller;

  const _FullRow({required this.label, required this.unit, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cream,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Expanded(child: Text(label, style: AppTextStyles.dmSans(
            fontSize: 12, color: AppColors.inkLight))),
        SizedBox(width: 80, child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.right,
          style: AppTextStyles.dmSans(
              fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink),
          decoration: InputDecoration(
            isDense: true, contentPadding: EdgeInsets.zero,
            border: InputBorder.none, filled: false,
            suffixText: unit, suffixStyle: AppTextStyles.caption))),
      ]),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelect;

  const _ToggleRow({required this.options, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(options.length, (i) => Expanded(
        child: GestureDetector(
          onTap: () => onSelect(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(right: i < options.length - 1 ? 6 : 0),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected == i ? AppColors.roseSoft : AppColors.cream,
              border: Border.all(
                color: selected == i ? AppColors.coral : AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(8)),
            child: Text(options[i], textAlign: TextAlign.center,
              style: AppTextStyles.dmSans(fontSize: 11,
                fontWeight: selected == i ? FontWeight.w600 : FontWeight.w400,
                color: selected == i ? AppColors.coral : AppColors.muted)),
          ),
        ),
      )),
    );
  }
}

class _BoolRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _BoolRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: Text(label, style: AppTextStyles.dmSans(
            fontSize: 13, color: AppColors.inkLight))),
        Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.coral),
      ]),
    );
  }
}