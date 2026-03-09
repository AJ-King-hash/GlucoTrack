import 'meal_model.dart';

class ArchiveModel {
  final int id;
  final double glucoPercent;
  final DateTime analysedAt;
  final String riskResult;
  final MealModel meal;

  ArchiveModel({
    required this.id,
    required this.glucoPercent,
    required this.analysedAt,
    required this.riskResult,
    required this.meal,
  });

  factory ArchiveModel.fromJson(Map<String, dynamic> json) {
    return ArchiveModel(
      id: json['id'],
      glucoPercent: (json['gluco_percent'] as num).toDouble(),
      analysedAt: DateTime.parse(json['analysed_at']),
      riskResult: json['risk_result'],
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
      'analysed_at': analysedAt.toIso8601String(),
      'risk_result': riskResult,
      'meal': meal.toJson(),
    };
  }
}
