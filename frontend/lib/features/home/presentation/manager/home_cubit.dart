import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/errors/failure.dart';
import 'package:untitled10/features/home/presentation/manager/home_state.dart';
import 'package:untitled10/features/risk/domain/usecase/get_risk_usecase.dart';
import 'package:untitled10/features/risk/domain/usecase/update_risk_usecase.dart';
import 'package:untitled10/features/risk/domain/entity/risk_entity.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetRiskUsecase _getRiskUsecase;
  final UpdateRiskUsecase _updateRiskUsecase;

  // Store the existing risk entity to preserve fields not in HomeState
  RiskEntity? _currentRiskEntity;

  HomeCubit(this._getRiskUsecase, this._updateRiskUsecase)
    : super(const HomeState(mealTime: 1, activity: 1, weight: 70, age: 30)) {
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    try {
      // Backend uses authentication token to identify user, so id parameter is ignored
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
    // We could emit a failure state if HomeState had one
    // For now, we'll just leave the initial reasonable values
  }

  void _handleError(dynamic error) {
    // Log error
    // We could emit an error state if HomeState had one
    // For now, we'll just leave the initial reasonable values
  }

  void _updateStateFromRisk(RiskEntity risk) {
    // Store the full risk entity for later use
    _currentRiskEntity = risk;
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

  String _mapIntToPhysicalActivity(int activity) {
    switch (activity) {
      case 0:
        return 'low';
      case 1:
        return 'moderate';
      case 2:
        return 'high';
      default:
        return 'moderate'; // Default to moderate
    }
  }

  // Helper method to convert HomeState to RiskEntity
  // Uses existing risk data as base, only updating fields from HomeState
  RiskEntity _stateToRiskEntity() {
    // Use existing risk entity as base if available, otherwise create new one
    final base = _currentRiskEntity;

    return RiskEntity(
      age: state.age,
      weight: state.weight.toDouble(),
      height: base?.height ?? 170.0, // Use existing or default
      bmi:
          base?.bmi ??
          (state.weight / (1.70 * 1.70)), // Use existing or calculate
      sugarPregnancy: state.pregnancyCount,
      smoking: base?.smoking ?? false, // Use existing or default
      geneticDisease: base?.geneticDisease ?? false, // Use existing or default
      physicalActivity: _mapIntToPhysicalActivity(state.activity),
      diabetesType: base?.diabetesType ?? 'type2', // Use existing or default
      medicineType:
          base?.medicineType ?? 'MouthSugarLower', // Use existing or default
    );
  }

  Future<void> updateMealTime(int mealTime) async {
    emit(state.copyWith(mealTime: mealTime));
    // Note: Meal time is not directly stored in RiskEntity, so no API call needed
  }

  Future<void> updateActivity(int activity) async {
    emit(state.copyWith(activity: activity));
    final riskEntity = _stateToRiskEntity();
    await _updateRisk(riskEntity);
  }

  Future<void> updateAge(int value) async {
    emit(state.copyWith(age: value));
    final riskEntity = _stateToRiskEntity();
    await _updateRisk(riskEntity);
  }

  Future<void> updateWeight(int value) async {
    emit(state.copyWith(weight: value));
    final riskEntity = _stateToRiskEntity();
    await _updateRisk(riskEntity);
  }

  Future<void> updateGender(Gender gender) async {
    emit(
      state.copyWith(gender: gender, maritalStatus: null, pregnancyCount: 0),
    );
    // Note: Gender is not directly stored in RiskEntity, so no API call needed
  }

  Future<void> updateMaterialStatus(MaritalStatus material) async {
    emit(state.copyWith(maritalStatus: material, pregnancyCount: 0));
    // Note: Marital status is not directly stored in RiskEntity, so no API call needed
  }

  Future<void> updatePregnancyCount(int count) async {
    emit(state.copyWith(pregnancyCount: count));
    final riskEntity = _stateToRiskEntity();
    await _updateRisk(riskEntity);
  }

  Future<void> _updateRisk(RiskEntity riskEntity) async {
    try {
      final result = await _updateRiskUsecase(
        UpdateRiskParams(id: 0, risk: riskEntity),
      );
      result.fold(
        (failure) => _handleFailure(failure),
        (risk) => _updateStateFromRisk(risk),
      );
    } catch (e) {
      _handleError(e);
    }
  }
}
