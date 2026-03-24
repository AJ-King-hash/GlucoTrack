import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:glucotrack/core/utils/global_refresher.dart';
import 'package:glucotrack/core/utils/toast_utility.dart';
import '../../repo/archive_repository.dart';
import '../../data/model/archives_model.dart';
import 'archives_state.dart';

class ArchiveCubit extends Cubit<ArchiveState> {
  final ArchiveRepository repository;

  ArchiveCubit({required this.repository}) : super(const ArchiveState());

  /// Fetch archives with optional pagination, search, and filtering
  Future<void> fetchArchives({
    int? page,
    String? search,
    String? sortBy,
    String? sortOrder,
    String? riskFilter,
    bool refresh = false,
  }) async {
    // If not refreshing and already loading, don't fetch again
    if (!refresh && state.status == ArchiveStatus.loading) return;

    final currentPage = page ?? 1;

    emit(
      state.copyWith(
        status: ArchiveStatus.loading,
        currentPage: currentPage,
        searchQuery: search ?? state.searchQuery,
        sortBy: sortBy ?? state.sortBy,
        sortOrder: sortOrder ?? state.sortOrder,
        riskFilter: riskFilter ?? state.riskFilter,
      ),
    );

    final result = await repository.getUserArchives(
      page: currentPage,
      limit: state.limit,
      search: search ?? state.searchQuery,
      sortBy: sortBy ?? state.sortBy,
      sortOrder: sortOrder ?? state.sortOrder,
      riskFilter: riskFilter ?? state.riskFilter,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ArchiveStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (archives) => emit(
        state.copyWith(
          status: ArchiveStatus.success,
          archives: archives,
          totalCount:
              archives.length, // Estimate: backend doesn't provide count
          hasMore: archives.length >= state.limit,
        ),
      ),
    );
  }

  /// Load more archives (pagination)
  Future<void> loadMore() async {
    if (!state.hasMore || state.status == ArchiveStatus.loading) return;

    final nextPage = state.currentPage + 1;
    emit(state.copyWith(status: ArchiveStatus.loading));

    final result = await repository.getUserArchives(
      page: nextPage,
      limit: state.limit,
      search: state.searchQuery,
      sortBy: state.sortBy,
      sortOrder: state.sortOrder,
      riskFilter: state.riskFilter,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ArchiveStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (newArchives) {
        final allArchives = [...state.archives, ...newArchives];
        emit(
          state.copyWith(
            status: ArchiveStatus.success,
            archives: allArchives,
            currentPage: nextPage,
            hasMore: newArchives.length >= state.limit,
          ),
        );
      },
    );
  }

  /// Search archives
  Future<void> searchArchives(String query) async {
    await fetchArchives(search: query.isEmpty ? null : query, refresh: true);
  }

  /// Filter archives by risk level
  Future<void> filterByRisk(String? riskFilter) async {
    await fetchArchives(riskFilter: riskFilter, refresh: true);
  }

  /// Sort archives
  Future<void> sortArchives({String? sortBy, String? sortOrder}) async {
    await fetchArchives(sortBy: sortBy, sortOrder: sortOrder, refresh: true);
  }

  /// Refresh archives
  Future<void> refreshArchives() async {
    await fetchArchives(refresh: true);
  }

  Future<void> createArchive(ArchiveModel archive) async {
    emit(state.copyWith(status: ArchiveStatus.loading));

    final result = await repository.createArchive(archive);

    result.fold(
      (failure) {
        ToastUtility.showError(failure.message);
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        emit(
          state.copyWith(
            status: ArchiveStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (newArchive) {
        ToastUtility.showSuccess("Archive created successfully");
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        final updatedList = [...state.archives, newArchive];
        emit(
          state.copyWith(
            status: ArchiveStatus.success,
            archives: updatedList,
            totalCount: state.totalCount + 1,
          ),
        );
      },
    );
  }

  Future<void> updateArchive(int id, ArchiveModel archive) async {
    emit(state.copyWith(status: ArchiveStatus.loading));

    final result = await repository.updateArchive(id, archive);

    result.fold(
      (failure) {
        ToastUtility.showError(failure.message);
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        emit(
          state.copyWith(
            status: ArchiveStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (updatedArchive) {
        ToastUtility.showSuccess("Archive updated successfully");
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        final updatedList =
            state.archives.map((a) => a.id == id ? updatedArchive : a).toList();
        emit(
          state.copyWith(status: ArchiveStatus.success, archives: updatedList),
        );
      },
    );
  }

  Future<void> deleteArchive(int archiveId) async {
    emit(state.copyWith(status: ArchiveStatus.loading));

    final result = await repository.deleteArchive(archiveId);

    result.fold(
      (failure) {
        ToastUtility.showError(failure.message);
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        emit(
          state.copyWith(
            status: ArchiveStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        ToastUtility.showSuccess("Archive deleted successfully");
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        final updatedList =
            state.archives.where((archive) => archive.id != archiveId).toList();

        emit(
          state.copyWith(
            status: ArchiveStatus.success,
            archives: updatedList,
            totalCount: state.totalCount - 1,
          ),
        );
      },
    );
  }
}
