import 'package:glucotrack/core/api/api_service.dart';
import 'package:glucotrack/core/errors/failure.dart';
import 'package:glucotrack/core/utils/either.dart';
import 'package:glucotrack/features/risk/data/model/risk_model.dart';
import 'package:glucotrack/features/risk/domain/entity/risk_entity.dart';
import 'package:glucotrack/features/risk/repo/risk_repo.dart';

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
      (data) => Right(RiskModel.fromJson(data as Map<String, dynamic>)),
    );
  }

  @override
  Future<Either<Failure, RiskEntity?>> getRisk(int id) async {
    // Note: The id parameter is not used as the backend identifies
    // the user from the authentication token. Kept for interface consistency.
    final result = await apiService.getRisk();
    return result.fold((failure) => Left(failure), (data) {
      // Handle null response OR empty array when no risk data exists
      // Backend returns [] (empty array) when no risk exists for user
      if (data == null || (data is List && data.isEmpty)) {
        return const Right<Failure, RiskEntity?>(null);
      }

      try {
        return Right<Failure, RiskEntity?>(
          RiskModel.fromJson(data as Map<String, dynamic>),
        );
      } catch (e) {
        return Left(ServerFailure(message: "Failed to parse risk data: $e"));
      }
    });
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
      (data) => Right(RiskModel.fromJson(data as Map<String, dynamic>)),
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
