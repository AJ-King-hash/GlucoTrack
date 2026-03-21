```dart

class MeasurementEntity {
  final int id;
  final double value;
  final DateTime timestamp;
  final String? note;

  MeasurementEntity({
    required this.id,
    required this.value,
    required this.timestamp,
    this.note,
  });
}
```
