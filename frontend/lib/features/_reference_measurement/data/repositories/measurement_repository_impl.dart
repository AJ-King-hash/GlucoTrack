import '../../domain/entities/measurement_entity.dart';
import '../../domain/repositories/measurement_repository.dart';
import '../datasources/measurement_remote_datasource.dart';
import '../models/measurement_model.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/utils/logger.dart';

class MeasurementRepositoryImpl implements MeasurementRepository {
  final MeasurementRemoteDatasource _remoteDatasource;

  MeasurementRepositoryImpl(this._remoteDatasource);

  @override
  Future<List<MeasurementEntity>> getMeasurements() async {
    try {
      final models = await _remoteDatasource.getMeasurements();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      Logger.e('Error getting measurements: $e');
      throw AppException('Failed to get measurements');
    }
  }

  @override
  Future<MeasurementEntity> addMeasurement(
    MeasurementEntity measurement,
  ) async {
    try {
      final model = await _remoteDatasource.addMeasurement(measurement);
      return model.toEntity();
    } catch (e) {
      Logger.e('Error adding measurement: $e');
      throw AppException('Failed to add measurement');
    }
  }
}
