import 'package:glucotrack/core/utils/either.dart';
import 'package:glucotrack/core/errors/failure.dart';
import 'package:glucotrack/core/api/api_service.dart';
import 'package:glucotrack/features/archives/data/model/meal_model.dart';

abstract class MealRepository {
  Future<Either<Failure, MealModel?>> getLastMeal();
}

class MealRepositoryImpl implements MealRepository {
  final ApiService apiService;

  MealRepositoryImpl(this.apiService);

  @override
  Future<Either<Failure, MealModel?>> getLastMeal() async {
    final result = await apiService.getLastMeal();

    return result.fold((failure) => Left(failure), (data) {
      if (data == null) return const Right(null);
      return Right(MealModel.fromJson(data as Map<String, dynamic>));
    });
  }
}
