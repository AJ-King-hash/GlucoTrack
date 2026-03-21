import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/measurement_entity.dart';

part 'measurement_model.g.dart';

@JsonSerializable()
class MeasurementModel extends MeasurementEntity {
  const MeasurementModel({
    required super.id,
    required super.value,
    required super.timestamp,
    super.note,
  });

  factory MeasurementModel.fromJson(Map<String, dynamic> json) =>
      _$MeasurementModelFromJson(json);

  Map<String, dynamic> toJson() => _$MeasurementModelToJson(this);

  factory MeasurementModel.fromEntity(MeasurementEntity entity) {
    return MeasurementModel(
      id: entity.id,
      value: entity.value,
      timestamp: entity.timestamp,
      note: entity.note,
    );
  }

  MeasurementEntity toEntity() {
    return MeasurementEntity(
      id: id,
      value: value,
      timestamp: timestamp,
      note: note,
    );
  }
}
