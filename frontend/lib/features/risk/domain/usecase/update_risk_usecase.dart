import 'package:untitled10/core/base_usecase/base_usecase.dart';
import 'package:untitled10/core/errors/failure.dart';
import 'package:untitled10/core/utils/either.dart';
import 'package:untitled10/features/risk/domain/entity/risk_entity.dart';
import 'package:untitled10/features/risk/repo/risk_repo.dart';

class UpdateRiskUsecase extends BaseUseCase<RiskEntity, UpdateRiskParams> {
  final RiskRepository _riskRepository;

  UpdateRiskUsecase(this._riskRepository);

  @override
  Future<Either<Failure, RiskEntity>> call(UpdateRiskParams params) {
    return _riskRepository.updateRisk(params.id, params.risk);
  }
}

class UpdateRiskParams {
  final int id;
  final RiskEntity risk;

  UpdateRiskParams({required this.id, required this.risk});
}
