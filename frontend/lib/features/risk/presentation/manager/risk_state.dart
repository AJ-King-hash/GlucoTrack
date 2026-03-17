import 'package:equatable/equatable.dart';
import 'package:untitled10/features/risk/domain/entity/risk_entity.dart';

abstract class RiskState extends Equatable {
  const RiskState();

  @override
  List<Object?> get props => [];
}

class RiskInitial extends RiskState {}

class RiskLoading extends RiskState {}

class RiskLoaded extends RiskState {
  final RiskEntity risk;

  const RiskLoaded(this.risk);

  @override
  List<Object?> get props => [risk];
}

class RiskCreated extends RiskState {
  final RiskEntity risk;

  const RiskCreated(this.risk);

  @override
  List<Object?> get props => [risk];
}

class RiskUpdated extends RiskState {
  final RiskEntity risk;

  const RiskUpdated(this.risk);

  @override
  List<Object?> get props => [risk];
}

class RiskDeleted extends RiskState {}

class RiskFailure extends RiskState {
  final String message;

  const RiskFailure(this.message);

  @override
  List<Object?> get props => [message];
}
