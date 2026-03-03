import '../data/model/archives_model.dart';


abstract class ArchiveRepository {
  Future<List<ArchiveModel>> getUserArchives(int userId);
  Future<void> deleteArchive(int archiveId);
}