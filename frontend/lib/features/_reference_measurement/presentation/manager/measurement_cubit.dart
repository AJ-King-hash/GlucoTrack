import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../domain/usecases/get_measurements_usecase.dart';
import '../../domain/usecases/add_measurement_usecase.dart';
import '../../domain/entities/measurement_entity.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/global_refresher.dart';

part 'measurement_state.dart';

class MeasurementCubit extends Cubit<MeasurementState> {
  final GetMeasurementsUseCase _getMeasurementsUseCase;
  final AddMeasurementUseCase _addMeasurementUseCase;

  MeasurementCubit(this._getMeasurementsUseCase, this._addMeasurementUseCase)
    : super(const MeasurementState.initial());

  Future<void> load() async {
    emit(const MeasurementState.loading());
    try {
      final measurements = await _getMeasurementsUseCase();
      if (measurements.isEmpty) {
        emit(const MeasurementState.empty());
      } else {
        emit(
          MeasurementState.loaded(
            measurements: measurements,
            lastRefreshed: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      Logger.e('Load measurements error: $e');
      emit(
        MeasurementState.error(
          message:
              e is AppException ? e.message : 'Failed to load measurements',
          error: e,
        ),
      );
    }
  }

  Future<void> refresh() async {
    try {
      final measurements = await _getMeasurementsUseCase();
      if (measurements.isEmpty) {
        emit(const MeasurementState.empty());
      } else {
        emit(
          MeasurementState.loaded(
            measurements: measurements,
            lastRefreshed: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      Logger.e('Refresh measurements error: $e');
      // Keep current state but log error
    }
  }

  Future<void> addMeasurement(MeasurementEntity measurement) async {
    try {
      await _addMeasurementUseCase(measurement);
      // Trigger global refresh
      GetIt.I<GlobalRefresher>().triggerRefresh();
    } catch (e) {
      Logger.e('Add measurement error: $e');
      emit(
        MeasurementState.error(
          message: e is AppException ? e.message : 'Failed to add measurement',
          error: e,
        ),
      );
    }
  }
}
