import 'package:untitled10/features/risk/domain/entity/risk_entity.dart';

class RiskModel extends RiskEntity {
  RiskModel({
    super.id,
    required super.age,
    required super.weight,
    required super.height,
    required super.bmi,
    required super.sugarPregnancy,
    required super.smoking,
    required super.geneticDisease,
    required super.physicalActivity,
    required super.diabetesType,
    required super.medicineType,
    super.createdAt,
    super.updatedAt,
  });

  factory RiskModel.fromJson(Map<String, dynamic> json) {
    return RiskModel(
      id: json['id'] as int?,
      age: json['age'] as int,
      weight: json['weight'] as double,
      height: json['height'] as double,
      bmi: json['BMI'] as double,
      sugarPregnancy: json['sugar_pregnancy'] as int,
      smoking: json['smoking'] as bool,
      geneticDisease: json['genetic_disease'] as bool,
      physicalActivity: json['physical_activity'] as String,
      diabetesType: json['diabetes_type'] as String,
      medicineType: json['medicine_type'] as String,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Note: 'user_id' is required by backend schema but gets overwritten
      // by the JWT token in the backend router
      'age': age,
      'weight': weight,
      'height': height,
      'sugar_pregnancy': sugarPregnancy,
      'smoking': smoking,
      'genetic_disease': geneticDisease,
      'physical_activity': physicalActivity,
      'diabetes_type': diabetesType,
      'medicine_type': medicineType,
    };
  }
}
