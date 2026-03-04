import 'package:untitled10/core/utils/either.dart';
import 'package:untitled10/core/errors/failure.dart';
import 'package:untitled10/core/api/api_service.dart';
import '../data/model/archives_model.dart';
import 'archive_repository.dart';

class ArchiveRepositoryImpl implements ArchiveRepository {
  final ApiService apiService;

  ArchiveRepositoryImpl({required this.apiService});

  @override
  Future<Either<Failure, List<ArchiveModel>>> getUserArchives() async {
    final result = await apiService.getAllAnalysis();

    return result.fold(
      (failure) => Left(failure),
      (data) => Right(
        (data as List).map((json) => ArchiveModel.fromJson(json)).toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, void>> deleteArchive(int archiveId) async {
    final result = await apiService.deleteAnalysis(archiveId);

    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }
}
