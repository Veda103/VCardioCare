import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/prediction_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = '30d';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final provider = context.read<PredictionProvider>();
    await provider.fetchHistory(filter: _selectedFilter);
  }

  @override
  Widget build(BuildContext context) {
    final predictions = context.watch<PredictionProvider>().predictionHistory;
    final isLoading = context.watch<PredictionProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        title: const Text('Health History'),
        backgroundColor: AppColors.cream,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.cream,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Last 30 Days',
                  isSelected: _selectedFilter == '30d',
                  onTap: () {
                    setState(() => _selectedFilter = '30d');
                    _loadHistory();
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Last 90 Days',
                  isSelected: _selectedFilter == '90d',
                  onTap: () {
                    setState(() => _selectedFilter = '90d');
                    _loadHistory();
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '1 Year',
                  isSelected: _selectedFilter == '1y',
                  onTap: () {
                    setState(() => _selectedFilter = '1y');
                    _loadHistory();
                  },
                ),
              ],
            ),
          ),
          // History list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.coral))
                : predictions.isEmpty
                    ? Center(
                        child: Text(
                          'No predictions in this period',
                          style: AppTextStyles.caption,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: predictions.length,
                        itemBuilder: (context, index) {
                          final pred = predictions[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.warmWhite,
                                border: Border.all(
                                    color: AppColors.border, width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Risk: ${pred.riskCategory}',
                                          style: AppTextStyles.dmSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 2),
                                      Text(
                                          '${pred.riskPercent}% • ${pred.confidenceScore.toStringAsFixed(0)}% confidence',
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
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.coral : AppColors.warmWhite,
          border: Border.all(
            color: isSelected ? AppColors.coral : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.dmSans(
            fontSize: 11,
            color: isSelected ? Colors.white : AppColors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}