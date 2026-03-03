import '../errors/failure.dart';
import '../utils/either.dart';


abstract class BaseUseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}