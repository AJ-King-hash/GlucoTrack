import 'package:glucotrack/core/utils/either.dart';
import 'package:glucotrack/core/errors/failure.dart';
import '../data/model/archives_model.dart';

abstract class ArchiveRepository {
  /// Get all archives with pagination, search, and filtering
  Future<Either<Failure, List<ArchiveModel>>> getUserArchives({
    int page = 1,
    int limit = 10,
    String? search,
    String? sortBy,
    String sortOrder = 'desc',
    String? riskFilter,
  });

  Future<Either<Failure, ArchiveModel>> createArchive(ArchiveModel archive);
  Future<Either<Failure, ArchiveModel>> updateArchive(
    int id,
    ArchiveModel archive,
  );
  Future<Either<Failure, void>> deleteArchive(int archiveId);
}
