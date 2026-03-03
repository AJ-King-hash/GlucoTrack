import 'package:flutter/material.dart';

import '../../../../core/color/app_color.dart';
import '../../data/model/archives_model.dart';

class ArchiveCard extends StatelessWidget {
  final ArchiveModel archive;
  final VoidCallback onTap;

  const ArchiveCard({
    super.key,
    required this.archive,
    required this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _getRiskColor().withOpacity(0.15),
          child: Text(
            "${archive.glucoPercent.toStringAsFixed(0)}%",
            style: TextStyle(
              color: _getRiskColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(archive.meal.mealType),
        subtitle: Text(
          archive.analysedAt.toLocal().toString(),
        ),
        trailing: Text(
          archive.riskResult,
          style: TextStyle(
            color: _getRiskColor(),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}