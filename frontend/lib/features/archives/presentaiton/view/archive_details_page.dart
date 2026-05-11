import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glucotrack/core/color/app_color.dart';
import 'package:glucotrack/core/localization/locale_cubit.dart';
import 'package:intl/intl.dart';
import '../../data/model/archives_model.dart';

class ArchiveDetailsPage extends StatelessWidget {
  final ArchiveModel archive;
  const ArchiveDetailsPage({super.key, required this.archive});

  Color _getRiskColor() {
    switch (archive.riskResult.toLowerCase()) {
      case 'High Insulin Need':
        return AppColor.negative;
      case 'Medium Risk':
        return AppColor.warning;
      case "Stable":
        return AppColor.positive;
      default:
        return AppColor.positive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.read<LocaleCubit>();
    final riskColor = _getRiskColor(); // Color for the Glucose/Risk score
    final Color hba1cColor = ArchiveModel.getHba1cColor(archive.hba1c ?? 0.0);

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
            // 1. Hero Header (Shows the Glucose Score)
            _buildHeroHeader(riskColor, locale),

            const SizedBox(height: 20),

            // 2. Insight Sections (Meal Tips & Recommendations)
            _buildInsightSection(
              title: locale.translate('meal_tips'),
              content: archive.mealTips ?? 'No specific tips for this meal',
              icon: Icons.lightbulb_outline,
              accentColor: Colors.orange,
            ),
            const SizedBox(height: 20),
            _buildInsightSection(
              title: locale.translate('recommendations'),
              content:
                  archive.recommendations ?? 'No recommendations available',
              icon: Icons.auto_awesome,
              accentColor: AppColor.info,
            ),

            const SizedBox(height: 20),

            // 3. Metadata Section (Now with the Dynamic HbA1c Row)
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

                if (archive.hba1c != null) _buildHba1cRow(locale, hba1cColor),

                _buildInfoRow(
                  locale.translate('risk_level'),
                  archive.riskResult,
                  valueColor: riskColor,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // PRO DISCLAIMER FOOTER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withOpacity(0.1)),
              ),
              child: Column(
                // Using Column for a cleaner centered stack
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.gpp_maybe_outlined,
                    color: Colors.green[300],
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    locale.translate('medical_disclaimer_short'),
                    textAlign: TextAlign.center, // Centers the text lines
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey[600],
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
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
    bool showMedicalDisclaimer = false, // Added flag to control visibility
  }) {
    return Builder(
      builder: (context) {
        final locale = context.read<LocaleCubit>();

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
                  // Icon and Title
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
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
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

  Widget _buildHba1cRow(LocaleCubit locale, Color color) {
    final classification = ArchiveModel.getHba1cRiskClassification(
      archive.hba1c,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            locale.translate('hba1c_result'),
            style: const TextStyle(color: Colors.grey),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.lens, size: 10, color: color), // Match card "Circle"
                const SizedBox(width: 6),
                Text(
                  '${archive.hba1c!}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                Text(
                  ' ($classification)',
                  style: TextStyle(color: color.withOpacity(0.8), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
