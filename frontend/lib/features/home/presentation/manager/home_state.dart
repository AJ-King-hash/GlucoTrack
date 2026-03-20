import 'package:equatable/equatable.dart';

enum Gender { male, female }

enum MaritalStatus { single, married }

class HomeState extends Equatable {
  final int mealTime;
  final int activity;
  final int age;
  final int weight;
  final int diabetesType;
  final Gender? gender;
  final bool isGenderUpdating;
  final String? genderUpdateMessage;
  final bool? genderUpdateSuccess;
  const HomeState({
    required this.weight,
    required this.age,
    required this.mealTime,
    required this.activity,
    required this.diabetesType,
    this.gender,
    this.isGenderUpdating = false,
    this.genderUpdateMessage,
    this.genderUpdateSuccess,
  });
  HomeState copyWith({
    int? mealTime,
    int? activity,
    int? age,
    int? weight,
    int? diabetesType,
    Gender? gender,
    bool? isGenderUpdating,
    String? genderUpdateMessage,
    bool? genderUpdateSuccess,
    bool clearGenderUpdate = false,
  }) {
    return HomeState(
      age: age ?? this.age,
      weight: weight ?? this.weight,
      mealTime: mealTime ?? this.mealTime,
      activity: activity ?? this.activity,
      diabetesType: diabetesType ?? this.diabetesType,
      gender: gender ?? this.gender,
      isGenderUpdating: isGenderUpdating ?? this.isGenderUpdating,
      genderUpdateMessage:
          clearGenderUpdate
              ? null
              : (genderUpdateMessage ?? this.genderUpdateMessage),
      genderUpdateSuccess:
          clearGenderUpdate
              ? null
              : (genderUpdateSuccess ?? this.genderUpdateSuccess),
    );
  }

  @override
  List<Object?> get props => [
    mealTime,
    activity,
    age,
    weight,
    diabetesType,
    gender,
    isGenderUpdating,
    genderUpdateMessage,
    genderUpdateSuccess,
  ];
}
