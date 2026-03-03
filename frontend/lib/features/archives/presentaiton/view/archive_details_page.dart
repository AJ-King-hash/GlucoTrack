import 'package:flutter/material.dart';
import 'package:untitled10/core/color/app_color.dart';

import '../../data/model/archives_model.dart';

class ArchiveDetailsPage extends StatelessWidget {
  final ArchiveModel archive;

  const ArchiveDetailsPage({
    super.key,
    required this.archive,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analysis Details"),
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
                  "Gluco Percentage",
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
                Text("Risk Result: ${archive.riskResult}"),
                SizedBox(height: 10),
                Text("Meal Type: ${archive.meal.mealType}"),
                SizedBox(height: 10),
                Text("Meal Description: ${archive.meal.description}"),
                SizedBox(height: 10),
                Text("Analysed At: ${archive.analysedAt.toLocal()}"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}