import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/injection_container.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';
import 'package:untitled10/core/widgets/states/loading_state.dart';
import 'package:untitled10/core/widgets/states/error_state.dart';
import 'package:untitled10/core/widgets/states/empty_state.dart';

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
          final bool hasActiveFilter = state.riskFilter != null;

          return Scaffold(
            backgroundColor: const Color(
              0xFFF8FAFC,
            ), // Soft health-tech background
            appBar: AppBar(
              title: Text(
                locale.translate('archives_page_title'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              actions: [
                _buildFilterButton(
                  context,
                  state,
                  cubit,
                  locale,
                  hasActiveFilter,
                ),
              ],
            ),
            body: _buildBody(context, state, cubit, locale),
          );
        },
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    ArchiveState state,
    ArchiveCubit cubit,
    LocaleCubit locale,
    bool isActive,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            onPressed: () => _showFilterSheet(context, state, cubit, locale),
            icon: Icon(
              isActive ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: isActive ? Colors.blue : Colors.grey[700],
            ),
          ),
          if (isActive)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Refined Filter Sheet with better sectioning
  void _showFilterSheet(
    BuildContext context,
    ArchiveState state,
    ArchiveCubit cubit,
    LocaleCubit locale,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(locale.translate('filter_by_risk')),
              const SizedBox(height: 16),
              _buildRiskChips(state, cubit, locale, bottomSheetContext),
              const SizedBox(height: 32),
              _buildSectionTitle(locale.translate('sort_by')),
              const SizedBox(height: 16),
              _buildSortChips(state, cubit, locale, bottomSheetContext),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.grey[400],
        letterSpacing: 1.2,
      ),
    );
  }

  // Reusable chip builder for cleaner code
  Widget _buildRiskChips(
    ArchiveState state,
    ArchiveCubit cubit,
    LocaleCubit locale,
    BuildContext context,
  ) {
    return Wrap(
      spacing: 10,
      children: [
        _customChip(
          label: locale.translate('all'),
          isSelected: state.riskFilter == null,
          onTap: () => cubit.filterByRisk(null),
          context: context,
        ),
        _customChip(
          label: locale.translate('low_risk'),
          isSelected: state.riskFilter == _lowRisk,
          activeColor: Colors.green,
          onTap: () => cubit.filterByRisk(_lowRisk),
          context: context,
        ),
        _customChip(
          label: locale.translate('medium_risk'),
          isSelected: state.riskFilter == _mediumRisk,
          activeColor: Colors.orange,
          onTap: () => cubit.filterByRisk(_mediumRisk),
          context: context,
        ),
        _customChip(
          label: locale.translate('high_risk'),
          isSelected: state.riskFilter == _highRisk,
          activeColor: Colors.red,
          onTap: () => cubit.filterByRisk(_highRisk),
          context: context,
        ),
      ],
    );
  }

  Widget _buildSortChips(
    ArchiveState state,
    ArchiveCubit cubit,
    LocaleCubit locale,
    BuildContext context,
  ) {
    return Wrap(
      spacing: 10,
      children: [
        _customChip(
          label: locale.translate('date_newest'),
          isSelected:
              state.sortBy == _sortByDate && state.sortOrder == _sortOrderDesc,
          onTap:
              () => cubit.sortArchives(
                sortBy: _sortByDate,
                sortOrder: _sortOrderDesc,
              ),
          context: context,
        ),
        _customChip(
          label: locale.translate('date_oldest'),
          isSelected:
              state.sortBy == _sortByDate && state.sortOrder == _sortOrderAsc,
          onTap:
              () => cubit.sortArchives(
                sortBy: _sortByDate,
                sortOrder: _sortOrderAsc,
              ),
          context: context,
        ),
        _customChip(
          label: locale.translate('gluco_high'),
          isSelected:
              state.sortBy == _sortByGluco && state.sortOrder == _sortOrderDesc,
          onTap:
              () => cubit.sortArchives(
                sortBy: _sortByGluco,
                sortOrder: _sortOrderDesc,
              ),
          context: context,
        ),
        _customChip(
          label: locale.translate('gluco_low'),
          isSelected:
              state.sortBy == _sortByGluco && state.sortOrder == _sortOrderAsc,
          onTap:
              () => cubit.sortArchives(
                sortBy: _sortByGluco,
                sortOrder: _sortOrderAsc,
              ),
          context: context,
        ),
      ],
    );
  }

  Widget _customChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required BuildContext context,
    Color activeColor = Colors.blue,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        onTap();
        Navigator.pop(context);
      },
      selectedColor: activeColor.withValues(alpha: 0.2),
      checkmarkColor: activeColor,
      labelStyle: TextStyle(
        color: isSelected ? activeColor : Colors.black54,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: isSelected ? activeColor : Colors.transparent),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ArchiveState state,
    ArchiveCubit cubit,
    LocaleCubit locale,
  ) {
    if (state.status == ArchiveStatus.loading) {
      return const LoadingState(message: 'Loading archives...');
    }

    if (state.status == ArchiveStatus.error) {
      return ErrorState(
        message: state.errorMessage,
        onActionPressed: () => cubit.refreshArchives(),
      );
    }

    if (state.archives.isEmpty) {
      return const EmptyState(lottieAsset: 'assets/lottie/empty ghost.json');
    }

    return RefreshIndicator(
      onRefresh: () => cubit.refreshArchives(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: state.archives.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final archive = state.archives[index];
          return ArchiveCard(
            archive: archive,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArchiveDetailsPage(archive: archive),
                  ),
                ),
          );
        },
      ),
    );
  }
}
