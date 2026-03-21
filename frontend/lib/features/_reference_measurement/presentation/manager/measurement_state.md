```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/measurement_entity.dart';

part 'measurement_state.freezed.dart';

@freezed
class MeasurementState with _$MeasurementState {
  const factory MeasurementState.initial() = _Initial;
  const factory MeasurementState.loading() = _Loading;
  const factory MeasurementState.loaded({
    required List<MeasurementEntity> measurements,
    DateTime? lastRefreshed,
  }) = _Loaded;
  const factory MeasurementState.error({
    required String message,
    Object? error,
  }) = _Error;
  const factory MeasurementState.empty() = _Empty;
}
```
