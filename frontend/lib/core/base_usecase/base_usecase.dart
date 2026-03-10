import '../errors/failure.dart';
import '../utils/either.dart';

// ignore: avoid_types_as_parameter_names
abstract class BaseUseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
