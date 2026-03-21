```dart

import '../../../core/base_usecase/base_usecase.dart';
import '../repositories/measurement_repository.md';
import '../entities/measurement_entity.dart';

class GetMeasurementsUseCase
    implements BaseUseCase<List<MeasurementEntity>, void> {
  final MeasurementRepository _repository;

  GetMeasurementsUseCase(this._repository);

  @override
  Future<List<MeasurementEntity>> call([void params]) {
    return _repository.getMeasurements();
  }
}
```
