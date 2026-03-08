import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/errors/failure.dart';
import 'package:untitled10/features/home/presentation/manager/home_state.dart';
import 'package:untitled10/features/risk/domain/usecase/get_risk_usecase.dart';
import 'package:untitled10/features/risk/domain/entity/risk_entity.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetRiskUsecase _getRiskUsecase;

  HomeCubit(this._getRiskUsecase)
    : super(const HomeState(mealTime: 1, activity: 1, weight: 1, age: 1)) {
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    try {
      // Assume user id is 0 - backend actually uses token to identify user
      final result = await _getRiskUsecase(0);
      result.fold(
        (failure) => _handleFailure(failure),
        (risk) => _updateStateFromRisk(risk),
      );
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleFailure(Failure failure) {
    // Log failure
    print('Failed to load user data: ${failure.message}');
    // We could emit a failure state if HomeState had one
    // For now, we'll just leave the initial hardcoded values
  }

  void _handleError(dynamic error) {
    // Log error
    print('Error loading user data: $error');
    // We could emit an error state if HomeState had one
    // For now, we'll just leave the initial hardcoded values
  }

  void _updateStateFromRisk(RiskEntity risk) {
    emit(
      state.copyWith(
        age: risk.age,
        weight: risk.weight.toInt(), // Convert to int if needed
        activity: _mapPhysicalActivityToInt(risk.physicalActivity),
        // We'll need to handle gender and marital status if they're added to backend
        // For now, we'll leave them as null/initial values
      ),
    );
  }

  int _mapPhysicalActivityToInt(String activity) {
    switch (activity.toLowerCase()) {
      case 'low':
        return 0;
      case 'moderate':
      case 'medarate':
        return 1;
      case 'high':
      case 'height':
        return 2;
      default:
        return 1; // Default to moderate
    }
  }

  void updateMealTime(int mealTime) {
    emit(state.copyWith(mealTime: mealTime));
  }

  void updateActivity(int activity) {
    emit(state.copyWith(activity: activity));
  }

  void updateAge(int value) {
    emit(state.copyWith(age: value));
  }

  void updateWeight(int value) {
    emit(state.copyWith(weight: value));
  }

  void updateGender(Gender gender) {
    emit(
      state.copyWith(gender: gender, maritalStatus: null, pregnancyCount: 0),
    );
  }

  void updateMaterialStatus(MaritalStatus material) {
    emit(state.copyWith(maritalStatus: material, pregnancyCount: 0));
  }

  void updatePregnancyCount(int count) {
    emit(state.copyWith(pregnancyCount: count));
  }
}
