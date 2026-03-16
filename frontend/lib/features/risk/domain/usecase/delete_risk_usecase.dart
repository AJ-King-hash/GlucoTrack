import 'package:untitled10/core/base_usecase/base_usecase.dart';
import 'package:untitled10/core/errors/failure.dart';
import 'package:untitled10/core/utils/either.dart';
import 'package:untitled10/features/risk/repo/risk_repo.dart';

class DeleteRiskUsecase extends BaseUseCase<void, int> {
  final RiskRepository _riskRepository;

  DeleteRiskUsecase(this._riskRepository);

  @override
  Future<Either<Failure, void>> call(int params) {
    return _riskRepository.deleteRisk(params);
  }
}
