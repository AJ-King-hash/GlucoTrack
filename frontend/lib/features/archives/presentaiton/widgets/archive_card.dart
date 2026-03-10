import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _getRiskColor().withValues(alpha: 0.15),
          child: Text(
            "${archive.glucoPercent.toStringAsFixed(0)}%",
            style: TextStyle(
              color: _getRiskColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(archive.meal.mealType),
        subtitle: Text(archive.analysedAt.toLocal().toString()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              archive.riskResult,
              style: TextStyle(
                color: _getRiskColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }
}
