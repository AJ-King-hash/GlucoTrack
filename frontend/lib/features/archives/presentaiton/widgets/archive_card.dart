import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';
import 'package:intl/intl.dart';

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

  void _showDeleteConfirmation(BuildContext context) {
    final locale = context.read<LocaleCubit>();
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(locale.translate('delete')),
            content: Text(locale.translate('delete_risk_confirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(locale.translate('cancel')),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<ArchiveCubit>().deleteArchive(archive.id);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(locale.translate('delete')),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Glucose Percentage Badge
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getRiskColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getRiskColor().withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      archive.glucoPercent.toStringAsFixed(0),
                      style: TextStyle(
                        color: _getRiskColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '%',
                      style: TextStyle(
                        color: _getRiskColor().withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Meal Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      archive.meal.mealType,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'yyyy-MM-dd HH:mm',
                      ).format(archive.analysedAt.toLocal()),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Risk Result and Delete Button
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getRiskColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getRiskColor().withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      archive.riskResult,
                      style: TextStyle(
                        color: _getRiskColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                    onPressed: () => _showDeleteConfirmation(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
