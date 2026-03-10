import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/injection_container.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';

import '../manager/archives_cubit.dart';
import '../manager/archives_state.dart';
import '../widgets/archive_card.dart';
import '../widgets/empty_state.dart';
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
              title: Text(locale.translate('archives_page_title')),
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed:
                      () => _showFilterSheet(context, state, cubit, locale),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locale.translate('filter_by_risk'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: Text(locale.translate('all')),
                    selected: state.riskFilter == null,
                    onSelected: (selected) {
                      cubit.filterByRisk(null);
                      Navigator.pop(bottomSheetContext);
                    },
                  ),
                  FilterChip(
                    label: Text(locale.translate('low_risk')),
                    selected: state.riskFilter == _lowRisk,
                    onSelected: (selected) {
                      cubit.filterByRisk('Low');
                      Navigator.pop(bottomSheetContext);
                    },
                  ),
                  FilterChip(
                    label: Text(locale.translate('medium_risk')),
                    selected: state.riskFilter == _mediumRisk,
                    onSelected: (selected) {
                      cubit.filterByRisk('Medium');
                      Navigator.pop(bottomSheetContext);
                    },
                  ),
                  FilterChip(
                    label: Text(locale.translate('high_risk')),
                    selected: state.riskFilter == _highRisk,
                    onSelected: (selected) {
                      cubit.filterByRisk('High');
                      Navigator.pop(bottomSheetContext);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                locale.translate('sort_by'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
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
        return const Center(child: CircularProgressIndicator());
      case ArchiveStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.errorMessage ??
                    locale.translate('archives_error_message'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => cubit.refreshArchives(),
                child: Text(locale.translate('refresh')),
              ),
            ],
          ),
        );
      case ArchiveStatus.success:
        if (state.archives.isEmpty) {
          return const EmptyState();
        }
        return RefreshIndicator(
          onRefresh: () => cubit.refreshArchives(),
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
        return const Center(child: CircularProgressIndicator());
    }
  }
}
