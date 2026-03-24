import 'package:glucotrack/core/errors/failure.dart';
import 'package:glucotrack/core/utils/either.dart';
import 'package:glucotrack/features/risk/domain/entity/risk_entity.dart';

abstract class RiskRepository {
  Future<Either<Failure, RiskEntity>> createRisk(RiskEntity risk);
  Future<Either<Failure, RiskEntity?>> getRisk(int id);
  Future<Either<Failure, RiskEntity>> updateRisk(int id, RiskEntity risk);
  Future<Either<Failure, void>> deleteRisk(int id);
}
