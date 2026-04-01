import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glucotrack/core/injection_container.dart';
import 'package:glucotrack/core/localization/locale_cubit.dart';
import 'package:glucotrack/core/widgets/states/loading_state.dart';
import 'package:glucotrack/core/widgets/states/error_state.dart';
import 'package:glucotrack/core/widgets/states/empty_state.dart';

import '../manager/archives_cubit.dart';
import '../manager/archives_state.dart';
import '../widgets/archive_card.dart';
import 'archive_details_page.dart';

class ArchivesPage extends StatelessWidget {
  const ArchivesPage({super.key});

  Widget build(BuildContext context) {
    final locale = context.read<LocaleCubit>();

    return BlocProvider(
      create: (context) => sl<ArchiveCubit>()..fetchArchives(),
      child: BlocBuilder<ArchiveCubit, ArchiveState>(
        builder: (context, state) {
          final cubit = context.read<ArchiveCubit>();

          return Scaffold(
            backgroundColor: const Color(
              0xFFF8FAFC,
            ), // Soft health-tech background
            appBar: AppBar(
              automaticallyImplyLeading: false,
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
              actions: [],
            ),
            body: _buildBody(context, state, cubit, locale),
          );
        },
      ),
    );
  }

  // Refined Filter Sheet with better sectioning

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
