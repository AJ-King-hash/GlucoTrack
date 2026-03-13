import 'package:equatable/equatable.dart';

abstract class Either<L, R> extends Equatable {
  const Either();

  T fold<T>(T Function(L l) leftFn, T Function(R r) rightFn);

  bool get isLeft;
  bool get isRight;

  @override
  List<Object?> get props => [];
}

class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);

  @override
  T fold<T>(T Function(L l) leftFn, T Function(R r) rightFn) {
    return leftFn(value);
  }

  @override
  bool get isLeft => true;

  @override
  bool get isRight => false;

  @override
  List<Object?> get props => [value];
}

class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);

  @override
  T fold<T>(T Function(L l) leftFn, T Function(R r) rightFn) {
    return rightFn(value);
  }

  @override
  bool get isLeft => false;

  @override
  bool get isRight => true;

  @override
  List<Object?> get props => [value];
}