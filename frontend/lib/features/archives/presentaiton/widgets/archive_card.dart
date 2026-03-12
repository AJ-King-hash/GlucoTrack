import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';

import '../../../../core/color/app_color.dart';
import '../../data/model/archives_model.dart';
import '../../presentaiton/manager/archives_cubit.dart';

class ArchiveCard extends StatelessWidget {
  final ArchiveModel archive;
  final VoidCallback onTap;

  const ArchiveCard({super.key, required this.archive, required this.onTap});

  Color _getRiskColor() {
    switch (archive.riskResult.toLowerCase()) {
      case 'high':
        return AppColor.negative;
      case 'medium':
        return AppColor.warning;
      default:
        return AppColor.positive;
    }
  }

  // Visual helper for meal icons
  IconData _getMealIcon() {
    final meal = archive.meal.mealType.toLowerCase();
    if (meal.contains('breakfast')) return Icons.wb_sunny_outlined;
    if (meal.contains('lunch')) return Icons.lunch_dining_outlined;
    if (meal.contains('dinner')) return Icons.nights_stay_outlined;
    return Icons.restaurant_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riskColor = _getRiskColor();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Left Section: Score Indicator
              _buildGlucoseIndicator(riskColor),

              const SizedBox(width: 16),

              // Middle Section: Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_getMealIcon(), size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          archive.meal.mealType,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'MMM dd, yyyy • hh:mm a',
                      ).format(archive.analysedAt.toLocal()),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Right Section: Risk Level & Action
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildRiskBadge(riskColor),
                  const SizedBox(height: 4),
                  IconButton(
                    onPressed: () => _showDeleteConfirmation(context),
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red[300],
                      size: 20,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlucoseIndicator(Color color) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: archive.glucoPercent.toStringAsFixed(0),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              TextSpan(
                text: '\n%',
                style: TextStyle(
                  color: color.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        archive.riskResult.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    // Note: Kept your logic, but switched to a more modern adaptive style
    final locale = context.read<LocaleCubit>();
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(locale.translate('delete')),
            content: Text(locale.translate('delete_risk_confirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  locale.translate('cancel'),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<ArchiveCubit>().deleteArchive(archive.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(locale.translate('delete')),
              ),
            ],
          ),
    );
  }
}
