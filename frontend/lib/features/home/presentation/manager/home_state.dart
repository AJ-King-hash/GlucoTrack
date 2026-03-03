import 'package:equatable/equatable.dart';
enum Gender { male, female }
enum MaritalStatus { single, married }
class HomeState extends Equatable{
  final int mealTime;
  final int activity;
  final int age;
  final int weight;
  final Gender? gender;
  final MaritalStatus? maritalStatus;
  final int pregnancyCount;
  const HomeState(
       {
    required this.weight,
     required this.age,
     required this.mealTime,
     required this.activity,
         this.gender,
         this.maritalStatus,
         this.pregnancyCount = 0,
  });
  HomeState copyWith({
    int? mealTime,
    int? activity,
    int? age,
    int? weight,
    Gender? gender,
    MaritalStatus? maritalStatus,
    int? pregnancyCount,
  }){
    return HomeState(
      age: age ?? this.age,
      weight: weight ?? this.weight,
      mealTime: mealTime?? this.mealTime,
      activity: activity?? this.activity,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      pregnancyCount: pregnancyCount ?? this.pregnancyCount,
    );
  } 
  @override
  List<Object?> get props => [
    mealTime,
    activity,
    age,
    weight,
    gender,
    maritalStatus,
    pregnancyCount,];
}