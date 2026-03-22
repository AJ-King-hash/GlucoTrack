import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:glucotrack/core/errors/failure.dart';
import 'package:glucotrack/core/utils/global_refresher.dart';
import 'package:glucotrack/core/utils/toast_utility.dart';
import 'package:glucotrack/features/risk/domain/entity/risk_entity.dart';
import 'package:glucotrack/features/risk/domain/usecase/create_risk_usecase.dart';
import 'package:glucotrack/features/risk/domain/usecase/delete_risk_usecase.dart';
import 'package:glucotrack/features/risk/domain/usecase/get_risk_usecase.dart';
import 'package:glucotrack/features/risk/domain/usecase/update_risk_usecase.dart';
import 'package:glucotrack/features/risk/presentation/manager/risk_state.dart';

class RiskCubit extends Cubit<RiskState> {
  final CreateRiskUsecase _createRiskUsecase;
  final GetRiskUsecase _getRiskUsecase;
  final UpdateRiskUsecase _updateRiskUsecase;
  final DeleteRiskUsecase _deleteRiskUsecase;

  RiskCubit({
    required CreateRiskUsecase createRiskUsecase,
    required GetRiskUsecase getRiskUsecase,
    required UpdateRiskUsecase updateRiskUsecase,
    required DeleteRiskUsecase deleteRiskUsecase,
  }) : _createRiskUsecase = createRiskUsecase,
       _getRiskUsecase = getRiskUsecase,
       _updateRiskUsecase = updateRiskUsecase,
       _deleteRiskUsecase = deleteRiskUsecase,
       super(RiskInitial());

  Future<void> createRisk(RiskEntity risk) async {
    emit(RiskLoading());

    final result = await _createRiskUsecase(risk);
    await result.fold(
      (failure) async {
        ToastUtility.showError(_mapFailureToMessage(failure));
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        emit(RiskFailure(_mapFailureToMessage(failure)));
      },
      (createdRisk) async {
        ToastUtility.showSuccess("Risk created successfully");
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        // Auto-fetch after creation to ensure data is fresh from server
        await getRisk(0);
      },
    );
  }

  Future<void> getRisk(int id) async {
    emit(RiskLoading());

    final result = await _getRiskUsecase(id);
    result.fold((failure) {
      // Treat 404 as "no risk exists" - not an error state
      if (failure is ServerFailure && failure.code == 404) {
        emit(RiskLoaded(null)); // No risk exists for user
      } else {
        emit(RiskFailure(_mapFailureToMessage(failure)));
      }
    }, (risk) => emit(RiskLoaded(risk)));
  }

  Future<void> updateRisk(int id, RiskEntity risk) async {
    emit(RiskLoading());

    final result = await _updateRiskUsecase(
      UpdateRiskParams(id: id, risk: risk),
    );
    await result.fold(
      (failure) async {
        ToastUtility.showError(_mapFailureToMessage(failure));
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        emit(RiskFailure(_mapFailureToMessage(failure)));
      },
      (updatedRisk) async {
        ToastUtility.showSuccess("Risk updated successfully");
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        // Auto-fetch after update to ensure data is fresh from server
        await getRisk(0);
      },
    );
  }

  Future<void> deleteRisk(int id) async {
    emit(RiskLoading());

    final result = await _deleteRiskUsecase(id);
    await result.fold(
      (failure) async {
        ToastUtility.showError(_mapFailureToMessage(failure));
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        emit(RiskFailure(_mapFailureToMessage(failure)));
      },
      (_) async {
        ToastUtility.showSuccess("Risk deleted successfully");
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        // Emit deleted state and show empty risk (no need to fetch)
        emit(RiskDeleted());
        // Show empty state directly
        emit(RiskLoaded(null));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return "Network failure. Please check your connection.";
    } else if (failure is ServerFailure) {
      return "Server error. Please try again later.";
    } else if (failure is UnauthorizedFailure) {
      return "Unauthorized. Please login again.";
    } else if (failure is ValidationFailure) {
      return "Validation error. Please check your input.";
    } else {
      return "Something went wrong. Please try again.";
    }
  }
}
