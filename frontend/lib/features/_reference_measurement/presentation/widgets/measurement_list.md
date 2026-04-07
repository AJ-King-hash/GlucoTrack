```dart

import 'package:flutter/material.dart';
import '../../domain/entities/measurement_entity.dart';
import 'measurement_card.md';

class MeasurementList extends StatelessWidget {
  final List<MeasurementEntity> measurements;

  const MeasurementList({super.key, required this.measurements});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: measurements.length,
      itemBuilder: (context, index) {
        return MeasurementCard(measurement: measurements[index]);
      },
    );
  }
}
```
