import 'package:equatable/equatable.dart';

enum Gender { male, female }

enum MaritalStatus { single, married }

class HomeState extends Equatable {
  final int mealTime;
  final int activity;
  final bool isLoading;

  const HomeState({
    required this.mealTime,
    required this.activity,
    this.isLoading = false,
  });

  HomeState copyWith({int? mealTime, int? activity, bool? isLoading}) {
    return HomeState(
      mealTime: mealTime ?? this.mealTime,
      activity: activity ?? this.activity,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [mealTime, activity, isLoading];
}
