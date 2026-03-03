class MealModel {
  final String description;
  final String mealType;
  final DateTime mealTime;
  final int userId;

  MealModel({
    required this.description,
    required this.mealType,
    required this.mealTime,
    required this.userId,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      description: json['description'],
      mealType: json['meal_type'],
      mealTime: DateTime.parse(json['meal_time']),
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'meal_type': mealType,
      'meal_time': mealTime.toIso8601String(),
      'user_id': userId,
    };
  }
}