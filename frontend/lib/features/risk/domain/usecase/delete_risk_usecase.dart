import 'package:glucotrack/core/base_usecase/base_usecase.dart';
import 'package:glucotrack/core/errors/failure.dart';
import 'package:glucotrack/core/utils/either.dart';
import 'package:glucotrack/features/risk/repo/risk_repo.dart';

class DeleteRiskUsecase extends BaseUseCase<void, int> {
  final RiskRepository _riskRepository;

  DeleteRiskUsecase(this._riskRepository);

  @override
  Future<Either<Failure, void>> call(int params) {
    return _riskRepository.deleteRisk(params);
  }
}
