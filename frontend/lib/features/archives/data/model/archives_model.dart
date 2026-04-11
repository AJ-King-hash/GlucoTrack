import 'meal_model.dart';

class ArchiveModel {
  final int id;
  final double glucoPercent;
  final double? hba1c;
  final DateTime analysedAt;
  final String riskResult;
  final String? recommendations;
  final String? mealTips;
  final MealModel meal;

  ArchiveModel({
    required this.id,
    required this.glucoPercent,
    this.hba1c,
    required this.analysedAt,
    required this.riskResult,
    this.recommendations,
    this.mealTips,
    required this.meal,
  });

  factory ArchiveModel.fromJson(Map<String, dynamic> json) {
    return ArchiveModel(
      id: json['id'],
      glucoPercent: (json['gluco_percent']),
      hba1c: json['hba1c'] != null ? (json['hba1c'] as num).toDouble() : null,
      analysedAt: DateTime.parse(json['analysed_at']),
      riskResult: json['risk_result'],
      recommendations: json['recommendations'],
      mealTips: json['meal_tips'],
      meal: MealModel.fromJson(json['meal']),
    );
  }

  /// Factory method to create a pending archive from meal data.
  /// The actual analysis values will be populated from the API response.
  factory ArchiveModel.fromMeal(MealModel meal) {
    return ArchiveModel(
      id: 0, // Will be assigned by backend
      glucoPercent: 0.0, // Will be populated from API analysis
      analysedAt: DateTime.now(), // Will be populated from API analysis
      riskResult: '', // Will be populated from API analysis
      meal: meal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gluco_percent': glucoPercent,
      'hba1c': hba1c,
      'analysed_at': analysedAt.toIso8601String(),
      'risk_result': riskResult,
      "recommendations": recommendations,
      "meal_tips": mealTips,
      'meal': meal.toJson(),
    };
  }

  static String getHba1cRiskClassification(double? hba1c) {
    if (hba1c == null) return '';
    if (hba1c < 5.7) return 'normal';
    if (hba1c < 6.5) return 'prediabetes';
    if (hba1c < 8.0) return 'diabetes';
    return 'severe';
  }
}
