class RiskEntity {
  final int? id;
  final int age;
  final double weight;
  final double height;
  final double bmi;
  final int? sugarPregnancy;
  final bool smoking;
  final bool geneticDisease;
  final String physicalActivity;
  final String diabetesType;
  final String medicineType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RiskEntity({
    this.id,
    required this.age,
    required this.weight,
    required this.height,
    required this.bmi,
    this.sugarPregnancy,
    required this.smoking,
    required this.geneticDisease,
    required this.physicalActivity,
    required this.diabetesType,
    required this.medicineType,
    this.createdAt,
    this.updatedAt,
  });

  RiskEntity copyWith({
    int? id,
    int? age,
    double? weight,
    double? height,
    double? bmi,
    int? sugarPregnancy,
    bool? smoking,
    bool? geneticDisease,
    String? physicalActivity,
    String? diabetesType,
    String? medicineType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RiskEntity(
      id: id ?? this.id,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bmi: bmi ?? this.bmi,
      sugarPregnancy: sugarPregnancy ?? this.sugarPregnancy,
      smoking: smoking ?? this.smoking,
      geneticDisease: geneticDisease ?? this.geneticDisease,
      physicalActivity: physicalActivity ?? this.physicalActivity,
      diabetesType: diabetesType ?? this.diabetesType,
      medicineType: medicineType ?? this.medicineType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
