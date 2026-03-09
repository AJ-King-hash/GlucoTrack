import 'package:untitled10/core/utils/either.dart';
import 'package:untitled10/core/errors/failure.dart';
import 'package:untitled10/core/api/api_service.dart';
import '../data/model/archives_model.dart';
import 'archive_repository.dart';

class ArchiveRepositoryImpl implements ArchiveRepository {
  final ApiService apiService;

  ArchiveRepositoryImpl({required this.apiService});

  @override
  Future<Either<Failure, List<ArchiveModel>>> getUserArchives({
    int page = 1,
    int limit = 10,
    String? search,
    String? sortBy,
    String sortOrder = 'desc',
    String? riskFilter,
  }) async {
    final result = await apiService.getAllAnalysis(
      page: page,
      limit: limit,
      search: search,
      sortBy: sortBy,
      sortOrder: sortOrder,
      riskFilter: riskFilter,
    );

    return result.fold(
      (failure) => Left(failure),
      (data) => Right(
        (data as List).map((json) => ArchiveModel.fromJson(json)).toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, int>> getArchiveCount() async {
    final result = await apiService.getAnalysisCount();

    return result.fold((failure) => Left(failure), (data) {
      if (data is Map && data['total'] != null) {
        return Right(data['total'] as int);
      }
      return const Right(0);
    });
  }

  @override
  Future<Either<Failure, ArchiveModel>> createArchive(
    ArchiveModel archive,
  ) async {
    final result = await apiService.createMeal(archive.meal.toJson());

    return result.fold((failure) => Left(failure), (data) {
      // Check if archive data exists in response
      final archiveData = data['archive'];
      if (archiveData == null) {
        return Left(
          UnknownFailure(message: 'Invalid response: archive data not found'),
        );
      }
      return Right(ArchiveModel.fromJson(archiveData));
    });
  }

  @override
  Future<Either<Failure, ArchiveModel>> updateArchive(
    int id,
    ArchiveModel archive,
  ) async {
    final result = await apiService.updateMeal(id, archive.meal.toJson());

    return result.fold((failure) => Left(failure), (data) {
      // Check if data is valid
      if (data == null) {
        return Left(
          UnknownFailure(message: 'Invalid response: no data returned'),
        );
      }
      return Right(ArchiveModel.fromJson(data));
    });
  }

  @override
  Future<Either<Failure, void>> deleteArchive(int archiveId) async {
    final result = await apiService.deleteAnalysis(archiveId);

    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }
}
