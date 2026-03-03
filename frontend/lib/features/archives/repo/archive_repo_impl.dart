import 'package:dio/dio.dart';
import '../data/model/archives_model.dart';

import 'archive_repository.dart';

class ArchiveRepositoryImpl implements ArchiveRepository {
  final Dio dio;

  ArchiveRepositoryImpl({required this.dio});

  @override
  Future<List<ArchiveModel>> getUserArchives(int userId) async {
    final response = await dio.get('/analyse/all/$userId');

    final List data = response.data;

    return data
        .map((json) => ArchiveModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> deleteArchive(int archiveId) async {
    await dio.delete('/analyse/$archiveId');
  }
}