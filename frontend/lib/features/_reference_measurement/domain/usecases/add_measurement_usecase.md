```dart

import '../../../core/base_usecase/base_usecase.dart';
import '../repositories/measurement_repository.md';
import '../entities/measurement_entity.dart';

class AddMeasurementUseCase
    implements BaseUseCase<MeasurementEntity, MeasurementEntity> {
  final MeasurementRepository _repository;

  AddMeasurementUseCase(this._repository);

  @override
  Future<MeasurementEntity> call(MeasurementEntity params) {
    return _repository.addMeasurement(params);
  }
}
```
