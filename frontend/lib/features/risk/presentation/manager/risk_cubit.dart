import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/errors/failure.dart';
import 'package:untitled10/features/risk/domain/entity/risk_entity.dart';
import 'package:untitled10/features/risk/domain/usecase/create_risk_usecase.dart';
import 'package:untitled10/features/risk/domain/usecase/delete_risk_usecase.dart';
import 'package:untitled10/features/risk/domain/usecase/get_risk_usecase.dart';
import 'package:untitled10/features/risk/domain/usecase/update_risk_usecase.dart';
import 'package:untitled10/features/risk/presentation/manager/risk_state.dart';

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
      (failure) async => emit(RiskFailure(_mapFailureToMessage(failure))),
      (createdRisk) async {
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
      (failure) async => emit(RiskFailure(_mapFailureToMessage(failure))),
      (updatedRisk) async {
        // Auto-fetch after update to ensure data is fresh from server
        await getRisk(0);
      },
    );
  }

  Future<void> deleteRisk(int id) async {
    emit(RiskLoading());

    final result = await _deleteRiskUsecase(id);
    await result.fold(
      (failure) async => emit(RiskFailure(_mapFailureToMessage(failure))),
      (_) async {
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
