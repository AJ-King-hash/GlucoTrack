import 'package:untitled10/core/base_usecase/base_usecase.dart';
import 'package:untitled10/core/errors/failure.dart';
import 'package:untitled10/core/utils/either.dart';
import 'package:untitled10/features/risk/domain/entity/risk_entity.dart';
import 'package:untitled10/features/risk/repo/risk_repo.dart';

class GetRiskUsecase extends BaseUseCase<RiskEntity, int> {
  final RiskRepository _riskRepository;

  GetRiskUsecase(this._riskRepository);

  @override
  Future<Either<Failure, RiskEntity>> call(int params) {
    return _riskRepository.getRisk(params);
  }
}
