import 'package:glucotrack/core/base_usecase/base_usecase.dart';
import 'package:glucotrack/core/errors/failure.dart';
import 'package:glucotrack/core/utils/either.dart';
import 'package:glucotrack/features/risk/domain/entity/risk_entity.dart';
import 'package:glucotrack/features/risk/repo/risk_repo.dart';

class GetRiskUsecase extends BaseUseCase<RiskEntity?, int> {
  final RiskRepository _riskRepository;

  GetRiskUsecase(this._riskRepository);

  @override
  Future<Either<Failure, RiskEntity?>> call(int params) {
    return _riskRepository.getRisk(params);
  }
}
