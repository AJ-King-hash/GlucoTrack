import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/color/app_color.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';

import '../../data/model/archives_model.dart';

class ArchiveDetailsPage extends StatelessWidget {
  final ArchiveModel archive;

  const ArchiveDetailsPage({super.key, required this.archive});

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
    return Scaffold(
      appBar: AppBar(
        title: Text(context.read<LocaleCubit>().translate('analysis_details')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.read<LocaleCubit>().translate('gluco_percentage'),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "${archive.glucoPercent.toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: 24,
                    color: _getRiskColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "${context.read<LocaleCubit>().translate('risk_result')}: ${archive.riskResult}",
                ),
                SizedBox(height: 10),
                Text(
                  "${context.read<LocaleCubit>().translate('meal_type')}: ${archive.meal.mealType}",
                ),
                SizedBox(height: 10),
                Text(
                  "${context.read<LocaleCubit>().translate('meal_description')}: ${archive.meal.description}",
                ),
                SizedBox(height: 10),
                Text(
                  "${context.read<LocaleCubit>().translate('analysed_at')}: ${archive.analysedAt.toLocal()}",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
