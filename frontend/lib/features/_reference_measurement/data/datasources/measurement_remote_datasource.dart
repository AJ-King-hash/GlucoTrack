import '../../domain/entities/measurement_entity.dart';
import '../models/measurement_model.dart';

abstract class MeasurementRemoteDatasource {
  Future<List<MeasurementEntity>> getMeasurements();
  Future<MeasurementEntity> addMeasurement(MeasurementEntity measurement);
}

class MeasurementRemoteDatasourceImpl implements MeasurementRemoteDatasource {
  @override
  Future<List<MeasurementEntity>> getMeasurements() async {
    // Fake API call
    await Future.delayed(const Duration(seconds: 1));
    return [
      MeasurementModel(
        id: 1,
        value: 120,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        note: 'Fasting',
      ),
      MeasurementModel(
        id: 2,
        value: 140,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        note: 'After breakfast',
      ),
    ];
  }

  @override
  Future<MeasurementEntity> addMeasurement(
    MeasurementEntity measurement,
  ) async {
    // Fake API call
    await Future.delayed(const Duration(500));
    return MeasurementModel.fromEntity(measurement);
  }
}
