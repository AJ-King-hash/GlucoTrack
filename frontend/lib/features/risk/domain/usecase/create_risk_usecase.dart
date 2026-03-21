import 'package:glucotrack/core/base_usecase/base_usecase.dart';
import 'package:glucotrack/core/errors/failure.dart';
import 'package:glucotrack/core/utils/either.dart';
import 'package:glucotrack/features/risk/domain/entity/risk_entity.dart';
import 'package:glucotrack/features/risk/repo/risk_repo.dart';

class CreateRiskUsecase extends BaseUseCase<RiskEntity, RiskEntity> {
  final RiskRepository _riskRepository;

  CreateRiskUsecase(this._riskRepository);

  @override
  Future<Either<Failure, RiskEntity>> call(RiskEntity params) {
    return _riskRepository.createRisk(params);
  }
}
