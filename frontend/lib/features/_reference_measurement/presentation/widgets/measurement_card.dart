import 'package:flutter/material.dart';
import '../../domain/entities/measurement_entity.dart';

class MeasurementCard extends StatelessWidget {
  final MeasurementEntity measurement;

  const MeasurementCard({super.key, required this.measurement});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${measurement.value} mg/dL',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatTime(measurement.timestamp),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            if (measurement.note != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  measurement.note!,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
