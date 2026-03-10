import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/injection_container.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';

import '../manager/archives_cubit.dart';
import '../manager/archives_state.dart';
import '../widgets/archive_card.dart';
import 'archive_details_page.dart';

class ArchivesPage extends StatelessWidget {
  const ArchivesPage({super.key});
  // Risk filter constants
  static const String _lowRisk = 'Low';
  static const String _mediumRisk = 'Medium';
  static const String _highRisk = 'High';

  // Sort constants
  static const String _sortByDate = 'analysed_at';
  static const String _sortByGluco = 'gluco_percent';
  static const String _sortOrderDesc = 'desc';
  static const String _sortOrderAsc = 'asc';

  @override
  Widget build(BuildContext context) {
    final locale = context.read<LocaleCubit>();

    return BlocProvider(
      create: (context) => sl<ArchiveCubit>()..fetchArchives(),
      child: BlocBuilder<ArchiveCubit, ArchiveState>(
        builder: (context, state) {
          final cubit = context.read<ArchiveCubit>();
          return Scaffold(
            appBar: AppBar(
              title: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  locale.translate('archives_page_title'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ElevatedButton.icon(
                    onPressed:
                        () => _showFilterSheet(context, state, cubit, locale),
                    icon: const Icon(Icons.filter_list, size: 18),
                    label: Text(
                      locale.translate('filter'),
                      style: const TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                      foregroundColor: Colors.blue,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: _buildBody(context, state, cubit, locale),
          );
        },
      ),
    );
  }

  void _showFilterSheet(
    BuildContext context,
    ArchiveState state,
    ArchiveCubit cubit,
    LocaleCubit locale,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter by Risk
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  locale.translate('filter_by_risk'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilterChip(
                    label: Text(locale.translate('all')),
                    selected: state.riskFilter == null,
                    onSelected: (selected) {
                      cubit.filterByRisk(null);
                      Navigator.pop(bottomSheetContext);
                    },
                    selectedColor: Colors.blue,
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color:
                            state.riskFilter == null
                                ? Colors.blue
                                : Colors.grey.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color:
                          state.riskFilter == null
                              ? Colors.white
                              : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  FilterChip(
                    label: Text(locale.translate('low_risk')),
                    selected: state.riskFilter == _lowRisk,
                    onSelected: (selected) {
                      cubit.filterByRisk('Low');
                      Navigator.pop(bottomSheetContext);
                    },
                    selectedColor: Colors.green,
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color:
                            state.riskFilter == _lowRisk
                                ? Colors.green
                                : Colors.grey.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color:
                          state.riskFilter == _lowRisk
                              ? Colors.white
                              : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  FilterChip(
                    label: Text(locale.translate('medium_risk')),
                    selected: state.riskFilter == _mediumRisk,
                    onSelected: (selected) {
                      cubit.filterByRisk('Medium');
                      Navigator.pop(bottomSheetContext);
                    },
                    selectedColor: Colors.orange,
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color:
                            state.riskFilter == _mediumRisk
                                ? Colors.orange
                                : Colors.grey.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color:
                          state.riskFilter == _mediumRisk
                              ? Colors.white
                              : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  FilterChip(
                    label: Text(locale.translate('high_risk')),
                    selected: state.riskFilter == _highRisk,
                    onSelected: (selected) {
                      cubit.filterByRisk('High');
                      Navigator.pop(bottomSheetContext);
                    },
                    selectedColor: Colors.red,
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color:
                            state.riskFilter == _highRisk
                                ? Colors.red
                                : Colors.grey.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color:
                          state.riskFilter == _highRisk
                              ? Colors.white
                              : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Sort by
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  locale.translate('sort_by'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilterChip(
                    label: Text(locale.translate('date_newest')),
                    selected:
                        state.sortBy == _sortByDate &&
                        state.sortOrder == _sortOrderDesc,
                    onSelected: (selected) {
                      cubit.sortArchives(
                        sortBy: _sortByDate,
                        sortOrder: _sortOrderDesc,
                      );
                      Navigator.pop(bottomSheetContext);
                    },
                    selectedColor: Colors.blue,
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color:
                            (state.sortBy == _sortByDate &&
                                    state.sortOrder == _sortOrderDesc)
                                ? Colors.blue
                                : Colors.grey.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color:
                          (state.sortBy == _sortByDate &&
                                  state.sortOrder == _sortOrderDesc)
                              ? Colors.white
                              : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  FilterChip(
                    label: Text(locale.translate('date_oldest')),
                    selected:
                        state.sortBy == 'analysed_at' &&
                        state.sortOrder == _sortOrderAsc,
                    onSelected: (selected) {
                      cubit.sortArchives(
                        sortBy: 'analysed_at',
                        sortOrder: _sortOrderAsc,
                      );
                      Navigator.pop(bottomSheetContext);
                    },
                    selectedColor: Colors.blue,
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color:
                            (state.sortBy == 'analysed_at' &&
                                    state.sortOrder == _sortOrderAsc)
                                ? Colors.blue
                                : Colors.grey.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color:
                          (state.sortBy == 'analysed_at' &&
                                  state.sortOrder == _sortOrderAsc)
                              ? Colors.white
                              : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  FilterChip(
                    label: Text(locale.translate('gluco_high')),
                    selected:
                        state.sortBy == _sortByGluco &&
                        state.sortOrder == 'desc',
                    onSelected: (selected) {
                      cubit.sortArchives(
                        sortBy: _sortByGluco,
                        sortOrder: 'desc',
                      );
                      Navigator.pop(bottomSheetContext);
                    },
                    selectedColor: Colors.blue,
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color:
                            (state.sortBy == _sortByGluco &&
                                    state.sortOrder == 'desc')
                                ? Colors.blue
                                : Colors.grey.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color:
                          (state.sortBy == _sortByGluco &&
                                  state.sortOrder == 'desc')
                              ? Colors.white
                              : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  FilterChip(
                    label: Text(locale.translate('gluco_low')),
                    selected:
                        state.sortBy == 'gluco_percent' &&
                        state.sortOrder == 'asc',
                    onSelected: (selected) {
                      cubit.sortArchives(
                        sortBy: 'gluco_percent',
                        sortOrder: 'asc',
                      );
                      Navigator.pop(bottomSheetContext);
                    },
                    selectedColor: Colors.blue,
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color:
                            (state.sortBy == 'gluco_percent' &&
                                    state.sortOrder == 'asc')
                                ? Colors.blue
                                : Colors.grey.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color:
                          (state.sortBy == 'gluco_percent' &&
                                  state.sortOrder == 'asc')
                              ? Colors.white
                              : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ArchiveState state,
    ArchiveCubit cubit,
    LocaleCubit locale,
  ) {
    switch (state.status) {
      case ArchiveStatus.loading:
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        );
      case ArchiveStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 250,
                child: Text(
                  state.errorMessage ??
                      locale.translate('archives_error_message'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => cubit.refreshArchives(),
                icon: const Icon(Icons.refresh),
                label: Text(locale.translate('refresh')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
        );
      case ArchiveStatus.success:
        if (state.archives.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.archive,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  locale.translate('archives_empty_message'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => cubit.refreshArchives(),
          color: Colors.blue,
          backgroundColor: Colors.white,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.archives.length,
            itemBuilder: (context, index) {
              final archive = state.archives[index];
              return ArchiveCard(
                archive: archive,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArchiveDetailsPage(archive: archive),
                    ),
                  );
                },
              );
            },
          ),
        );
      default:
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        );
    }
  }
}
