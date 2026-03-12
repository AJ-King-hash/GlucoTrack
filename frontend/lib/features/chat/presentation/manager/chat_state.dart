import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';

abstract class BotState extends Equatable {
  const BotState();

  @override
  List<Object?> get props => [];
}

class BotInitial extends BotState {
  const BotInitial();
}

class BotLoading extends BotState {
  const BotLoading();
}

class BotSuccess<T> extends BotState {
  final T data;

  const BotSuccess(this.data);

  BotSuccess<T> copyWith({T? data}) {
    return BotSuccess<T>(data ?? this.data);
  }

  @override
  List<Object?> get props => [data];
}

class BotListSuccess<T> extends BotState {
  final List<T> data;

  const BotListSuccess(this.data);

  BotListSuccess<T> copyWith({List<T>? data}) {
    return BotListSuccess<T>(data ?? this.data);
  }

  @override
  List<Object?> get props => [data];
}

class BotError extends BotState {
  final Failure failure;

  const BotError(this.failure);

  BotError copyWith({Failure? failure}) {
    return BotError(failure ?? this.failure);
  }

  @override
  List<Object?> get props => [failure];
}
