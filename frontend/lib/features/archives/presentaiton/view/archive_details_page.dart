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
      ),
      body: SingleChildScrollView(
        // Best practice to prevent overflow
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. The Hero Percentage Header
            _buildHeroHeader(statusColor, locale),

            const SizedBox(height: 20),

            // 2. Meal Information Section
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

            // 3. Time and Metadata Section
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
                _buildInfoRow(
                  locale.translate('risk_level'),
                  archive.riskResult,
                  valueColor: statusColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(Color statusColor, LocaleCubit locale) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
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
          // Circular visual indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: CircularProgressIndicator(
                  value: archive.glucoPercent,
                  strokeWidth: 10,
                  color: statusColor,
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                ),
              ),
              Text(
                "${archive.glucoPercent.toStringAsFixed(1)}%",
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
}
