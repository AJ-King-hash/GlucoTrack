import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repo/archive_repository.dart';
import '../../data/model/archives_model.dart';
import 'archives_state.dart';

class ArchiveCubit extends Cubit<ArchiveState> {
  final ArchiveRepository repository;

  ArchiveCubit({required this.repository}) : super(const ArchiveState());

  Future<void> fetchArchives() async {
    emit(state.copyWith(status: ArchiveStatus.loading));

    final result = await repository.getUserArchives();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ArchiveStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (archives) => emit(
        state.copyWith(status: ArchiveStatus.success, archives: archives),
      ),
    );
  }

  Future<void> createArchive(ArchiveModel archive) async {
    emit(state.copyWith(status: ArchiveStatus.loading));

    final result = await repository.createArchive(archive);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ArchiveStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (newArchive) {
        final updatedList = [...state.archives, newArchive];
        emit(
          state.copyWith(status: ArchiveStatus.success, archives: updatedList),
        );
      },
    );
  }

  Future<void> updateArchive(int id, ArchiveModel archive) async {
    emit(state.copyWith(status: ArchiveStatus.loading));

    final result = await repository.updateArchive(id, archive);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ArchiveStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (updatedArchive) {
        final updatedList =
            state.archives.map((a) => a.id == id ? updatedArchive : a).toList();
        emit(
          state.copyWith(status: ArchiveStatus.success, archives: updatedList),
        );
      },
    );
  }

  Future<void> deleteArchive(int archiveId) async {
    final result = await repository.deleteArchive(archiveId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ArchiveStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        final updatedList =
            state.archives.where((archive) => archive.id != archiveId).toList();

        emit(state.copyWith(archives: updatedList));
      },
    );
  }
}
