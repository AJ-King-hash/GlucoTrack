import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glucotrack/core/color/app_color.dart';
import 'package:glucotrack/core/localization/locale_cubit.dart';
import 'package:intl/intl.dart';
import '../../data/model/archives_model.dart';

class ArchiveDetailsPage extends StatelessWidget {
  final ArchiveModel archive;

  const ArchiveDetailsPage({super.key, required this.archive});

  Color _getStatusColor() {
    switch (archive.riskResult.toLowerCase()) {
      case 'high':
        return AppColor.negative;
      case 'medium':
        return AppColor.warning;
      default:
        return AppColor.positive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.read<LocaleCubit>();
    final statusColor = _getStatusColor();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(locale.translate('analysis_details')),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // 1. The Hero Percentage Header
            _buildHeroHeader(statusColor, locale),

            const SizedBox(height: 20),

            // 1. NEW: Proactive Meal Tips
            _buildInsightSection(
              title: locale.translate('meal_tips'),
              content: archive.mealTips ?? 'No specific tips for this meal',
              icon: Icons.lightbulb_outline,
              accentColor: Colors.orange,
            ),

            const SizedBox(height: 20),

            // 2. NEW: Health Recommendations (AI Insight)
            _buildInsightSection(
              title: locale.translate('recommendations'),
              content:
                  archive.recommendations ?? 'No recommendations available',
              icon: Icons.auto_awesome, // Represents AI/Smart insight
              accentColor: AppColor.info,
            ),

            const SizedBox(height: 20),

            // 4. Meal Information Section
            _buildInfoSection(
              title: locale.translate('meal_details'),
              icon: Icons.restaurant,
              children: [
                _buildInfoRow(
                  locale.translate('meal_type'),
                  archive.meal.mealType,
                ),
                _buildInfoRow(
                  locale.translate('meal_description'),
                  archive.meal.description,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 5. Time and Metadata Section
            _buildInfoSection(
              title: locale.translate('report_metadata'),
              icon: Icons.history,
              children: [
                _buildInfoRow(
                  locale.translate('analysed_at'),
                  DateFormat(
                    'yyyy-MM-dd | hh:mm a',
                  ).format(archive.analysedAt.toLocal()),
                ),
                if (archive.hba1c != null)
                  _buildHba1cRow(locale),
                _buildInfoRow(
                  locale.translate('risk_level'),
                  archive.riskResult,
                  valueColor: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Modern Insight Section for Recommendations and Tips
  Widget _buildInsightSection({
    required String title,
    required String content,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blueGrey[800],
              height: 1.5, // Better readability for long text
            ),
          ),
        ],
      ),
    );
  }

  // Rest of your existing helper methods (_buildHeroHeader, _buildInfoSection, etc.)
  Widget _buildHeroHeader(Color statusColor, LocaleCubit locale) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Text(
            locale.translate('gluco_percentage'),
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: CircularProgressIndicator(
                  // Note: Ensure archive.glucoPercent is 0.0 to 1.0 for the indicator
                  // If it's a raw number like 1300, you need to normalize it
                  value: archive.glucoPercent,
                  strokeWidth: 10,
                  color: statusColor,
                  backgroundColor: statusColor.withOpacity(0.1),
                ),
              ),
              Text(
                "${archive.glucoPercent.toStringAsFixed(1)}",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blueGrey),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontWeight: FontWeight.w600, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHba1cRow(LocaleCubit locale) {
    final classification = ArchiveModel.getHba1cRiskClassification(archive.hba1c);
    String label;
    Color color;
    switch (classification) {
      case 'normal':
        label = locale.translate('hba1c_normal');
        color = AppColor.positive;
        break;
      case 'prediabetes':
        label = locale.translate('hba1c_prediabetes');
        color = AppColor.warning;
        break;
      case 'diabetes':
        label = locale.translate('hba1c_diabetes');
        color = AppColor.negative;
        break;
      case 'severe':
        label = locale.translate('hba1c_severe');
        color = Colors.red[900]!;
        break;
      default:
        label = '';
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            locale.translate('hba1c_result'),
            style: const TextStyle(color: Colors.grey),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bloodtype, size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(
                      '${archive.hba1c!.toStringAsFixed(1)}% ($label)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
