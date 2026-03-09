import 'package:untitled10/core/utils/either.dart';
import 'package:untitled10/core/errors/failure.dart';
import '../data/model/archives_model.dart';

abstract class ArchiveRepository {
  Future<Either<Failure, List<ArchiveModel>>> getUserArchives();
  Future<Either<Failure, ArchiveModel>> createArchive(ArchiveModel archive);
  Future<Either<Failure, ArchiveModel>> updateArchive(
    int id,
    ArchiveModel archive,
  );
  Future<Either<Failure, void>> deleteArchive(int archiveId);
}
