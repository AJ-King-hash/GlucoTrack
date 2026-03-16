import 'package:untitled10/core/api/api_service.dart';
import 'package:untitled10/core/errors/failure.dart';
import 'package:untitled10/core/utils/either.dart';
import 'package:untitled10/features/risk/data/model/risk_model.dart';
import 'package:untitled10/features/risk/domain/entity/risk_entity.dart';
import 'package:untitled10/features/risk/repo/risk_repo.dart';

class RiskRepoImpl implements RiskRepository {
  final ApiService apiService;

  RiskRepoImpl({required this.apiService});

  @override
  Future<Either<Failure, RiskEntity>> createRisk(RiskEntity risk) async {
    final result = await apiService.createRisk(
      RiskModel(
        id: risk.id,
        age: risk.age,
        weight: risk.weight,
        height: risk.height,
        bmi: risk.bmi,
        sugarPregnancy: risk.sugarPregnancy,
        smoking: risk.smoking,
        geneticDisease: risk.geneticDisease,
        physicalActivity: risk.physicalActivity,
        diabetesType: risk.diabetesType,
        medicineType: risk.medicineType,
        createdAt: risk.createdAt,
        updatedAt: risk.updatedAt,
      ).toJson(),
    );

    return result.fold(
      (failure) => Left(failure),
      (data) => Right(RiskModel.fromJson(data)),
    );
  }

  @override
  Future<Either<Failure, RiskEntity>> getRisk(int id) async {
    // Note: The id parameter is not used as the backend identifies
    // the user from the authentication token. Kept for interface consistency.
    final result = await apiService.getRisk();
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(RiskModel.fromJson(data)),
    );
  }

  @override
  Future<Either<Failure, RiskEntity>> updateRisk(
    int id,
    RiskEntity risk,
  ) async {
    // Note: The id parameter is not used as the backend identifies
    // the user from the authentication token. Kept for interface consistency.
    final result = await apiService.updateRisk(
      RiskModel(
        id: risk.id,
        age: risk.age,
        weight: risk.weight,
        height: risk.height,
        bmi: risk.bmi,
        sugarPregnancy: risk.sugarPregnancy,
        smoking: risk.smoking,
        geneticDisease: risk.geneticDisease,
        physicalActivity: risk.physicalActivity,
        diabetesType: risk.diabetesType,
        medicineType: risk.medicineType,
        createdAt: risk.createdAt,
        updatedAt: risk.updatedAt,
      ).toJson(),
    );

    return result.fold(
      (failure) => Left(failure),
      (data) => Right(RiskModel.fromJson(data)),
    );
  }

  @override
  Future<Either<Failure, void>> deleteRisk(int id) async {
    // Note: The id parameter is not used as the backend identifies
    // the user from the authentication token. Kept for interface consistency.
    final result = await apiService.deleteRisk();
    return result.fold((failure) => Left(failure), (data) => const Right(null));
  }
}
