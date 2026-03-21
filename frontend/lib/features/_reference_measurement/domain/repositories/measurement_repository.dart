import '../entities/measurement_entity.dart';

abstract class MeasurementRepository {
  Future<List<MeasurementEntity>> getMeasurements();
  Future<MeasurementEntity> addMeasurement(MeasurementEntity measurement);
}
