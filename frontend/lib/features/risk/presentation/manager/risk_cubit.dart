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
    result.fold(
      (failure) => emit(RiskFailure(_mapFailureToMessage(failure))),
      (createdRisk) => emit(RiskCreated(createdRisk)),
    );
  }

  Future<void> getRisk(int id) async {
    emit(RiskLoading());

    final result = await _getRiskUsecase(id);
    result.fold(
      (failure) => emit(RiskFailure(_mapFailureToMessage(failure))),
      (risk) => emit(RiskLoaded(risk)),
    );
  }

  Future<void> updateRisk(int id, RiskEntity risk) async {
    emit(RiskLoading());

    final result = await _updateRiskUsecase(
      UpdateRiskParams(id: id, risk: risk),
    );
    result.fold(
      (failure) => emit(RiskFailure(_mapFailureToMessage(failure))),
      (updatedRisk) => emit(RiskUpdated(updatedRisk)),
    );
  }

  Future<void> deleteRisk(int id) async {
    emit(RiskLoading());

    final result = await _deleteRiskUsecase(id);
    result.fold(
      (failure) => emit(RiskFailure(_mapFailureToMessage(failure))),
      (_) => emit(RiskDeleted()),
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
