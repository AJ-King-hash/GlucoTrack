import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repo/archive_repository.dart';
import 'archives_state.dart';

class ArchiveCubit extends Cubit<ArchiveState> {
 final ArchiveRepository repository;

 ArchiveCubit({required this.repository})
     : super(const ArchiveState());

 Future<void> fetchArchives(int userId) async {
  emit(state.copyWith(status: ArchiveStatus.loading));

  try {
   final archives = await repository.getUserArchives(userId);

   emit(
    state.copyWith(
     status: ArchiveStatus.success,
     archives: archives,
    ),
   );
  } catch (e) {
   emit(
    state.copyWith(
     status: ArchiveStatus.error,
     errorMessage: e.toString(),
    ),
   );
  }
 }

 Future<void> deleteArchive(int archiveId) async {
  try {
   await repository.deleteArchive(archiveId);

   final updatedList = state.archives
       .where((archive) => archive.id != archiveId)
       .toList();

   emit(
    state.copyWith(
     archives: updatedList,
    ),
   );
  } catch (e) {
   emit(
    state.copyWith(
     status: ArchiveStatus.error,
     errorMessage: e.toString(),
    ),
   );
  }
 }
}